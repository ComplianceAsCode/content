<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://checklists.nist.gov/xccdf/1.1" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xccdf">

<xsl:output method="xml" indent="yes"/>

<!-- This transform expects a stringparam "overlay" which specifies a filename
     containing a list of "overlays" onto which the project's
     content will be projected.  New Rules can thus be created based on external
     parties' identifiers or titles. -->

  <xsl:template match="xccdf:Benchmark">
    <xsl:copy>
    <title>Pre-release Final STIG for <xsl:value-of select="$product_long_name" /></title>

  	<xsl:variable name="rules" select="//xccdf:Rule"/>

    <xsl:for-each select="$overlays/xccdf:overlay">  <!-- make sure overlays file namespace is XCCDF (hack) -->
      <xsl:variable name="overlay_id" select="@ownerid"/>
      <xsl:variable name="overlay_rule" select="@ruleid"/>
      <xsl:variable name="overlay_severity" select="@severity"/>
      <xsl:variable name="overlay_ref" select="@disa"/>
      <xsl:variable name="overlay_title" select="xccdf:title/text()"/>

      <xsl:for-each select="$rules">
        <xsl:if test="@id=$overlay_rule">
		  <Group id="{$overlay_id}">
		    <title>SRG-OS-ID</title>
		    <description></description>
            <Rule id="{$overlay_rule}" severity="{$overlay_severity}" >
			<version><xsl:value-of select="$overlay_id"/></version>
          	<title><xsl:value-of select="$overlay_title"/></title>
          	<description><xsl:copy-of select="xccdf:rationale/node()" /></description>
          	<check system="C-{$overlay_id}_chk">
          		<check-content><xsl:copy-of select="xccdf:check[@system='ocil-transitional']/xccdf:check-content/node()" />

          		If <xsl:value-of select="xccdf:check[@system='ocil-transitional']/xccdf:check-export/@export-name" />, this is a finding.
          		</check-content>
          	</check>
		  	<ident system="http://iase.disa.mil/cci"><xsl:value-of select="concat('CCI-', format-number($overlay_ref,'000000'))" /></ident>
          	<fixtext><xsl:copy-of select="xccdf:description/node()" /></fixtext>
          </Rule> 
          </Group>
        </xsl:if>
      </xsl:for-each> 

    </xsl:for-each> 
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
