<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- This file is used to hold the style element shared by transforms which
     produce HTML tables -->

<xsl:template name="table-style">
	<style type="text/css">
		table
		{
			border-collapse:collapse;
		}
		table,th, td
		{
			border: 1px solid black;
			vertical-align: top;
			padding: 3px;
		}
		thead
		{
			display: table-header-group;
			font-weight: bold;
		}
	</style>
</xsl:template>

     
</xsl:stylesheet>
