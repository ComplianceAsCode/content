#!/usr/bin/python

from subprocess import Popen, PIPE
import tempfile
import sys


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


def main():
    # Default exit with failure
    EXIT_CODE = 1

    xccdf = tempfile.NamedTemporaryFile()
    xccdf.write(svg_benchmark.encode("utf-8"))
    xccdf.flush()

    # Call oscap process to generate guide
    command = "oscap xccdf generate guide %s" % (xccdf.name)
    child = Popen(command.split(), stdout=PIPE, stderr=PIPE)
    out, err = child.communicate()
    out = out.decode("utf-8")
    print(out)

    # Child run sanity check
    if child.returncode != 0:
        # Set exit value to failure
        EXIT_CODE = 1

    # Check if generated guide contains desired SVG element
    if "circle" in out:
        # If so, set exit value to success
        EXIT_CODE = 0
    else:
        # Otherwise to failure
        EXIT_CODE = 1

    # Call exit with appropriate value
    sys.exit(EXIT_CODE)

if __name__ == "__main__":
    main()
