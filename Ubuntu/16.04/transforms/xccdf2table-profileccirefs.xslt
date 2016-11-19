<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:cci="http://iase.disa.mil/cci" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:ovalns="http://oval.mitre.org/XMLSchema/oval-definitions-5">

<xsl:import href="../../../shared/transforms/shared_xccdf2table-profileccirefs.xslt"/>

<xsl:variable name="cci_list" select="document('../../../shared/references/disa-cci-list.xml')/cci:cci_list" />
<xsl:variable name="os_srg" select="document('../../../shared/references/disa-os-srg-v1r4.xml')/cdf:Benchmark" />
<xsl:variable name="ovaldefs" select="document('../output/unlinked-ubuntu1604-oval.xml')/ovalns:oval_definitions" />

<xsl:include href="constants.xslt"/>
<xsl:include href="table-style.xslt"/>

</xsl:stylesheet>
