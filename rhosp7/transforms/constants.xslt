<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:include href="../../shared/transforms/shared_constants.xslt"/>

<xsl:variable name="product_long_name">Red Hat OpenStack Platform 7</xsl:variable>
<xsl:variable name="product_short_name">RHEL OSP 7</xsl:variable>
<xsl:variable name="product_stig_id_name">RHEL_OSP_7_STIG</xsl:variable>
<xsl:variable name="prod_type">osp7</xsl:variable>

<xsl:variable name="cisuri">empty</xsl:variable>
<xsl:variable name="product_guide_id_name">RHEL-7-OSP</xsl:variable>
<xsl:variable name="platform_cpes">cpe:/o:redhat:enterprise_linux:7,cpe:/o:redhat:enterprise_linux:7::client,cpe:/o:redhat:enterprise_linux:7::computenode</xsl:variable>
<xsl:variable name="disa-stigs-uri" select="$disa-stigs-os-unix-linux-uri"/>
<xsl:variable name="os-stigid-concat" />

<!-- Define URI for custom CCE identifier which can be used for mapping to corporate policy -->
<!--xsl:variable name="custom-cce-uri">https://www.example.org</xsl:variable-->

<!-- Define URI for custom policy reference which can be used for linking to corporate policy -->
<!--xsl:variable name="custom-ref-uri">https://www.example.org</xsl:variable-->

</xsl:stylesheet>
