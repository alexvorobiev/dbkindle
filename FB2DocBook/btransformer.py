#!/usr/bin/env python

import sys, os, shutil, tempfile
import re
import random
import logging
import subprocess
from io import StringIO, BytesIO
import binascii
from PIL import Image
from PIL import ImageDraw
from PIL import ImageFont
import xml.dom.minidom
import urllib.request, urllib.parse, urllib.error
import zipfile, gzip, bz2
import optparse
from lxml import etree
#import cssutils

VERSION = '0.1.bzr348'
VERSION_XSLT = '0.1.bzr349'

# UserPalette for non-JPEG images can have up to 256 colors in ascending order.
# First entry must be equal to 0, last entry must be equal to 255.
UserPalette = [0, 37, 73, 110, 146, 183, 219, 255] # pure colors for PRS-505

has_translify = False
try:
    import pytils
    from BeautifulSoup import BeautifulStoneSoup
    def translify(s):
        try:
            d = str(BeautifulStoneSoup(s, convertEntities = BeautifulStoneSoup.XML_ENTITIES))
            d = pytils.translit.translify(d)
        except:
            d = s
        return d
    has_translify = True
except ImportError as err: pass


registred_processors = {}

to_xml_uri = lambda x: x

def unix_to_xml_uri(x):
    x = urllib.request.pathname2url(x)
    return 'file://' + x

def win32_to_xml_uri(x):
    if len(x) > 2 and x[1] == ':':
        return 'file:///' + x[:2] + urllib.request.pathname2url(x[2:])
    else:
        return 'file://' + urllib.request.pathname2url(x)

if sys.platform == 'win32':
    to_xml_uri = win32_to_xml_uri
else:
    to_xml_uri = unix_to_xml_uri

class XSLTransformerException(Exception): pass
class XSLTLibxsltCommandException(XSLTransformerException): pass
class XSLTXalanCommandException(XSLTransformerException): pass
class XSLTSaxon6CommandException(XSLTransformerException): pass
class FOTransformerException(Exception): pass
class FOPCommandException(FOTransformerException): pass
class DBLATEXCommandException(FOTransformerException): pass
class XEPCommandException(FOTransformerException): pass
class PdfToolException(Exception): pass
class PdftkCommandException(PdfToolException): pass
class PdftkCommandDumpDataException(PdftkCommandException): pass
class PdftkCommandUpdateInfoException(PdftkCommandException): pass
class PdfOptimizerException(Exception): pass
class GSCommandException(PdfOptimizerException): pass

def gen_tmp_name(prefix = '.fb2d'):
    return '%s%012X' % (prefix, random.randint(0, 0xFFFFFFFFFFFF))

def import_module(mod_name, to_reload = False):
    ##todo: import module like mod.submod1.submod2.x.x
    module = None
    if mod_name in sys.modules:
        if to_reload:
            module = reload(sys.modules[mod_name])
            globals()[mod_name] = module
    else:
        module = __import__(mod_name, globals(), locals(), [])
        globals()[mod_name] = module
    return module

def findAll(elem, tagname):
    for node in elem.childNodes:
        if node.nodeType == node.ELEMENT_NODE and node.tagName == tagname:
            yield node

def getText(nodelist):
    rc = ""
    for node in nodelist:
        if node.nodeType == node.TEXT_NODE:
            rc = rc + node.data
    return rc

def setText(text, nodelist):
#set text to first text node in list!!!
    for node in nodelist:
        if node.nodeType == node.TEXT_NODE:
            node.data = text

def get_param(root_node, *node_names):
    if len(node_names) == 0:
        return getText(root_node.childNodes)
    name = node_names[0]
    for node in root_node.childNodes:
        if node.nodeType == node.ELEMENT_NODE and node.tagName == name:
            return get_param(node, *node_names[1:])

def set_param(root_node, text, *node_names):
    print(root_node)
    if len(node_names) == 0:
        if len(root_node.childNodes) == 0: root_node.appendChild(xml.dom.minidom.Text())
        return setText(text, root_node.childNodes)
    name = node_names[0]
    for node in root_node.childNodes:
        if node.nodeType == node.ELEMENT_NODE and node.tagName == name:
            return set_param(node, text, *node_names[1:])
    node = root_node.appendChild(xml.dom.minidom.Element(name))
    return set_param(node, text, *node_names[1:])

def replace_broken_img(self, bg = "#ffffff", x0 = 0, x1 = 30, y0 = 0, y1 = 30):
    img = Image.new('RGB', (x1, y1), bg)
    draw = ImageDraw.Draw(img)
    draw.line((x0+7, y0+7, x1-8, y1-7), 'red', 3)
    draw.line((x0+7, y1-7, x1-8, y0+7), 'red', 3)
    draw.line((x0, y0, x1, y0), 'red', 3)
    draw.line((x1, y0, x1, y1), 'red', 3)
    draw.line((x1, y1, x0, y1), 'red', 5)
    draw.line((x0, y1, x0, y0), 'red', 3)
    del draw
    return img

# Replace with text on a image
#def replace_broken_img(img_name, fg = "#000000", bg = "#ffffff", font = "Verdana.ttf", font_size = 16, font_dir = ""):
#    fnt = ImageFont.truetype(font_dir + font, font_size)
#    img = Image.new('L',(167 * 3, 100), bg)
#    draw = ImageDraw.Draw(img)                              # setup to draw on the main image
#    draw.text((10, 0), img_name, font = fnt, fill = fg)     # add some text to the main
#    draw.rectangle([(0, 0), (img.size[0] - 1, img.size[1] - 1)])
#    del draw
#    return img

