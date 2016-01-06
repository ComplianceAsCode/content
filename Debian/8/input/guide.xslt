<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dc="http://purl.org/dc/elements/1.1/">

<!-- This transform assembles all fragments into one "shorthand" XCCDF document -->

  <xsl:template match="Benchmark">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />

      <!-- adding profiles here -->
          <!---
          <xsl:if test=" number($withtest) = number(0) ">
	       <xsl:apply-templates select="document('profiles/test.xml')" />
          </xsl:if>
          -->
          <xsl:apply-templates select="document('profiles/common.xml')" />

      <Value id="conditional_clause" type="string" operator="equals">
                <title>A conditional clause for check statements.</title>
                <description>A conditional clause for check statements.</description>
                <value>This is a placeholder.</value>
      </Value>
      
      <xsl:apply-templates select="document('intro/intro.xml')" />
      <xsl:apply-templates select="document('xccdf/system/system.xml')" />
      <xsl:apply-templates select="document('xccdf/system/permissions/permissions.xml')" />
      <xsl:apply-templates select="document('xccdf/services/services.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='system']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('xccdf/system/partitions.xml')" />
      <xsl:apply-templates select="document('xccdf/system/logging.xml')" />
      <xsl:apply-templates select="document('xccdf/system/permissions/files.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='services']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('xccdf/services/deprecated.xml')" />
      <xsl:apply-templates select="document('xccdf/services/basics.xml')" />
      <xsl:apply-templates select="document('xccdf/services/ssh.xml')" />
    </xsl:copy>
  </xsl:template>

  <!-- copy everything else through to final output -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    
</xsl:copy>
  </xsl:template>
</xsl:stylesheet>
