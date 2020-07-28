<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://checklists.nist.gov/xccdf/1.1" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dc="http://purl.org/dc/elements/1.1/" exclude-result-prefixes="cdf">

<!-- This transforms a body of XCCDF content into the format expected in a DISA
     STIG. It expects an XCCDF file with exactly one Profile.
     -->

<xsl:strip-space elements="*" />
<xsl:output method="xml" indent="yes" />

<xsl:param name="profile" select="''" />

  <xsl:template match="cdf:Benchmark">
	<Benchmark xmlns:dsig="http://www.w3.org/2000/09/xmldsig#" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:cpe="http://cpe.mitre.org/language/2.0" xmlns:dc="http://purl.org/dc/elements/1.1/"
xmlns="http://checklists.nist.gov/xccdf/1.1" id="{$product_stig_id_name}" xml:lang="en"
xsi:schemaLocation="http://checklists.nist.gov/xccdf/1.1 http://nvd.nist.gov/schema/xccdf-1.1.4.xsd http://cpe.mitre.org/dictionary/2.0 http://cpe.mitre.org/files/cpe-dictionary_2.1.xsd">
	<status date="2012-10-01">draft</status>
	<title>Pre-Draft <xsl:value-of select="$product_long_name" /> Security Technical Implementation Guide</title>
	<description>The <xsl:value-of select="$product_long_name" /> Security Technical Implementation Guide (STIG) is published as a tool to improve the security of Department of Defense (DoD) information systems. Comments or proposed revisions to this document should be sent via e-mail to the following address: disa.stig@mail.mil.</description>
	<notice id="terms-of-use" xml:lang="en" />
	<reference href="https://public.cyber.mil">
	<!-- this is here as a placeholder, prior to any publication.  this is PRE-DRAFT, NON-RELEASE material. -->
         <dc:publisher>DISA, Field Security Operations</dc:publisher>
         <dc:source>public.cyber.mil</dc:source>
	</reference>
	<version>0.7</version>

	<!-- retain desired Profile -->
	<xsl:apply-templates select="cdf:Profile" />
	<!-- retain all Values -->
	<xsl:apply-templates select=".//cdf:Value" />
	<!-- retain all Values -->
	<xsl:apply-templates select="//cdf:Rule" />
	</Benchmark>
  </xsl:template>

  <xsl:template match="cdf:Profile">
  	<xsl:if test="@id=$profile">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:if>
  </xsl:template>

  <xsl:template match="cdf:Value">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
  </xsl:template>


  <xsl:template match="cdf:Rule">
	<xsl:variable name="ruleid" select="@id"/>
	<!-- process Rule only if it's in the selected Profile -->
	<xsl:if test="/cdf:Benchmark/cdf:Profile[@id=$profile]/cdf:select[@idref=$ruleid]">

    <Group>
    <xsl:attribute name="id">V-<xsl:value-of select="position()"/></xsl:attribute>
    <title>GEN<xsl:value-of select="format-number(position(),'000000')"/></title>
    <description>GroupDescription</description>
	<!-- if desire exists to change id to format "SV-{position()}r0_rule", must also do so in Profile -->
    <Rule id="{@id}" severity="{@severity}" weight="10.0">
    	<version>GroupTitle</version>
		<title><xsl:value-of select="cdf:title"/></title>
		<description>
			<xsl:apply-templates select="cdf:rationale/node()"/>
		</description>
		<reference>
			<dc:title>VMS Target <xsl:value-of select="$product_long_name" /></dc:title>
			<dc:publisher>DISA FSO</dc:publisher>
			<dc:type>VMS Target</dc:type>
			<dc:subject><xsl:value-of select="$product_long_name" /></dc:subject>
			<dc:identifier>2400</dc:identifier>
		</reference>
		<xsl:for-each select="cdf:reference[@href=$disa-cciuri]">
			<ident system="{$disa-cciuri}"><xsl:value-of select="text()"/></ident>
		</xsl:for-each>
		<xsl:for-each select="cdf:reference[@href=$disa-ossrguri]">
			<ident system="{$disa-ossrguri}"><xsl:value-of select="text()"/></ident>
		</xsl:for-each>
                <xsl:for-each select="cdf:reference[@href=$disa-appsrguri]">
                        <ident system="{$disa-appsrguri}"><xsl:value-of select="text()"/></ident>
                </xsl:for-each>
		<fixtext fixref="{@id}_fix">
			<xsl:apply-templates select="cdf:description/node()"/>
		</fixtext>
		<check system="{concat('C-',position(),'_chk')}">
			<check-content>
				<xsl:value-of select="cdf:check[@system='ocil-transitional']/cdf:check-content"/>
			</check-content>
		</check>
    </Rule>
    </Group>
    </xsl:if>
  </xsl:template>


  <xsl:template match="@*|node()">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()" />
	</xsl:copy>
  </xsl:template>

</xsl:stylesheet>
