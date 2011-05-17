<?xml version='1.0' encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl"
                version='1.0'>

  <xsl:import href="xsl/coverpage.xsl"/>
  <xsl:import href="xsl/lettrine.xsl"/>
  <xsl:import href="xsl/poem.xsl"/>
  <xsl:import href="xsl/epigraph.xsl"/>
  
  <!-- Options used for documentclass -->

  <xsl:param name="latex.class.book">memoir</xsl:param> 

  <xsl:param name="latex.class.options">12pt,oneside,showtrims</xsl:param>

  <xsl:param name="latex.encoding">utf8</xsl:param>

  <xsl:param name="titleabbrev.in.toc">1</xsl:param>

  <!-- Correction for test for xetex which is provided by memoir and inclusion of custom coverpage (maketitle must be redefined before standard preamble templates kick in) -->
  <xsl:template name="encode.before.style">
    <xsl:param name="lang"/>
    <xsl:variable name="use-unicode">
      <xsl:call-template name="lang-in-unicode">
        <xsl:with-param name="lang" select="$lang"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- XeTeX preamble to handle fonts -->
    <xsl:text>\ifxetex&#10;</xsl:text>
    <xsl:text>\usepackage{fontspec}&#10;</xsl:text>
    <xsl:text>\usepackage{xltxtra}&#10;</xsl:text>
    <xsl:value-of select="$xetex.font"/>
    <xsl:text>\else&#10;</xsl:text>

    <!-- Standard latex font setup -->
    <xsl:choose>
      <xsl:when test="$use-unicode='1'"/>
      <xsl:when test="$latex.encoding='latin1'">
        <xsl:text>\usepackage[T1,T2A]{fontenc}&#10;</xsl:text>
        <!-- <xsl:text>\usepackage[latin1]{inputenc}&#10;</xsl:text> -->
        <xsl:text>\usepackage{ucs}&#10;</xsl:text>
        <xsl:text>\usepackage[utf8x]{inputenc}&#10;</xsl:text>
        <xsl:text>\usepackage[russian,greek,english]{babel}&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="$latex.encoding='utf8'">
        <xsl:text>\usepackage[T3,OT2,T2A,T1]{fontenc}&#10;</xsl:text>
        <xsl:text>\usepackage{ucs}&#10;</xsl:text>
        <xsl:text>\usepackage[utf8x]{inputenc}&#10;</xsl:text>
        <xsl:text>\def\hyperparamadd{unicode=true}&#10;</xsl:text>
      </xsl:when>
    </xsl:choose>

    <xsl:text>\fi&#10;</xsl:text>

    <!-- <xsl:text>\usepackage{dbkindle_coverpage}</xsl:text> -->
  </xsl:template>

  <!-- Multi-line titles -->
  <xsl:template match="title/para">
    <xsl:apply-templates/>
    <xsl:text>\\</xsl:text>
  </xsl:template>

  <!-- Empty <literallayout> is produced by FB2's <emptyline/>-->
  <xsl:template match="literallayout[.='']">
    <xsl:text>\par \vspace{\baselineskip}</xsl:text>
  </xsl:template>

  <!-- Fancy breaks -->
  <xsl:template match="bridgehead">
    <xsl:text>\fancybreak{\pfbreakdisplay}</xsl:text>
  </xsl:template>

  <!-- Disable generation of \label's since they won't compile if they use unicode symbols -->
  <xsl:template name="label.id"/>

</xsl:stylesheet>
