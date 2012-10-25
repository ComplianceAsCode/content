<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<!-- this style sheet expects parameter $ref, which is the abbreviation of the ref to be shown -->

<!-- optionally, the style sheet can receive parameter $delim, will result in splitting of references onto 
     separate rows of output -->

<xsl:param name="delim"/>

<xsl:include href="constants.xslt"/>

	<xsl:template match="/">
		<html>
		<head>
			<title> Rules with <xsl:value-of select="$ref"/> Reference in <xsl:value-of select="/cdf:Benchmark/cdf:title" /> </title>
		</head>
		<body>
			<br/>
			<br/>
			<div style="text-align: center; font-size: x-large; font-weight:bold">
			Rules with <xsl:value-of select="$ref"/> Reference in <xsl:value-of select="/cdf:Benchmark/cdf:title" />
			</div>
			<br/>
			<br/>
			<xsl:apply-templates select="cdf:Benchmark"/>
		</body>
		</html>
	</xsl:template>


	<xsl:template match="cdf:Benchmark">
		<style type="text/css">
		table
		{
			border-collapse:collapse;
		}
		table,th, td
		{
			border: 1px solid black;
			vertical-align: top;
			padding: 3px;
		}
		thead
		{
			display: table-header-group;
			font-weight: bold;
		}
		</style>
		<table>
			<thead>
				<td>Reference (<xsl:value-of select="$ref"/>)</td>
				<td>Rule Title</td>
				<td>Description</td>
				<td>Rationale</td>
				<td>Variable Setting</td>
			</thead>

                <xsl:apply-templates select=".//cdf:Rule" />
		</table>
	</xsl:template>


	<xsl:template name="rule-output">
          <xsl:param name="refstring"/>
		<tr>
			<td> 
			<xsl:value-of select="$refstring"/>
			</td> 
			<!--<td> <xsl:value-of select="cdf:ident" /></td>-->
			<td> <xsl:value-of select="cdf:title" /></td>
			<td> <xsl:apply-templates select="cdf:description"/> </td>
			<!-- call template to grab text and also child nodes (which should all be xhtml)  -->
			<!-- need to resolve <sub idref=""> here  -->
			<td> <xsl:apply-templates select="cdf:rationale"/> </td>
			<td> <!-- TODO: print refine-value from profile associated with rule --> </td>
		</tr>
        </xsl:template>


	<xsl:template name="rule-info">
		<xsl:param name="refinfo"/>
		<!-- <xsl:variable name="$delim" select="','" /> -->

		<xsl:choose>
			<xsl:when test="$delim and contains($refinfo, $delim)">
				<!-- output the rule -->
				<xsl:call-template name="rule-output" >
					<xsl:with-param name="refstring" select="substring-before($refinfo, $delim)" />
				</xsl:call-template>

				<!-- recurse for additional refs -->
				<xsl:call-template name="rule-info">
					<xsl:with-param name="refinfo" select="substring-after($refinfo, $delim)" />
				</xsl:call-template>
			</xsl:when>

		 	<xsl:otherwise>
				<xsl:call-template name="rule-output" >
					<xsl:with-param name="refstring" select="$refinfo" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	 
	</xsl:template>


	<xsl:template match="cdf:Rule">
		  <xsl:if test="cdf:reference[@href=$nist800-53uri] and $ref='nist'">
                    <xsl:call-template name="rule-info">
		      <xsl:with-param name="refinfo" select="cdf:reference[@href=$nist800-53uri]" />
                    </xsl:call-template>
		  </xsl:if>
		  <xsl:if test="cdf:reference[@href=$dcid63uri] and $ref='dcid'">
                    <xsl:call-template name="rule-info">
		      <xsl:with-param name="refinfo" select="cdf:reference[@href=$dcid63uri]" />
                    </xsl:call-template>
		  </xsl:if>
		  <xsl:if test="cdf:reference[@href=$cnss1253uri] and $ref='cnss'">
                    <xsl:call-template name="rule-info">
		      <xsl:with-param name="refinfo" select="cdf:reference[@href=$cnss1253uri]" />
                    </xsl:call-template>
		  </xsl:if>
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
