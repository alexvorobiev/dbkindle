<?xml version='1.0' encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl"
                version='1.0'>


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
  
</xsl:stylesheet>
