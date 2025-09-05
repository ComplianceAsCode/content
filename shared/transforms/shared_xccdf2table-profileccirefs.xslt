<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:cci="https://public.cyber.mil/stigs/cci" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:ovalns="http://oval.mitre.org/XMLSchema/oval-definitions-5">

<!-- this style sheet expects parameter $profile, which is the id of the Profile to be shown -->

<xsl:variable name="cci_list" select="document('../references/disa-cci-list.xml')/cci:cci_list" />
<xsl:variable name="os_srg" select="document('../references/disa-os-srg-v1r6.xml')/cdf:Benchmark" />

<xsl:param name="profile" select="''"/>
<xsl:param name="testinfo" select="''" />

	<xsl:template match="/">
		<xsl:if test="not(/cdf:Benchmark/cdf:Profile[@id=$profile])">
			<xsl:message terminate="yes">Profile '<xsl:value-of select="$profile"/>' not found.</xsl:message>
		</xsl:if>
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
			<xsl:apply-templates select="/cdf:Benchmark"/>
		</body>
		</html>
	</xsl:template>


	<xsl:template match="cdf:Benchmark">
		<xsl:call-template name="table-style" />
		<table>
			<thead>
				<td>ID</td>
				<td>Severity</td>
				<td>Title</td>
				<td>Discussion (Rationale)</td>
				<td>Fix Text (Description)</td>
				<td>Check Text (OCIL Check)</td>
				<!-- <td>Variable Setting</td> -->
				<td>SRG Refs</td>
				<td>CCI Refs</td>
				<td>800-53 Refs</td>
			</thead>

		<xsl:for-each select="/cdf:Benchmark/cdf:Profile[@id=$profile]/cdf:select">
			<xsl:variable name="idrefer" select="@idref" />
			<xsl:variable name="enabletest" select="@selected" />
			<xsl:for-each select="//cdf:Rule">
				<xsl:call-template name="ruleplate">
					<xsl:with-param name="idreference" select="$idrefer" />
					<xsl:with-param name="enabletest" select="$enabletest" />
				</xsl:call-template>
			</xsl:for-each>
		</xsl:for-each>

		</table>
	</xsl:template>


	<xsl:template match="cdf:Rule" name="ruleplate">
		<xsl:param name="idreference" />
		<xsl:param name="enabletest" />
		<xsl:if test="@id=$idreference and $enabletest='true'">

		<tr>
			<td> <xsl:value-of select="@id" /></td>
			<td> <xsl:value-of select="@severity" /></td>
			<td> <xsl:value-of select="cdf:title" /></td>
			<!-- call template to grab text and also child nodes (which should all be xhtml)  -->
			<td> <xsl:apply-templates select="cdf:rationale"/> </td>
			<td> <xsl:apply-templates select="cdf:description"/> </td>

			<td>
			<!-- print the manual check text -->
			<xsl:apply-templates select="cdf:check" /> 
			</td>

			<td> 
			<xsl:for-each select="cdf:reference[@href=$disa-cciuri]">
            	<xsl:variable name="cci_formatted" select='self::node()[text()]' />
				<xsl:variable name="cci_expanded" select="$cci_formatted"  />
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
            	<xsl:variable name="cci_formatted" select='self::node()[text()]' />
				<xsl:variable name="cci_expanded" select="$cci_formatted"  />
				<xsl:value-of select="$cci_expanded"/>
				<br/>
			</xsl:for-each>
			</td> 

			<td> 
			<xsl:for-each select="cdf:reference[@href=$disa-cciuri]">
            	<xsl:variable name="cci_formatted" select='self::node()[text()]' />
				<xsl:variable name="cci_expanded" select="$cci_formatted"  />
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
