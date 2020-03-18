<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:include href="../../shared/transforms/shared_constants.xslt"/>

<xsl:variable name="product_long_name">SUSE Linux Enterprise 15</xsl:variable>
<xsl:variable name="product_short_name">sle15</xsl:variable>
<xsl:variable name="product_stig_id_name">SLE_STIG</xsl:variable>
<xsl:variable name="product_guide_id_name">SLE-15</xsl:variable>
<xsl:variable name="prod_type">sle15</xsl:variable>

<!-- Define URI of official Center for Internet Security Benchmark for SUSE Linux Enterprise 15 -->
<xsl:variable name="cisuri">https://benchmarks.cisecurity.org/tools2/linux/CIS_SUSE Linux Enterprise_Benchmark_v1.0.pdf</xsl:variable>
<xsl:variable name="disa-stigs-uri" select="-stigs-os-unix-linux-uri"/>
<xsl:variable name="os-stigid-concat" />

<!-- Define URI for custom CCE identifier which can be used for mapping to corporate policy -->
<!--xsl:variable name="custom-cce-uri">https://www.example.org</xsl:variable-->

<!-- Define URI for custom policy reference which can be used for linking to corporate policy -->
<!--xsl:variable name="custom-ref-uri">https://www.example.org</xsl:variable-->

</xsl:stylesheet>
