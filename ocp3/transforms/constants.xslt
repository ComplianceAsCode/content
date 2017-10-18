<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:include href="../../shared/transforms/shared_constants.xslt"/>

<xsl:variable name="product_long_name">Red Hat Enterprise OpenShift Container Platform 3</xsl:variable>
<xsl:variable name="product_short_name">OCP 3</xsl:variable>
<xsl:variable name="product_stig_id_name">OCP_3_STIG</xsl:variable>
<xsl:variable name="product_guide_id_name">OCP-3</xsl:variable>
<xsl:variable name="platform_cpes">cpe:/a:redhat:openshift:3.0,cpe:/a:redhat:openshift:3.1</xsl:variable>
<xsl:variable name="prod_type">OCP3</xsl:variable>


<!-- Define URI of official CIS Kubernetes Benchmark -->
<xsl:variable name="cisuri">https://benchmarks.cisecurity.org/tools2/virtualization/CIS_Kubernetes_Benchmark_v1.2.0.pdf</xsl:variable>
<xsl:variable name="disa-stigs-uri" select="$disa-stigs-os-unix-linux-uri"/>
<xsl:variable name="os-stigid-concat"></xsl:variable>

<!-- Define URI for custom CCE identifier which can be used for mapping to corporate policy -->
<!--xsl:variable name="custom-cce-uri">https://www.example.org</xsl:variable-->

<!-- Define URI for custom policy reference which can be used for linking to corporate policy -->
<!--xsl:variable name="custom-ref-uri">https://www.example.org</xsl:variable-->

</xsl:stylesheet>
