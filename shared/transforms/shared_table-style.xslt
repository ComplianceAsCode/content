<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- This file is used to hold the style element shared by transforms which
     produce HTML tables -->

<xsl:template name="table-style">
	<style type="text/css">
		table
		{
			border-collapse:collapse;
		}
		table, th, td
		{
			border: 2px solid #dcdcdc;
			border-left: none;
			border-right: none;
			vertical-align: top;
			padding: 2px;
			font-family: verdana,arial,sans-serif;
			font-size:11px;
		}
		pre { 
			white-space: pre-wrap;
			white-space: -moz-pre-wrap !important;
			word-wrap:break-word; 
		}
		table tr:nth-child(2n+2) { background-color: #f4f4f4; }
		thead
		{
			display: table-header-group;
			font-weight: bold;
			background-color: #dedede;
		}
	</style>
</xsl:template>

     
</xsl:stylesheet>
