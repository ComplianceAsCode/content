<?xml version="1.0"?>
<!--
	Used by compare_generated.sh
	Output is sorted document with important oval entities - easier to compare
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cat="urn:oasis:names:tc:entity:xmlns:xml:catalog" xmlns:ds="http://scap.nist.gov/schema/scap/source/1.2" xmlns:ind="http://oval.mitre.org/XMLSchema/oval-definitions-5#independent" xmlns:linux="http://oval.mitre.org/XMLSchema/oval-definitions-5#linux" xmlns:oval="http://oval.mitre.org/XMLSchema/oval-common-5" xmlns:unix="http://oval.mitre.org/XMLSchema/oval-definitions-5#unix" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.2" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:oval-def="http://oval.mitre.org/XMLSchema/oval-definitions-5">

	<xsl:output method="xml" indent="yes" />
	<xsl:template match="@*|node()">
		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template name="show-entity">
		<xsl:param name="selector" />
		<xsl:param name="description" />
		<xsl:param name="component-id" />
		<xsl:for-each select="$selector">
			<xsl:sort select="concat(name(.),@id)" data-type="text" order="ascending" />
			<xsl:comment>..........<xsl:value-of select="$description" />: <xsl:value-of select="translate($component-id,'-','_')" />/<xsl:value-of select="@id" /> ........... </xsl:comment>
			<xsl:copy-of select="." />
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="/">
		<oval-entities>
			<xsl:for-each select="//oval-def:oval_definitions">
				<xsl:sort select="../@id" data-type="text" order="ascending" />

				<xsl:call-template name="show-entity">
					<xsl:with-param name="selector" select="oval-def:definitions/*"></xsl:with-param>
					<xsl:with-param name="description">Definition</xsl:with-param>
					<xsl:with-param name="component-id" select="../@id"></xsl:with-param>
				</xsl:call-template>

				<xsl:call-template name="show-entity">
					<xsl:with-param name="selector" select="oval-def:tests/*"></xsl:with-param>
					<xsl:with-param name="description">Test</xsl:with-param>
					<xsl:with-param name="component-id" select="../@id"></xsl:with-param>
				</xsl:call-template>

				<xsl:call-template name="show-entity">
					<xsl:with-param name="selector" select="oval-def:objects/*"></xsl:with-param>
					<xsl:with-param name="description">Object</xsl:with-param>
					<xsl:with-param name="component-id" select="../@id"></xsl:with-param>
				</xsl:call-template>

				<xsl:call-template name="show-entity">
					<xsl:with-param name="selector" select="oval-def:states/*"></xsl:with-param>
					<xsl:with-param name="description">State</xsl:with-param>
					<xsl:with-param name="component-id" select="../@id"></xsl:with-param>
				</xsl:call-template>

				<xsl:call-template name="show-entity">
					<xsl:with-param name="selector" select="oval-def:variables/*"></xsl:with-param>
					<xsl:with-param name="description">Variable</xsl:with-param>
					<xsl:with-param name="component-id" select="../@id"></xsl:with-param>
				</xsl:call-template>

			</xsl:for-each>
		</oval-entities>
	</xsl:template>
</xsl:stylesheet>
