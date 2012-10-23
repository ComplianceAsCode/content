<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<!-- this transform inserts a counter into the first column, as Vuln-ID placeholder -->
<!-- a unique Vuln-ID is assigned on a per-description basis (td[5]) -->

<xsl:key name="rows-by-title" match="tr" use="td[5]" />

<xsl:template match="table/tr/td[1]" >
	<!-- this (possibly witchcraft) will go away as soon as oscap's xccdf resolve works -->
	<!-- see stackoverflow.com question 941662 for explanation -->
	<td>V-<xsl:value-of select="count(
					(.. | ../preceding-sibling::tr)[
	              count(. | key('rows-by-title', td[5])[1]) = 1
	                    ])" /> </td>
</xsl:template>


<xsl:template match="@*|node()" >
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
