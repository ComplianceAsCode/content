<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:include href="../../shared/transforms/shared_constants.xslt"/>

<xsl:variable name="product_long_name">Red Hat Enterprise Linux 7</xsl:variable>
<xsl:variable name="product_short_name">RHEL 7</xsl:variable>
<xsl:variable name="product_stig_id_name">RHEL_7_STIG</xsl:variable>
<xsl:variable name="product_guide_id_name">RHEL-7</xsl:variable>
<xsl:variable name="platform_cpes">cpe:/o:redhat:enterprise_linux:7,cpe:/o:redhat:enterprise_linux:7::client,cpe:/o:redhat:enterprise_linux:7::computenode</xsl:variable>
<xsl:variable name="prod_type">rhel7</xsl:variable>


<!-- Define URI of official CIS Red Hat Enterprise Linux 7 Benchmark -->
<xsl:variable name="cisuri">https://benchmarks.cisecurity.org/tools2/linux/CIS_Red_Hat_Enterprise_Linux_7_Benchmark_v1.1.0.pdf</xsl:variable>
<xsl:variable name="disa-stigs-uri" select="$disa-stigs-os-unix-linux-uri"/>
<xsl:variable name="os-stigid-concat">RHEL-07-</xsl:variable>

<!-- Define URI for custom CCE identifier which can be used for mapping to corporate policy -->
<!--xsl:variable name="custom-cce-uri">https://www.example.org</xsl:variable-->

<!-- Define URI for custom policy reference which can be used for linking to corporate policy -->
<!--xsl:variable name="custom-ref-uri">https://www.example.org</xsl:variable-->

</xsl:stylesheet>
