<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xccdf">

<xsl:output method="xml" omit-xml-declaration="no"/>

<!--identity template to pass through any tags not explicitly matched elsewhere -->
<xsl:template match="node()|@*">
	<xsl:copy>
		<xsl:apply-templates select="node()|@*"/>
	</xsl:copy>
</xsl:template>


<xsl:template match="xccdf:version"/>
<xsl:template match="xccdf:metadata"/>
<xsl:template match="xccdf:status"/>
<!--
<xsl:template match="xccdf:Profile">
<xsl:comment> Profile removed: <xsl:value-of select="@id" /> </xsl:comment> 
</xsl:template>
-->

<!--attributes that we want to remove, as they are a distraction to content authors-->
<xsl:template match="@abstract" />
<xsl:template match="@xml:lang" />
<xsl:template match="@override" />
<xsl:template match="@hidden" />
<xsl:template match="@prohibitChanges" />
<xsl:template match="@selected" />
<xsl:template match="@weight" />
<xsl:template match="@role" />
<xsl:template match="@severity" />

<xsl:template match="xccdf:ident[@system='http://cce.mitre.org']">
	<ident xmlns="http://checklists.nist.gov/xccdf/1.1">
		<xsl:attribute name="cce">
			<xsl:value-of select="substring-after(node(),'CCE-')"/> 
		</xsl:attribute>
	</ident>
</xsl:template>

<!-- abuse of namespaces, pretending xhtml is in xccdf -->
<xsl:template match="xhtml:*">
	<xsl:element name="{local-name()}" xmlns="http://checklists.nist.gov/xccdf/1.1">
		<!--it's a lie.  we are intentionally abusing namespaces here.-->
		<xsl:apply-templates select="@* | node()"/>
	</xsl:element>
</xsl:template>

<!--get rid of everything else from the check, it's all oval anyway-->
<xsl:template match="xccdf:check">
	<xsl:apply-templates select="xccdf:check-content-ref"/>
</xsl:template>

<xsl:template match="xccdf:check-content-ref">
<oval xmlns="http://checklists.nist.gov/xccdf/1.1">
	<xsl:variable name="ovalid" select="@name"/>
	<xsl:attribute name="id">
		<xsl:value-of select="substring-after($ovalid,'oval:gov.nist.usgcb.rhel:def:')"/> 
	</xsl:attribute>
</oval>
</xsl:template>

</xsl:stylesheet>
