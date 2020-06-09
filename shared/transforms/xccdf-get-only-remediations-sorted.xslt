<?xml version="1.0"?>
<!--
	Used by compare_remediations.sh
	Output is sorted document with fixes only - easier to compare
-->
<xsl:stylesheet version="1.0"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.2" xmlns:xhtml="http://www.w3.org/1999/xhtml"   exclude-result-prefixes="xccdf">
	<xsl:strip-space elements="*" />


<xsl:template name="fix-template">
	<xsl:param name="fix" />
	<xsl:param name="type" />
	<xsl:param name="id" />

	<xsl:comment>.......... RULE <xsl:value-of select="$id" /> .. <xsl:value-of select="$type"/> ...........</xsl:comment>
	<xccdf:Rule>
		<xsl:attribute name="id">
			<xsl:value-of select="$id" />
		</xsl:attribute>
		<xsl:copy-of  select="$fix" />
	</xccdf:Rule>
</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:apply-templates select="@*|node()"/>
	</xsl:template>

	<xsl:template match="/">
		<benchmark>

			<xsl:for-each select="//xccdf:fix[@system='urn:xccdf:fix:script:sh']">
				<xsl:sort select="../@id" data-type="text" order="ascending" />
				<xsl:call-template name="fix-template">
					<xsl:with-param name="fix"><xsl:value-of select="." /></xsl:with-param>
					<xsl:with-param name="id"><xsl:value-of select="../@id" /></xsl:with-param>
					<xsl:with-param name="type">BASH</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>

			<xsl:for-each select="//xccdf:fix[@system='urn:xccdf:fix:script:ansible']">
				<xsl:sort select="../@id" data-type="text" order="ascending" />
				<xsl:call-template name="fix-template">
					<xsl:with-param name="fix"><xsl:value-of select="." /></xsl:with-param>
					<xsl:with-param name="id"><xsl:value-of select="../@id" /></xsl:with-param>
					<xsl:with-param name="type">ANSIBLE</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>

			<xsl:for-each select="//xccdf:fix[@system='urn:redhat:anaconda:pre']">
				<xsl:sort select="../@id" data-type="text" order="ascending" />
				<xsl:call-template name="fix-template">
					<xsl:with-param name="fix"><xsl:value-of select="." /></xsl:with-param>
					<xsl:with-param name="id"><xsl:value-of select="../@id" /></xsl:with-param>
					<xsl:with-param name="type">ANACONDA</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>

			<xsl:for-each select="//xccdf:fix[@system='urn:xccdf:fix:script:ignition']">
				<xsl:sort select="../@id" data-type="text" order="ascending" />
				<xsl:call-template name="fix-template">
					<xsl:with-param name="fix"><xsl:value-of select="." /></xsl:with-param>
					<xsl:with-param name="id"><xsl:value-of select="../@id" /></xsl:with-param>
					<xsl:with-param name="type">IGNITION</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>

			<xsl:for-each select="//xccdf:fix[@system='urn:xccdf:fix:script:kubernetes']">
				<xsl:sort select="../@id" data-type="text" order="ascending" />
				<xsl:call-template name="fix-template">
					<xsl:with-param name="fix"><xsl:value-of select="." /></xsl:with-param>
					<xsl:with-param name="id"><xsl:value-of select="../@id" /></xsl:with-param>
					<xsl:with-param name="type">KUBERNETES</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
		</benchmark>
	</xsl:template>


</xsl:stylesheet>
