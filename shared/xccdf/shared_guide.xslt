<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dc="http://purl.org/dc/elements/1.1/">

  <xsl:template match="Group[@id='system']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/software/software.xml'))" /> 
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/permissions/permissions.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/selinux.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/accounts/accounts.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/network/network.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/logging.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/auditing.xml'))" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='software']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/software/disk_partitioning.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/software/updating.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/software/integrity.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/software/gnome.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/software/sudo.xml'))" />
    </xsl:copy>
  </xsl:template>


  <xsl:template match="Group[@id='accounts']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/accounts/restrictions/restrictions.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/accounts/pam.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/accounts/session.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/accounts/physical.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/accounts/banners.xml'))" />
    </xsl:copy>
  </xsl:template>


  <xsl:template match="Group[@id='accounts-restrictions']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/accounts/restrictions/root_logins.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/accounts/restrictions/password_storage.xml'))" /> 
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/accounts/restrictions/password_expiration.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/accounts/restrictions/account_expiration.xml'))" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='permissions']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/permissions/partitions.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/permissions/mounting.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/permissions/files.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/permissions/execution.xml'))" /> 
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='network']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/network/kernel.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/network/wireless.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/network/ipv6.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/network/firewalld.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/network/ssl.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/network/uncommon.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/system/network/ipsec.xml'))" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Group[@id='services']">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/obsolete.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/base.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/cron.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/docker.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/ssh.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/sssd.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/xorg.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/avahi.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/printing.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/dhcp.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/ntp.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/mail.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/ldap.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/nfs.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/dns.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/ftp.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/http.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/imap.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/quagga.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/smb.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/squid.xml'))" />
      <xsl:apply-templates select="document(concat($SHARED_RP, '/xccdf/services/snmp.xml'))" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

