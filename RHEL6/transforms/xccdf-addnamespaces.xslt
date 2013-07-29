<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1"
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:xhtml="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="xccdf dc xhtml">

  <!-- This transform places elements into the correct namespaces,
       so that content authors never have to bother with them. 
       XHTML elements are explicitly identified and the xhtml
       namespace is added.  Any element with an empty namespace
       is assigned to the xccdf namespace. -->

  <!-- table and list-related xhtml -->
  <xsl:template match="table | tr | th | td | ul | li | ol">
    <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>

  <!-- general formatting xhtml -->
  <xsl:template match="code | strong | b | em | i | pre | br | hr">
    <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>

  <!-- convert tt to code, which seems better-supported -->
  <xsl:template match="tt">
    <xhtml:code>
      <xsl:apply-templates select="@*|node()"/>
    </xhtml:code>
  </xsl:template>

  <!-- if no namespace is indicated, put into xccdf namespace-->
  <xsl:template match="*[namespace-uri()='']" priority="-1">
    <xsl:element name="{local-name()}" namespace="http://checklists.nist.gov/xccdf/1.1">
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>

  <!-- pass everything else through -->
  <xsl:template match="@*|node()" priority="-2">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
