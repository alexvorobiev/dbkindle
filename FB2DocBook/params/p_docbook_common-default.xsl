<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.1">
    <xsl:output encoding="UTF-8" indent="no" method="xml"/>

<!-- ==================================================================== -->

    <!-- Позволяет использовать расширения FOP 0.90 и выше (включая графические форматы) -->
    <xsl:param name="fop1.extensions" select="1"/>

<!-- ==================================================================== -->

    <!-- Формат нумерации глав, если не 0 (1 | a | A | i | I) -->
    <xsl:param name="chapter.autolabel" select="0"/>

    <!-- Формат нумерации частей, если не 0 (1 | a | A | i | I) -->
    <xsl:param name="part.autolabel" select="0"/>

    <!-- Разделитель заданных выше меток и названий глав в оглавлении -->
    <xsl:param name="autotoc.label.separator" select="'.'"/>

<!-- ==================================================================== -->

    <!-- Отображать второе имя (отчество) автора между именем и фамилией (не показывать, если 0) -->
    <!-- Также отвечает за отображение авторов в эпиграфах, цитатах и поэмах -->
    <xsl:param name="author.othername.in.middle" select="1"/>

<!-- ==================================================================== -->

    <!-- Параметр ulink задаёт внешние гиперссылки на полный URL документа, включая протокол -->
    <!-- Отображать URL всех ulink-объектов после текста ссылки, если не 0 -->
    <!-- (при идентичных URL и текст ссылки URL не показывается) -->
    <xsl:param name="ulink.show" select="0"/>
    <!-- Показывать URL всех ulink-объектов в виде сносок, если не 0 (и при ненулевом ulink.show) -->
    <xsl:param name="ulink.footnotes" select="1"/>
    <!-- Стиль нумерации ulink-сносок (1 | a | A | i | I) -->
    <xsl:param name="ulink.footnote.number.format" select="'1'"/>
    <!-- Если не пусто, заданный символ добавляется к URL после любого (по умолчанию /) символа из ulink.hyphenate.chars -->
    <xsl:param name="ulink.hyphenate" select="''"/>

    <!-- Параметр xref задаёт перекрёстные ссылки внутри документа (с автотекстом ссылки, link с произвольным) -->
    <!-- Отображать число и заголовок в ссылках -->
    <xsl:param name="xref.with.number.and.title" select="1"/>

    <!-- Номер страницы во внутренних и междокументных ссылках (yes | no | maybe) -->
    <xsl:param name="insert.xref.page.number">no</xsl:param>
    <xsl:param name="insert.link.page.number">no</xsl:param>
    <xsl:param name="insert.olink.page.number">no</xsl:param>

    <!-- В DocBook старше 4.3 можно использовать атрибут role, например: xref xrefstyle="title" -->
    <xsl:param name="use.role.as.xrefstyle" select="0"></xsl:param>

<!-- ==================================================================== -->

    <!-- Стиль нумерации страниц (1 | a | A | i | I) -->
    <xsl:template name="page.number.format">1</xsl:template>

    <!-- Стиль нумерации сносок (1 | a | A | i | I) -->
    <xsl:param name="footnote.number.format" >1</xsl:param>
    <xsl:param name="table.footnote.number.format" >I</xsl:param>

<!-- ==================================================================== -->

    <!-- Черновой режим с фоновым рисунком (yes | no | maybe) -->
    <xsl:param name="draft.mode" select="'no'"/>
    <xsl:param name="draft.watermark.image">../docbook-xsl/images/draft.png</xsl:param>

<!-- ==================================================================== -->

    <!-- Расскоментировать, чтобы отключить расстановку переносов для всех элементов -->
    <!-- Для конкретных элементов - см. как отключаются у всех title в стилях (KiR) -->
    <!-- xsl:param name="hyphenate">false</xsl:param -->

<!-- ==================================================================== -->

    <!-- Оглавление -->
    <!-- Максимальная глубина оглавления -->
    <xsl:param name="toc.max.depth">2</xsl:param>
    <!-- Глубина вложенных секций в оглавлении -->
    <xsl:param name="toc.section.depth">1</xsl:param>
    <!-- Сворачивать закладки, если не 0 -->
    <xsl:param name="bookmarks.collapse" select="1"/>
    <!-- Собственно генерация оглавления -->
    <xsl:param name="generate.toc" xml:space="preserve">
        /appendix  toc,title
        article/appendix  nop
        /article  toc,title
        book  toc,title,figure,table,example,equation
        /chapter  toc,title
        part  toc,title
        /preface  toc,title
        qandadiv  toc
        qandaset  toc
        reference  toc,title
        /sect1  toc
        /sect2  toc
        /sect3  toc
        /sect4  toc
        /sect5  toc
        /section  toc
        set  toc,title
    </xsl:param>
    <!-- Для отключения оглавления заменить всю конструкцию "generate.toc" на нижеследующую -->
    <!-- xsl:param name="generate.toc"/ -->
    <xsl:template match="*[@role = 'NotInToc']" mode="toc"/>

<!-- ==================================================================== -->

</xsl:stylesheet>
