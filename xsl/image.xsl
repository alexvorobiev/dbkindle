<?xml version='1.0' encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl"
                version='1.0'>

  <!-- Images narrower than this portion of line width will be surrounded by text -->
  <xsl:param name="wrapimage.threshold">0.4</xsl:param> 
  
  <xsl:template match="mediaobject">
    <xsl:call-template name="processimage">
      <xsl:with-param name="image" select="./imageobject/imagedata/@fileref"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="figure">
    <xsl:call-template name="processimage">
      <xsl:with-param name="image" select="./mediaobject/imageobject/imagedata/@fileref"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="processimage">
    <xsl:param name="image" select="."/>
    <xsl:text>\wrapifneeded{</xsl:text><xsl:value-of select="$wrapimage.threshold"/>
    <xsl:text>}{</xsl:text><xsl:value-of select="$image"/><xsl:text>} %&#10;</xsl:text>
  </xsl:template>

</xsl:stylesheet>