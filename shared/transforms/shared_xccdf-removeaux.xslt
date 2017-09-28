<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xccdf">

<!-- This transform removes Groups from the XCCDF document.  In general, these
     are expected to be Groups added from files in the overlays/
     directory.  -->


  <!-- remove the srg_support Group from final output, as it exists only to
       support the OS SRG mapping -->
  <xsl:template match="xccdf:Group[@id='srg_support']" />


  <!-- copy everything else through to final output -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
