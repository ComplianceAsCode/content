<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xccdf">

<!-- This transform expects stringparams "bash_remediations", "ansible_remediations", "puppet_remediations",
     & "anaconda_remediations"
     specifying a filenames containing a list of remediations.  It inserts these into the Rules
     specified inside the remediations file. -->
<xsl:param name="bash_remediations"/>
<xsl:param name="ansible_remediations"/>
<xsl:param name="puppet_remediations"/>
<xsl:param name="anaconda_remediations"/>

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



<xsl:variable name="fixgroups" select="$bash_fixgroup | $ansible_fixgroup | $puppet_fixgroup | $anaconda_fixgroup" />
<xsl:variable name="fixcommongroups" select="$bash_fixcommongroup | $ansible_fixcommongroup | $puppet_fixcommongroup | $anaconda_fixcommongroup" />

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
  <xsl:variable name="ref_nist800_53" select="$rule/xccdf:reference[starts-with(@href, 'http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-53')]/text()"/>
  <xsl:variable name="ref_nist800_171" select="$rule/xccdf:reference[starts-with(@href, 'http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-171')]/text()"/>
  <xsl:variable name="ref_pci_dss" select="$rule/xccdf:reference[starts-with(@href, 'https://www.pcisecuritystandards.org/')]/text()"/>
  <xsl:variable name="ref_cjis" select="$rule/xccdf:reference[starts-with(@href, 'https://www.fbi.gov/file-repository/cjis-security-policy')]/text()"/>
  <xsl:variable name="ref_disa_ossrg" select="$rule/xccdf:reference[starts-with(@href, 'http://iase.disa.mil/stigs/srgs/Pages/index.aspx')]/text()"/>
  <xsl:variable name="ref_disa_stigid" select="$rule/xccdf:reference[starts-with(@href, 'http://iase.disa.mil/stigs/os/unix-linux/Pages/index.aspx')]/text()"/>

  <xsl:variable name="ansible_tags">- <xsl:value-of select="$rule/@id"/>
    - <xsl:value-of select="$rule/@severity"/>_severity<xsl:if test="$fix/@strategy">
    - <xsl:value-of select="$fix/@strategy"/>_strategy</xsl:if><xsl:if test="$fix/@complexity">
    - <xsl:value-of select="$fix/@complexity"/>_complexity</xsl:if><xsl:if test="$fix/@disruption">
    - <xsl:value-of select="$fix/@disruption"/>_disruption</xsl:if><xsl:for-each select="$ident_cce">
    - <xsl:value-of select="."/></xsl:for-each><xsl:for-each select="$ref_nist800_53">
    - NIST-800-53-<xsl:value-of select="."/></xsl:for-each><xsl:for-each select="$ref_nist800_171">
    - NIST-800-171-<xsl:value-of select="."/></xsl:for-each><xsl:for-each select="$ref_pci_dss">
    - PCI-DSS-<xsl:value-of select="."/></xsl:for-each><xsl:for-each select="$ref_cjis">
    - CJIS-<xsl:value-of select="."/></xsl:for-each><xsl:for-each select="$ref_disa_ossrg">
    - DISA-<xsl:value-of select="."/></xsl:for-each><xsl:for-each select="$ref_disa_stigid">
    - DISA-STIG-<xsl:value-of select="."/></xsl:for-each></xsl:variable>

  <xsl:variable name="rep1">
    <xsl:call-template name="find-and-replace">
      <xsl:with-param name="text" select="$rep0"/>
      <xsl:with-param name="replace" select="'@CCENUM@'"/>
      <xsl:with-param name="with" select="$ident_cce"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="rep2">
    <xsl:call-template name="find-and-replace">
      <xsl:with-param name="text" select="$rep1"/>
      <xsl:with-param name="replace" select="'@ANSIBLE_TAGS@'"/>
      <xsl:with-param name="with" select="$ansible_tags"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="rep3">
    <xsl:call-template name="find-and-replace">
      <xsl:with-param name="text" select="$rep2"/>
      <xsl:with-param name="replace" select="'@RULE_ID@'"/>
      <xsl:with-param name="with" select="$rule/@id"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="rep4">
    <xsl:call-template name="find-and-replace">
      <xsl:with-param name="text" select="$rep3"/>
      <xsl:with-param name="replace" select="'@RULE_TITLE@'"/>
      <xsl:with-param name="with" select="$rule/xccdf:title[1]/text()"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:value-of select="$rep4"/>
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
  <xsl:if test="$bash_remediations='' or not($bash_remediations_doc)">
    <xsl:message terminate="yes">Fatal error while loading "<xsl:value-of select="$bash_remediations"/>".</xsl:message>
  </xsl:if>

  <xsl:if test="$ansible_remediations='' or not($ansible_remediations_doc)">
    <xsl:message terminate="yes">Fatal error while loading "<xsl:value-of select="$ansible_remediations"/>".</xsl:message>
  </xsl:if>

  <xsl:if test="$anaconda_remediations='' or not($anaconda_remediations_doc)">
    <xsl:message terminate="yes">Fatal error while loading "<xsl:value-of select="$anaconda_remediations"/>".</xsl:message>
  </xsl:if>

  <xsl:if test="$puppet_remediations='' or not($puppet_remediations_doc)">
    <xsl:message terminate="yes">Fatal error while loading "<xsl:value-of select="$puppet_remediations"/>".</xsl:message>
  </xsl:if>

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
