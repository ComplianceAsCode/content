#!/usr/bin/python

# PURPOSE: Generate XSLT transform to adjust:
#
#   Fedora/input/guide.xml
#
# content (release name and CPE) based on underlying system's Fedora version
# (for now building on RHEL isn't supported)

from contextlib import contextmanager
import sys

# Script helper routines below
# ----------------------------

# Open a file (PEP 343 version)
@contextmanager
def pep_343_open_file(filename, mode="r"):
  try:
    f = open(filename, mode)
  except IOError, e:
    yield None, e
  else:
    try:
      yield f, None
    finally:
      f.close()

# Read one line from file
def read_file_line(filename):
  with pep_343_open_file(filename) as (f, e):
    if e:
      return None
    else:
      return f.readline().rstrip('\n')

# Constants for generated XSLT content below
# ------------------------------------------

XSLT_HEADER = '''<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1"
 xmlns:xhtml="http://www.w3.org/1999/xhtml"
 xmlns:dc="http://purl.org/dc/elements/1.1/">'''

XSLT_TEMPLATES = '''

<!-- Copy children -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()" />
  </xsl:copy>
</xsl:template>
<!-- Update full Fedora release name based on param value -->
<xsl:template match="fedora_release">
  <xsl:value-of select="$fedora_release" />
</xsl:template>
<!-- Update Fedora CPE based on param value -->
<xsl:template match="platform/@idref">
  <xsl:attribute name="idref">
    <xsl:value-of select="$fedora_cpe" />
  </xsl:attribute>
</xsl:template>

'''

XSLT_FOOTER = '</xsl:stylesheet>'

# Helper XSLT content routines below
# ----------------------------------

# Store retrieved values from the system
# into XSLT params
def create_fedora_xslt_params(xslt_file):
    release_xslt_param = "\n<xsl:param name=\"fedora_release\" select=\"\'%s\'\" />" % FEDORA_RELEASE
    cpe_xslt_param = "\n<xsl:param name=\"fedora_cpe\" select=\"\'%s\'\" />" % FEDORA_CPE
  
    xslt_file.write(NEW_LINE + release_xslt_param)
    xslt_file.write(cpe_xslt_param)
 
# Create final XSLT transform file
def create_xslt(filename):
  with pep_343_open_file(filename, "w") as (f, e):
    if e:
      print "Error generating XSLT transform."
      sys.exit(1)
    else:
      print "Writing XSLT transform file into: %s" % filename
      f.write(XSLT_HEADER)
      create_fedora_xslt_params(f)
      f.write(XSLT_TEMPLATES)
      f.write(XSLT_FOOTER)

# Main section
# ------------
if __name__ == "__main__":

  if len(sys.argv) < 2:
    print "Provide filename for resulting XSLT file."
    sys.exit(1)
  
  NEW_LINE = '\n'
  XSLT_FILE = str(sys.argv[1])
  FEDORA_RELEASE = read_file_line('/etc/fedora-release')
  FEDORA_CPE = read_file_line('/etc/system-release-cpe')

  if FEDORA_RELEASE is None or FEDORA_CPE is None:
    print '''
Unable to determine version of Fedora at the system. Be sure to
build scap-security-guide (source) RPM either at Fedora 18 or at
Fedora 19.\n'''
    sys.exit(1)

  create_xslt(XSLT_FILE)
