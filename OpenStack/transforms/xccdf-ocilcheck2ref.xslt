<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xccdf">

<xsl:include href="constants.xslt"/>

<!-- This transform replaces check-content with a check-content-ref, using the enclosing Rule id to create
     an id for the check (by appending "_ocil") -->

  <!-- replace check system attribute with the real OCIL one -->
  <xsl:template match="xccdf:check[@system='ocil-transitional']">
    <xsl:copy>
		<xsl:apply-templates select="@*" />
		<xsl:attribute name="system"><xsl:value-of select="$ocil_cs" /></xsl:attribute>
      <xsl:apply-templates select="node()" />
    </xsl:copy>
  </xsl:template>

  <!-- remove check-content nodes and replace them with a check-content-ref node, using the Rule id 
       to create a reference name -->
  <xsl:template match="xccdf:check-content">
	<xsl:element name="check-content-ref" namespace="http://checklists.nist.gov/xccdf/1.1">
		<xsl:attribute name="href">unlinked-openstack-ocil.xml</xsl:attribute>
		<xsl:attribute name="name"><xsl:value-of select="../../@id"/>_ocil</xsl:attribute>
	</xsl:element>
  </xsl:template>


  <!-- copy everything else through to final output -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