class MZipFile(zipfile.ZipFile):
    def rec_add_dir(self, fdir, adir, compress_type = None):
        if compress_type == None: compress_type = zipfile.ZIP_DEFLATED
        for dirpath, dirnames, filenames in os.walk(fdir):
            arc_dir = dirpath[len(fdir):]
            for filename in filenames:
                self.write(os.path.join(dirpath, filename), '/'.join((adir, arc_dir, filename)), compress_type)

class Options(object):
    def __init__(self, opts_fname):
        self._soup = None
        self.load(opts_fname)

        self.image_transfrom = False
        self.thumb_type = Image.ANTIALIAS
        self.cnv_tmp_dir = tempfile.gettempdir()

    def load(self, opts_fname):
        finp = None
        try:
            finp = open(opts_fname)
            self._soup = xml.dom.minidom.parse(finp)
        finally:
            if finp != None: finp.close()

    def save(self, opts_fname):
        ###add my exception, if _soup is None
        fout = None
        try:
            fout = open(opts_fname, 'wb')
            self._soup.writexml(fout)
        finally:
            if fout != None: fout.close()

    def option(self, *params):
        return get_param(self._soup.documentElement, *params).encode()
    def set_option(self, text, *params):
        return set_param(self._soup.documentElement, text, *params)

class ProcessorMeta(type):
    def __init__(cls, name, bases, ns):
        registred_processors[cls.get_reg_name()] = cls

class XSLT_libxslt_exec(object, metaclass=ProcessorMeta):
    retcodes = {1: 'No argument',
                2: 'Too many parameters',
                3: 'Unknown option',
                4: 'Failed to parse the stylesheet',
                5: 'Error in the stylesheet',
                6: 'Error in one of the documents',
                7: 'Unsupported xsl:output method',
                8: 'String parameter contains both quote and double-quotes',
                9: 'Internal processing error',
                10: 'Processing was stopped by a terminating message', }
    @staticmethod
    def get_reg_name(): return 'libxslt_bin'
    @staticmethod
    def use_type(): return 'exec'
    @staticmethod
    def get_document_element_type(): return 'exsl:document'
    def __init__(self, options):
        self._command = options.option('xslt_proc', 'libxslt_bin', 'bin')

    def transform(self, xslt_fname, fname_in, fname_out, params = tuple()):
        def yld_pars(command_name, pars, *other):
            yield command_name
            for p in pars:
                yield '--stringparam'
                yield p[0]
                yield p[1]
            for p in other: yield p
        args = list(yld_pars(self._command, params, '-output', fname_out, xslt_fname, fname_in))
        p = subprocess.Popen(args = args)
        retcode = p.wait()
        if retcode != 0:
            raise XSLTLibxsltCommandException('%s: %s' % (retcode, XSLT_libxslt_exec.retcodes.get(retcode, '')))

class XSLT_libxslt_lib(object, metaclass=ProcessorMeta):
    @staticmethod
    def get_reg_name(): return 'libxslt_lib'
    @staticmethod
    def use_type(): return 'lib'
    @staticmethod
    def get_document_element_type(): return 'exsl:document'
    # def __init__(self, options):
        # import_module('lxml')
    def transform(xslt_fname, fname_in, fname_out, params = tuple()):
        def mk_params_dict(params):
            res = {}
            for par in params: res[par[0]] = "'%s'" % (par[1], )
            if len(res) == 0: res = None
            return res
        print(xslt_fname)
        styledoc = etree.parse(xslt_fname)


        style = doc = result = None
        try:
            transform = etree.XSLT(styledoc)
            doc = etree.parse(fname_in)
            params_dict = mk_params_dict(params)
            print(params_dict)
            if params_dict != None:
                result = transform(doc, **params_dict)
                result.write_output(fname_out)
            else:
                result = transform(doc)
                print(fname_out)
                result.write(fname_out)

            # style.saveResultToFilename(fname_out, result, 0)
        finally:
            if style != None: style.freeStylesheet()
            # if doc != None: doc.xmlFreeDoc()
            # if result != None: result.xmlFreeDoc()

class XSLT_4xslt_lib(object, metaclass=ProcessorMeta):
    @staticmethod
    def get_reg_name(): return '4xslt_lib'
    @staticmethod
    def use_type(): return 'lib'
    @staticmethod
    def get_document_element_type(): return 'exsl:document'
    def __init__(self, options):
        import_module('Ft.Xml.XPath')
        import_module('Ft.Xml.Xslt')
    def transform(self, xslt_fname, fname_in, fname_out, params = tuple()):
        def mk_params_dict(params):
            res = {}
            for par in params: res[par[0]] = par[1]
            if len(res) == 0: res = None
            return res
        params_dict = mk_params_dict(params)
        fout = open(fname_out, 'wb')
        try:
            Ft.Xml.Xslt.Transform(fname_in, xslt_fname, params_dict, output=fout)
        finally:
            fout.close()

class XSLT_xalan_exec(object, metaclass=ProcessorMeta):
    @staticmethod
    def get_reg_name(): return 'xalan_bin'
    @staticmethod
    def use_type(): return 'exec'
    @staticmethod
    def get_document_element_type(): return 'redirect:write'
    def __init__(self, options):
        self._command = options.option('xslt_proc', 'xalan_bin', 'bin')

    def transform(self, xslt_fname, fname_in, fname_out, params = tuple()):
        def yld_pars(command_name, pars, *other):
            yield command_name
            for p in pars:
                yield '-param'
                yield p[0]
                yield p[1]
            for p in other: yield p
        args = list(yld_pars(self._command, params, '-out', fname_out,
                             '-xsl', xslt_fname, '-in', fname_in))
        p = subprocess.Popen(args = args)
        retcode = p.wait()
        if retcode != 0:
            raise XSLTXalanCommandException(str(retcode))

