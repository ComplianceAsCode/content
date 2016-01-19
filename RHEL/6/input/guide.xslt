<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dc="http://purl.org/dc/elements/1.1/">

<!-- This transform assembles all fragments into one "shorthand" XCCDF document -->
<!-- An optional parameter "withtest 0" specifies whether the 'test' profile should
     be included into the benchmark. -->

  <xsl:template match="Benchmark">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />

       <!-- adding profiles here -->
		<xsl:if test=" number($withtest) = number(0) ">
			<xsl:apply-templates select="document('profiles/test.xml')" />
		</xsl:if>
		<xsl:apply-templates select="document('profiles/standard.xml')" />
		<xsl:apply-templates select="document('profiles/CS2.xml')" />
		<xsl:apply-templates select="document('profiles/common.xml')" />
		<!-- <xsl:apply-templates select="document('profiles/desktop.xml')" /> -->
		<xsl:apply-templates select="document('profiles/server.xml')" />
		<!-- <xsl:apply-templates select="document('profiles/ftp.xml')" /> -->
		<xsl:apply-templates select="document('profiles/stig-rhel6-server-upstream.xml')" />
		<xsl:apply-templates select="document('profiles/usgcb-rhel6-server.xml')" />
		<xsl:apply-templates select="document('profiles/rht-ccp.xml')" />
		<xsl:apply-templates select="document('profiles/CSCF-RHEL6-MLS.xml')" />
		<xsl:apply-templates select="document('profiles/C2S.xml')" />
		<xsl:apply-templates select="document('profiles/pci-dss.xml')" />
		<xsl:apply-templates select="document('profiles/nist-CL-IL-AL.xml')" />

       <Value id="conditional_clause" type="string" operator="equals">
                 <title>A conditional clause for check statements.</title>
                 <description>A conditional clause for check statements.</description>
                 <value>This is a placeholder.</value>
       </Value>
      <xsl:apply-templates select="document('intro/intro.xml')" />
      <xsl:apply-templates select="document('xccdf/system/system.xml')" />
      <xsl:apply-templates select="document('xccdf/services/services.xml')" />
      <!-- the auxiliary Groups here will be removed prior to some outputs -->
      <xsl:apply-templates select="document('auxiliary/srg_support.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='system']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('xccdf/system/entropy.xml')" />
      <xsl:apply-templates select="document('xccdf/system/software/software.xml')" />
      <xsl:apply-templates select="document('xccdf/system/permissions/permissions.xml')" />
      <xsl:apply-templates select="document('xccdf/system/selinux.xml')" />
      <xsl:apply-templates select="document('xccdf/system/accounts/accounts.xml')" />
      <xsl:apply-templates select="document('xccdf/system/network/network.xml')" />
      <xsl:apply-templates select="document('xccdf/system/logging.xml')" />
      <xsl:apply-templates select="document('xccdf/system/auditing.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='software']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('xccdf/system/software/disk_partitioning.xml')" />
      <xsl:apply-templates select="document('xccdf/system/software/updating.xml')" />
      <xsl:apply-templates select="document('xccdf/system/software/integrity.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='accounts']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('xccdf/system/accounts/restrictions/restrictions.xml')" />
      <xsl:apply-templates select="document('xccdf/system/accounts/pam.xml')" />
      <xsl:apply-templates select="document('xccdf/system/accounts/session.xml')" />
      <xsl:apply-templates select="document('xccdf/system/accounts/physical.xml')" />
      <xsl:apply-templates select="document('xccdf/system/accounts/banners.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='accounts-restrictions']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('xccdf/system/accounts/restrictions/root_logins.xml')" />
      <xsl:apply-templates select="document('xccdf/system/accounts/restrictions/password_storage.xml')" />
      <xsl:apply-templates select="document('xccdf/system/accounts/restrictions/password_expiration.xml')" />
      <xsl:apply-templates select="document('xccdf/system/accounts/restrictions/account_expiration.xml')" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='permissions']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('xccdf/system/permissions/partitions.xml')" />
      <xsl:apply-templates select="document('xccdf/system/permissions/mounting.xml')" />
      <xsl:apply-templates select="document('xccdf/system/permissions/files.xml')" />
      <xsl:apply-templates select="document('xccdf/system/permissions/execution.xml')" />
    </xsl:copy>
  </xsl:template>


  <xsl:template match="Group[@id='network']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('xccdf/system/network/kernel.xml')" />
      <xsl:apply-templates select="document('xccdf/system/network/wireless.xml')" />
      <xsl:apply-templates select="document('xccdf/system/network/ipv6.xml')" />
      <xsl:apply-templates select="document('xccdf/system/network/iptables.xml')" />
      <xsl:apply-templates select="document('xccdf/system/network/ssl.xml')" />
      <xsl:apply-templates select="document('xccdf/system/network/uncommon.xml')" />
      <xsl:apply-templates select="document('xccdf/system/network/ipsec.xml')" />
    </xsl:copy>
  </xsl:template>



  <xsl:template match="Group[@id='services']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document('xccdf/services/obsolete.xml')" />
      <xsl:apply-templates select="document('xccdf/services/base.xml')" />
      <xsl:apply-templates select="document('xccdf/services/cron.xml')" />
      <xsl:apply-templates select="document('xccdf/services/ssh.xml')" />
      <xsl:apply-templates select="document('xccdf/services/xorg.xml')" />
      <xsl:apply-templates select="document('xccdf/services/avahi.xml')" />
      <xsl:apply-templates select="document('xccdf/services/printing.xml')" />
      <xsl:apply-templates select="document('xccdf/services/dhcp.xml')" />
      <xsl:apply-templates select="document('xccdf/services/ntp.xml')" />
      <xsl:apply-templates select="document('xccdf/services/mail.xml')" />
      <xsl:apply-templates select="document('xccdf/services/ldap.xml')" />
      <xsl:apply-templates select="document('xccdf/services/nfs.xml')" />
      <xsl:apply-templates select="document('xccdf/services/dns.xml')" />
      <xsl:apply-templates select="document('xccdf/services/ftp.xml')" />
      <xsl:apply-templates select="document('xccdf/services/http.xml')" />
      <xsl:apply-templates select="document('xccdf/services/imap.xml')" />
      <xsl:apply-templates select="document('xccdf/services/smb.xml')" />
      <xsl:apply-templates select="document('xccdf/services/squid.xml')" />
      <xsl:apply-templates select="document('xccdf/services/snmp.xml')" />
    </xsl:copy>
  </xsl:template>

  <!-- copy everything else through to final output -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
