<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dc="http://purl.org/dc/elements/1.1/">

<!-- This transform assembles all fragments into one "shorthand" XCCDF document -->

  <xsl:template match="Benchmark">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />

       <!-- adding profiles here -->
		<xsl:apply-templates select="document('profiles/test.xml')" />
		<xsl:apply-templates select="document('profiles/rht-ccp.xml')" />
		<xsl:apply-templates select="document('profiles/common.xml')" />
		<xsl:apply-templates select="document('profiles/stig-rhel7-server-upstream.xml')" />

       <Value id="conditional_clause" type="string" operator="equals">
                 <title>A conditional clause for check statements.</title>
                 <description>A conditional clause for check statements.</description>
                 <value>This is a placeholder.</value>
       </Value>
      <xsl:apply-templates select="document('intro/intro.xml')" />
      <xsl:apply-templates select="document('system/system.xml')" />
      <xsl:apply-templates select="document('services/services.xml')" />
      <!-- the auxiliary Groups here will be removed prior to some outputs -->
      <xsl:apply-templates select="document('auxiliary/srg_support.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='system']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('system/software/software.xml')" /> 
      <xsl:apply-templates select="document('system/permissions/permissions.xml')" />
      <xsl:apply-templates select="document('system/selinux.xml')" />
      <xsl:apply-templates select="document('system/accounts/accounts.xml')" />
      <xsl:apply-templates select="document('system/network/network.xml')" />
      <xsl:apply-templates select="document('system/logging.xml')" />
      <xsl:apply-templates select="document('system/auditing.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='software']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('system/software/disk_partitioning.xml')" />
      <xsl:apply-templates select="document('system/software/updating.xml')" />
      <xsl:apply-templates select="document('system/software/integrity.xml')" />
    </xsl:copy>
  </xsl:template>


  <xsl:template match="Group[@id='accounts']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('system/accounts/restrictions/restrictions.xml')" />
      <xsl:apply-templates select="document('system/accounts/pam.xml')" />
      <xsl:apply-templates select="document('system/accounts/session.xml')" />
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
      <xsl:apply-templates select="document('system/permissions/partitions.xml')" />
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
      <xsl:apply-templates select="document('services/obsolete.xml')" />
      <xsl:apply-templates select="document('services/base.xml')" />
      <xsl:apply-templates select="document('services/cron.xml')" />
      <xsl:apply-templates select="document('services/ssh.xml')" />
      <xsl:apply-templates select="document('services/xorg.xml')" />
      <xsl:apply-templates select="document('services/avahi.xml')" />
      <xsl:apply-templates select="document('services/printing.xml')" />
      <xsl:apply-templates select="document('services/dhcp.xml')" />
      <xsl:apply-templates select="document('services/ntp.xml')" />
      <xsl:apply-templates select="document('services/mail.xml')" />
      <xsl:apply-templates select="document('services/ldap.xml')" />
      <xsl:apply-templates select="document('services/nfs.xml')" />
      <xsl:apply-templates select="document('services/dns.xml')" />
      <xsl:apply-templates select="document('services/ftp.xml')" />
      <xsl:apply-templates select="document('services/http.xml')" />
      <xsl:apply-templates select="document('services/imap.xml')" />
      <xsl:apply-templates select="document('services/smb.xml')" />
      <xsl:apply-templates select="document('services/squid.xml')" />
      <xsl:apply-templates select="document('services/snmp.xml')" />
    </xsl:copy>
  </xsl:template>

  <!-- copy everything else through to final output -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>

