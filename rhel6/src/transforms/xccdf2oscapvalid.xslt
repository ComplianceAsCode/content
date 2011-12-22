<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
exclude-result-prefixes="xccdf">


  <!-- need to fix this so that it re-orders the elements instead of just removing them -->
  <xsl:template match="xccdf:reference"/>
  <xsl:template match="xccdf:rationale"/>
  <xsl:template match="xhtml:code"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
