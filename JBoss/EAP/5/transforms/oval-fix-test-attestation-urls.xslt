<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:oval-def="http://oval.mitre.org/XMLSchema/oval-definitions-5">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>



  <!-- This transform takes an OVAL document as input and expands
       'test_attestation' value in the 'ref_url' <reference> attribute
       to proper GitHub SCAP Security Guide Contributors URL:
         [1] https://github.com/OpenSCAP/scap-security-guide/wiki/Contributors

       The valid URLs in the OVAL document's "ref_url" attribute are
       required in order to the OVAL HTML report to contain valid links,
       when inspected via toolks like e.g. "linklint".

       This fixes Red Hat downstream bug for OVAL files produced by
       SCAP Security Guide:
         [2] https://bugzilla.redhat.com/show_bug.cgi?id=1155809

       DO NOT REMOVE THIS TRANSFORMATION! -->



  <xsl:include href="constants.xslt"/>

  <!-- First copy the input OVAL into the output OVAL -->
  <xsl:template match="@*|node()" priority="-2">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <!-- Then update 'test_attestation' URL's in "ref_url" attribute
       of the <reference> element to be a valid URL pointing to [1] -->
  <xsl:template match="@ref_url">
    <xsl:attribute name="ref_url">
      <xsl:if test=". = 'test_attestation'">
        <xsl:value-of select="$ssg-contributors-uri" />
      </xsl:if>
    </xsl:attribute>
  </xsl:template>

</xsl:stylesheet>
