<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:include href="../../../../shared/transforms/shared_constants.xslt"/>

<xsl:variable name="product_long_name">JBoss EAP 5</xsl:variable>
<xsl:variable name="product_short_name">EAP 5</xsl:variable>
<xsl:variable name="product_stig_id_name">EAP_5_STIG</xsl:variable>
<xsl:variable name="prod_type">eap5</xsl:variable>

<xsl:variable name="cisuri">empty</xsl:variable>
<xsl:variable name="product_guide_id_name">Jboss-EAP-5</xsl:variable>
<xsl:variable name="platform_cpes">cpe:/a:redhat:jboss_enterprise_application_platform:5.0.0,cpe:/a:redhat:jboss_enterprise_application_platform:5.0.1,cpe:/a:redhat:jboss_enterprise_application_platform:5.1.0,cpe:/a:redhat:jboss_enterprise_application_platform:5.1.1,cpe:/a:redhat:jboss_enterprise_application_platform:5.1.2</xsl:variable>
<xsl:variable name="disa-stigs-uri" select="$disa-stigs-apps-appserver-uri"/>
<xsl:variable name="os-stigid-concat" />

<!-- Define URI for custom CCE identifier which can be used for mapping to corporate policy -->
<!--xsl:variable name="custom-cce-uri">https://www.example.org</xsl:variable-->

<!-- Define URI for custom policy reference which can be used for linking to corporate policy -->
<!--xsl:variable name="custom-ref-uri">https://www.example.org</xsl:variable-->

</xsl:stylesheet>
