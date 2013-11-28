<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dc="http://purl.org/dc/elements/1.1/">

<!-- This transform assembles all fragments into one "shorthand" XCCDF document -->

  <xsl:template match="Benchmark">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />

      <!-- adding profiles here -->
      <xsl:apply-templates select="document('profiles/common.xml')" />

      <Value id="conditional_clause" type="string" operator="equals">
                <title>A conditional clause for check statements.</title>
                <description>A conditional clause for check statements.</description>
                <value>This is a placeholder.</value>
      </Value>
      <xsl:apply-templates select="document('intro/intro.xml')" />
      <xsl:apply-templates select="document('system/system.xml')" />
      <xsl:apply-templates select="document('services/services.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='system']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('system/settings/settings.xml')" />
      <xsl:apply-templates select="document('system/software/software.xml')" />
      <xsl:apply-templates select="document('system/permissions/permissions.xml')" />
      <xsl:apply-templates select="document('system/accounts/accounts.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='settings']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('system/settings/disable_prelink.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='software']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('system/software/updating.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='accounts']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('system/accounts/restrictions/restrictions.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='accounts-restrictions']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('system/accounts/restrictions/root_logins.xml')" />
      <xsl:apply-templates select="document('system/accounts/restrictions/password_storage.xml')" />
      <xsl:apply-templates select="document('system/accounts/restrictions/password_expiration.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='permissions']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('system/permissions/files.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='services']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('services/ntp.xml')" />
      <xsl:apply-templates select="document('services/ssh.xml')" />
    </xsl:copy>
  </xsl:template>

  <!-- copy everything else through to final output -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
