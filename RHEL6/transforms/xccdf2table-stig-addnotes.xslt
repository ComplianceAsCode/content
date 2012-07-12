<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<!-- the file for notes is hard-coded below -->

<xsl:variable name="notefile">../input/auxiliary/transition_notes.xml</xsl:variable>
<xsl:variable name="notegroup" select="document($notefile)/notegroup" />

<xsl:include href="constants.xslt"/>

	<xsl:template match="/">
		<html>
		<head>
			<title>Rules In <xsl:value-of select="/cdf:Benchmark/cdf:title" /> with Notes for Transition to RHEL 6 Consensus</title>
		</head>
		<body>
			<br/>
			<br/>
			<div style="text-align: center; font-size: x-large; font-weight:bold">
			Rules In <i><xsl:value-of select="/cdf:Benchmark/cdf:title" /></i> with Notes for Transition to RHEL 6 Consensus
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
				<td>V-ID</td>
				<td>GEN-ID</td>
				<td>Title</td>
				<td>Description</td>
				<td>Fixtext</td>
				<td>Notes</td>
			</thead>

                <xsl:apply-templates select=".//cdf:Group" />
		</table>
	</xsl:template>


	<xsl:template name="rule-output">
          <xsl:param name="vulnid"/>
		<tr>
			<td><xsl:value-of select="@id"/></td> 
			<!--<td> <xsl:value-of select="cdf:ident" /></td>-->
			<td> <xsl:value-of select="cdf:title" /></td>
			<td> <xsl:value-of select="cdf:Rule/cdf:title" /></td>
			<td> <xsl:call-template name="extract-vulndiscussion"><xsl:with-param name="desc" select="cdf:Rule/cdf:description"/></xsl:call-template> </td>
			<td> <xsl:apply-templates select="cdf:Rule/cdf:fixtext"/> </td>
			<td> <xsl:call-template name="print-notes"><xsl:with-param name="vulnid" select="@id"/></xsl:call-template> </td>
		</tr>
     </xsl:template>


	<xsl:template match="cdf:Group">
        <xsl:call-template name="rule-output" select="cdf:Rule">
		    <xsl:with-param name="vulnid" select="@id" />
        </xsl:call-template>
	</xsl:template>


    <xsl:template name="print-notes">
            <xsl:param name="vulnid"/>
		<xsl:for-each select="$notegroup/note">
			<table>
        	<xsl:call-template name="search_vulnidlist" select="note">
		    	<xsl:with-param name="vulnid_sought" select="$vulnid" />
		    	<xsl:with-param name="vulnid_list" select="@ref" />
        	</xsl:call-template>
			</table>
		</xsl:for-each>

    </xsl:template>


  <xsl:template name="search_vulnidlist">
     <xsl:param name="vulnid_sought"/>
     <xsl:param name="vulnid_list"/>
     <xsl:variable name="delim" select="','" />
      <xsl:choose>
        <xsl:when test="$delim and contains($vulnid_list, $delim)">
			<xsl:call-template name="note-output" >
      			<xsl:with-param name="vulnid_sought" select="$vulnid_sought" />
   				<xsl:with-param name="vulnid_found" select="substring-before($vulnid_list, $delim)" />
			</xsl:call-template>

         <!-- recurse for additional vuln ids in list -->
			<xsl:call-template name="search_vulnidlist">
				<xsl:with-param name="vulnid_sought" select="$vulnid_sought" />
				<xsl:with-param name="vulnid_list" select="substring-after($vulnid_list, $delim)" />
			</xsl:call-template>
		</xsl:when>

		<xsl:otherwise>
			<xsl:call-template name="note-output" >
      			<xsl:with-param name="vulnid_sought" select="$vulnid_sought" />
   				<xsl:with-param name="vulnid_found" select="$vulnid_list" />
			</xsl:call-template>
		</xsl:otherwise>

	</xsl:choose>
  </xsl:template>


 <!-- output note text if vuln ID matches -->
  <xsl:template name="note-output">
     <xsl:param name="vulnid_sought"/>
     <xsl:param name="vulnid_found"/>

	 <xsl:variable name="vulnid_expanded" select="concat('V-', $vulnid_found)"  />
	 <xsl:if test="$vulnid_sought=$vulnid_expanded">
		<tr><td><xsl:value-of select="@auth"/>: <xsl:value-of select="." /></td></tr>
	 </xsl:if>

 </xsl:template>


    <!-- return only the text between the "VulnDiscussion" (non-XCCDF) tags -->
    <!-- this should be removed as soon as SRGs include only a description instead of odd tags -->
    <xsl:template name="extract-vulndiscussion">
            <xsl:param name="desc"/>
          <xsl:variable name="desc_info" select="substring-before($desc, '&lt;/VulnDiscussion&gt;')"/>
          <xsl:value-of select="substring-after($desc_info, '&lt;VulnDiscussion&gt;')"/>
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
