<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<!-- this style sheet is designed to take as input the OS SRG and a body of XCCDF content (e.g. draft STIG), 
     and to map the requirements from the SRG to Rules in the XCCDF (which include CCIs as references). 
     The output shows how a body of XCCDF meets SRG requirements. If the stylesheet is provided a stringparam
     "flat", then it will output a separate row for every Rule which satisfies an SRG requirement. -->

<xsl:param name="flat" select="''"/>

	<xsl:template match="/">
		<html>
		<head>
			<title>CCIs from <xsl:value-of select="cdf:Benchmark/cdf:title"/> Mapped to <xsl:value-of select="$title"/></title>
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
		<xsl:call-template name="table-style" />

		<table>
			<thead>
				<td>SRG ID</td>
				<td>CCI ID</td>
				<td>SRG Title</td>
				<td>SRG Description</td>
				<xsl:choose>
					<xsl:when test="$flat">
						<td>Rule ID</td>
						<td>Rule Title</td>
						<td>Rule Desc</td>
						<td>Rule Check</td>
					</xsl:when>
					<xsl:otherwise>
						<td>Rules Mapped</td>
					</xsl:otherwise>
				</xsl:choose>
			</thead>
			<xsl:for-each select=".//cdf:Rule">
				<xsl:variable name="curr_cci" select="string(number(substring-after(cdf:ident,'CCI-')))"/> 
				<xsl:choose>
					<!-- output multiple rows if we're in flat mode and at least one ref exists -->
					<xsl:when test="$flat and $items/cdf:reference[@href=$disa-cciuri and text()=$curr_cci]">
						<xsl:call-template name="output-rows-flat"> <xsl:with-param name="rule" select="."/> </xsl:call-template> 
					</xsl:when>
					<!-- otherwise output a row with all (and possibly zero) Rules in nested tables  -->
					<xsl:otherwise>
						<xsl:call-template name="output-row-nested"> <xsl:with-param name="rule" select="."/> </xsl:call-template> 
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</table>
	</xsl:template>


	<xsl:template name="output-row-nested">
		<xsl:param name="rule" />
		<tr>
		<td> <xsl:value-of select="$rule/cdf:version"/> </td> 
		<td> <xsl:value-of select="$rule/cdf:ident"/> </td> 
		<td> <xsl:value-of select="$rule/cdf:title"/> </td>
		<td> <xsl:call-template name="extract-vulndiscussion">
				<xsl:with-param name="desc" select="$rule/cdf:description"/>
			 </xsl:call-template> 
		</td>
		<!-- iterate over the items (everything with references) in the (externally-provided) XCCDF document -->
		<td>
		<xsl:for-each select="$items">
			<xsl:variable name="item" select="."/>
			<xsl:for-each select="cdf:reference[@href=$disa-cciuri]"> 
			    <xsl:variable name="cci_formatted" select='format-number(self::node()[text()], "000000")' />
			    <xsl:variable name="cci_expanded" select="concat('CCI-', $cci_formatted)"  />
			    <xsl:variable name="srg_cci" select="$rule/cdf:ident"  />
				<xsl:if test="$cci_expanded=$srg_cci" >
					<table>
					<tr>
					<td> <xsl:value-of select="$item/cdf:title"/> </td>
					<td> <xsl:apply-templates select="$item/cdf:description"/> </td>
					</tr>
					</table>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
	  </td>
	  </tr>
	</xsl:template>

	<xsl:template name="output-rows-flat">
		<xsl:param name="rule" />
		<!-- iterate over the items (everything with references) in the (externally-provided) XCCDF document -->
		<xsl:for-each select="$items">
			<xsl:variable name="item" select="."/>
			<xsl:for-each select="cdf:reference[@href=$disa-cciuri]">
			    <xsl:variable name="cci_formatted" select='format-number(self::node()[text()], "000000")' />
			    <xsl:variable name="cci_expanded" select="concat('CCI-', $cci_formatted)"  />
			    <xsl:variable name="srg_cci" select="$rule/cdf:ident"  />
				<xsl:if test="$cci_expanded=$srg_cci" >
					<tr>
					<td> <xsl:value-of select="$rule/cdf:version"/> </td>
					<td> <xsl:value-of select="$rule/cdf:ident"/> </td>
					<td> <xsl:value-of select="$rule/cdf:title"/> </td>
					<td> <xsl:call-template name="extract-vulndiscussion">
							<xsl:with-param name="desc" select="$rule/cdf:description"/>
						 </xsl:call-template>
					</td>
					<td> <xsl:value-of select="$item/@id"/> </td>
					<td> <xsl:value-of select="$item/cdf:title"/> </td>
					<td> <xsl:apply-templates select="$item/cdf:description"/> </td>
					<td> <xsl:apply-templates select="$item/cdf:check/cdf:check-content"/> </td>
					</tr>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
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

	<xsl:template match="cdf:check-content">
		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

</xsl:stylesheet>
