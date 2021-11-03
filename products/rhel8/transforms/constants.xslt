<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:include href="../../../shared/transforms/shared_constants.xslt"/>

<xsl:variable name="product_long_name">Red Hat Enterprise Linux 8</xsl:variable>
<xsl:variable name="product_short_name">RHEL 8</xsl:variable>
<xsl:variable name="product_stig_id_name">RHEL_8_STIG</xsl:variable>
<xsl:variable name="prod_type">rhel8</xsl:variable>

<xsl:variable name="cisuri">https://www.cisecurity.org/benchmark/red_hat_linux/</xsl:variable>
<xsl:variable name="disa-srguri" select="$disa-ossrguri"/>

</xsl:stylesheet>
