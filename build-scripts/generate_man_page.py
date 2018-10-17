#!/usr/bin/env python2

from __future__ import print_function

import argparse
import sys
import ssg.build_profile
import ssg.constants
import ssg.xml
import os
import io

try:
    from xml.etree import cElementTree as ElementTree
except ImportError:
    import cElementTree as ElementTree

prolog = u"""
.TH scap-security-guide 8 "26 Jan 2013" "version 1"

.SH NAME
SCAP Security Guide - Delivers security guidance, baselines, and
associated validation mechanisms utilizing the Security Content
Automation Protocol (SCAP).


.SH DESCRIPTION
The project provides practical security hardening advice for Red Hat products,
and also links it to compliance requirements in order to ease deployment
activities, such as certification and accreditation. These include requirements
in the U.S. government (Federal, Defense, and Intelligence Community) as well
as of the financial services and health care industries. For example,
high-level and widely-accepted policies such as NIST 800-53 provides prose
stating that System Administrators must audit "privileged user actions," but do
not define what "privileged actions" are. The SSG bridges the gap between
generalized policy requirements and specific implementation guidance, in SCAP
formats to support automation whenever possible.

The projects homepage is located at:
https://www.open-scap.org/security-policies/scap-security-guide
"""

epilog = u"""
.SH EXAMPLES
To scan your system utilizing the OpenSCAP utility against the
ospp profile:

oscap xccdf eval --profile ospp \
--results /tmp/`hostname`-ssg-results.xml \
--report /tmp/`hostname`-ssg-results.html \
--oval-results \
/usr/share/xml/scap/ssg/content/ssg-rhel7-xccdf.xml
.PP
Additional details can be found on the projects wiki page:
https://www.github.com/OpenSCAP/scap-security-guide/wiki


.SH FILES
.I /usr/share/xml/scap/ssg/content
.RS
Houses SCAP content utilizing the following naming conventions:

.I CPE_Dictionaries:
ssg-{profile}-cpe-dictionary.xml

.I CPE_OVAL_Content:
ssg-{profile}-cpe-oval.xml

.I OVAL_Content:
ssg-{profile}-oval.xml

.I XCCDF_Content:
ssg-{profile}-xccdf.xml
.RE

.I /usr/share/doc/scap-security-guide/guides/
.RS
HTML versions of SSG profiles.
.RE


.SH STATEMENT OF SUPPORT
The SCAP Security Guide, an open source project jointly maintained by Red Hat
and the NSA, provides XCCDF and OVAL content for Red Hat technologies. As an open
source project, community participation extends into U.S. Department of Defense
agencies, civilian agencies, academia, and other industrial partners.

SCAP Security Guide is provided to consumers through Red Hat's Extended
Packages for Enterprise Linux (EPEL) repository. As such, SCAP Security Guide
content is considered "vendor provided."

Note that while Red Hat hosts the infrastructure for this project and
Red Hat engineers are involved as maintainers and leaders, there is no
commercial support contracts or service level agreements provided by Red Hat.

Support, for both users and developers, is provided through the SCAP Security
Guide community.

Homepage: https://www.open-scap.org/security-policies/scap-security-guide
.PP
Mailing List: https://lists.fedorahosted.org/mailman/listinfo/scap-security-guide


.SH DEPLOYMENT TO U.S. CIVILIAN GOVERNMENT SYSTEMS
SCAP Security Guide content is considered vendor (Red Hat) provided content.
Per guidance from the U.S. National Institute of Standards and Technology (NIST),
U.S. Government programs are allowed to use Vendor produced SCAP content in absence
of "Governmental Authority" checklists. The specific NIST verbage:
http://web.nvd.nist.gov/view/ncp/repository/glossary?cid=1#Authority


.SH DEPLOYMENT TO U.S. MILITARY SYSTEMS
DoD Directive (DoDD) 8500.1 requires that "all IA and IA-enabled IT products
incorporated into DoD information systems shall be configured in accordance
with DoD-approved security configuration guidelines" and tasks Defense
Information Systems Agency (DISA) to "develop and provide security configuration
guidance for IA and IA-enabled IT products in coordination with Director, NSA."
The output of this authority is the DISA Security Technical Implementation Guides,
or STIGs. DISA FSO is in the process of moving the STIGs towards the use
of the NIST Security Content Automation Protocol (SCAP) in order to "automate"
compliance reporting of the STIGs.

Through a common, shared vision, the SCAP Security Guide community enjoys
close collaboration directly with NSA, NIST, and DISA FSO. As stated in Section 1.1 of
the Red Hat Enterprise Linux 6 STIG Overview, Version 1, Release 2, issued on 03-JUNE-2013:

"The consensus content was developed using an open-source project called SCAP
Security Guide. The project's website is https://www.open-scap.org/security-policies/scap-security-guide.
Except for differences in formatting to accomodate the DISA STIG publishing
process, the content of the Red Hat Enterprise Linux 6 STIG should mirrot the SCAP Security Guide
content with only minor divergence as updates from multiple sources work through
the concensus process."

The DoD STIG for Red Hat Enterprise Linux 6 was released June 2013. Currently, the
DoD Red Hat Enterprise Linux 6 STIG contains only XCCDF content and is available online:
http://iase.disa.mil/stigs/os/unix-linux/Pages/red-hat.aspx

Content published against the iase.disa.mil website is authoritative
STIG content. The SCAP Security Guide project, as noted in the STIG overview,
is considered upstream content. Unlike DISA FSO, the SCAP Security Guide project
does publish OVAL automation content. Individual programs and C&A evaluators
make program-level determinations on the direct usage of the SCAP Security Guide.
Currently there is no blanket approval.


.SH SEE ALSO
.B oscap(8)


.SH AUTHOR
Please direct all questions to the SSG mailing list:
https://lists.fedorahosted.org/mailman/listinfo/scap-security-guide
"""


