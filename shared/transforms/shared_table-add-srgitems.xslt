<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:cci="https://public.cyber.mil/stigs/cci">

<!-- this transform "fills out" a table of Rules with any SRG items (from an SRG mapping table)
     that are not already included -->

<xsl:template match="table">
	<xsl:variable name="ruletable" select="." />
    <table>
    	<!-- copy the existing table in -->
        <xsl:apply-templates />
    	<!-- then copy any SRG items not already included -->
        <xsl:for-each select="$srgtable/tr">
        	<xsl:variable name="srg_id" select="td[1]"/>
        	<xsl:variable name="cci_id" select="td[2]"/>
        	<xsl:variable name="title" select="td[3]"/>

			<xsl:if test="not($ruletable/tr[contains(td[7],$srg_id)])" >
            <tr>
            <td>TBD</td>
            <td>medium</td> <!-- based ONLY on the fact that all OS SRG items have "medium" severity -->
            <td> <xsl:value-of select="$title" /> </td>
            <td> <xsl:value-of select="td[4]" /> </td>
            <td> <xsl:value-of select="td[7]" /> </td>
            <td> <xsl:value-of select="td[8]" /> </td>
            <td> <xsl:value-of select="$srg_id" /> </td>
            <td> <xsl:value-of select="$cci_id" /> </td>
            <td>
			<xsl:for-each select="$cci_list/cci:cci_items/cci:cci_item">
				<xsl:if test="@id=$cci_id">
					<xsl:for-each select="cci:references/cci:reference">
						<xsl:if test="@title='NIST SP 800-53'">
							<xsl:value-of select="@index"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:if>
        	</xsl:for-each>
			</td>
            </tr>
            </xsl:if>

       	</xsl:for-each>
    </table>
</xsl:template>


<xsl:template match="@*|node()" >
    <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
</xsl:template>

</xsl:stylesheet>
