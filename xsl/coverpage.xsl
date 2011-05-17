<?xml version='1.0' encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl"
                version='1.0'>

  <!-- <xsl:param name="doc.layout">coverpage toc mainmatter index </xsl:param> -->

  <!-- The cover image is extracted from abstract -->
  <xsl:template match="abstract" mode="docinfo">
    <xsl:call-template name="coverimage">
      <xsl:with-param name="image" select=".//imagedata/@fileref"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="coverimage">
    <xsl:param name="image" select="."/>
    <xsl:text>\renewcommand{\maketitle}{%&#10;</xsl:text>
    <xsl:text>\begin{titlingpage}&#10;</xsl:text>
    <xsl:text>\includegraphics[height=\textheight,keepaspectratio=true]{</xsl:text>
    <xsl:value-of select="$image"/>
    <xsl:text>}&#10;</xsl:text>
    <xsl:text>\end{titlingpage}&#10;</xsl:text>
    <xsl:text>}%&#10;</xsl:text>
  </xsl:template>

  <!-- Don't show the same picture in the abstract -->
  <xsl:template match="abstract/para[mediaobject]"/>

</xsl:stylesheet>
