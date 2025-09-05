#!/usr/bin/env python2

import tempfile
import sys
import os.path

import ssg.shims


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
    oscap_executable = sys.argv[1]

    xccdf = tempfile.NamedTemporaryFile()
    xccdf.write(svg_benchmark.encode("utf-8"))
    xccdf.flush()

    out = ssg.shims.subprocess_check_output(
        [oscap_executable, "xccdf", "generate", "guide", xccdf.name]
    ).decode("utf-8")

    # check whether oscap threw away the SVG elements
    sys.exit(0 if "circle" in out else 1)


if __name__ == "__main__":
    main()
