#!/usr/bin/python

from subprocess import Popen, PIPE
from tempfile import mkstemp
import os
import sys

# Default exit with failure
EXIT_CODE = 1

svg_benchmark = """<?xml version="1.0"?>
<Benchmark xmlns="http://checklists.nist.gov/xccdf/1.1"
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           id="RHEL-6" resolved="1" xml:lang="en-US">
  <status date="2014-08-04">draft</status>
  <title xmlns:xhtml="http://www.w3.org/1999/xhtml" xml:lang="en-US"/>
  <description xmlns:xhtml="http://www.w3.org/1999/xhtml" xml:lang="en-US"/>
  <notice xmlns:xhtml="http://www.w3.org/1999/xhtml" xml:lang="en-US" id="terms_of_use"/>
  <front-matter xmlns:xhtml="http://www.w3.org/1999/xhtml" xml:lang="en-US">
    <p xmlns="http://www.w3.org/1999/xhtml">
      <svg xmlns="http://www.w3.org/2000/svg"
           xmlns:xlink="http://www.w3.org/1999/xlink"
           width="100px" height="100px">
        <circle cx="50" cy="50" r="40" stroke="black" stroke-width="3" fill="darkred" />
      </svg>
    </p>
  </front-matter>
  <platform idref="cpe:/o:redhat:enterprise_linux:6"/>
  <version>0.9</version>
  <model system="urn:xccdf:scoring:default"/>
</Benchmark>
"""

# Create temporary file with the content of svg_benchmark variable above
fd, filename = mkstemp(prefix='svg_', suffix='.xml')
xccdf = os.fdopen(fd, 'wt')
xccdf.write(svg_benchmark)
xccdf.close()

# Call oscap process to generate guide
command = "oscap xccdf generate guide --profile allrules %s" % filename
child = Popen(command.split(), stdout=PIPE, stderr=PIPE)
out, err = child.communicate()
out = out.decode("utf-8")

# Child run sanity check
if child.returncode != 0:
    # Set exit value to failure
    EXIT_CODE = 1

# Delete the temporary file
try:
    os.remove(filename)
except OSError as e:
    sys.stderr.write(
        "Error removing file: %s - %s\n" % (e.filename, e.strerror)
    )

# Check if generated guide contains desired SVG element
if "circle" in out:
    # If so, set exit value to success
    EXIT_CODE = 0
else:
    # Otherwise to failure
    EXIT_CODE = 1

# Call exit with appropriate value
sys.exit(EXIT_CODE)
