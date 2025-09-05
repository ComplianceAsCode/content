<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.2" xmlns:xccdf-1.1="http://checklists.nist.gov/xccdf/1.1" xmlns:cci="http://iase.disa.mil/cci" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:ovalns="http://oval.mitre.org/XMLSchema/oval-definitions-5" xmlns:ocil2="http://scap.nist.gov/schema/ocil/2.0">

<!-- this style sheet expects parameter $profile, which is the id of the Profile to be shown -->

<xsl:variable name="cci_list" select="document('../references/disa-cci-list.xml')/cci:cci_list" />
<xsl:variable name="os_srg" select="document('../references/disa-os-srg-v2r3.xml')/xccdf-1.1:Benchmark" />

<xsl:param name="profile" select="''"/>
<xsl:param name="testinfo" select="''" />

<xsl:param name="ocil-document" select="''"/>
<xsl:variable name="ocil" select="document($ocil-document)/ocil2:ocil"/>

<xsl:variable name="profile_id" select="concat('xccdf_org.ssgproject.content_profile_', $profile)" />

	<xsl:template match="/">
		<xsl:if test="not(/cdf:Benchmark/cdf:Profile[@id=$profile_id])">
			<xsl:message terminate="yes">Profile '<xsl:value-of select="$profile_id"/>' not found.</xsl:message>
		</xsl:if>
		<html>
		<head>
			<title><xsl:value-of select="/cdf:Benchmark/cdf:Profile[@id=$profile_id]/cdf:title" /></title>
		</head>
		<body>
			<br/>
			<br/>
			<div style="text-align: center; font-size: x-large; font-weight:bold"><xsl:value-of select="/cdf:Benchmark/cdf:Profile[@id=$profile_id]/cdf:title" /></div>
			<div style="text-align: center; font-size: normal "><xsl:value-of select="/cdf:Benchmark/cdf:Profile[@id=$profile_id]/cdf:description" /></div>
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

		<xsl:for-each select="/cdf:Benchmark/cdf:Profile[@id=$profile_id]/cdf:select">
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
				<pre>
					<xsl:apply-templates select="cdf:check[@system='http://scap.nist.gov/schema/ocil/2']"/>
				</pre>
			</td>

			<td> 
			<xsl:for-each select="cdf:reference[@href=$disa-cciuri]">
            	<xsl:variable name="cci_formatted" select='self::node()[text()]' />
				<xsl:variable name="cci_expanded" select="$cci_formatted"  />
				<xsl:for-each select="$os_srg/xccdf-1.1:Group/xccdf-1.1:Rule" >
					<xsl:if test="xccdf-1.1:ident=$cci_expanded">
						<xsl:value-of select="xccdf-1.1:version"/>
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

	<xsl:template match="cdf:check[@system='http://scap.nist.gov/schema/ocil/2']">
		<xsl:variable name="questionaireId" select="cdf:check-content-ref/@name"/>
		<xsl:variable name="questionaire" select="$ocil/ocil2:questionnaires/ocil2:questionnaire[@id=$questionaireId]"/>
		<xsl:variable name="testActionRef" select="$questionaire/ocil2:actions/ocil2:test_action_ref/text()"/>
		<xsl:variable name="questionRef" select="$ocil/ocil2:test_actions/*[@id=$testActionRef]/@question_ref"/>
		<xsl:value-of select="$ocil/ocil2:questions/ocil2:*[@id=$questionRef]/ocil2:question_text"/>
	</xsl:template>
</xsl:stylesheet>
