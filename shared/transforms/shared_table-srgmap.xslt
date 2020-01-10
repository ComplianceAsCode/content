<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:ocil2="http://scap.nist.gov/schema/ocil/2.0">

<!-- this style sheet is designed to take as input the OS SRG and a body of XCCDF content (e.g. draft STIG),
     and to map the requirements from the SRG to Rules in the XCCDF (which include CCIs as references).
     The output shows how a body of XCCDF meets SRG requirements. If the stylesheet is provided a stringparam
     "flat", then it will output a separate row for every Rule which satisfies an SRG requirement. -->

<xsl:param name="flat" select="''"/>
<xsl:param name="ocil-document" select="''"/>
<xsl:variable name="ocil" select="document($ocil-document)/ocil2:ocil"/>

	<xsl:template match="/">
		<html>
		<head>
			<title>SRGs from <xsl:value-of select="cdf:Benchmark/cdf:title"/> Mapped to <xsl:value-of select="$title"/></title>
		</head>
		<body>
			<br/> <br/>
			<div style="text-align: center; font-size: x-large; font-weight:bold">
			SRGs from <xsl:value-of select="cdf:Benchmark/cdf:title"/> Mapped to <xsl:value-of select="$title"/>
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
				<td>CCI</td>
				<td>SRGID</td>
				<td>STIGID</td>
				<td>SRG Requirement</td>
				<td>Requirement</td> <!-- XCCDF RULE Title -->
				<xsl:choose>
					<xsl:when test="$flat">
						<td>SRG VulDiscussion</td>
						<td>VulDiscussion</td> <!-- XCCDF RATIONALE -->
						<td>Status</td>
						<td>SRG Check</td>
						<td>Check</td> <!-- XCCDF DESCRIPTION -->
						<td>SRG Fix</td>
						<td>Fix</td> <!-- OCIL -->
						<td>Severity</td>
						<td>Mitigation</td>
						<td>Artifact Description</td>
						<td>Status Justification</td>
					</xsl:when>
					<xsl:otherwise>
						<td>Rules Mapped</td>
					</xsl:otherwise>
				</xsl:choose>
			</thead>
			<xsl:for-each select=".//cdf:Rule">
				<xsl:variable name="curr_srg" select="cdf:version"/>
				<xsl:choose>
					<!-- output multiple rows if we're in flat mode and at least one ref exists -->
					<xsl:when test="$flat and $items/cdf:reference[@href=$disa-srguri and text()=$curr_srg]">
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
		<td> <xsl:value-of select="$rule/cdf:ident"/> </td>
		<td> <xsl:value-of select="$rule/cdf:version"/> </td>
		<td><i>TBD - Assigned by DISA after STIG release</i></td>
		<td> <xsl:value-of select="$rule/cdf:title"/> </td>
		<xsl:if test="$flat"><td></td></xsl:if>
		<td> <xsl:call-template name="extract-vulndiscussion">
				<xsl:with-param name="desc" select="$rule/cdf:description"/>
			 </xsl:call-template>
		</td>
		<!-- iterate over the items (everything with references) in the (externally-provided) XCCDF document -->
		<td>
		<xsl:for-each select="$items">
			<xsl:variable name="item" select="."/>
			<xsl:for-each select="cdf:reference[@href=$disa-srguri]">
				<xsl:variable name="ssg_srg" select='self::node()[text()]' />
				<xsl:variable name="disa_srg" select="$rule/cdf:version"  />
				<xsl:if test="$ssg_srg=$disa_srg" >
					<table>
					<tr>
					<td> <xsl:value-of select="$item/cdf:title"/> </td>
					<td> <xsl:apply-templates select="$item/cdf:description"/> </td>
					</tr>
					</table>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
		<xsl:if test="$flat">
			<!-- there is no Rule matching the SRG. Let's output empty fields. -->
			<td/><td/><td/><td/><td/><td/><td/><td/><td/>
		</xsl:if>
	  </td>
	  </tr>
	</xsl:template>

	<xsl:template name="output-rows-flat">
		<xsl:param name="rule" />
		<!-- iterate over the items (everything with references) in the (externally-provided) XCCDF document -->
		<xsl:for-each select="$items">
			<xsl:variable name="item" select="."/>
			<xsl:for-each select="cdf:reference[@href=$disa-srguri]">
			  <xsl:variable name="ssg_srg" select='self::node()[text()]' />
			  <xsl:variable name="disa_srg" select="$rule/cdf:version"  />
				<xsl:if test="$ssg_srg=$disa_srg" >
					<tr>
						<td><xsl:value-of select="$rule/cdf:ident" /></td> 								<!-- CCI -->
						<td><xsl:value-of select="$rule/cdf:version" /></td> 							<!-- SRGID -->
						<td><i>TBD - Assigned by DISA after STIG release</i></td> 						<!-- STIGID -->
						<td><xsl:value-of select="$rule/cdf:title"/> </td>								<!-- SRG Requirement -->
						<td>													<!-- Requirement -->
							<xsl:if test="$item/cdf:ident"><xsl:value-of select="$item/cdf:ident"/>:</xsl:if>
							<xsl:value-of select="$item/cdf:title"/>
						</td>
						<td><xsl:call-template name="extract-vulndiscussion">							<!-- SRG VulDiscussion -->
								<xsl:with-param name="desc" select="$rule/cdf:description"/>
							</xsl:call-template>
						</td>
						<td> <xsl:apply-templates select="$item/cdf:description"/></td>					<!-- VulDiscussion -->
						<td>												<!-- Status -->
							<xsl:choose>
								<xsl:when test="contains($item/@id, 'met_inherently_')">Applicable - Inherently Meets</xsl:when>
								<xsl:when test="contains($item/@id, '-overlay-')">N/A</xsl:when>
								<xsl:otherwise>Applicable - Configurable</xsl:otherwise>
							</xsl:choose>
						</td>
						<td><xsl:apply-templates select="$rule/cdf:check/cdf:check-content"/></td>		<!-- SRG Check -->
						<td><xsl:apply-templates select="$item/cdf:check[@system='http://scap.nist.gov/schema/ocil/2']"/></td>	<!-- Check -->
						<td><xsl:apply-templates select="$rule/cdf:fixtext"/></td>						<!-- SRG Fix -->
						<td><xsl:value-of select="$item/cdf:description"/></td>							<!-- Fix -->
						<td><xsl:value-of select="$item/@severity"/></td>								<!-- Severity -->
						<td></td>																		<!-- Mitigation -->
						<td></td>																		<!-- Artifact Description -->
						<td></td>																		<!-- Status Justification -->

					</tr>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="cdf:check[@system='http://scap.nist.gov/schema/ocil/2']">
		<xsl:variable name="questionaireId" select="cdf:check-content-ref/@name"/>
		<xsl:variable name="questionaire" select="$ocil/ocil2:questionnaires/ocil2:questionnaire[@id=$questionaireId]"/>
		<xsl:variable name="testActionRef" select="$questionaire/ocil2:actions/ocil2:test_action_ref/text()"/>
		<xsl:variable name="questionRef" select="$ocil/ocil2:test_actions/*[@id=$testActionRef]/@question_ref"/>
		<xsl:value-of select="$ocil/ocil2:questions/ocil2:*[@id=$questionRef]/ocil2:question_text"/>
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
