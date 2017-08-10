#!/usr/bin/env python2

import subprocess
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


def subprocess_check_output(*popenargs, **kwargs):
    # Backport of subprocess.check_output taken from
    # https://gist.github.com/edufelipe/1027906
    #
    # Originally from Python 2.7 stdlib under PSF, compatible with LGPL2+
    # Copyright (c) 2003-2005 by Peter Astrand <astrand@lysator.liu.se>
    # Changes by Eduardo Felipe

    process = subprocess.Popen(stdout=subprocess.PIPE, *popenargs, **kwargs)
    output, unused_err = process.communicate()
    retcode = process.poll()
    if retcode:
        cmd = kwargs.get("args")
        if cmd is None:
            cmd = popenargs[0]
        error = subprocess.CalledProcessError(retcode, cmd)
        error.output = output
        raise error
    return output


if hasattr(subprocess, "check_output"):
    # if available we just use the real function
    subprocess_check_output = subprocess.check_output


def main():
    oscap_executable = sys.argv[1]

    xccdf = tempfile.NamedTemporaryFile()
    xccdf.write(svg_benchmark.encode("utf-8"))
    xccdf.flush()

    out = subprocess_check_output(
        [oscap_executable, "xccdf", "generate", "guide", xccdf.name]
    ).decode("utf-8")

    # check whether oscap threw away the SVG elements
    sys.exit(0 if "circle" in out else 1)


if __name__ == "__main__":
    main()
