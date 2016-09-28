<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xccdf">

 <xsl:template name="find-and-replace">
   <xsl:param name="text"/>
   <xsl:param name="replace"/>
   <xsl:param name="with"/>
   <xsl:choose>
     <xsl:when test="contains($text,$replace)">
       <xsl:value-of select="substring-before($text,$replace)"/>
       <xsl:value-of select="$with"/>
       <xsl:call-template name="find-and-replace">
         <xsl:with-param name="text" select="substring-after($text,$replace)"/>
         <xsl:with-param name="replace" select="$replace"/>
         <xsl:with-param name="with" select="$with"/>
       </xsl:call-template>
     </xsl:when>
     <xsl:otherwise>
       <xsl:value-of select="$text" />
     </xsl:otherwise>
   </xsl:choose>
 </xsl:template>

 <xsl:template match="xccdf:fix/text()">
   <xsl:variable name="ident_cce" select="../../xccdf:ident[@system='https://nvd.nist.gov/cce/index.cfm']/text()"/>
   <xsl:choose>
   <xsl:when test="contains(., '$CCENUM')">
     <xsl:call-template name="find-and-replace">
       <xsl:with-param name="text" select="."/>
       <xsl:with-param name="replace" select="'$CCENUM'"/>
       <xsl:with-param name="with" select="$ident_cce"/>
     </xsl:call-template>
   </xsl:when>
   <xsl:otherwise>
     <xsl:value-of select="."/>
   </xsl:otherwise>
   </xsl:choose>
 </xsl:template>

 <xsl:template match="@*|node()">
   <xsl:copy>
     <xsl:apply-templates select="@*|node()" />
   </xsl:copy>
 </xsl:template>

</xsl:stylesheet>
