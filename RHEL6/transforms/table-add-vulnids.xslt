<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<!-- this transform inserts a counter into the first column, as Vuln-ID placeholder -->

<xsl:template match="table/tr/td[1]" >
	<td>V-<xsl:value-of select="count(../preceding-sibling::*)"/></td>
</xsl:template>


<xsl:template match="@*|node()" >
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
