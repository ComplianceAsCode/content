<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<!-- setting the external variable $notes identifies a file from which to add notes,
	 but set to nothing by default -->
<xsl:param name="notes" select="''" />

<xsl:variable name="notegroup" select="document($notes)/notegroup" />

	<xsl:template match="/">
		<html>
		<head>
			<title>Rules In <xsl:value-of select="/cdf:Benchmark/cdf:title" /><xsl:if test="$notes"> with Notes for Transition to <xsl:value-of select="$product_short_name" /> Consensus</xsl:if></title>
		</head>
		<body>
			<br/>
			<br/>
			<div style="text-align: center; font-size: x-large; font-weight:bold">
			Rules In <i><xsl:value-of select="/cdf:Benchmark/cdf:title" /></i><xsl:if test="$notes"> with Notes for Transition to <xsl:value-of select="$product_short_name" /> Consensus</xsl:if>
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
			<xsl:choose>
			<xsl:when test="$notes">
			<td>
			<table class="bbl">
				<tr><td class="bl">Title</td></tr>
				<tr><td>V-ID</td></tr>
				<tr><td>CCI</td></tr>
				<tr><td>CAT</td></tr>
			</table>
			</td>
			</xsl:when>
			<xsl:otherwise>
				<td>V-ID</td>
				<td>CCI</td>
				<td>CAT</td>
				<td>Title</td>
			</xsl:otherwise>
			</xsl:choose>
				<td>Description</td>
				<td>Check Procedures</td>
				<td>Fixtext</td>
				<td>Version</td>
			<xsl:if test='$notes'>
				<td>Notes</td>
			</xsl:if>
			</thead>

                <xsl:apply-templates select=".//cdf:Group" />
		</table>
	</xsl:template>


	<xsl:template name="rule-output">
          <xsl:param name="vulnid"/>
		<tr>
			<xsl:choose>
			<xsl:when test="$notes">
			<td>
			<table class="bl">
					<tr><td><xsl:value-of select="cdf:Rule/cdf:title" /></td></tr>
					<tr><td><xsl:value-of select="@id"/></td></tr>
					<!--<tr><td><xsl:value-of select="cdf:title" /></td></tr>-->
					<tr><td><xsl:value-of select="cdf:Rule/@severity" /></td></tr>
			</table>
			</td>
			</xsl:when>
			<xsl:otherwise>
				<td><xsl:value-of select="@id"/></td> 
				<td> <xsl:value-of select="cdf:Rule/cdf:ident" /></td>
				<!--<td> <xsl:value-of select="cdf:title" /></td>-->
				<td> <xsl:value-of select="cdf:Rule/@severity" /></td>
				<td> <xsl:value-of select="cdf:Rule/cdf:title" /></td>
			</xsl:otherwise>
			</xsl:choose>
			<td> <xsl:call-template name="extract-vulndiscussion"><xsl:with-param name="desc" select="cdf:Rule/cdf:description"/></xsl:call-template> </td>
			<td> <xsl:apply-templates select="cdf:Rule/cdf:check/cdf:check-content/node()"/> </td>
			<td> <xsl:apply-templates select="cdf:Rule/cdf:fixtext/node()"/> </td>
			<td> <xsl:apply-templates select="cdf:Rule/cdf:version/node()"/> </td>
			<xsl:if test='$notes'>
				<td> <table><xsl:call-template name="print-notes"><xsl:with-param name="vulnid" select="@id"/></xsl:call-template> </table> </td>
			</xsl:if>
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
        	<xsl:call-template name="search_vulnidlist" select="note">
		    	<xsl:with-param name="vulnid_sought" select="$vulnid" />
		    	<xsl:with-param name="vulnid_list" select="@ref" />
        	</xsl:call-template>
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
	 <xsl:variable name="vulnid_found_normal" select="normalize-space($vulnid_found)"  />
	 <xsl:variable name="vulnid_expanded" select="concat('V-', $vulnid_found_normal)"  />
	 <xsl:if test="$vulnid_sought=$vulnid_expanded">
		<tr><td><xsl:value-of select="@auth"/>: <xsl:value-of select="." /></td></tr>
	 </xsl:if>

 </xsl:template>


    <!-- remove any encoded non-XCCDF tags. -->
    <!-- continue to wonder: -->
    <!-- 1) why this is not in the XCCDF spec, if it's needed by one of its major users, or -->
    <!-- 2) why this garbage is ever exported by VMS -->
    <!-- this should be removed as soon as SRGs don't include this detritus -->
  <xsl:template name="extract-vulndiscussion">
	<xsl:param name="desc"/>
	<xsl:if test="contains($desc, '&lt;VulnDiscussion&gt;')">
		<xsl:variable name="desc_info" select="substring-before($desc, '&lt;/VulnDiscussion&gt;')"/>
		<xsl:value-of select="substring-after($desc_info, '&lt;VulnDiscussion&gt;')"/>
	</xsl:if>
	<xsl:if test="not(contains($desc, '&lt;VulnDiscussion&gt;'))">
		<xsl:apply-templates select="$desc"/>
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
