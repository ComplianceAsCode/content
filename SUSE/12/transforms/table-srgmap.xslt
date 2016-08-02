<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<xsl:include href="../../../shared/transforms/shared_table-srgmap.xslt"/>
<xsl:include href="constants.xslt"/>
<xsl:include href="table-style.xslt"/>

<xsl:variable name="items" select="document($map-to-items)//*[cdf:reference]" />
<xsl:variable name="title" select="document($map-to-items)/cdf:Benchmark/cdf:title" />

</xsl:stylesheet>