class XSLT_saxon6_exec(object, metaclass=ProcessorMeta):
    @staticmethod
    def get_reg_name(): return 'saxon6_bin'
    @staticmethod
    def use_type(): return 'exec'
    @staticmethod
    def get_document_element_type(): return 'xsl:document'
    def __init__(self, options):
        self._command = options.option('xslt_proc', 'saxon6_bin', 'bin')

    def transform(self, xslt_fname, fname_in, fname_out, params = tuple()):
        def yld_pars(command_name, pars, *other):
            yield command_name
            for p in other: yield p
            for p in pars:
                yield '%s=%s' % p
        args = list(yld_pars(self._command, params, '-o', fname_out,
                             fname_in, xslt_fname, ))
        p = subprocess.Popen(args = args)
        retcode = p.wait()
        if retcode != 0:
            raise XSLTSaxon6CommandException(str(retcode))

class FO_fop_exec(object, metaclass=ProcessorMeta):
    @staticmethod
    def get_reg_name(): return 'fop_bin'
    @staticmethod
    def use_type(): return 'exec'
    def __init__(self, options, command = None):
        self._command = command
        if command == None:
            self._command = options.option('fo_proc', 'fop_bin', 'bin')
        self._fop_config = os.path.abspath(options.option('fo_proc', 'fop_bin', 'config'))
        #self._dpi = options.output_dpi[0]
        self._dpi = None
    @staticmethod
    def docbook_params(): return (('fop1.extensions', '1'), )
    def transform(self, fo_fname, pdf_fname):
        args = [self._command, ]
        if self._fop_config: args += ['-c', self._fop_config]
        if self._dpi: args += ['-dpi', str(self._dpi)]
        args += ['-fo', fo_fname, '-pdf', pdf_fname]
        p = subprocess.Popen(args = args)
        retcode = p.wait()
        if retcode != 0:
            raise FOPCommandException(str(retcode))

class LATEX_dblatex_exec(object, metaclass=ProcessorMeta):
    @staticmethod
    def get_reg_name(): return 'dblatex_bin'
    @staticmethod
    def use_type(): return 'exec'
    def __init__(self, options, command = None):
        self._command = command
        if command == None:
            self._command = options.option('latex_proc', 'dblatex_bin', 'bin')
        self._dblatex_config = options.option('latex_proc', 'dblatex_bin', 'config')
    @staticmethod
    def docbook_params(): return (('fop1.extensions', '1'), )
    def transform(self, docbook_fname, pdf_fname):
        args = [self._command, ]
        if self._dblatex_config: args += ['-T', self._dblatex_config]
        args += ['-o', pdf_fname, docbook_fname]
        logging.info(args)
        p = subprocess.Popen(args = args)
        retcode = p.wait()
        if retcode != 0:
            raise DBLATEXCommandException(str(retcode))

class FO_xep_exec(object, metaclass=ProcessorMeta):
    @staticmethod
    def get_reg_name(): return 'xep_bin'
    @staticmethod
    def use_type(): return 'exec'
    def __init__(self, options):
        self._command = options.option('fo_proc', 'xep_bin', 'bin')
    @staticmethod
    def docbook_params(): return (('xep.extensions', '1'), )
    def transform(self, fo_fname, pdf_fname):
        args = [self._command, ]
        args += ['-fo', fo_fname, '-pdf', pdf_fname]
        p = subprocess.Popen(args = args)
        retcode = p.wait()
        if retcode != 0:
            raise XEPCommandException(str(retcode))

class PdfTool_pdftk_exec(object, metaclass=ProcessorMeta):
    @staticmethod
    def get_reg_name(): return 'pdftk_bin'
    @staticmethod
    def use_type(): return 'exec'
    def __init__(self, options, command = None):
        self._command = command
        if command == None:
            self._command = options.option('pdf_proc', 'pdftk_bin', 'bin')
    def transform(self, soup_metadata, in_pdf_fname, out_pdf_fname,
                  in_dd_fname, out_dd_fname, translify_fun = lambda x: x):
        def dump_data(in_pdf_fname, in_dd_fname):
            args = [self._command, ]
            args += [in_pdf_fname, 'dump_data', 'output', in_dd_fname]
            p = subprocess.Popen(args = args)
            retcode = p.wait()
            if retcode != 0:
                raise PdftkCommandDumpDataException(str(retcode))
        def update_info(in_pdf_fname, out_pdf_fname, out_dd_fname):
            args = [self._command, ]
            args += [in_pdf_fname, 'update_info', out_dd_fname, 'output', out_pdf_fname]
            p = subprocess.Popen(args = args)
            retcode = p.wait()
            if retcode != 0:
                raise PdftkCommandUpdateInfoException(str(retcode))
        def write_new_metadata(soup_metadata, inp_dd_fname,
                               out_dd_fname, translify_fun):
            mts = []
            for node in soup_metadata.childNodes:
                if node.nodeType == node.ELEMENT_NODE:
                    mts.append((node.tagName, getText(node.childNodes)))
            finp = fout = None
            try:
                finp = open(in_dd_fname)
                fout = open(out_dd_fname, 'wb')
                for mt in mts:
                    s = 'InfoKey: %s\nInfoValue: %s\n' % tuple([x.encode('ascii', 'xmlcharrefreplace') for x in mt])
                    fout.write(translify_fun(s))
                for line in finp:
                    fout.write(translify_fun(line))
            finally:
                if finp != None: finp.close()
                if fout != None: fout.close()
        dump_data(in_pdf_fname, in_dd_fname)
        write_new_metadata(soup_metadata, in_dd_fname, out_dd_fname, translify_fun)
        update_info(in_pdf_fname, out_pdf_fname, out_dd_fname)

