<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xccdf">

<!-- This transform expects stringparams "bash_remediations", "ansible_remediations", "puppet_remediations",
     "anaconda_remediations", "ignition_remediations", "kubernetes_remediations"
     specifying a filenames containing a list of remediations.  It inserts these into the Rules
     specified inside the remediations file. -->
<xsl:param name="bash_remediations"/>
<xsl:param name="ansible_remediations"/>
<xsl:param name="puppet_remediations"/>
<xsl:param name="anaconda_remediations"/>
<xsl:param name="ignition_remediations"/>
<xsl:param name="kubernetes_remediations"/>

<xsl:variable name="bash_remediations_doc" select="document($bash_remediations)" />
<xsl:variable name="bash_fixgroup" select="$bash_remediations_doc/xccdf:fix-content/xccdf:fix-group" />
<xsl:variable name="bash_fixcommongroup" select="$bash_remediations_doc/xccdf:fix-content/xccdf:fix-common-group" />

<xsl:variable name="ansible_remediations_doc" select="document($ansible_remediations)" />
<xsl:variable name="ansible_fixgroup" select="$ansible_remediations_doc/xccdf:fix-content/xccdf:fix-group" />
<xsl:variable name="ansible_fixcommongroup" select="$ansible_remediations_doc/xccdf:fix-content/xccdf:fix-common-group" />

<xsl:variable name="puppet_remediations_doc" select="document($puppet_remediations)" />
<xsl:variable name="puppet_fixgroup" select="$puppet_remediations_doc/xccdf:fix-content/xccdf:fix-group" />
<xsl:variable name="puppet_fixcommongroup" select="$puppet_remediations_doc/xccdf:fix-content/xccdf:fix-common-group" />

<xsl:variable name="anaconda_remediations_doc" select="document($anaconda_remediations)" />
<xsl:variable name="anaconda_fixgroup" select="$anaconda_remediations_doc/xccdf:fix-content/xccdf:fix-group" />
<xsl:variable name="anaconda_fixcommongroup" select="$anaconda_remediations_doc/xccdf:fix-content/xccdf:fix-common-group" />

<xsl:variable name="ignition_remediations_doc" select="document($ignition_remediations)" />
<xsl:variable name="ignition_fixgroup" select="$ignition_remediations_doc/xccdf:fix-content/xccdf:fix-group" />
<xsl:variable name="ignition_fixcommongroup" select="$ignition_remediations_doc/xccdf:fix-content/xccdf:fix-common-group" />

<xsl:variable name="kubernetes_remediations_doc" select="document($kubernetes_remediations)" />
<xsl:variable name="kubernetes_fixgroup" select="$kubernetes_remediations_doc/xccdf:fix-content/xccdf:fix-group" />
<xsl:variable name="kubernetes_fixcommongroup" select="$kubernetes_remediations_doc/xccdf:fix-content/xccdf:fix-common-group" />



<xsl:variable name="fixgroups" select="$bash_fixgroup | $ansible_fixgroup | $puppet_fixgroup | $anaconda_fixgroup | $ignition_fixgroup | $kubernetes_fixgroup" />
<xsl:variable name="fixcommongroups" select="$bash_fixcommongroup | $ansible_fixcommongroup | $puppet_fixcommongroup | $anaconda_fixcommongroup | $ignition_fixcommongroup | $kubernetes_fixcommongroup" />

<xsl:template name="find-and-replace">
  <xsl:param name="text"/>
  <xsl:param name="replace"/>
  <xsl:param name="with"/>
  <xsl:choose>
    <xsl:when test="contains($text,$replace)">
      <xsl:value-of select="substring-before($text,$replace)"/>
      <xsl:value-of select="$with"/>
      <xsl:call-template name="find-and-replace">
        <xsl:with-param name="text" select="substring-after($text,$replace)"/>
        <xsl:with-param name="replace" select="$replace"/>
        <xsl:with-param name="with" select="$with"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$text" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="text()" mode="fix_contents">
  <xsl:param name="rule"/>
  <xsl:param name="fix"/>
  <xsl:variable name="rep0" select="."/>

  <xsl:variable name="ident_cce" select="$rule/xccdf:ident[@system='https://nvd.nist.gov/cce/index.cfm']/text()"/>

  <xsl:variable name="rep1">
    <xsl:call-template name="find-and-replace">
      <xsl:with-param name="text" select="$rep0"/>
      <xsl:with-param name="replace" select="'@CCENUM@'"/>
      <xsl:with-param name="with" select="$ident_cce"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:value-of select="$rep1"/>
