<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dc="http://purl.org/dc/elements/1.1/">

<!-- This transform assembles all fragments into one "shorthand" XCCDF document
     Accepts the following parameters:

     * SHARED_RP    (required)  Holds the resolved ABSOLUTE path
                    to the SSG's "shared/" directory.
     * BUILD_RP     (required)  Holds the resolved ABSOLUTE path
                    to the SSG's build directory - $CMAKE_BINARY_PATH
-->

<xsl:param name="SHARED_RP" select='undef' />
<xsl:param name="BUILD_RP" select='undef' />

  <xsl:template match="Benchmark">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />

      <!-- Adding profiles here -->
      <xsl:apply-templates select="document('profiles/stig-chromium-upstream.xml')" />

      <!-- Adding 'conditional_clause' placeholder <xccdf:Value> here -->
      <Value id="conditional_clause" type="string" operator="equals">
        <title>A conditional clause for check statements.</title>
        <description>A conditional clause for check statements.</description>
        <value>This is a placeholder.</value>
      </Value>

      <xsl:apply-templates select="document(concat($BUILD_RP, '/bash-remediation-functions.xml'))" />

      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/remediation_functions.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/intro/shared_intro_app.xml'))" />
      <xsl:apply-templates select="document('xccdf/chromium.xml')" />
    </xsl:copy>
  </xsl:template>
  
  <!-- copy everything else through to final output -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
