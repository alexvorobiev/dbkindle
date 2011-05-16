<?xml version='1.0' encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl"
                version='1.0'>

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


</xsl:stylesheet>
