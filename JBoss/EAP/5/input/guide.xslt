<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dc="http://purl.org/dc/elements/1.1/">

<!-- This transform assembles all fragments into one "shorthand" XCCDF document
     Accepts the following parameters:

     * SHARED_RP	(required)	Holds the resolved ABSOLUTE path
					to the SSG's "shared/" directory.
-->

<!-- Define the default value of the required "SHARED_RP" parameter -->
<xsl:param name="SHARED_RP" select='undef' />

  <xsl:template match="Benchmark">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />

       <!-- Adding profiles here -->
       <xsl:apply-templates select="document('profiles/stig-eap5-upstream.xml')" />

       <!-- Adding 'conditional_clause' placeholder <xccdf:Value> here -->
       <Value id="conditional_clause" type="string" operator="equals">
         <title>A conditional clause for check statements.</title>
         <description>A conditional clause for check statements.</description>
         <value>This is a placeholder.</value>
       </Value>

      <!-- Adding remediation functions from concat($SHARED_RP, '/xccdf/remediation_functions.xml')
           location here -->
      <xsl:if test=" string($SHARED_RP) != 'undef' ">
        <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/remediation_functions.xml'))" />
      </xsl:if>

      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/intro/shared_intro_app.xml'))" /> 
      <xsl:apply-templates select="document('xccdf/application/eap5.xml')" />
    </xsl:copy>
  </xsl:template>
 
  <xsl:template match="Group[@id='general-configuration']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('xccdf/application/general/general.xml')" />
      <xsl:apply-templates select="document('xccdf/application/general/secure_platform.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='deployed-applications']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('xccdf/application/deployed_applications.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='policy']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('xccdf/application/policy/architecture.xml')" />
      <xsl:apply-templates select="document('xccdf/application/policy/policy.xml')" />
      <xsl:apply-templates select="document('xccdf/application/policy/practices.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='trimming']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('xccdf/application/trimming.xml')" />
    </xsl:copy>
  </xsl:template>


  <!-- copy everything else through to final output -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
