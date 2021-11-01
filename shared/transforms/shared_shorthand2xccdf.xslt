<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:date="http://exslt.org/dates-and-times" extension-element-prefixes="date"
  exclude-result-prefixes="xccdf xhtml dc">

  <!-- This transform takes a "shorthand" variant of XCCDF
       and expands its elements into proper XCCDF elements.
       It also assigns all elements into the proper namespace,
       whether it be xccdf, xhtml, or simply maintained from the
       input. -->

<xsl:variable name="defaultseverity" select="'low'" />

<!-- put elements created in this stylesheet into the xccdf namespace,
     if no namespace explicitly indicated -->
<xsl:namespace-alias result-prefix="xccdf" stylesheet-prefix="#default" />


  <xsl:template match="Benchmark">
    <xsl:element name="{local-name()}" namespace="http://checklists.nist.gov/xccdf/1.1">
        <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>

  <!-- if no namespace is indicated, put into xccdf namespace-->
  <xsl:template match="*[namespace-uri()='']" priority="-1">
    <xsl:element name="{local-name()}" namespace="http://checklists.nist.gov/xccdf/1.1">
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>

  <!-- identity transform: pass anything else through -->
  <xsl:template match="@*|node()" priority="-2">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
