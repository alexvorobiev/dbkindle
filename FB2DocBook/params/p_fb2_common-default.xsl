<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.1">
    <xsl:output encoding="UTF-8" indent="no" method="xml"/>

<!-- ==================================================================== -->

    <xsl:variable name="fb2.book-parts">
        <!-- Если сделать chapter первым уровнем, то заголовки частей не будут идти отдельной страницей -->
        <!-- Зато главы ниже него не смогут начинаться с новой страницы без break-after после <section> -->
        <part level="1" name="part" intro-name="partintro"/>
        <part level="2" name="chapter"/>
        <part level="3" name="section"/>
        <part level="4" name="sect1"/>
        <part level="5" name="sect2"/>
        <part level="6" name="sect3"/>
        <part level="7" name="sect4"/>
        <part level="8" name="sect5"/>
    </xsl:variable>
    <xsl:variable name="fb2.image.align" select="'center'"/>
    <xsl:variable name="fb2.image.valign" select="'middle'"/>
    <xsl:variable name="fb2.default.language" select="'ru'"/>
    <!-- Информация о FB2; для отображения задать параметр true() -->
    <xsl:variable name="fb2.print.infos" select="false"/>
    <xsl:variable name="fb2.not_in_toc" select="'NotInToc'"/>

<!-- ==================================================================== -->

</xsl:stylesheet>