class PdfOptimizer_GS_exec(object, metaclass=ProcessorMeta):
    @staticmethod
    def get_reg_name(): return 'gspdfopt_bin'
    @staticmethod
    def use_type(): return 'exec'
    def __init__(self, options, command = None):
        self._command = command
        if command == None:
            self._command = options.option('pdf_optimizer', 'gspdfopt_bin', 'bin')
    def transform(self, inp_pdf_fname, out_pdf_fname):
        args = [self._command, inp_pdf_fname, out_pdf_fname]
        p = subprocess.Popen(args = args)
        retcode = p.wait()
        if retcode != 0:
            raise GSCommandException(str(retcode))

class Transformer(object):
    def __init__(self, options, xslt_transformer, fo_transformer, latex_transformer,
                 pdf_tool, pdf_optimizer,
                 xslt_params, xslt_titlepages,
                 update_metadata = False, linearize_pdf = False, to_translify = False):
        self.options = options
        self.xslt_transformer = xslt_transformer
        self.fo_transformer = fo_transformer
        self.latex_transformer = latex_transformer
        self.pdf_tool = pdf_tool
        self.pdf_optimizer = pdf_optimizer
        self.xslt_params = xslt_params
        self.xslt_titlepages = xslt_titlepages
        self.update_metadata = update_metadata
        self.linearize_pdf = linearize_pdf
        self.to_translify = to_translify
        self._tmp_fnames = set()
    def _add_tmp_fname(self, fname):
        self._tmp_fnames.add(os.path.abspath(fname))
    def _transform_image(self, ascii_finp, bin_fout, image_name):
        try:
            im = Image.open(BytesIO(binascii.a2b_base64(ascii_finp.read())))
            im_format = im.format
        except IOError as err:
            logging.error('%s [broken image]', err)
            im = replace_broken_img(image_name)
            im_format = os.path.splitext(image_name)[1][1:]
        max_size = self.options.max_image_size
        dpi = self.options.output_dpi
        itrans = self.options.image_transform
        if im_format.lower() == 'gif':
            im_format = 'png'
        if im_format.lower() != 'png':
            im_format = 'jpeg'
        if max_size[0] < im.size[0] or max_size[1] < im.size[1]:
            t_ratio = min(max_size[0]/float(im.size[0]), max_size[1]/float(im.size[1]))
            if itrans == 3:
                t_r = min(max_size[0]/float(im.size[1]), max_size[1]/float(im.size[0]))
                if t_r > t_ratio:
                    t_ratio = min(t_r,1.0)
                    im = im.transpose(Image.ROTATE_90)
            if itrans == 2 or itrans == 3:
                dpi = (dpi[0]/t_ratio, dpi[1]/t_ratio)
            else:
                im.thumbnail([int(x*t_ratio) for x in im.size], self.options.thumb_type)
        if im.mode in ('RGBA', 'LA', 'P') or 'transparency' in im.info:
            im = im.convert("RGBA")
            if self.options.image_mode.lower() == 'bw':
                im = im.convert("LA").convert("RGBA")
            if self.options.image_mode.lower() == 'plte':
                im = im.convert("L")
                if self.options.image_mode.lower() == 'plte' and im_format.lower() != 'jpeg':
                    if UserPalette[len(UserPalette)-2] != 255:
                        UserPalette.append(255)
                    table = []
                    k = 0
                    for i in range(256):
                        if abs(i-UserPalette[k]) > abs(i-UserPalette[k+1]):
                            k = k+1
                        table.append(UserPalette[k])
                    im = im.point(table)
            if self.options.image_mode.lower() == 'bl':
                im = im.convert("1")
            im.save(bin_fout, 'png', dpi = dpi)
        else:
            if self.options.image_mode.lower() == 'bw' or self.options.image_mode.lower() == 'plte':
                im = im.convert("L")
                if self.options.image_mode.lower() == 'plte' and im_format.lower() != 'jpeg':
                    if UserPalette[len(UserPalette)-2] != 255:
                        UserPalette.append(255)
                    table = []
                    k = 0
                    for i in range(256):
                        if abs(i-UserPalette[k]) > abs(i-UserPalette[k+1]):
                            k = k+1
                        table.append(UserPalette[k])
                    im = im.point(table)
            if self.options.image_mode.lower() == 'bl':
                im = im.convert("1")
            im.save(bin_fout, im_format, quality=95, dpi = dpi)
    def _wrk_transform_binaries(self, conv_info_soup, out_dir):
        self.options.image_transform = int(get_param(conv_info_soup.documentElement, 'page', 'images_mode', 'resize'))
        if self.options.image_transform != 0:
            self.options.image_mode = get_param(conv_info_soup.documentElement, 'page', 'images_mode', 'mode')
            self.options.output_dpi = (int(get_param(conv_info_soup.documentElement, 'page', 'dpi', 'width')),
                        int(get_param(conv_info_soup.documentElement, 'page', 'dpi', 'height')))
            page_size = (get_param(conv_info_soup.documentElement, 'page', 'size', 'width'),
                         get_param(conv_info_soup.documentElement, 'page', 'size', 'height'))
            self.options.page_size = tuple([float(x[:-2]) for x in page_size])
            self.options.page_image_margin = (int(get_param(conv_info_soup.documentElement, 'page', 'max_image_margin', 'width')),
                                 int(get_param(conv_info_soup.documentElement, 'page', 'max_image_margin', 'height')))
            self.options.max_image_size = ((((self.options.page_size[0] - self.options.page_image_margin[0]*2)/25.4)*self.options.output_dpi[0],
                ((self.options.page_size[1] - self.options.page_image_margin[1]*2)/25.4)*self.options.output_dpi[1]))
        for binary_node in findAll(conv_info_soup.documentElement.getElementsByTagName('binaries')[0], 'binary'):
            href_binary = binary_node.attributes['href_binary'].value
            href_ascii = binary_node.attributes['href_ascii'].value
            content_type = binary_node.attributes['content-type'].value
            bin_fout = open(os.path.join(out_dir, href_binary), 'wb')
            self._add_tmp_fname(os.path.join(out_dir, href_binary))
            ascii_finp = open(href_ascii)
            self._add_tmp_fname(href_ascii)
            try:
                if self.options.image_transform != 0 and content_type.split('/')[0].lower() == 'image':
                    logging.info('transforming image [%s]' % href_binary)
                    self._transform_image(ascii_finp, bin_fout, href_binary)
                else:
                    bin_fout.write(binascii.a2b_base64(ascii_finp.read()))
            finally:
                bin_fout.close()
                ascii_finp.close()
    def unpack_try(self, inp_fb2_fname):
        def unp_gzip(fnp, fu):
            gf = gzip.GzipFile(fnp)
            try:
                fu.write(gf.read())
            finally:
                gf.close()
        def unp_bzip2(fnp, fu):
            gf = bz2.BZ2File(fnp)
            try:
                fu.write(gf.read())
            finally:
                gf.close()
        def unp_zip(fnp, fu):
            try:
                ar = zipfile.ZipFile(fnp)
                namelist = ar.namelist()
                if len(namelist) == 1: fn_u = namelist[0]
                else: fn_u = os.path.splitext(os.path.basename(fnp))[0]
                fu.write(ar.read(fn_u))
            finally:
                ar.close()
        ext_map = {'.gz': unp_gzip,
                  '.zip': unp_zip,
                  '.bz2': unp_bzip2
                  }
        name, ext = os.path.splitext(os.path.basename(inp_fb2_fname))
        unp_fun = ext_map.get(ext.lower(), None)
        if unp_fun == None:
            logging.info('file seems to be non-packed (has no known packer extension)')
            return inp_fb2_fname
        logging.info('file seems to be packed (has known packer extension)')
        try:
            unp_inp_fb2_fname = os.path.join(self.trns_dir, name)
            fu = open(unp_inp_fb2_fname, 'wb')
            self._add_tmp_fname(unp_inp_fb2_fname)
            logging.info('unpacking file')
            unp_fun(inp_fb2_fname, fu)
        finally:
            fu.close()
        return unp_inp_fb2_fname
    def _mk_trns_dir(self):
        self.cur_dir = os.getcwd()
        self.trns_dir = os.path.abspath(os.path.join(self.options.cnv_tmp_dir, gen_tmp_name()))
        try:
            os.mkdir(self.trns_dir)
        except OSError as err:
            if err.errno != 17: raise err
    def transform_to_epub(self, fb2_fname, epub_fname):
        self._mk_trns_dir()
        oebps_fdir = 'OEBPS'
        metainf_fdir = 'META-INF'
        inp_fb2_fname = os.path.abspath(fb2_fname)
        inp_fb2_fname = self.unpack_try(inp_fb2_fname)
        out_epub_fname = os.path.abspath(epub_fname)
        self.interim_name = os.path.split(inp_fb2_fname)[1]
        conv_info_fname = self.options.option('conv_info_fname')
        docbook_fname = self._transform_fb2_docbook(inp_fb2_fname, conv_info_fname)
        abs_conv_info_fname = os.path.abspath(os.path.join(self.trns_dir, conv_info_fname))
        self._add_tmp_fname(abs_conv_info_fname)
        conv_info_soup = xml.dom.minidom.parse(abs_conv_info_fname)
        oebps_dir = os.path.join(self.trns_dir, oebps_fdir)
        self._add_tmp_fname(oebps_dir)
        metainf_dir = os.path.join(self.trns_dir, metainf_fdir)
        self._add_tmp_fname(metainf_dir)
        for d in oebps_dir, metainf_dir: os.mkdir(d)

        self._transform_binaries(conv_info_soup, oebps_dir)

        self._transform_docbook_epub(docbook_fname)
        wf_epub_fname = os.path.abspath(self.interim_name + '.epub')
        epub_f = None
        fonts_dir = self.options.option('fonts_dir')
        try:
            epub_f = MZipFile(wf_epub_fname, 'w', zipfile.ZIP_STORED)
            epub_f.writestr('mimetype', "application/epub+zip")
            epub_f.rec_add_dir(oebps_dir, oebps_fdir, zipfile.ZIP_DEFLATED)
            epub_f.rec_add_dir(metainf_dir, metainf_fdir, zipfile.ZIP_DEFLATED)
            stylesheet_fname = self.options.option('epub', 'stylesheet')
            epub_f.write(stylesheet_fname, '/'.join((oebps_fdir, os.path.split(stylesheet_fname)[1])))
            for font_fname, arc_font_fname in self._get_fonts_arc_names(stylesheet_fname):
                logging.info('add font %s', font_fname)
                abs_font_fname = os.path.join(fonts_dir, font_fname)
                if os.path.isfile(abs_font_fname):
                    epub_f.write(abs_font_fname,
                            '/'.join((oebps_fdir, arc_font_fname)),
                            zipfile.ZIP_DEFLATED)
                else:
                    logging.warning('Can\'t find font file: %s', abs_font_fname)
        finally:
            if epub_f != None: epub_f.close()

        logging.info('moving resulting epub to final location')
        shutil.move(wf_epub_fname, out_epub_fname)
    def transform_to_pdf(self, fb2_fname, pdf_fname):
        self._mk_trns_dir()
        inp_fb2_fname = os.path.abspath(fb2_fname)
        inp_fb2_fname = self.unpack_try(inp_fb2_fname)
        out_pdf_fname = os.path.abspath(pdf_fname)
        self.interim_name = os.path.split(inp_fb2_fname)[1]
        conv_info_fname = self.options.option('conv_info_fname')
        docbook_fname = self._transform_fb2_docbook(inp_fb2_fname, conv_info_fname)
        print(self.trns_dir)
        print(conv_info_fname)
        abs_conv_info_fname = os.path.abspath(os.path.join(self.trns_dir, conv_info_fname.decode('UTF-8')))
        self._add_tmp_fname(abs_conv_info_fname)
        conv_info_soup = xml.dom.minidom.parse(abs_conv_info_fname)
        self._transform_binaries(conv_info_soup, self.trns_dir)

        if options.option('docbook_pdf_proc') == b'latex_proc':
            latex_pdf_fname = self._transform_latex(docbook_fname)
            wf_pdf_fname = latex_pdf_fname
        else:
            titlepages_fname = self._transform_titlepages()
            abs_fo_fname = self._transform_docbook_fo(docbook_fname, titlepages_fname)
            fo_pdf_fname = self._transform_fo(abs_fo_fname)
            wf_pdf_fname = fo_pdf_fname

        if self.update_metadata:
            upd_desc_pdf_fname = self._make_pdf_description(
                                    conv_info_soup.documentElement.getElementsByTagName('metadata')[0],
                                    wf_pdf_fname)
            self._add_tmp_fname(wf_pdf_fname)
            wf_pdf_fname = upd_desc_pdf_fname
        if self.linearize_pdf:
            optimzed_pdf_fname = self._pdf_optimize(wf_pdf_fname)
            self._add_tmp_fname(wf_pdf_fname)
            wf_pdf_fname = optimzed_pdf_fname
        logging.info('moving resulting pdf to final location')
        shutil.move(wf_pdf_fname, out_pdf_fname)
    def _transform_fo(self, abs_fo_fname):
        try:
            logging.info('transforming XSL-FO to pdf')
            os.chdir(self.trns_dir)
            fo_pdf_fname = os.path.abspath(self.interim_name + '.pdf')
            self.fo_transformer.transform(abs_fo_fname, fo_pdf_fname)
        finally:
            os.chdir(self.cur_dir)
        return fo_pdf_fname
    def _transform_latex(self, abs_latex_fname):
        try:
            logging.info('transforming via LaTeX to pdf')
            os.chdir(self.trns_dir)
            latex_pdf_fname = os.path.abspath(self.interim_name + '.pdf')
            self.latex_transformer.transform(abs_latex_fname, latex_pdf_fname)
        finally:
            os.chdir(self.cur_dir)
        return latex_pdf_fname

    def _pdf_optimize(self, inp_pdf_fname):
        try:
            logging.info('linearizing pdf')
            out_pdf_fname = os.path.abspath(os.path.join(self.trns_dir, self.interim_name + '.linearized.pdf'))
            self.pdf_optimizer.transform(inp_pdf_fname, out_pdf_fname)
        finally:
            pass
        return out_pdf_fname
    def _make_pdf_description(self, soup_metadata, in_pdf_fname):
        try:
            logging.info('updating pdf description')
            in_dd_fname = os.path.abspath(os.path.join(self.trns_dir, self.interim_name + '.inp.metadata'))
            self._add_tmp_fname(in_dd_fname)
            out_dd_fname = os.path.abspath(os.path.join(self.trns_dir, self.interim_name + '.out.metadata'))
            self._add_tmp_fname(out_dd_fname)
            out_pdf_fname = os.path.abspath(os.path.join(self.trns_dir, self.interim_name + '.upd.desc.pdf'))
            translify_fun = lambda x: x
            if self.to_translify: translify_fun = translify
            self.pdf_tool.transform(soup_metadata, in_pdf_fname,
                                    out_pdf_fname, in_dd_fname, out_dd_fname,
                                    translify_fun)
        finally:
            pass
        return out_pdf_fname
    def _transform_binaries(self, conv_info_soup, out_dir):
        logging.info('transforming binaries')
        try:
            os.chdir(self.trns_dir)
            self._wrk_transform_binaries(conv_info_soup, out_dir)
        finally:
            os.chdir(self.cur_dir)
    def _transform_titlepages(self):
        logging.info('preparing xsl for titlepages')
        titlepages_fname_inp = os.path.abspath(self.xslt_titlepages)
        titlepages_fname = os.path.abspath(os.path.join(self.trns_dir,
                                                           os.path.split(titlepages_fname_inp)[1] + '.xsl'))
        xslt_trans = os.path.abspath(os.path.join(self.options.option('docbook', 'root'),
                                                  self.options.option('docbook', 'titlepages_trans'))).decode('UTF-8')
        self.xslt_transformer.transform(xslt_trans, titlepages_fname_inp, titlepages_fname)
        self._add_tmp_fname(titlepages_fname)
        return titlepages_fname
    def _transform_docbook_fo(self, docbook_fname, titlepages_fname):
        def cr_trns_f(fname):
            content = """<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1">
            <xsl:import href="%s"/>
            <xsl:import href="%s"/>
            <xsl:import href="%s"/>
</xsl:stylesheet>"""
            fout = open(fname, 'wb')
            try:
                docbook_xslt = os.path.abspath(os.path.join(self.options.option('docbook', 'root'),
                                                            self.options.option('docbook', 'fo_trans')))
                user_xslt = os.path.abspath(self.xslt_params)
                fout.write(content % (to_xml_uri(docbook_xslt), to_xml_uri(titlepages_fname), to_xml_uri(user_xslt)))
            finally:
                fout.close()
        logging.info('transforming Docbook to XSL-FO')
        trns_xslt_fname = os.path.abspath(os.path.join(self.trns_dir, 'trns_docbook_fo.xsl'))
        cr_trns_f(trns_xslt_fname)
        self._add_tmp_fname(trns_xslt_fname)
        abs_fo_fname = os.path.abspath(os.path.join(self.trns_dir, self.interim_name + '.fo'))
        self.xslt_transformer.transform(trns_xslt_fname,
                                        docbook_fname,
                                        abs_fo_fname,
                                        self.fo_transformer.docbook_params())
        self._add_tmp_fname(abs_fo_fname)
        return abs_fo_fname
    def _transform_fb2_docbook(self, inp_fb2_fname, conv_info_idx_fname):
        def cr_trns_f(fname):
            content = """<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1">
            <xsl:import href="%s"/>
            <xsl:include href="%s"/>
</xsl:stylesheet>"""
            fout = open(fname, 'wb')
            try:
                user_xslt = os.path.abspath(self.xslt_params)
                script_xslt = os.path.abspath(os.path.join(self.options.option('fb2', 'root'),
                    self.options.option('fb2', 'docbook_trans')))
                fout.write((content % (to_xml_uri(user_xslt), to_xml_uri(script_xslt))).encode())
            finally:
                fout.close()
        params = (('conv_info_idx', conv_info_idx_fname.decode("UTF-8")),
                  ('document-element', self.xslt_transformer.get_document_element_type()))
        try:
            logging.info('transforming FB2 to Docbook')
            trns_xslt_fname = os.path.join(self.trns_dir, 'trns_fb2_docbook.xsl')
            cr_trns_f(trns_xslt_fname)
            self._add_tmp_fname(trns_xslt_fname)
            os.chdir(self.trns_dir)
            docbook_fname = os.path.abspath(self.interim_name + '.docbook')
            self.xslt_transformer.transform(trns_xslt_fname, inp_fb2_fname,
                                            docbook_fname, params)
            # self._add_tmp_fname(docbook_fname)
        finally:
            os.chdir(self.cur_dir)
        return docbook_fname
    def _transform_docbook_epub(self, docbook_fname):
        def cr_trns_f(fname):
            content = """<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1">
            <xsl:import href="%s"/>
            <xsl:import href="%s"/>
            <xsl:param name="html.stylesheet" select="'%s'"/>
</xsl:stylesheet>"""
            fout = open(fname, 'wb')
            try:
                docbook_xslt = os.path.abspath(os.path.join(self.options.option('docbook', 'root'),
                                                            self.options.option('docbook', 'epub_trans')))
                user_xslt = os.path.abspath(self.xslt_params)
                stylesheet_fname = os.path.split(self.options.option('epub', 'stylesheet'))[1]
                fout.write((content % (to_xml_uri(docbook_xslt), to_xml_uri(user_xslt), stylesheet_fname)).encode())
            finally:
                fout.close()
        logging.info('transforming Docbook to Epub XHTMLs')
        trns_xslt_fname = os.path.abspath(os.path.join(self.trns_dir, 'trns_docbook_epub.xsl'))
        cr_trns_f(trns_xslt_fname)
        self._add_tmp_fname(trns_xslt_fname)
        try:
            os.chdir(self.trns_dir)
            self.xslt_transformer.transform(trns_xslt_fname,
                                        docbook_fname,
                                        'out')
        finally:
            os.chdir(self.cur_dir)
    def _get_fonts_arc_names(self, css_fname):
        res = []
        pattern = '^url\(([A-Za-z]+://)?(.*)\)$'
        c = re.compile(pattern)
        sheet = cssutils.css.CSSStyleSheet()
        css_f = None
        try:
            css_f = open(css_fname, 'rb')
            sheet.cssText = css_f.read()
        finally:
            if css_f != None: css_f.close()

        for rule in sheet.cssRules:
            if not isinstance(rule, cssutils.css.CSSFontFaceRule): continue
            for prop in rule.style.getProperties('src'):
                m = c.match(prop.value)
                ut, ul = m.groups()
                if ut != None:
                    logging.info('found font-face with external url in src property: %s', prop.value)
                if ul == None or len(ul) == 0:
                    logging.warning('found font-face with null url in src property: %s', prop.value)
                    continue
                if ul[0] == '/':
                    logging.warning('found fomt-face with local url and leading \'/\' in src property', prop.value)
                    continue
                ul = ul.encode()
                res.append((os.path.split(ul)[1], ul))
        return res
    def rm_tmp_files(self):
        def rec_rmdir(fdir):
            for dirpath, dirnames, filenames in os.walk(fdir, topdown = False):
                for filename in filenames:
                    os.unlink(os.path.join(dirpath, filename))
                for dirname in dirnames:
                    os.rmdir(os.path.join(dirpath, dirname))
            os.rmdir(fdir)
        fdirs = []
        for fn in self._tmp_fnames:
            try:
                if os.path.isdir(fn):
                    fdirs.append(fn)
                else:
                    os.unlink(fn)
            except Exception as err:
                logging.error('Error %s while unlinking file: %s', err, fn)
        for fdir in fdirs:
            try:
                rec_rmdir(fdir)
            except Exception as err:
                logging.error('Error %s while recursively unlink directory: %s', err, fdir)
        try:
            os.rmdir(self.trns_dir)
        except Exception as err:
            logging.error('Error %s while removing directory: %s', err, self.trns_dir)

