<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="node()|@*" priority="-2">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*">
        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:variable name="elem" select="."/>

            <xsl:for-each select="namespace::*">
                <xsl:variable name="ns" select="name()"/>
                <!-- check that no descendant elements or attributes use the ns -->
                <xsl:if test="$elem/descendant::*[namespace-uri()=current() and substring-before(name(),':') = $ns or @*[substring-before(name(),':') = $ns]]">
                    <xsl:copy-of select="."/>
                </xsl:if>
            </xsl:for-each>

            <xsl:apply-templates select="node()|@*"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