def main():
    p = argparse.ArgumentParser(
        description="Generates man page from profile data")
    p.add_argument("--input_dir", required=True)
    p.add_argument("--output", required=True)
    args = p.parse_args()
    input_dir = os.path.abspath(args.input_dir)
    with io.open(args.output, "w", encoding="utf-8") as output_file:
        output_file.write(prolog)
        print_all_profiles(input_dir, output_file)
        output_file.write(epilog)


def print_all_profiles(input_dir, output_file):
    for item in sorted(os.listdir(input_dir)):
        if item.endswith("-ds.xml"):
            print_profiles_in_ds(os.path.join(input_dir, item), output_file)


def print_profiles_in_ds(ds_filepath, output_file):
    tree = ElementTree.parse(ds_filepath)
    root = tree.getroot()
    benchmark = root.find(".//{%s}Benchmark" % (ssg.constants.XCCDF12_NS))
    benchmark_title = benchmark.find(
        "{%s}title" % (ssg.constants.XCCDF12_NS)).text
    output_file.write(u".SH\nProfiles in %s\n\n" % (benchmark_title))
    ds_filename = os.path.basename(ds_filepath)
    output_file.write(u"Source Datastream: \\fI %s\\fR\n\n" % (ds_filename))
    output_file.write(
        u"The %s is broken into 'profiles', groupings of security settings "
        "that correlate to a known policy. Available profiles are:\n\n" % (
            benchmark_title))
    profiles = list_profiles(benchmark)
    for profile_id, title, description in profiles:
        output_file.write(
            u".B %s\n\n.RS\nProfile ID: \\fI%s\\fR\n\n%s\n.RE\n\n\n" % (
                title, profile_id, description))


def list_profiles(benchmark):
    all_profile_elems = benchmark.findall(
        "./{%s}Profile" % (ssg.constants.XCCDF12_NS))
    profiles_info = []
    for elem in all_profile_elems:
        profile_id = elem.get('id')
        title = elem.find(
                "{%s}title" % (ssg.constants.XCCDF12_NS)
                ).text
        description = elem.find(
                "{%s}description" % (ssg.constants.XCCDF12_NS)
                ).text
        profiles_info.append((profile_id, title, description))
    return profiles_info


if __name__ == '__main__':
    main()
