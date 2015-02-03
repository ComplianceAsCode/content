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
      <xsl:apply-templates select="document('system/software/software.xml')" />
      <xsl:apply-templates select="document('system/permissions/permissions.xml')" />
      <xsl:apply-templates select="document('system/accounts/accounts.xml')" />
      <xsl:apply-templates select="document('system/network/network.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='software']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('system/software/updating.xml')" />
      <xsl:apply-templates select="document('system/software/integrity.xml')" />
    </xsl:copy>
  </xsl:template>


  <xsl:template match="Group[@id='accounts']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('system/accounts/restrictions/restrictions.xml')" />
      <xsl:apply-templates select="document('system/accounts/session.xml')" />
      <xsl:apply-templates select="document('system/accounts/pam.xml')" />
      <xsl:apply-templates select="document('system/accounts/physical.xml')" />
      <xsl:apply-templates select="document('system/accounts/banners.xml')" />
    </xsl:copy>
  </xsl:template>


  <xsl:template match="Group[@id='accounts-restrictions']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('system/accounts/restrictions/root_logins.xml')" />
      <xsl:apply-templates select="document('system/accounts/restrictions/password_storage.xml')" />
      <xsl:apply-templates select="document('system/accounts/restrictions/password_expiration.xml')" />
     <!--  <xsl:apply-templates select="document('system/accounts/restrictions/account_expiration.xml')" /> -->
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='permissions']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('system/permissions/mounting.xml')" />
      <xsl:apply-templates select="document('system/permissions/files.xml')" />
      <xsl:apply-templates select="document('system/permissions/execution.xml')" /> 
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='network']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('system/network/kernel.xml')" />
      <xsl:apply-templates select="document('system/network/wireless.xml')" />
      <xsl:apply-templates select="document('system/network/ipv6.xml')" />
      <xsl:apply-templates select="document('system/network/iptables.xml')" />
      <xsl:apply-templates select="document('system/network/ssl.xml')" />
      <xsl:apply-templates select="document('system/network/uncommon.xml')" />
      <xsl:apply-templates select="document('system/network/ipsec.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='services']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('services/ssh.xml')" />
      <xsl:apply-templates select="document('services/ntp.xml')" />
      <xsl:apply-templates select="document('services/ftp.xml')" />
      <xsl:apply-templates select="document('services/snmp.xml')" />
      <xsl:apply-templates select="document('services/nfs.xml')" />
    </xsl:copy>
  </xsl:template>

  <!-- copy everything else through to final output -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
