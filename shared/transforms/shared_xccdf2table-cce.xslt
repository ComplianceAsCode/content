<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cce="http://cce.mitre.org" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<!-- This style sheet takes as input a XCCDF file.  It outputs each Rule and CCE ident element, in document order.  
     If provided parameter $ref, this style sheet will display the referenced CCE file side-by-side for comparison -->

<xsl:param name="ref" select="''" />

<xsl:variable name="cce_list" select="document($ref)/cce:cce_list" />

	<xsl:template match="/">
		<html>
		<head>
			<title> CCE Identifiers in <xsl:value-of select="/cdf:Benchmark/cdf:title" /><xsl:if test="$ref"> with references common to <xsl:value-of select="$ref"/></xsl:if></title>
		</head>
		<body>
			<br/>
			<br/>
			<div style="text-align: center; font-size: x-large; font-weight:bold">
			CCE Identifiers in <xsl:value-of select="/cdf:Benchmark/cdf:title" /><xsl:if test="$ref"> with references common to <xsl:value-of select="$ref"/></xsl:if>
			</div>
			<br/>
			<br/>
			<xsl:apply-templates select="cdf:Benchmark"/>
		</body>
		</html>
	</xsl:template>


	<xsl:template match="cdf:Benchmark">
		<xsl:call-template name="table-style" />
		<table>
			<thead>
				<td>CCE ID</td>
				<td>Rule Title</td>
				<td>Description</td>
				<xsl:if test="$ref">
					<td>CCE Description</td>
					<td>CCE Mechanism</td>
				</xsl:if>
			</thead>

                <xsl:apply-templates select=".//cdf:Rule" />
		</table>
	</xsl:template>


	<xsl:template name="cce-output">
		<xsl:param name="idstring"/>
		<xsl:for-each select="$cce_list/cce:cces/cce:cce">
			<xsl:if test="$idstring=@cce_id">
				<td><xsl:value-of select="cce:description" /></td>
				<td><xsl:value-of select="cce:technical_mechanisms/cce:technical_mechanism"/> </td>
			</xsl:if>
		</xsl:for-each>
     </xsl:template>


	<xsl:template match="cdf:Rule">
		<xsl:variable name="cce-id" select="cdf:ident[@system=$cceuri]"/>

		<tr>
			<td><xsl:value-of select="$cce-id"/></td> 
			<td><xsl:value-of select="cdf:title" /></td>
			<td><xsl:apply-templates select="cdf:description"/> </td>
			<xsl:if test="$ref">
				<xsl:call-template name="cce-output" >
					<xsl:with-param name="idstring" select="$cce-id" />
				</xsl:call-template>
			</xsl:if>
		</tr>

		  <!--</xsl:if>-->
	</xsl:template>

	<!-- getting rid of XHTML namespace -->
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

	<xsl:template match="cdf:rationale">
		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

</xsl:stylesheet>
