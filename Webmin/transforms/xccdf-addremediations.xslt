<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xccdf">

<!-- This transform expects a stringparam "fixes" specifying a filename
     containing a list of fixes.  It inserts these into the Rules 
     specified inside the fixes file. -->

<xsl:variable name="fixgroup" select="document($fixes)/xccdf:fix-content/xccdf:fix-group" />
<xsl:variable name="fixsystem" select="$fixgroup/@system"/>
<xsl:variable name="fixcommongroup" select="document($fixes)/xccdf:fix-content/xccdf:fix-common-group" />

  <xsl:template match="xccdf:Rule">
    <xsl:copy>
	  <!-- deal with the fact that oscap demands fixes stand only before checks -->
      <xsl:apply-templates select="@*|node()[not(self::xccdf:check)]"/>

      <xsl:variable name="rule_id" select="@id"/>
      <xsl:for-each select="$fixgroup/xccdf:fix"> 
        <xsl:if test="@rule=$rule_id">
          <xsl:element name="fix" namespace="http://checklists.nist.gov/xccdf/1.1">
          <xsl:attribute name="system"><xsl:value-of select="$fixsystem"/></xsl:attribute>
          <xsl:apply-templates select="node()"/>
          </xsl:element>
        </xsl:if>
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

      <xsl:for-each select="$fixcommongroup/xccdf:fix-common">
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
