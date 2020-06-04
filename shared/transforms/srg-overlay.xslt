<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://checklists.nist.gov/xccdf/1.1" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xccdf">
  <xsl:output method="xml" indent="yes"/>
  <!--
  This stylesheet takes
   - Product XCCDF from ComplianceAsCode
   - relevant DISA STIG XCCDF
   - and overlay file information
   and outputs unified XCCDF that serves as a response to DISA STIG SRGs; overlaying information from these three sources.
  -->

  <xsl:param name="productXccdf"/>
  <xsl:param name="profileId" select="'stig'"/>
  <xsl:param name="overlay"/>

  <xsl:variable name="disaOssrgUri">https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cgeneral-purpose-os</xsl:variable>
  <xsl:variable name="disaSrgUri" select="$disaOssrgUri"/>

  <xsl:variable name="title" select="document($productXccdf)/xccdf:Benchmark/xccdf:title" />
  <xsl:variable name="profile" select="document($productXccdf)/xccdf:Benchmark/xccdf:Profile[@id=$profileId]"/>
  <xsl:variable name="selectedRules" select="document($productXccdf)//*[xccdf:reference and @id = $profile/xccdf:select[@selected='true']/@idref]"/>
  <xsl:variable name="overlayRules" select="document($overlay)//Rule"/>

  <xsl:template match="/xccdf:Benchmark">
    <xsl:copy>
      <xsl:attribute name="id">benchmark-with-overlays-for-srg</xsl:attribute>
      <xccdf:status>draft</xccdf:status>
      <xsl:copy-of select="$profile/xccdf:title"/>

      <xsl:variable name="srgsNeeded" select=".//xccdf:Rule/xccdf:version/text()"/>
      <xsl:variable name="srgsImplemented" select="$selectedRules/xccdf:reference[@href=$disaSrgUri][not(text() = preceding::text())]/text()"/>

      <xsl:for-each select="$selectedRules[xccdf:reference[@href=$disaSrgUri]]">
          <xsl:call-template name="copyProductRule">
            <xsl:with-param name="rule" select="."/>
          </xsl:call-template>
      </xsl:for-each>

      <xsl:for-each select=".//xccdf:Rule[not(contains($srgsImplemented, xccdf:version/text()))]">
         <xsl:apply-templates select="."/>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xccdf:Rule">
    <xsl:variable name="disaRule" select="."/>

    <xsl:variable name="override-rtf">
      <xsl:call-template name="findOverlay">
        <xsl:with-param name="cci" select="$disaRule/xccdf:ident/text()"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="override" select="exsl:node-set($override-rtf)//Rule[1]" xmlns:exsl="http://exslt.org/common"/>

    <xsl:if test="$override">
      <xsl:element name="Rule" namespace="http://checklists.nist.gov/xccdf/1.1">
        <xsl:attribute name="id">
          <xsl:value-of select="concat($override/@id, '-overlay-', $disaRule/xccdf:ident/text())"/>
        </xsl:attribute>
        <xsl:attribute name="severity">
          <xsl:value-of select="$disaRule/@severity"/>
        </xsl:attribute>
        <xsl:element name="title">
          <xsl:value-of select="$override/title"/>
        </xsl:element>
        <xsl:element name="description">
          <xsl:value-of select="$override/description"/>
        </xsl:element>
        <xsl:element name="reference">
          <xsl:attribute name="href">
            <xsl:value-of select="$disaSrgUri"/>
          </xsl:attribute>
          <xsl:value-of select="$disaRule/xccdf:version"/>
        </xsl:element>
        <xsl:element name="check">
          <xsl:attribute name="system">http://scap.nist.gov/schema/ocil/2</xsl:attribute>
          <xsl:value-of select="$override/ocil"/>
        </xsl:element>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template name="copyProductRule">
    <xsl:param name="rule"/>
    <xsl:copy-of select="$rule"/>
  </xsl:template>

  <xsl:template name="findOverlay">
    <xsl:param name="cci"/>

    <xsl:variable name="cciNumber" select="concat(',', number(substring-after($cci, 'CCI-')), ',')"/>
    <xsl:variable name="result">
      <xsl:for-each select="$overlayRules">
        <xsl:variable name="relevantCcis" select="concat(',', ./ref/@disa, ',')"/>
        <xsl:if test="contains($relevantCcis, $cciNumber)">
          <xsl:copy-of select="."/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:if test="count($result) > 1">
      <xsl:message terminate="yes">Error: multiple overlays match <xsl:value-of select="$cci"/></xsl:message>
    </xsl:if>

    <xsl:copy-of select="$result"/>
  </xsl:template>
</xsl:stylesheet>