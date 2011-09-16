<?xml version='1.0' encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl"
                version='1.0'>

  <!-- Dropped capitals -->

<!-- Catch nodes having text() in the first para of a section -->
  <!-- At the para level:
       if the node is directly a text() starting the para, or
       if the node is an element containing text() that is not preceded
       by nodes having text
    -->
  <xsl:template match="para[preceding-sibling::*[1]
                       [self::title or self::titleabbrev]]//text()
                       [normalize-space()]">
    <xsl:choose>
      
      <xsl:when test="(parent::para and position()=1 and not(ancestor::*[parent::footnote])) or
                      (ancestor::*[parent::para][
                      not(preceding-sibling::*//text()[normalize-space()]) and
                      not(preceding-sibling::text()[normalize-space()])])">
        
        <xsl:text>\lettrine[lines=2]{</xsl:text>
        <xsl:call-template name="scape">
          <xsl:with-param name="string" select="substring(.,1,1)"/>
        </xsl:call-template>
        <xsl:text>}{}</xsl:text>
        <xsl:call-template name="scape">
          <xsl:with-param name="string" select="substring(.,2)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-imports/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


</xsl:stylesheet>
