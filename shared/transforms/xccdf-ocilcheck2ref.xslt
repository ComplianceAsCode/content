<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xccdf">

<xsl:include href="shared_constants.xslt"/>

  <!-- Replace check system attribute with the real OCIL one -->
  <xsl:template match="xccdf:check[@system='ocil-transitional']">
    <xsl:copy>
		<xsl:apply-templates select="@*" />
		<xsl:attribute name="system"><xsl:value-of select="$ocil_cs" /></xsl:attribute>
      <xsl:apply-templates select="node()" />
    </xsl:copy>
  </xsl:template>

  <!-- Remove OCIL <check-export> nodes since they were used only to append the appropriate question
       to OCIL <check-content> nodes by previous run of $(SHARED)/$(TRANS)/xccdf-create-ocil.xslt.
       But at this state of building the content this has been already finished.
       Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1189
       Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1190 -->
  <xsl:template match="xccdf:check-export[@value-id='conditional_clause']"/>

  <!-- Remove the "conditional_clause" <xccdf:Value> since it was required only to expand OCIL macros
       to insert proper questions when creating OCIL content. At this stage the OCIL content was built
       alreaady, thus "conditional_clause" is not needed anymore in the final XCCDF benchmark (and only
       causing confusion e.g. in SCAP Workbench tool -->
  <xsl:template match="xccdf:Value[@id='conditional_clause']"/>

  <!-- Remove check-content nodes and replace them with a check-content-ref node, using the Rule id
       to create a reference name -->
  <xsl:template match="xccdf:check-content">
    <xsl:element name="check-content-ref" namespace="http://checklists.nist.gov/xccdf/1.1">
      <xsl:attribute name="href">ocil-unlinked.xml</xsl:attribute>
      <xsl:attribute name="name"><xsl:value-of select="../../@id"/>_ocil</xsl:attribute>
    </xsl:element>
  </xsl:template>

  <!-- Copy everything else through to final output -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
