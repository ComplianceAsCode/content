<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xccdf">

<!-- This transform transforms that project's main XCCDF content 
     into the format expected in a DISA STIG. -->


<xsl:include href="constants.xslt"/>


  <xsl:template match="xccdf:Rule">
    <xsl:copy>
	  <!-- deal with oscap element ordering pickiness -->
      <xsl:apply-templates select="@*|node()[not(self::xccdf:rationale|self::xccdf:ident|self::xccdf:check|self::xccdf:fix)]"/>
	    <!-- insert CCI 336 if no other CCI is referenced --> 
        <xsl:if test="not(xccdf:reference[@href=$disa-cciuri])">
          <xsl:element name="reference" namespace="http://checklists.nist.gov/xccdf/1.1">
          <xsl:attribute name="href"><xsl:value-of select="$disa-cciuri"/></xsl:attribute>
          <xsl:text>366</xsl:text>
          </xsl:element>
        </xsl:if>

      <xsl:apply-templates select="node()[self::xccdf:rationale|self::xccdf:ident|self::xccdf:check|self::xccdf:fix]"/>
    </xsl:copy>
  </xsl:template>


  <!-- copy everything else through to final output -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
