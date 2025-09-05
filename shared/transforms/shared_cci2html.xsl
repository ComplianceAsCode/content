<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cci="https://public.cyber.mil/stigs/cci">

	<xsl:decimal-format NaN=""/>

	<!-- default search order -->
	<xsl:param name="sortorder" select="'type'"/>

	<xsl:template match="/">
		<html>
			<head>
				<style type="text/css">
					BODY { font-family: sans-serif; }
					TD { border: none; font-size: 12pt; vertical-align: top; }
					TR.header, TD.header { font-weight: bold; }
				</style>
				<title>CCI List</title>
			</head>
			<body>
				<xsl:apply-templates select="cci:cci_list"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="cci:cci_list">
		<b>CCI List</b><br />
		<b>Version <xsl:value-of select="cci:metadata/cci:version"/></b><br />
		<b>Date <xsl:value-of select="cci:metadata/cci:publishdate"/></b>
		<hr/>
		<xsl:choose>
			<xsl:when test="$sortorder = 'publishdate'">
				<xsl:apply-templates select="cci:cci_items/cci:cci_item">
					<xsl:sort data-type="text" select="publishdate"/>
				</xsl:apply-templates>				
			</xsl:when>
			<xsl:when test="$sortorder = '800-53'">
				<xsl:apply-templates select="cci:cci_items/cci:cci_item">
					<xsl:sort data-type="text" select="concat(substring(cci:references/cci:reference[@title = 'NIST SP 800-53']/@index, 1, 2), '-', format-number(substring-before(substring-after(cci:references/cci:reference[@title = 'NIST SP 800-53']/@index, '-'), ' '), '000'), format-number(substring-after(cci:references/cci:reference[@title = 'NIST SP 800-53']/@index, '-'), '000'), translate(substring(substring-after(cci:references/cci:reference[@title = 'NIST SP 800-53']/@index, ' '), 1, 1), '(abcdefghijklmnopqrstuvwxyz', '-//////////////////////////'),  translate(substring(substring-after(cci:references/cci:reference[@title = 'NIST SP 800-53']/@index, ' '), 1, 1), 'abcdefghijklmnopqrstuvwxyz(', 'abcdefghijklmnopqrstuvwxyz'), format-number(substring-before(substring-after(cci:references/cci:reference[@title = 'NIST SP 800-53']/@index, '('), ')'), '000'), translate(substring(substring-after(substring-after(cci:references/cci:reference[@title = 'NIST SP 800-53']/@index, '('), '('), 1, 1), '0123456789abcdefghijklmnopqrstuvwxyz', '----------//////////////////////////'),  translate(substring(substring-after(substring-after(cci:references/cci:reference[@title = 'NIST SP 800-53']/@index, '('), '('), 1, 1), 'abcdefghijklmnopqrstuvwxyz', 'abcdefghijklmnopqrstuvwxyz'), format-number(substring-before(substring-after(substring-after(cci:references/cci:reference[@title = 'NIST SP 800-53']/@index, '('), '('), ')'), '000'))"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$sortorder = 'type'">
				<xsl:apply-templates select="cci:cci_items/cci:cci_item">
					<xsl:sort data-type="text" select="cci:type"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$sortorder = 'status'">
				<xsl:apply-templates select="cci:cci_items/cci:cci_item">
					<xsl:sort data-type="text" select="cci:status"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="cci:cci_items/cci:cci_item">
					<xsl:sort data-type="text" select="@id"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	

	<xsl:template match="cci:cci_item">
		<table width="100%">
			<tr>
				<td width="15%" class="header"><xsl:value-of select="'CCI:'"/></td>
				<td width="35%"><xsl:value-of select="@id"/></td>
				<td width="15%" class="header"><xsl:value-of select="'Status:'"/></td>
				<td width="35%"><xsl:value-of select="cci:status"/></td>
			</tr>
			<tr>
				<td class="header"><xsl:value-of select="'Contributor:'"/></td>
				<td><xsl:value-of select="cci:contributor"/></td>
				<td class="header"><xsl:value-of select="'Published Date:'"/></td>
				<td><xsl:value-of select="cci:publishdate"/></td>
			</tr>
			<tr>
				<td class="header"><xsl:value-of select="'Definition:'"/></td>
				<td colspan="3"><xsl:value-of select="cci:definition"/></td>
			</tr>
			<xsl:if test="cci:type != ''">
				<tr>
					<td class="header"><xsl:value-of select="'Type:'"/></td>
					<td colspan="3"><xsl:value-of select="cci:type"/></td>
				</tr>
			</xsl:if>
			<xsl:if test="cci:note != ''">
				<tr>
					<td class="header"><xsl:value-of select="'Note:'"/></td>
					<td colspan="3"><xsl:value-of select="cci:note"/></td>
				</tr>
			</xsl:if>
			<xsl:if test="cci:parameter != ''">
				<tr>
					<td class="header"><xsl:value-of select="'Parameter:'"/></td>
					<td colspan="3"><xsl:value-of select="cci:parameter"/></td>
				</tr>
			</xsl:if>
			<xsl:apply-templates select="cci:references/cci:reference">
				<xsl:sort select="@creator"/>
				<xsl:sort select="@title"/>
				<xsl:sort select="@version"/>
			</xsl:apply-templates>
		</table>
		<hr />
	</xsl:template>	
	
	<xsl:template match="cci:reference">
		<tr>
			<td class="header">
				<xsl:if test="position() = 1">
					References:
				</xsl:if>
			</td>
			<td colspan="3">
				<xsl:value-of select="@creator"/>
				<xsl:value-of select="':  '"/>
				<a>
					<xsl:attribute name="href">
						<xsl:value-of select="@location"/>
					</xsl:attribute>
					<xsl:value-of select="@title"/>
					<xsl:value-of select="' (v'"/>
					<xsl:value-of select="@version"/>
					<xsl:value-of select="')'"/>
				</a>
				<xsl:value-of select="':  '"/>
				<xsl:value-of select="@index"/>
			</td>
		</tr>
	</xsl:template>
	
</xsl:stylesheet>