def setup_logger():
    rootLogger = logging.getLogger('')
    rootLogger.setLevel(logging.INFO)
#    rootLogger.setLevel(logging.WARNING)
    formatter = logging.Formatter('%(asctime)s %(levelname)s: %(message)s')
    lg_hnd = logging.StreamHandler(sys.stdout)
    lg_hnd.setFormatter(formatter)
    rootLogger.addHandler(lg_hnd)

def get_fname_with_ext(fb2_fname, ext):
    r_p = r"(\.fb2)?(\.(?:zip|gz|bz2))?$"
    return '%s.%s' % (fb2_fname[:re.search(r_p, fb2_fname).start()], ext)

if __name__ == '__main__':
    setup_logger()
    prog_cwd = os.path.dirname(sys.argv[0])
    cur_cwd = os.getcwd()
    cl_parser = optparse.OptionParser(usage = 'usage: %prog --config config_file [options] fb2_file[.(zip|gz|bz2)] output_file',
                             version = '%s version %s; fb2docbook.xsl version %s' % ('%prog', VERSION, VERSION_XSLT))
    cl_parser.add_option('-c', '--config', dest = 'configname',
                  help = 'read config from FILE', metavar = 'FILE')
    cl_parser.add_option('--epub', action='store_true', default=False, dest='to_epub',
                        help = 'transform to epub')
    cl_parser.add_option('--wh', action='store_true', dest='win32hack',
                         help = 'turn on win32hack -- non closed console window')
    cl_parser.add_option('--no-remove_tmp', action='store_false', default=True, dest='remove_tmp',
                         help = 'do not remove working temporal files')
    cl_parser.add_option('--update_metadata', action='store_true', default=False, dest='update_metadata',
                         help = 'update pdf metadata')
    cl_parser.add_option('--linearize_pdf', action='store_true', default=False, dest='linearize_pdf',
                         help = 'linearize pdf')
    cl_parser.add_option('--xslt_proc', action='store', type='string', dest='xslt_proc',
                         help = 'set xslt_proc to use')
    cl_parser.add_option('--fo_proc', action='store', type='string', dest='fo_proc',
                         help = 'set fo_proc to use')
    cl_parser.add_option('--latex_proc', action='store', type='string', dest='latex_proc',
                         help = 'set latex_proc to use')
    cl_parser.add_option('--pdf_proc', action='store', type='string', dest='pdf_proc',
                         help = 'set pdf_proc to use')
    cl_parser.add_option('--pdf_optimizer', action='store', type='string', dest='pdf_optimizer',
                         help = 'set pdf_optimizer to use')
    cl_parser.add_option('--xslt_params', action='store', type='string', dest='xslt_params',
                         help = 'set xslt_params file to use', metavar='FILE')
    cl_parser.add_option('--xslt_titlepages', action='store', type='string', dest='xslt_titlepages',
                         help = 'set xslt_titlepages file to use', metavar='FILE')
    if has_translify:
        cl_parser.add_option('--translify', action='store_true', default=False, dest='to_translify',
                         help = 'translify pdf description')
    (cl_options, cl_args) = cl_parser.parse_args()

    if cl_options.win32hack:
        import atexit, msvcrt
        def getch():
            print('Press any key...')
            msvcrt.getch()
        atexit.register(getch)

    logging.info('initializing')
    if not cl_options.configname:
        cl_options.configname = os.path.join(prog_cwd, 'config/btconfig.xml')
    if len(cl_args) > 2 or len(cl_args) == 0:
        cl_parser.error('you should provide at least input fb2_file')
    if len(cl_args) == 1:
        fb2_fname = cl_args[0]
        if cl_options.to_epub:
            out_fname = get_fname_with_ext(fb2_fname, 'epub')
        else:
            out_fname = get_fname_with_ext(fb2_fname, 'pdf')
    else:
        fb2_fname, out_fname = cl_args

    options = Options(cl_options.configname)

    if not cl_options.xslt_proc:
        xslt_proc_name = options.option('xslt_proc', 'default')
    else:
        xslt_proc_name = cl_options.xslt_proc
    if not cl_options.fo_proc:
        fo_proc_name = options.option('fo_proc', 'default')
    else:
        fo_proc_name = cl_options.fo_proc

    if not cl_options.latex_proc:
        latex_proc_name = options.option('latex_proc', 'default')
    else:
        latex_proc_name = cl_options.latex_proc
    if not cl_options.pdf_proc:
        pdf_proc_name = options.option('pdf_proc', 'default')
    else:
        pdf_proc_name = cl_options.pdf_proc
    if not cl_options.pdf_optimizer:
        pdf_optimizer_name = options.option('pdf_optimizer', 'default')
    else:
        pdf_optimizer_name = cl_options.pdf_optimizer

    xslt_proc = registred_processors[xslt_proc_name.decode('UTF-8')]
    fo_proc = registred_processors[fo_proc_name.decode('UTF-8')](options)
    latex_proc = registred_processors[latex_proc_name.decode('UTF-8')](options)
    pdf_proc = registred_processors[pdf_proc_name.decode('UTF-8')](options)
    pdf_optimizer = registred_processors[pdf_optimizer_name.decode('UTF-8')](options)

    logging.info('using xslt_proc: %s; fo_proc: %s; pdf_proc: %s, pdf_optimizer: %s',
                 xslt_proc_name, fo_proc_name, pdf_proc_name, pdf_optimizer_name)


    if not cl_options.xslt_params:
        if cl_options.to_epub:
            xslt_params = options.option('xslt_epub_params')
        else:
            xslt_params = options.option('xslt_params')
    else:
        xslt_params = cl_options.xslt_params

    if not cl_options.xslt_titlepages:
        xslt_titlepages = options.option('xslt_titlepages')
    else:
        xslt_titlepages = cl_options.xslt_titlepages

    trns = Transformer(options, xslt_proc, fo_proc, latex_proc,
                       pdf_proc, pdf_optimizer,
                       xslt_params, xslt_titlepages.decode('UTF-8'),
                       update_metadata = cl_options.update_metadata,
                       linearize_pdf = cl_options.linearize_pdf,
                       to_translify = has_translify and cl_options.to_translify)
    try:
        if cl_options.to_epub:
            trns.transform_to_epub(fb2_fname, out_fname)
        else:
            trns.transform_to_pdf(fb2_fname, out_fname)
    finally:
        if cl_options.remove_tmp:
            logging.info('removing temporary files')
            trns.rm_tmp_files()
    logging.info('finish')
