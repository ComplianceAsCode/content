<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >

  <xsl:template match="Benchmark/version">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:copy-of select="node()" />
    </xsl:copy>
    <xsl:if test="'allprofiles'=$profile">
          <xsl:apply-templates select="document('../input/profiles/test.xml')" />
          <xsl:apply-templates select="document('../input/profiles/CS2.xml')" />
          <xsl:apply-templates select="document('../input/profiles/common.xml')" />
          <xsl:apply-templates select="document('../input/profiles/desktop.xml')" />
          <xsl:apply-templates select="document('../input/profiles/server.xml')" />
          <xsl:apply-templates select="document('../input/profiles/ftp.xml')" />
          <xsl:apply-templates select="document('../input/profiles/stig-rhel6-server.xml')" />
    </xsl:if>
  </xsl:template>

  <!-- add attribute selected=false so that Profiles
       can activate Rules as needed -->
  <xsl:template match="Rule">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:attribute name="selected">false</xsl:attribute>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>


  <!-- copy everything else through to final output -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
