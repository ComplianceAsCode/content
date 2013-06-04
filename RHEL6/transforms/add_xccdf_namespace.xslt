<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- Add the XCCDF 1.1 namespace to all elements without namespace. -->
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[namespace-uri()='']">
		<xsl:element name="{local-name()}" namespace="http://checklists.nist.gov/xccdf/1.1">
			<xsl:apply-templates select="node()|@*" />
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
