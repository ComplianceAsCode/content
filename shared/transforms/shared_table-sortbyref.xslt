<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<!-- this transform sorts an HTML document with a table by its first column -->

<xsl:template match="table" >
	<table>
	<xsl:apply-templates> 
	<xsl:sort select="td" />
	</xsl:apply-templates> 
	</table>
</xsl:template>


<xsl:template match="@*|node()" >
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
