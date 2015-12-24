<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<!-- this style sheet expects parameter $ref, the abbreviation of the reference type to be shown -->

<xsl:include href="constants.xslt"/>
<xsl:include href="table-style.xslt"/>

	<xsl:template match="/">
		<html>
		<head>
			<title> Rules with <xsl:value-of select="$ref"/> Reference in <xsl:value-of select="/cdf:Benchmark/cdf:title" /> </title>
		</head>
		<body>
			<br/>
			<br/>
			<div style="text-align: center; font-size: x-large; font-weight:bold">
			Rules with <xsl:value-of select="$ref"/> Reference in <xsl:value-of select="/cdf:Benchmark/cdf:title" />
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
				<td>Reference (<xsl:value-of select="$ref"/>)</td>
				<td>Rule Title</td>
				<td>Description</td>
				<td>Rationale</td>
				<td>Variable Setting</td>
			</thead>

			<xsl:if test="$ref='nist'">
				<xsl:for-each select="//cdf:reference[@href=$nist800-53uri]" >
					<xsl:call-template name="rule-output">
						<xsl:with-param name="refinfo" select="." />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="$ref='cis'">
				<xsl:for-each select="//cdf:reference[@href=$cisuri]" >
					<xsl:call-template name="rule-output">
						<xsl:with-param name="refinfo" select="." />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>
			<xsl:if test="$ref='cnss'">
				<xsl:for-each select="//cdf:reference[@href=$cnss1253uri]" >
					<xsl:call-template name="rule-output">
						<xsl:with-param name="refinfo" select="." />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="$ref='pcidss'">
				<xsl:for-each select="//cdf:reference[@href=$pcidssuri]" >
					<xsl:sort select="substring-after(.,'-')" data-type="number" />
					<xsl:call-template name="pci-dss-rule-output">
						<xsl:with-param name="refinfo" select="." />
					</xsl:call-template>

				</xsl:for-each>
			</xsl:if>

		</table>
	</xsl:template>


	<xsl:template name="rule-output">
          <xsl:param name="refinfo"/>
		<tr>
			<td> 
			<xsl:value-of select="$refinfo"/>
			</td> 
			<!--<td> <xsl:value-of select="cdf:ident" /></td>-->
			<td> <xsl:value-of select="../cdf:title" /></td>
			<td> <xsl:apply-templates select="../cdf:description"/> </td>
			<td> <xsl:apply-templates select="../cdf:rationale"/> </td>
			<td> <!-- TODO: print refine-value from profile associated with rule --> </td>
		</tr>
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
