<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dc="http://purl.org/dc/elements/1.1/">

  <xsl:template match="Benchmark">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
       <!-- adding profiles here -->
		<xsl:apply-templates select="document('profiles/stig-chromium-upstream.xml')" />
       <Value id="conditional_clause" type="string" operator="equals">
                 <title>A conditional clause for check statements.</title>
                 <description>A conditional clause for check statements.</description>
                 <value>This is a placeholder.</value>
       </Value>

      <xsl:apply-templates select="document('intro/intro.xml')" /> 
      <xsl:apply-templates select="document('application/chromium.xml')" />
    </xsl:copy>
  </xsl:template>
  
  <!-- copy everything else through to final output -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
