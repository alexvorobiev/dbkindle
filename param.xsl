<?xml version='1.0' encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl"
                version='1.0'>

<!-- Options used for documentclass -->

<xsl:param name="latex.class.book">memoir</xsl:param> 

<xsl:param name="latex.class.options">12pt,oneside,showtrims</xsl:param>

<xsl:param name="latex.encoding">utf8</xsl:param>

<xsl:param name="titleabbrev.in.toc">1</xsl:param>

<!-- Correction for test for xetex which is provided by memoir -->

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
</xsl:template>

<xsl:template match="title/para">
  <xsl:apply-templates/>
  <xsl:text>\\</xsl:text>
</xsl:template>


<!-- Poems -->

<!-- Replaces line breaks with \\ -->
<xsl:template name="break">
  <xsl:param name="text" select="."/>
  <xsl:choose>
    <xsl:when test="contains($text, '&#xa;')">
      <xsl:value-of select="substring-before($text, '&#xa;')"/>
                
      <xsl:text>\\&#10;</xsl:text>
      <xsl:call-template name="break">
        <xsl:with-param name="text" select="substring-after($text, '&#xa;')"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$text"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="para[@role='poem']">
  <xsl:text>\begin{verse}\normalfont&#10;</xsl:text>
  <xsl:for-each select="literallayout[@xml:space='preserve' and @role='poem']/* | literallayout[@xml:space='preserve' and @role='poem']/text()">
    <xsl:choose>
      <xsl:when test="self::text()">
        <xsl:text>\begin{itshape}&#10;</xsl:text>

        <xsl:call-template name="break">
          <xsl:with-param name="text" select="."/>
        </xsl:call-template>

        <xsl:text>\end{itshape}&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="."/>
      </xsl:otherwise>
      
    </xsl:choose>
  </xsl:for-each>
  <xsl:text>\end{verse}&#10;</xsl:text>
</xsl:template>

<xsl:template match="literallayout[@xml:space='default' and @role='poem']/author">
  <xsl:text>\attrib{</xsl:text>
  <xsl:value-of select="./node()"/>
  <xsl:text>}</xsl:text>
</xsl:template>

<!-- Empty <literallayout> is produced by FB2's <emptyline/>-->
<xsl:template match="literallayout[.='']">
  <xsl:text>\par \vspace{\baselineskip}</xsl:text>
</xsl:template>

<!-- Fancy breaks -->

<xsl:template match="bridgehead">
  <xsl:text>\fancybreak{\pfbreakdisplay}</xsl:text>
</xsl:template>



<!-- <xsl:template match="chapter/para[1]"> -->
<!--   <xsl:variable name="initial" select="substring(.,1,1)"/> -->
<!--   <xsl:text>\lettrine[lines=3]{</xsl:text> -->
<!--   <xsl:value-of select="$initial"/> -->
<!--   <xsl:text>}{}</xsl:text> -->

<!--   <xsl:apply-templates select="exsl:node-set(substring-after(.,$initial))"/> -->
<!-- </xsl:template> -->

<!-- Disable generation of \label's since they won't compile if they use unicode symbols -->
<xsl:template name="label.id"/>

<!-- Epigraphs -->
<xsl:template match="epigraph">
  <xsl:text>\begin{savenotes}&#10;</xsl:text>
  <xsl:text>\epigraph{&#10;</xsl:text>
  <xsl:apply-templates select="*[not(self::attribution)]"/>
  <xsl:text>&#10;}{</xsl:text>
  <xsl:apply-templates select="attribution"/>
  <xsl:text>}&#10;</xsl:text>
  <xsl:text>\end{savenotes}&#10;</xsl:text>
</xsl:template>



<xsl:template match="attribution">
  <xsl:apply-templates/>
</xsl:template>


<!-- Dropped capitals -->

<!-- Catch nodes having text() in the first para of a section -->
  <!-- At the para level:
       if the node is directly a text() starting the para, or
       if the node is an element containing text() that is not preceded
       by nodes having text
    -->
<!-- <xsl:template match="para[preceding-sibling::*[1] -->
<!--                           [self::title or self::titleabbrev]]//text() -->
<!--                            [normalize-space()]"> -->
<!--   <xsl:choose> -->

<!--   <xsl:when test="(parent::para and position()=1) or -->
<!--                   (ancestor::*[parent::para][ -->
<!--                        not(preceding-sibling::*//text()[normalize-space()]) and -->
<!--                        not(preceding-sibling::text()[normalize-space()])])"> -->
    
<!--     <xsl:text>\lettrine[lines=2]{</xsl:text> -->
<!--     <xsl:call-template name="scape"> -->
<!--       <xsl:with-param name="string" select="substring(.,1,1)"/> -->
<!--     </xsl:call-template> -->
<!--     <xsl:text>}{}</xsl:text> -->
<!--     <xsl:call-template name="scape"> -->
<!--       <xsl:with-param name="string" select="substring(.,2)"/> -->
<!--     </xsl:call-template> -->
<!--   </xsl:when> -->
<!--   <xsl:otherwise> -->
<!--     <xsl:apply-imports/> -->
<!--   </xsl:otherwise> -->
<!--   </xsl:choose> -->
<!-- </xsl:template> -->

</xsl:stylesheet>
