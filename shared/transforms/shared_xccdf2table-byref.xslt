<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<!-- this style sheet expects parameter $ref, the abbreviation of the reference type to be shown -->

	<xsl:template name="ref-translate">
		<xsl:param name="ref" />
		<xsl:choose>
			<xsl:when test="$ref='pcidss'">PCI DSS</xsl:when>
			<xsl:otherwise><xsl:value-of select="$ref" /></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Return page to PCI-DSS v3 document-->
	<xsl:template name="pci-dss-links">
		<xsl:param name="ref" />
			<xsl:choose>
				<xsl:when test="starts-with($ref,'Req-12')">97</xsl:when>
				<xsl:when test="starts-with($ref,'Req-11')">89</xsl:when>
				<xsl:when test="starts-with($ref,'Req-10')">82</xsl:when>
				<xsl:when test="starts-with($ref,'Req-9')">73</xsl:when>
				<xsl:when test="starts-with($ref,'Req-8')">64</xsl:when>
				<xsl:when test="starts-with($ref,'Req-7')">61</xsl:when>
				<xsl:when test="starts-with($ref,'Req-6')">49</xsl:when>
				<xsl:when test="starts-with($ref,'Req-5')">46</xsl:when>
				<xsl:when test="starts-with($ref,'Req-4')">44</xsl:when>
				<xsl:when test="starts-with($ref,'Req-3')">34</xsl:when>
				<xsl:when test="starts-with($ref,'Req-2')">28</xsl:when>
				<xsl:when test="starts-with($ref,'Req-1')">19</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
	</xsl:template>

	<!-- Return link PCI-DSS pdf document with corresponding #page -->
	<xsl:template name="get-pci-dss-href">
		<xsl:param name="ref" />

		<xsl:variable name="page">
			<xsl:call-template name="pci-dss-links">
				<xsl:with-param name="ref" select="$ref" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$page=0">
				<xsl:value-of select="$pcidssuri" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($pcidssuri,concat('#page=',$page))" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="/">
		<html>
		<head>
			<title> Rules with
			<xsl:call-template name="ref-translate">
				<xsl:with-param name="ref" select="$ref" />
			</xsl:call-template>
			Reference in <xsl:value-of select="/cdf:Benchmark/cdf:title" /> </title>
		</head>
		<body>
			<br/>
			<br/>
			<div style="text-align: center; font-size: x-large; font-weight:bold">
			Rules with  <xsl:call-template name="ref-translate">
							<xsl:with-param name="ref" select="$ref" />
						</xsl:call-template> Reference in <xsl:value-of select="/cdf:Benchmark/cdf:title" />
			</div>
			<br/>
			<br/>
			<xsl:apply-templates select="cdf:Benchmark"/>
		</body>
		</html>
	</xsl:template>


	<xsl:template match="cdf:Benchmark">
		<xsl:call-template name="table-style" />
		<table>
			<thead>
				<td>Reference (<xsl:call-template name="ref-translate"><xsl:with-param name="ref" select="$ref" /></xsl:call-template>)</td>
				<td>Rule Title</td>
				<td>Description</td>
				<td>Rationale</td>
				<td>Variable Setting</td>
			</thead>

			<xsl:if test="$ref='nist'">
				<xsl:for-each select="//cdf:reference[@href=$nist800-53uri]" >
					<xsl:call-template name="rule-output">
						<xsl:with-param name="refinfo" select="." />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>

                        <xsl:if test="$ref='cjis'">
                                <xsl:for-each select="//cdf:reference[@href=$cjisd-its-uri]" >
                                        <xsl:call-template name="rule-output">
                                                <xsl:with-param name="refinfo" select="." />
                                        </xsl:call-template>
                                </xsl:for-each>
                        </xsl:if>

                        <xsl:if test="$ref='ospp'">
                                <xsl:for-each select="//cdf:reference[@href=$osppuri]" >
                                        <xsl:call-template name="rule-output">
                                                <xsl:with-param name="refinfo" select="." />
                                        </xsl:call-template>
                                </xsl:for-each>
                        </xsl:if>

			<xsl:if test="$ref='cui'">
                                <xsl:for-each select="//cdf:reference[@href=$nist800-171uri]" >
                                        <xsl:call-template name="rule-output">
                                                <xsl:with-param name="refinfo" select="." />
                                        </xsl:call-template>
                                </xsl:for-each>
                        </xsl:if>

			<xsl:if test="$ref='cis'">
				<xsl:for-each select="//cdf:reference[@href=$cisuri]" >
					<xsl:call-template name="rule-output">
						<xsl:with-param name="refinfo" select="." />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="$ref='cnss'">
				<xsl:for-each select="//cdf:reference[@href=$cnss1253uri]" >
					<xsl:call-template name="rule-output">
						<xsl:with-param name="refinfo" select="." />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="$ref='pcidss'">
				<xsl:for-each select="//cdf:reference[@href=$pcidssuri]" >
					<xsl:sort select="substring-after(.,'-')" data-type="number" />
					<xsl:call-template name="pci-dss-rule-output">
						<xsl:with-param name="refinfo" select="." />
					</xsl:call-template>

				</xsl:for-each>
			</xsl:if>

			<xsl:if test="$ref='anssi'">
				<xsl:for-each select="//cdf:reference[@href=$anssiuri]" >
					<!-- There can be ANSSI references for NT28, NT007 and NT012,
						let's sort by document and requirement number -->
					<xsl:sort select="substring-before(.,'(')" data-type="text" />
					<xsl:sort select="substring-before(substring-after(.,'(R'),')')" data-type="number" />
					<xsl:call-template name="rule-output">
						<xsl:with-param name="refinfo" select="." />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>

		</table>
	</xsl:template>

	<xsl:template name="pci-dss-rule-output">
		<xsl:param name="refinfo"/>
		<tr>
			<td>
			<a>
				<xsl:attribute name="href">
					<xsl:call-template name="get-pci-dss-href">
						<xsl:with-param name="ref" select="$refinfo" />
					</xsl:call-template>
				</xsl:attribute>
				<xsl:value-of select="$refinfo" />
			</a>
			</td>

			<td> <xsl:value-of select="../cdf:title" /></td>
			<td> <xsl:apply-templates select="../cdf:description"/> </td>
			<td> <xsl:apply-templates select="../cdf:rationale"/> </td>
			<td> <!-- TODO: print refine-value from profile associated with rule --> </td>
		</tr>
	</xsl:template>

	<xsl:template name="rule-output">
          <xsl:param name="refinfo"/>
		<tr>
			<td> 
			<xsl:value-of select="$refinfo"/>
			</td> 
			<!--<td> <xsl:value-of select="cdf:ident" /></td>-->
			<td> <xsl:value-of select="../cdf:title" /></td>
			<td> <xsl:apply-templates select="../cdf:description"/> </td>
			<td> <xsl:apply-templates select="../cdf:rationale"/> </td>
			<td> <!-- TODO: print refine-value from profile associated with rule --> </td>
		</tr>
	</xsl:template>


	<!-- getting rid of XHTML namespace -->
	<xsl:template match="xhtml:*">
		<xsl:element name="{local-name()}">
 			<xsl:apply-templates select="node()|@*"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="cdf:description">
		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="cdf:rationale">
		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

</xsl:stylesheet>
