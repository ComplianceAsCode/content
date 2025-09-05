<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:include href="../../shared/transforms/shared_constants.xslt"/>

<xsl:variable name="product_long_name">SUSE Linux Enterprise 11</xsl:variable>
<xsl:variable name="product_short_name">SUSE 11</xsl:variable>
<xsl:variable name="product_stig_id_name">SUSE_11_STIG</xsl:variable>
<xsl:variable name="product_guide_id_name">SUSE-11</xsl:variable>
<xsl:variable name="prod_type">sle11</xsl:variable>

<!-- Define URI of official CIS SUSE Linux Enterprise 11 Benchmark -->
<xsl:variable name="cisuri"></xsl:variable>
<xsl:variable name="disa-stigs-uri" select="$disa-stigs-os-unix-linux-uri"/>

<!-- Define URI for custom CCE identifier which can be used for mapping to corporate policy -->
<!--xsl:variable name="custom-cce-uri">https://www.example.org</xsl:variable-->

<!-- Define URI for custom policy reference which can be used for linking to corporate policy -->
<!--xsl:variable name="custom-ref-uri">https://www.example.org</xsl:variable-->

</xsl:stylesheet>
