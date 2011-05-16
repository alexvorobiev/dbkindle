<?xml version='1.0' encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl"
                version='1.0'>

  <xsl:param name="doc.layout">frontmatter mainmatter index </xsl:param>

  <xsl:template match="abstract">
    <xsl:call-template name="coverimage">
      <xsl:with-param name="image" select=".//imagedata/@fileref"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="coverimage">
    <xsl:param name="image" select="."/>
    <xsl:text>\renewcommand{\maketitle}{%&#10;</xsl:text>

    <xsl:text>\begin{minipage}[c]{\linewidth}&#10;</xsl:text>
    <xsl:text>\begin{center}&#10;</xsl:text>
    <xsl:text>\imgexists{</xsl:text><xsl:value-of select="$image"/>
    <xsl:text>}{{\centering \imgevalsize{</xsl:text><xsl:value-of select="$image"/>
    <xsl:text>}{\includegraphics[width=\imgwidth,height=\imgheight,keepaspectratio=true]{</xsl:text>
    <xsl:value-of select="$image"/>
    <xsl:text>}}}}{}\end{center}&#10;</xsl:text>
    <xsl:text>\end{minipage}&#10;</xsl:text>
    
    <xsl:text>}%&#10;</xsl:text>
    <xsl:text>\maketitle&#10;</xsl:text>
  </xsl:template>


</xsl:stylesheet>
