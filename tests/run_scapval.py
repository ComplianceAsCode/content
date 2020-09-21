#!/usr/bin/python

from __future__ import print_function

import argparse
import subprocess
import os
import xml.etree.ElementTree as ET
import sys

scapval_results_ns = "http://csrc.nist.gov/ns/decima/results/1.0"
oval_unix_ns = "http://oval.mitre.org/XMLSchema/oval-definitions-5#unix"
xccdf_ns = "http://checklists.nist.gov/xccdf/1.2"


def parse_args():
    parser = argparse.ArgumentParser(
        description="Runs SCAP Validation of our data streams using SCAP"
        "Validation Tool (SCAPVal)")
    parser.add_argument(
        "--scap-version",
        help="SCAP Version (Only 1.2 and 1.3 supported)",
        choices=["1.2", "1.3"], required=True)
    parser.add_argument(
        "--scapval-path",
        help="Full path to the SCAPVal JAR archive", required=True)
    parser.add_argument(
        "--build-dir",
        help="Full path to the ComplianceAsCode build directory",
        required=True)
    return parser.parse_args()


def process_results(result_path):
    ret_val = True
    tree = ET.parse(result_path)
    root = tree.getroot()
    results = root.find("./{%s}results" % scapval_results_ns)
    for base_req in results.findall(
            "./{%s}base-requirement" % scapval_results_ns):
        id_ = base_req.get("id")
        status = base_req.find("./{%s}status" % scapval_results_ns).text
        if status == "FAIL":
            if 'ssg-ocp4-ds' in result_path and id_ == "SRC-329":
                print("    %s: %s" % (id_, "WARNING (Contains non-standardized yamlfilecontent_test)"))
            else:
                print("    %s: %s" % (id_, status))
                ret_val = False
    return ret_val


def test_datastream(datastream_path,  scapval_path, scap_version):
    result_path = datastream_path + ".result.xml"
    report_path = datastream_path + ".report.html"
    scapval_command = [
            "java",
            "-Xmx1024m",
            "-jar", scapval_path,
            "-scapversion", scap_version,
            "-file", datastream_path,
            "-valresultfile", result_path,
            "-valreportfile", report_path
            ]
    try:
        subprocess.check_output(scapval_command, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
        scapval_output = e.output.decode("utf-8")
        # Workaround: SCAPVal 1.3.2 can't generate HTML report because
        # it throws a NullPointerException, but we don't need the HTML
        # report for this test, so we can ignore this error.
        # TODO: Remove this when this is fixed in SCAPVal
        last_line = scapval_output.splitlines()[-1]
        if not last_line.endswith(
                "ERROR SCAPVal has encountered a problem and cannot continue "
                "with this validation. - java.lang.NullPointerException: "
                "XSLTemplateExtension cannot be null"):
            sys.stderr.write("Command '{0}' returned {1}:\n{2}\n".format(
                " ".join(e.cmd), e.returncode, scapval_output))
            sys.exit(1)
    return process_results(result_path)


def main():
    overall_result = True
    args = parse_args()
    if args.scap_version == "1.2":
        ds_suffix = "-ds-1.2.xml"
    elif args.scap_version == "1.3":
        ds_suffix = "-ds.xml"
    for filename in os.listdir(args.build_dir):
        if filename.endswith(ds_suffix):
            print("Testing %s ..." % filename)
            datastream_path = os.path.join(args.build_dir, filename)
            datastream_result = test_datastream(
                    datastream_path, args.scapval_path, args.scap_version)
            if datastream_result:
                print("%s: PASS" % filename)
            else:
                print("%s: FAIL" % filename)
                overall_result = False
    if overall_result:
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
