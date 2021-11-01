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

  <!-- expand reference to OVAL ID inside single complex-check -->
  <xsl:template match="Rule/complex-check/oval">
    <xsl:choose>
      <xsl:when test="contains(@prodtype, $prod_type) or @prodtype = 'all' or not(@prodtype)">
        <check>
          <xsl:attribute name="system">
            <xsl:value-of select="$ovaluri" />
          </xsl:attribute>

          <xsl:for-each select="@*">
          <xsl:choose>
          <xsl:when test="contains(name(),'value')">
            <check-export>
              <xsl:attribute name="export-name">
                <xsl:value-of select="." />
              </xsl:attribute>
              <xsl:attribute name="value-id">
                <xsl:value-of select="." />
              </xsl:attribute>
            </check-export>
          </xsl:when>
          </xsl:choose>
          </xsl:for-each>

          <check-content-ref>
            <xsl:attribute name="href">
              <xsl:value-of select="'oval-unlinked.xml'" />
            </xsl:attribute>
            <xsl:attribute name="name">
              <xsl:value-of select="@id" />
            </xsl:attribute>
          </check-content-ref>
        </check>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- expand reference to OVAL ID inside double complex-check (e.g., OCIL + SCE + OVAL) -->
  <xsl:template match="Rule/complex-check/complex-check/oval">
    <xsl:choose>
      <xsl:when test="contains(@prodtype, $prod_type) or @prodtype = 'all' or not(@prodtype)">
        <check>
          <xsl:attribute name="system">
            <xsl:value-of select="$ovaluri" />
          </xsl:attribute>

          <xsl:for-each select="@*">
          <xsl:choose>
          <xsl:when test="contains(name(),'value')">
            <check-export>
              <xsl:attribute name="export-name">
                <xsl:value-of select="." />
              </xsl:attribute>
              <xsl:attribute name="value-id">
                <xsl:value-of select="." />
              </xsl:attribute>
            </check-export>
          </xsl:when>
          </xsl:choose>
          </xsl:for-each>

          <check-content-ref>
            <xsl:attribute name="href">
              <xsl:value-of select="'oval-unlinked.xml'" />
            </xsl:attribute>
            <xsl:attribute name="name">
              <xsl:value-of select="@id" />
            </xsl:attribute>
          </check-content-ref>
        </check>
      </xsl:when>
    </xsl:choose>
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
