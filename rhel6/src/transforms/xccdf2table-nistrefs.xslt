<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1">
<xsl:variable name="profilename">desktop_baseline</xsl:variable>

	<xsl:template match="/">
		<html>
			<head>
				<title><xsl:copy-of select="$profilename" /></title>
			</head>

			<body>
				<br/>
				<br/>
				<div style="text-align: center; font-size: x-large; font-weight:bold"><xsl:copy-of select="$profilename" /></div>
				<br/>
				<br/>
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
		<xsl:for-each select="cdf:Profile">
			<xsl:if test="@id=$profilename">
				<table>
					<thead>
						<td>CCE ID</td>
						<td>Rule Title</td>
						<td>Description</td>
						<td>Rationale</td>
						<td>Variable Setting</td>
		<!--				<td>Configuration Mechanism</td> -->
						<td>NIST 800-53 Mapping</td>
					</thead>
					<xsl:for-each select="cdf:select">
						<xsl:variable name="idrefer" select="@idref" />
						<xsl:variable name="enabletest" select="@selected" />
						<xsl:for-each select="/cdf:Benchmark/cdf:Group">
							<xsl:call-template name="groupplate">
								<xsl:with-param name="idreference" select="$idrefer" />
								<xsl:with-param name="enabletest" select="$enabletest" />
							</xsl:call-template>
						</xsl:for-each>
					</xsl:for-each>
				</table>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="cdf:Group" name="groupplate">
		<xsl:param name="idreference" />
		<xsl:param name="enabletest" />
		<xsl:param name="nist" />

		<xsl:variable name="pasta">
			<xsl:choose>
				<xsl:when test="cdf:reference">
					<xsl:for-each select="cdf:reference">
						<xsl:if test="@href='http://csrc.nist.gov/publications/nistpubs/800-53-Rev3/sp800-53-rev3-final-errata.pdf'">
							<xsl:value-of select="." />
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="$nist" /></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- Group cdf:title -->
		<xsl:for-each select="cdf:Group">
			<xsl:call-template name="groupplate">
				<xsl:with-param name="idreference" select="$idreference" />
				<xsl:with-param name="enabletest" select="$enabletest" />
				<xsl:with-param name="nist" select="$pasta" />
					<!--<xsl:for-each select="cdf:reference">
						<xsl:if test="@href='http://csrc.nist.gov/publications/nistpubs/800-53-Rev3/sp800-53-rev3-final-errata.pdf'">
							<xsl:value-of select="." />
						</xsl:if>
					</xsl:for-each>
					-->
			</xsl:call-template>
		</xsl:for-each>

		<xsl:for-each select="cdf:Rule">
			<xsl:call-template name="ruleplate">
				<xsl:with-param name="idreference" select="$idreference" />
				<xsl:with-param name="enabletest" select="$enabletest" />
				<xsl:with-param name="nist" select="$pasta" />
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>


	<xsl:template match="cdf:Rule" name="ruleplate">
		<xsl:param name="idreference" />
		<xsl:param name="enabletest" />
		<xsl:param name="nist" />
		<xsl:if test="@id=$idreference and $enabletest='true'">
		<tr>
			<td><xsl:value-of select="cdf:ident" /></td>
			<td><xsl:value-of select="cdf:title" /></td>
			<td>
				<xsl:apply-templates select="cdf:description"/>
			</td>
			<td>
				<xsl:apply-templates select="cdf:rationale"/>
			</td>
<!--			<td>
				<xsl:value-of select="$nist" />
			</td>
			<td>
				<xsl:apply-templates select="cdf:check"/>
			</td> -->
			<td>
				<xsl:apply-templates select="cdf:fixtext"/>
			</td>
<!--			<td>
				<xsl:apply-templates select="cdf:fix"/>
			</td> -->
			<td>
				<xsl:apply-templates select="cdf:reference"/>
			</td>
		</tr>
		</xsl:if>
	</xsl:template>


	<xsl:template match="cdf:ident">
		<xsl:value-of select="."/>
	</xsl:template>


	<xsl:template match="cdf:fixtext">
			<xsl:value-of select="." />
	</xsl:template>


	<xsl:template match="cdf:fix">
			<xsl:value-of select="." />
	</xsl:template>


	<xsl:template match="cdf:check">
		<xsl:for-each select="cdf:check-export">
			<xsl:variable name="rulevar" select="@value-id" />
				<!--<xsl:value-of select="$rulevar" />:-->
				<xsl:for-each select="/cdf:Benchmark/cdf:Profile[@id=$profilename]/cdf:refine-value">
					<xsl:if test="@idref=$rulevar">
						<xsl:value-of select="@selector" />
					</xsl:if>
				</xsl:for-each>
		</xsl:for-each>
	</xsl:template>


	<xsl:template match="cdf:description">
			<xsl:value-of select="." />
	</xsl:template>

	<xsl:template match="cdf:rationale">
			<xsl:value-of select="." />
	</xsl:template>
	<xsl:template match="cdf:reference">
			<xsl:value-of select="." />
	</xsl:template>

</xsl:stylesheet>
