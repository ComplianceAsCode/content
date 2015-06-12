<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:cci="http://iase.disa.mil/cci" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<!-- this style sheet expects parameter $profile, which is the id of the Profile to be shown -->

<xsl:variable name="cci_list" select="document('../../../shared/references/disa-cci-list.xml')/cci:cci_list" />
<xsl:variable name="os_srg" select="document('../../../shared/references/disa-os-srg-v1r1.xml')/cdf:Benchmark" />

<xsl:param name="testinfo" select="''" />

<xsl:param name="format" select="''"/>

<xsl:include href="constants.xslt"/>

	<xsl:template match="/">
		<html>
		<head>
			<title><xsl:value-of select="/cdf:Benchmark/cdf:Profile[@id=$profile]/cdf:title" /></title>
		</head>
		<body>
			<br/>
			<br/>
			<div style="text-align: center; font-size: x-large; font-weight:bold"><xsl:value-of select="/cdf:Benchmark/cdf:Profile[@id=$profile]/cdf:title" /></div>
			<div style="text-align: center; font-size: normal "><xsl:value-of select="/cdf:Benchmark/cdf:Profile[@id=$profile]/cdf:description" /></div>
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
		<table>
			<thead>
				<td>Vuln ID</td>
				<td>CAT</td>
				<!-- <td>GEN ID</td> -->
				<td>Title</td>
				<td>Discussion (Rationale)</td>
				<td>Fix Text (Description)</td>
				<td>Check Text (OCIL Check)</td>
				<!-- <td>Variable Setting</td> -->
				<td>SRG Refs</td>
				<td>CCI Refs</td>
				<td>800-53 Refs</td>
			</thead>

		<xsl:call-template name="profileplate">
			<xsl:with-param name="profileid" select="$profile" />
		</xsl:call-template>
		</table>
	</xsl:template>

	<!-- recursively-called, to handle Profile "extends" behavior -->
	<xsl:template match="cdf:Profile" name="profileplate">
		<xsl:param name="profileid" />
		<xsl:comment> Entered Profile: <xsl:value-of select="$profileid" />	 </xsl:comment>

		<xsl:for-each select="/cdf:Benchmark/cdf:Profile[@id=$profileid]">
		<xsl:if test="@extends">
			<xsl:variable name="extendedprofile" select="@extends" />
			<xsl:call-template name="profileplate">
				<xsl:with-param name="profileid" select="$extendedprofile" />
			</xsl:call-template>
		</xsl:if>
		</xsl:for-each>

		<xsl:for-each select="/cdf:Benchmark/cdf:Profile[@id=$profileid]/cdf:select">
			<xsl:variable name="idrefer" select="@idref" />
			<xsl:variable name="enabletest" select="@selected" />
			<xsl:for-each select="/cdf:Benchmark/cdf:Group">
				<xsl:call-template name="groupplate">
					<xsl:with-param name="idreference" select="$idrefer" />
					<xsl:with-param name="enabletest" select="$enabletest" />
				</xsl:call-template>
			</xsl:for-each>
		</xsl:for-each>

	</xsl:template>

	<xsl:template match="cdf:Group" name="groupplate">
		<xsl:param name="idreference" />
		<xsl:param name="enabletest" />
		<!-- Group cdf:title -->
		<xsl:for-each select="cdf:Group">
			<xsl:call-template name="groupplate">
				<xsl:with-param name="idreference" select="$idreference" />
				<xsl:with-param name="enabletest" select="$enabletest" />
			</xsl:call-template>
		</xsl:for-each>

		<xsl:for-each select="cdf:Rule">
			<xsl:choose>
			<xsl:when test="$format='flat'">
				<xsl:call-template name="ruleplate-flat">
					<xsl:with-param name="idreference" select="$idreference" />
					<xsl:with-param name="enabletest" select="$enabletest" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="ruleplate">
					<xsl:with-param name="idreference" select="$idreference" />
					<xsl:with-param name="enabletest" select="$enabletest" />
				</xsl:call-template>
			</xsl:otherwise>

			</xsl:choose>
		</xsl:for-each>
	</xsl:template>


	<xsl:template match="cdf:Rule" name="ruleplate">
		<xsl:param name="idreference" />
		<xsl:param name="enabletest" />
		<xsl:if test="@id=$idreference and $enabletest='true'">
		<tr>
			<td>TBD<!-- insert proper Vuln-ID if available --></td>
			<td> <xsl:value-of select="@severity" /></td>
			<td> <xsl:value-of select="cdf:title" /></td>
			<!-- call template to grab text and also child nodes (which should all be xhtml)  -->
			<td> <xsl:apply-templates select="cdf:rationale"/> </td>
			<td> <xsl:apply-templates select="cdf:description"/> </td>


			<td>
			<!-- print pretty visual indication of testing data -->
			<xsl:if test="$testinfo and cdf:reference[@href=$ssg-contributors-uri]">
				<!-- add green border on left if test attestation found -->
				<xsl:attribute name="style">border-left:solid thick lime</xsl:attribute>
			</xsl:if>

			<!-- print the manual check text -->
			<xsl:apply-templates select="cdf:check" /> 

			<!-- print the test attestation info -->
			<xsl:if test="$testinfo">
				<!-- in the XCCDF -->
				<xsl:for-each select="cdf:reference[@href=$ssg-contributors-uri]">
					<!--    Process the text() of test_attestation reference to drop
						'Test attestation on' prefix and keep only date and contributor -->
					<br/><i>Manual check tested on <xsl:value-of select="substring-after(text(), 'Test attestation on ')"/>.</i>
				</xsl:for-each>
			</xsl:if>
			</td>

			<td> 
			<xsl:for-each select="cdf:reference[@href=$disa-cciuri]">
            	<xsl:variable name="cci_formatted" select='format-number(self::node()[text()], "000000")' />
				<xsl:variable name="cci_expanded" select="concat('CCI-', $cci_formatted)"  />
				<xsl:for-each select="$os_srg/cdf:Group/cdf:Rule" >
					<xsl:if test="cdf:ident=$cci_expanded">
						<xsl:value-of select="cdf:version"/>
						<br/>
					</xsl:if>
				</xsl:for-each>
			</xsl:for-each>
			</td> 

			<td> 
			<xsl:for-each select="cdf:reference[@href=$disa-cciuri]">
            	<xsl:variable name="cci_formatted" select='format-number(self::node()[text()], "000000")' />
				<xsl:variable name="cci_expanded" select="concat('CCI-', $cci_formatted)"  />
				<xsl:value-of select="$cci_expanded"/>
				<br/>
			</xsl:for-each>
			</td> 

			<td> 
			<xsl:for-each select="cdf:reference[@href=$disa-cciuri]">
            	<xsl:variable name="cci_formatted" select='format-number(self::node()[text()], "000000")' />
				<xsl:variable name="cci_expanded" select="concat('CCI-', $cci_formatted)"  />
				<xsl:for-each select="$cci_list/cci:cci_items/cci:cci_item">
					<xsl:if test="@id=$cci_expanded">
						<xsl:for-each select="cci:references/cci:reference">
							<xsl:if test="@title='NIST SP 800-53'">
								<xsl:value-of select="@index"/>
								<br/>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
				</xsl:for-each>
			</xsl:for-each>
			</td> 
		</tr>
		</xsl:if>
	</xsl:template>


	<xsl:template match="cdf:Rule" name="ruleplate-flat">
		<xsl:param name="idreference" />
		<xsl:param name="enabletest" />
		<xsl:if test="@id=$idreference and $enabletest='true'">

		<xsl:variable name="rule" select="."  />

		<xsl:for-each select="cdf:reference[@href=$disa-cciuri]">
           	<xsl:variable name="cci_formatted" select='format-number(self::node()[text()], "000000")' />
			<xsl:variable name="cci_expanded" select="concat('CCI-', $cci_formatted)"  />

			<tr>
			<td>TBD<!-- insert proper Vuln-ID if available --></td>
			<td> <xsl:value-of select="../@severity" /></td>
			<td> <xsl:value-of select="../cdf:title" /></td>
			<!-- call template to grab text and also child nodes (which should all be xhtml)  -->
			<td> <xsl:apply-templates select="../cdf:rationale"/> </td>
			<td> <xsl:apply-templates select="../cdf:description"/> </td>
			<td> <xsl:apply-templates select="../cdf:check" /> </td>

			<td> 
			<xsl:for-each select="$os_srg/cdf:Group/cdf:Rule" >
				<xsl:if test="cdf:ident=$cci_expanded">
					<!-- output the SRG ID -->
					<xsl:value-of select="cdf:version"/>
					<br/>
				</xsl:if>
			</xsl:for-each>
			</td> 

			<td> <xsl:value-of select="$cci_expanded"/> </td> 

			<td> 
				<xsl:for-each select="$cci_list/cci:cci_items/cci:cci_item">
					<xsl:if test="@id=$cci_expanded">
						<xsl:for-each select="cci:references/cci:reference">
							<xsl:if test="@title='NIST SP 800-53'">
								<xsl:value-of select="@index"/>
								<br/>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
				</xsl:for-each>
			</td> 

			</tr>

		</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template match="cdf:check">
	    <xsl:if test="@system=$ociltransitional">
			<xsl:apply-templates select="cdf:check-content" />
			<!-- print clause with "finding" text -->
			 <xsl:if test="cdf:check-export/@export-name != ''">
			 <br/>If <xsl:value-of select="cdf:check-export/@export-name" />, this is a finding. 
			 </xsl:if>
		</xsl:if>
<!--	    <xsl:if test="@system=$ovaluri">
		<xsl:for-each select="cdf:check-export">
			<xsl:variable name="rulevar" select="@value-id" />
				<xsl:for-each select="/cdf:Benchmark/cdf:Profile[@id=$profile]/cdf:refine-value">
					<xsl:if test="@idref=$rulevar">
						<xsl:value-of select="@selector" />
					</xsl:if>
				</xsl:for-each>
		</xsl:for-each>
		</xsl:if> -->
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
        <!-- print all the text and children (xhtml elements) of the description -->
        <xsl:apply-templates select="@*|node()" />
    </xsl:template>

    <xsl:template match="cdf:rationale">
        <!-- print all the text and children (xhtml elements) of the description -->
        <xsl:apply-templates select="@*|node()" />
    </xsl:template>

    <xsl:template match="cdf:check-content">
        <xsl:apply-templates select="@*|node()" />
    </xsl:template>

</xsl:stylesheet>
