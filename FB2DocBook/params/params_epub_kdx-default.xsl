<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.1">
    <xsl:import href="p_fb2_common-default.xsl"/>
    <xsl:import href="p_docbook_common-kdx.xsl"/>
    <xsl:output encoding="UTF-8" indent="no" method="xml"/>

<!-- ==================================================================== -->

    <!-- Параметры изображений (для KDX разрешение равно 150 dpi, для прочих 166) -->
    <xsl:param name="output.dpi.width" select="'150'"/>
    <xsl:param name="output.dpi.height" select="'150'"/>
    <xsl:param name="output.max_image_margin.width" select="'5'"/>
    <xsl:param name="output.max_image_margin.height" select="'5'"/>
    <!-- Параметры обработки изображений при использовании изменённого btransformer.py (для старого: 0, 1) -->
    <!-- 0 - размер изображений не меняется, лишнее обрезается (на некоторых картинках конвертер падает) -->
    <!-- 1 - при необходимости изображения масштабируются -->
    <!-- 2 - при необходимости изменяется DPI изображений -->
    <!-- 3 - аналог 2, но широкие изображения могут быть повёрнуты -->
    <xsl:param name="output.images_mode.resize" select="'1'"/>
    <!-- Параметры цвета изображений при использовании изменённого btransformer.py (для старого: BW) -->
    <!-- ''     - цвета не меняются, прозрачные/палитровые изображения приводятся к RGBA -->
    <!-- 'BW'   - изображения приводятся к 256 оттенкам серого с сохранением альфа-канала -->
    <!-- 'BL'   - изображения преобразуются в растровые чёрно-белые (нет альфа-канала) -->
    <!-- 'PLTE' - используется чёрно-белая пользовательская палитра (нет альфа-канала) -->
    <!-- Полезно для чертежей/карт и т.п., если пользовательская палитра совпадает с палитрой еКниги -->
    <xsl:param name="output.images_mode.mode" select="'BW'"/>

<!-- ==================================================================== -->

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
    <!-- Kindle DX Graphite портретный, под форматирование через FOP (786x1136) - 133.096mm x 192.363mm -->
    <xsl:param name="paper.type" select="'KDX'"/>
    <xsl:param name="page.width" select="'133.096mm'"/>
    <xsl:param name="page.height" select="'192.363mm'"/>

<!-- ==================================================================== -->

    <xsl:template name="user.head.content">
        <link rel="stylesheet" href="{$html.stylesheet}" type="{$html.stylesheet.type}"/> 
    </xsl:template>

<!-- ==================================================================== -->

</xsl:stylesheet>
