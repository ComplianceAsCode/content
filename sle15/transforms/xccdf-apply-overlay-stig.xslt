<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://checklists.nist.gov/xccdf/1.1" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xccdf">

<xsl:include href="../../shared/transforms/shared_xccdf-apply-overlay-stig.xslt"/>
<xsl:include href="constants.xslt"/>
<xsl:variable name="overlays" select="document($overlay)/xccdf:overlays" />

</xsl:stylesheet>