</xsl:template>

<xsl:template match="@* | node()" mode="fix_contents">
  <xsl:param name="rule"/>
  <xsl:param name="fix"/>
  <xsl:copy>
    <xsl:apply-templates select="@* | node()" mode="fix_contents">
      <xsl:with-param name="rule" select="$rule"/>
      <xsl:with-param name="fix" select="$fix"/>
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<xsl:template match="xccdf:Rule">
  <xsl:copy>
    <!-- deal with the fact that oscap demands fixes stand only before checks -->
    <xsl:apply-templates select="@*|node()[not(self::xccdf:check)]"/>

    <xsl:variable name="rule" select="."/>
    <xsl:variable name="rule_id" select="$rule/@id"/>

    <xsl:for-each select="$fixgroups/xccdf:fix[@rule=$rule_id]">
      <xsl:variable name="fix" select="."/>
      <xsl:element name="fix" namespace="http://checklists.nist.gov/xccdf/1.1">
        <xsl:attribute name="system"><xsl:value-of select="../@system"/></xsl:attribute>
        <xsl:attribute name="id"><xsl:value-of select="$rule_id"/></xsl:attribute>
        <xsl:if test="@complexity != ''">
          <xsl:attribute name="complexity"><xsl:value-of select="@complexity"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="@disruption != ''">
          <xsl:attribute name="disruption"><xsl:value-of select="@disruption"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="@platform != ''">
          <xsl:attribute name="platform"><xsl:value-of select="@platform"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="@reboot != ''">
          <xsl:attribute name="reboot"><xsl:value-of select="@reboot"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="@strategy != ''">
          <xsl:attribute name="strategy"><xsl:value-of select="@strategy"/></xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="node()" mode="fix_contents">
          <xsl:with-param name="rule" select="$rule"/>
          <xsl:with-param name="fix" select="$fix"/>
        </xsl:apply-templates>
      </xsl:element>
    </xsl:for-each>

    <xsl:apply-templates select="node()[self::xccdf:check]"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="xccdf:Benchmark">

  <xsl:copy>
    <!-- plain-text elements must appear in sequence -->
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates select="xccdf:status"/>
    <xsl:apply-templates select="xccdf:dc-status"/>
    <xsl:apply-templates select="xccdf:title"/>
    <xsl:apply-templates select="xccdf:description"/>
    <xsl:apply-templates select="xccdf:notice"/>
    <xsl:apply-templates select="xccdf:front-matter"/>
    <xsl:apply-templates select="xccdf:rear-matter"/>
    <xsl:apply-templates select="xccdf:reference"/>

    <xsl:for-each select="$fixcommongroups/xccdf:fix-common">
      <xsl:variable name="fix_common_id" select="@id"/>
      <xsl:element name="plain-text" namespace="http://checklists.nist.gov/xccdf/1.1">
      <xsl:attribute name="id"><xsl:value-of select="$fix_common_id"/></xsl:attribute>
      <xsl:value-of select="text()"/>
      </xsl:element>
    </xsl:for-each>
    <xsl:apply-templates select="node()[not(self::xccdf:status|self::xccdf:dc-title|self::xccdf:title|self::xccdf:description|self::xccdf:notice|self::xccdf:front-matter|self::xccdf:rear-matter|self::xccdf:reference)]"/>
<!--
    <xsl:apply-templates select="node()[not(self::xccdf:status)]"/>
-->
  </xsl:copy>
</xsl:template>

<!-- copy everything else through to final output -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()" />
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
