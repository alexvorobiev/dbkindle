<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.1">
    <xsl:import href="p_fb2_common-default.xsl"/>
    <xsl:import href="p_docbook_common-kdx.xsl"/>
    <xsl:import href="p_fonts_pala.xsl"/>
    <xsl:output encoding="UTF-8" indent="no" method="xml"/>

    <!-- Этот параметр позволяет задать расширенную поддержку графических форматов -->
    <xsl:param name="fop1.extensions" select="1"/>

    <!-- Параметры изображений (для KDX разрешение равно 150 dpi, для прочих 166) -->
    <xsl:param name="output.dpi.width" select="'167'"/>
    <xsl:param name="output.dpi.height" select="'167'"/>
    <xsl:param name="output.max_image_margin.width" select="'5'"/>
    <xsl:param name="output.max_image_margin.height" select="'5'"/>
    <!-- Параметры обработки изображений при использовании изменённого btransformer.py (для старого .exe - 1) -->
    <!-- 0 - размер изображения не меняется, при необходимости оно обрезается -->
    <!-- 1 - при необходимости изображение масштабируется -->
    <!-- 2 - при необходимости изменяется DPI изображения -->
    <!-- 3 - аналог 2, но широкое изображение может быть повёрнуто -->
    <xsl:param name="output.images_mode.resize" select="'1'"/>
    <!-- Параметры цвета изображений при использовании изменённого btransformer.py (для старого .exe - BW) -->
    <!-- '' - цвета непрозрачных изображений не меняются, у прозрачных пропадает альфа-канал -->
    <!-- 'Color' - цвета PNG приводятся к RGBA (без PIL-патча не учитывается tRNS); прочие не изменяются -->
    <!-- 'BW' - изображения преобразуются к 256 оттенкам серого (нет альфа-канала) -->
    <!-- 'PLTE' - используется чёрно-белая пользовательская палитра (задаётся в btransformer.py; нет альфа-канала) -->
    <!-- Полезно для чертежей/карт/таблиц и т.д., если пользовательская палитра совпадает с палитрой еКниги. -->
    <xsl:param name="output.images_mode.mode" select="'BW'"/>

    <!-- Размеры страниц -->
    <!-- Sony PRS 500/505/600/700/650 портретный - 88.184mm x 113.854mm -->
    <!-- Sony PRS 500/505/600/700/650 альбомный - 118.384mm x 83.654mm -->
    <!-- Sony PRS 300/350 портретный - 74.168mm x 95.758mm -->
    <!-- Sony PRS 300/350 альбомный - 99.568mm x 70.358mm -->
    <!-- Sony PRS 900/950 портретный - 88.184mm x 147.678mm -->
    <!-- Sony PRS 900/950 альбомный - 152.208mm x 83.654mm -->
    <!-- Kindle 3 портретный - 84.560mm x 110.985mm (второй вариант - 85.09mm x 111.76mm) -->
    <!-- Kindle DX портретный - 132.757mm x 194.733mm -->
    <!-- Kindle DX альбомный - 196.427mm x 131.064mm -->
    <!-- Kindle DX портретный (для Graphite) - 132.08mm x 191.01mm -->
    <xsl:param name="paper.type" select="'KDX'"/>
    <xsl:param name="page.width" select="'85.09mm'"/>
    <xsl:param name="page.height" select="'111.76mm'"/>


    <!-- Переплёт, поля страницы и основного текста -->
    <!-- Для Kindle: page.margin.top и page.margin.bottom должны быть равны 0 (см. ниже) -->
    <xsl:param name="double.sided" select="'0'"/>
    <xsl:param name="page.margin.top" select="'0mm'"/>
    <xsl:param name="page.margin.bottom" select="'0mm'"/>
    <xsl:param name="page.margin.inner" select="'0.4mm'"/>
    <xsl:param name="page.margin.outer" select="'0.8mm'"/>
    <xsl:param name="body.margin.top" select="'1mm'"/>
    <xsl:param name="body.margin.bottom" select="'1mm'"/>
    <xsl:param name="body.start.indent" select="'0pt'"/>

<!-- ==================================================================== -->

    <!-- Для Kindle: линии предотвращают центровку незаполненных страниц по вертикали -->
    <!-- Верхние и нижние поля задавать в параметрах body.margin, иначе линиии съедут -->
    <!-- Отключаются эти линии нулевым значением параметров header.rule и footer.rule -->

    <!-- Верхний колонтитул -->
    <!-- При изменении размера страниц (полей) возможны проблемы с верхней линией (уезжает вниз) -->
    <!-- В таком случае попробуйте поставить ненулевую высоту отделяемого поля, например 0.09pt -->
    <xsl:param name="header.rule" select="1"/>
    <xsl:param name="header.table.height">0.456pt</xsl:param>

    <!-- Параметры его разделительной линии, если она включена в "header.rule" -->
    <!-- Линия может быть:  none, solid, dashed, dotted, double, groove, ridge -->
    <xsl:template name="head.sep.rule">
        <xsl:if test="$header.rule != 0">
            <xsl:attribute name="border-bottom-width">0.05pt</xsl:attribute>
            <xsl:attribute name="border-bottom-style">dashed</xsl:attribute>
            <xsl:attribute name="border-bottom-color">#E8E8E8</xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:attribute-set name="header.table.properties">
        <xsl:attribute name="width">101.35%</xsl:attribute>
        <xsl:attribute name="margin-left">-0.4mm</xsl:attribute>
    </xsl:attribute-set>

    <!-- Нижний колонтитул -->
    <xsl:param name="footer.rule" select="1"/>
    <xsl:param name="footer.table.height">0pt</xsl:param>

    <!-- Параметры его разделительной линии, если включена в "footer.rule" -->
    <xsl:template name="foot.sep.rule">
        <xsl:if test="$footer.rule != 0">
            <xsl:attribute name="border-top-width">0.05pt</xsl:attribute>
            <xsl:attribute name="border-top-style">dashed</xsl:attribute>
            <xsl:attribute name="border-top-color">#E8E8E8</xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:attribute-set name="footer.table.properties">
        <xsl:attribute name="width">101.35%</xsl:attribute>
        <xsl:attribute name="margin-left">-0.4mm</xsl:attribute>
    </xsl:attribute-set>

    <!-- Конец настроек центровки для Kindle -->

<!-- ==================================================================== -->

    <!-- Размер основного шрифта (на его базе считаются другие, кроме шаблона обложки) -->
    <xsl:param name="body.font.master" select="12"/>

</xsl:stylesheet>
