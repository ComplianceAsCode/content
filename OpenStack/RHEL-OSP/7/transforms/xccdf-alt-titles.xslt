<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xccdf">

<!-- This transform expects a stringparam "alttitles" specifying a filename
     containing a list of alternative titles.  It replaces existing titles
     in the Rules specified inside the titles file. -->

<xsl:variable name="titles" select="document($alttitles)/xccdf:titles" />

  <xsl:template match="xccdf:Rule">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="rule_id" select="@id"/>
      <xsl:for-each select="$titles/xccdf:title"> 
        <xsl:if test="@rule=$rule_id">
      	  <!-- copy in the new title -->
          <xsl:element name="title" namespace="http://checklists.nist.gov/xccdf/1.1">
          <xsl:value-of select="text()"/>
          </xsl:element>
        </xsl:if>
      </xsl:for-each> 
      <!-- copy everything else that isn't the title-->
      <xsl:apply-templates select="node()[not(self::xccdf:title)]"/>

    </xsl:copy>
  </xsl:template>


  <!-- copy everything else through to final output -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
