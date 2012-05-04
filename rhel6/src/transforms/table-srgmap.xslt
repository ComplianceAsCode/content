<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<!-- this style sheet is designed to take as input the OS SRG and a body of XCCDF content (e.g. draft STIG), 
     and to map the requirements from the SRG to Rules in the XCCDF (which include CCIs as references). 
     The output shows how a body of XCCDF meets SRG requirements. -->

<xsl:include href="constants.xslt"/>

<!-- expecting external variable "map-to-items", a filename to an XCCDF document with Rules and Groups -->
<!-- put everything in it with a reference into "items" (should only be Rules and Groups) -->
<xsl:variable name="items" select="document($map-to-items)//*[cdf:reference]" />
<xsl:variable name="title" select="document($map-to-items)/cdf:Benchmark/cdf:title" />

	<xsl:template match="/">
		<html>
		<head>
			<title>
			CCIs from <xsl:value-of select="cdf:Benchmark/cdf:title"/> Mapped to <xsl:value-of select="$title"/>
 			</title>
		</head>
		<body>
			<br/> <br/> 
			<div style="text-align: center; font-size: x-large; font-weight:bold">
			CCIs from <xsl:value-of select="cdf:Benchmark/cdf:title"/> Mapped to <xsl:value-of select="$title"/>
			</div>
			<br/> <br/>
			<xsl:apply-templates select="cdf:Benchmark"/>
		</body>
		</html>
	</xsl:template>


	<xsl:template match="cdf:Benchmark">
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
		<table>
			<thead>
				<td>SRG ID</td>
				<td>CCI ID</td>
				<td>SRG Title</td>
				<td>SRG Description</td>
				<td>Rules Mapped</td>
			</thead>
			<xsl:for-each select=".//cdf:Rule">
				<xsl:sort select="cdf:version"/>
				<xsl:call-template name="output-rule-info"> 
					<xsl:with-param name="srg_id"><xsl:value-of select="cdf:version"/></xsl:with-param>
					<xsl:with-param name="srg_cci"><xsl:value-of select="cdf:ident"/></xsl:with-param>
					<xsl:with-param name="srg_title"><xsl:value-of select="cdf:title"/></xsl:with-param>
					<xsl:with-param name="srg_desc"><xsl:value-of select="cdf:description"/></xsl:with-param>
				</xsl:call-template> 
			</xsl:for-each>
		</table>
	</xsl:template>

	<xsl:template name="output-rule-info">
      <xsl:param name="srg_id" />
      <xsl:param name="srg_cci" />
      <xsl:param name="srg_title" />
      <xsl:param name="srg_desc" />
		  <tr>
		  <td> <xsl:value-of select="$srg_id"/> </td> 
		  <td> <xsl:value-of select="$srg_cci"/> </td> 
		  <td> <xsl:value-of select="$srg_title"/> </td>
		  <td> <xsl:call-template name="extract-vulndiscussion"><xsl:with-param name="desc" select="$srg_desc"/></xsl:call-template> </td>
		  <td>
      		<!-- iterate over the items (everything with references) in the (externally-provided) XCCDF document -->
			<xsl:for-each select="$items">
				<xsl:variable name="item" select="."/>
				<xsl:if test="cdf:reference[@href=$disa-cciuri]" > 
				<table>
				<xsl:for-each select="cdf:reference[@href=$disa-cciuri]"> 
				    <xsl:variable name="cci_formatted" select='format-number(self::node()[text()], "000000")' />
				    <xsl:variable name="cci_expanded" select="concat('CCI-', $cci_formatted)"  />
			  		<xsl:if test="$cci_expanded=$srg_cci" >
						<tr>
						<td> <xsl:value-of select="$item/cdf:title"/> </td>
						<td> <xsl:apply-templates select="$item/cdf:description"/> </td>
				  		</tr>
			  		</xsl:if>
				</xsl:for-each>
				</table>
				</xsl:if>
			</xsl:for-each>
			</td>
		  </tr>
	</xsl:template>


	<!-- return only the text between the "VulnDiscussion" (non-XCCDF) tags -->
	<!-- this should be removed as soon as SRGs include only a description instead of odd tags -->
	<xsl:template name="extract-vulndiscussion">
		<xsl:param name="desc"/>
		<xsl:variable name="desc_info" select="substring-before($desc, '&lt;/VulnDiscussion&gt;')"/>
		<xsl:value-of select="substring-after($desc_info, '&lt;VulnDiscussion&gt;')"/>
	</xsl:template>


	<!-- get rid of XHTML namespace since we're outputting to HTML -->
	<xsl:template match="xhtml:*">
		<xsl:element name="{local-name()}">
 			<xsl:apply-templates select="node()|@*"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="cdf:description">
		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

</xsl:stylesheet>
