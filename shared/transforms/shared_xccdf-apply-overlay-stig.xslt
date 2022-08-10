<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://checklists.nist.gov/xccdf/1.2" xmlns:xccdf-1.1="http://checklists.nist.gov/xccdf/1.1"  xmlns:xccdf-1.2="http://checklists.nist.gov/xccdf/1.2" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:ocil2="http://scap.nist.gov/schema/ocil/2.0" exclude-result-prefixes="xccdf-1.2">

<xsl:output method="xml" indent="yes"/>

<!-- This transform expects a stringparam "overlay" which specifies a filename
     containing a list of "overlays" onto which the project's
     content will be projected.  New Rules can thus be created based on external
     parties' identifiers or titles. -->
  <xsl:param name="ocil-document" select="''"/>
  <xsl:variable name="ocil" select="document($ocil-document)/ocil2:ocil"/>

  <xsl:template match="xccdf-1.2:Benchmark">
    <xsl:copy>
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>

    <title>DISA STIG for <xsl:value-of select="$product_long_name" /></title>

	<xsl:variable name="rules" select="//xccdf-1.2:Rule"/>

    <xsl:for-each select="$overlays/xccdf-1.1:overlay">  <!-- make sure overlays file namespace is XCCDF (hack) -->
      <xsl:variable name="overlay_id" select="xccdf-1.1:VMSinfo/@VKey"/>
      <xsl:variable name="overlay_version" select="@ownerid"/>
      <xsl:variable name="overlay_rule" select="@ruleid"/>
      <xsl:variable name="overlay_severity" select="@severity"/>
      <xsl:variable name="overlay_ref" select="@disa"/>
      <xsl:variable name="overlay_title" select="xccdf-1.1:title/@text"/>

      <xsl:choose>
        <xsl:when test="$overlay_rule='XXXX'">
          <Group id="V-{$overlay_id}">
            <title>SRG-OS-ID</title>
            <description></description>
                <Rule id="Missing Rule" severity="{$overlay_severity}" >
          <version><xsl:value-of select="$overlay_version"/></version>
                <title><xsl:value-of select="$overlay_title"/></title>
                <description></description>
                <check system="C-{$overlay_id}_chk">
                  <check-content>
                  </check-content>
                </check>
                <ident></ident>
                <fixtext></fixtext>
              </Rule>
          </Group>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="$rules">
            <xsl:if test="@id = concat('xccdf_org.ssgproject.content_rule_', $overlay_rule)">
          <Group id="V-{$overlay_id}">
            <title>SRG-OS-ID</title>
            <description></description>
                <Rule id="{$overlay_rule}" severity="{$overlay_severity}" >
          <version><xsl:value-of select="$overlay_version"/></version>
                <title><xsl:value-of select="$overlay_title"/></title>
                <description><xsl:copy-of select="xccdf-1.2:rationale/node()" /></description>
                <check system="C-{$overlay_id}_chk">
                  <check-content>
                    <xsl:apply-templates select="xccdf-1.2:check[@system='http://scap.nist.gov/schema/ocil/2']"/>
                  </check-content>
                </check>
            <ident system="https://public.cyber.mil/stigs/cci"><xsl:value-of select="$overlay_ref" /></ident>
                <fixtext><xsl:copy-of select="xccdf-1.2:description/node()" /></fixtext>
              </Rule>
              </Group>
            </xsl:if>
          </xsl:for-each>
        </xsl:otherwise>
    </xsl:choose>

    </xsl:for-each> 
    </xsl:copy>
  </xsl:template>

	<xsl:template match="xccdf-1.2:check[@system='http://scap.nist.gov/schema/ocil/2']">
		<xsl:variable name="questionaireId" select="xccdf-1.2:check-content-ref/@name"/>
		<xsl:variable name="questionaire" select="$ocil/ocil2:questionnaires/ocil2:questionnaire[@id=$questionaireId]"/>
		<xsl:variable name="testActionRef" select="$questionaire/ocil2:actions/ocil2:test_action_ref/text()"/>
		<xsl:variable name="questionRef" select="$ocil/ocil2:test_actions/*[@id=$testActionRef]/@question_ref"/>
		<xsl:value-of select="$ocil/ocil2:questions/ocil2:*[@id=$questionRef]/ocil2:question_text"/>
	</xsl:template>
</xsl:stylesheet>
