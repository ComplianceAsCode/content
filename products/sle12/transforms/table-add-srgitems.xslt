<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:cci="https://public.cyber.mil/stigs/cci">

<xsl:include href="../../shared/transforms/shared_table-add-srgitems.xslt"/>
<xsl:variable name="srgtable" select="document('../output/table-sle12-srgmap-flat.xhtml')/html/body/table" />
<xsl:variable name="cci_list" select="document('../../shared/references/disa-cci-list.xml')/cci:cci_list" />

</xsl:stylesheet>
