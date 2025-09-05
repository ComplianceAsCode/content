<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- This file is used to hold constants used across several transforms. -->
<!-- Constants are called variables in XSLT.  At this point this is not a surprise. -->

<!-- abbreviated as idents in the XCCDF-->
<xsl:variable name="cceuri">https://nvd.nist.gov/cce/index.cfm</xsl:variable>

<!-- abbreviated as references in the XCCDF-->
<xsl:variable name="anssiuri">http://www.ssi.gouv.fr/administration/bonnes-pratiques/</xsl:variable>
<xsl:variable name="cjisd-its-uri">https://www.fbi.gov/file-repository/cjis-security-policy-v5_5_20160601-2-1.pdf</xsl:variable>
<xsl:variable name="cnss1253uri">http://www.cnss.gov/Assets/pdf/CNSSI-1253.pdf</xsl:variable>
<xsl:variable name="dcid63uri">not_officially_available</xsl:variable>
<xsl:variable name="disa-appsrguri">https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=application-servers</xsl:variable>
<xsl:variable name="disa-cciuri">https://public.cyber.mil/stigs/cci/</xsl:variable>
<xsl:variable name="disa-ossrguri">https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cgeneral-purpose-os</xsl:variable>
<xsl:variable name="disa-stigs-apps-appsecurity-dev-uri">https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=app-security%2Capp-security-dev</xsl:variable>
<xsl:variable name="disa-stigs-apps-appserver-uri">https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=app-security%2Capplication-servers</xsl:variable>
<xsl:variable name="disa-stigs-apps-browers-uri">https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=app-security%2Cbrowser-guidance</xsl:variable>
<xsl:variable name="disa-stigs-apps-web-server-uri">https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=app-security%2Cweb-servers</xsl:variable>
<xsl:variable name="disa-stigs-os-mainframe-uri">https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cmainframe</xsl:variable>
<xsl:variable name="disa-stigs-os-unix-linux-uri">https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cunix-linux</xsl:variable>
<xsl:variable name="disa-stigs-virutalization-uri">https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cvirtualization</xsl:variable>
<xsl:variable name="hipaauri">https://www.gpo.gov/fdsys/pkg/CFR-2007-title45-vol1/pdf/CFR-2007-title45-vol1-chapA-subchapC.pdf</xsl:variable>
<xsl:variable name="iso27001-2013uri">https://www.iso.org/standard/54534.html</xsl:variable>
<xsl:variable name="nist800-171uri">http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-171.pdf</xsl:variable>
<xsl:variable name="nist800-53uri">http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-53r4.pdf</xsl:variable>
<xsl:variable name="nistcsfuri">https://nvlpubs.nist.gov/nistpubs/CSWP/NIST.CSWP.04162018.pdf</xsl:variable>
<xsl:variable name="isa-62443-2013uri">https://www.isa.org/templates/one-column.aspx?pageid=111294&amp;productId=116785</xsl:variable>
<xsl:variable name="isa-62443-2009uri">https://www.isa.org/templates/one-column.aspx?pageid=111294&amp;productId=116731</xsl:variable>
<xsl:variable name="cobit5uri">https://www.isaca.org/resources/cobit</xsl:variable>
<xsl:variable name="cis-cscuri">https://www.cisecurity.org/wp-content/uploads/2017/03/Poster_Winter2016_CSCs.pdf</xsl:variable>
<xsl:variable name="osppuri">https://www.niap-ccevs.org/Profile/PP.cfm</xsl:variable>
<xsl:variable name="pcidssuri">https://www.pcisecuritystandards.org/documents/PCI_DSS_v3-1.pdf</xsl:variable>
<xsl:variable name="ssg-benchmark-latest-uri">https://github.com/OpenSCAP/scap-security-guide/releases/latest</xsl:variable>
<xsl:variable name="ssg-contributors-uri">https://github.com/OpenSCAP/scap-security-guide/wiki/Contributors</xsl:variable>
<xsl:variable name="ssg-project-name">SCAP Security Guide Project</xsl:variable>

<!-- misc language URI's -->
<xsl:variable name="ovaluri">http://oval.mitre.org/XMLSchema/oval-definitions-5</xsl:variable>

<xsl:variable name="ociltransitional">ocil-transitional</xsl:variable>
<xsl:variable name="ocil_cs">http://scap.nist.gov/schema/ocil/2</xsl:variable>
<xsl:variable name="ocil_ns">http://scap.nist.gov/schema/ocil/2.0</xsl:variable>
</xsl:stylesheet>
