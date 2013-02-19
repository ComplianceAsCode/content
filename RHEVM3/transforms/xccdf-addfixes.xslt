<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xccdf">

<!-- This transform expects a stringparam "fixes" specifying a filename
     containing a list of fixes.  It inserts these into the Rules 
     specified inside the fixes file. -->

<xsl:variable name="fixgroup" select="document($fixes)/xccdf:fix-group" />
<xsl:variable name="fixsystem" select="$fixgroup/@system"/>

  <xsl:template match="xccdf:Rule">
    <xsl:copy>
	  <!-- deal with the fact that oscap demands fixes stand only before checks -->
      <xsl:apply-templates select="@*|node()[not(self::xccdf:check)]"/>

      <xsl:variable name="rule_id" select="@id"/>
      <xsl:for-each select="$fixgroup/xccdf:fix"> 
        <xsl:if test="@rule=$rule_id">
          <xsl:element name="fix" namespace="http://checklists.nist.gov/xccdf/1.1">
          <xsl:attribute name="system"><xsl:value-of select="$fixsystem"/></xsl:attribute>
          <xsl:value-of select="text()"/>
          </xsl:element>
        </xsl:if>
      </xsl:for-each> 
      <xsl:apply-templates select="node()[self::xccdf:check]"/>

    </xsl:copy>
  </xsl:template>


  <!-- copy everything else through to final output -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
