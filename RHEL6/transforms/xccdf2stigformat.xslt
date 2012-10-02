<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xccdf">

<!-- This transform transforms that project's main XCCDF content 
     into the format expected in a DISA STIG. -->

<xsl:include href="constants.xslt"/>

  <xsl:template match="xccdf:Benchmark">
	<Benchmark xmlns:dsig="http://www.w3.org/2000/09/xmldsig#" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:cpe="http://cpe.mitre.org/language/2.0" xmlns:dc="http://purl.org/dc/elements/1.1/"
xmlns="http://checklists.nist.gov/xccdf/1.1" id="RHEL_6_STIG" xml:lang="en"
xsi:schemaLocation="http://checklists.nist.gov/xccdf/1.1 http://nvd.nist.gov/schema/xccdf-1.1.4.xsd http://cpe.mitre.org/dictionary/2.0 http://cpe.mitre.org/files/cpe-dictionary_2.1.xsd">
	<status date="2012-10-01">pre-draft</status>
	<title>Pre-Draft Red Hat Enterprise Linux 6 Security Technical Implementation Guide</title>
	<description>The Red Hat Enterprise Linux 6 Security Technical Implementation Guide (STIG) is published as a tool to improve the security of Department of Defense (DoD) information systems. Comments or proposed revisions to this document should be sent via e-mail to the following address: fso_spt@disa.mil.</description>
	<notice id="terms-of-use" xml:lang="en" />
	<!-- this is here as a placeholder, prior to any publication.  this is PRE-DRAFT, NON-RELEASE material. -->
	<reference href="http://iase.disa.mil">
         <dc:publisher>DISA, Field Security Operations</dc:publisher>
         <dc:source>iase.disa.mil</dc:source>
	</reference>
	<version>0.7</version>

	<!-- retain desired Profile -->
	<xsl:apply-templates select="xccdf:Profile" />
	<!-- retain all Values -->
	<xsl:apply-templates select=".//xccdf:Value" />
	<!-- retain Rules only from the selected Profile -->
	<xsl:apply-templates select=".//xccdf:Rule" />
	</Benchmark>
  </xsl:template>


  <xsl:template match="xccdf:Profile">
  	<xsl:if test="@id=$profile">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:if>
  </xsl:template>


  <xsl:template match="xccdf:Value">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
  </xsl:template>


  <xsl:template match="xccdf:Rule">
    <Group>
    <xsl:attribute name="id">groupid</xsl:attribute>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
    </Group>
  </xsl:template>


  <xsl:template match="@*|node()">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()" />
	</xsl:copy>
  </xsl:template>

</xsl:stylesheet>
