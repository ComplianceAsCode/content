#!/usr/bin/env python2

import os
import os.path
import re
import sys
import argparse
import datetime
import yaml
import string


try:
    from xml.etree import cElementTree as ET
except ImportError:
    import cElementTree as ET

try:
    set
except NameError:
    # for python2
    from sets import Set as set

sys.path.insert(0, os.path.join(
        os.path.dirname(os.path.dirname(os.path.realpath(__file__))),
        "modules"))
from xccdf_generator import XCCDFGeneratorFromYAML


script_extensions = (".yml", ".sh", ".anaconda", ".pp", ".rb", "chef", "py")
ssg_guide_extensions = ("benchmark", "profile", "group", "var", "rule")
ssg_file_ingest_order = ("benchmark", "profile", "group", "var", "rule",
                         "anaconda", "sh", "yml", "pp", "chef", "rb", "py")


def fix_xml_elements(xmlfile):
    # Horrible hack function. This should be replaced.
    fix_elements = {#"&lt;pre&gt;": "<pre>",
                    #'&lt;/pre&gt;': '</pre>',
                    #'&lt;tt&gt;': '<tt>',
                    #'&lt;/tt&gt;': '</tt>',
                    '&lt;li&gt;': '<li>',
                    '&lt;/li&gt;': '</li>',
                    '&lt;ul&gt;': '<ul>',
                    '&lt;/ul&gt;': '</ul>',
                    '&lt;br/&gt;': '<br/>',
                    "/&gt;": "/>",
                    '&lt;product-name-macro/&gt;': '<product-name-macro/>',
                    "&lt;weblink-macro": "<weblink-macro",
                    #"&lt;i&gt;": "<i>",
                    #"&lt;/i&gt;": "</i>",
                    "&lt;br": "<br",
                    #"/&gt;": "/>",
                    }

    for key, value in fix_elements.iteritems():
        xmlfile = xmlfile.replace(key, value)

    return xmlfile


def custom_sort(files_list, ordered_list):
    custom_list = []

    for order in ordered_list:
        for files in files_list:
            if files.endswith(order):
                custom_list.append(files)

    return custom_list


def read_content_in_dirs(directory):
    guide_files = []
    script_files = []

    for dirs in directory:
        for root, dirs, files in sorted(os.walk(dirs)):
            for filename in sorted(files):
                filename = os.path.join(root, filename)
                if filename.endswith(ssg_guide_extensions):
                    guide_files.append(filename)
                if filename.endswith(script_extensions):
                    script_files.append(filename)

    return (guide_files, script_files)


def write_file(filename, content):
    with open(filename, "w") as outputfile:
        outputfile.write(content)


def main():
    xccdf_xmlns = "http://checklists.nist.gov/xccdf/1.1"
    parser = argparse.ArgumentParser()
    parser.add_argument("--input_type", action="store",
                        default="yaml", required=False,
                        help="Input file format to ingest [Default: %(default)s]")
    sub_parser = parser.add_subparsers(help="Content Types")
    xccdf_parser = sub_parser.add_parser("xccdf", help="Generate XCCDF content")
    xccdf_parser.add_argument("--shorthand", action="store_true",
                              help="Merges content together to create a XML file")
    xccdf_parser.add_argument("--product", action="store",
                              default="product_name", required=False,
                              help="Name of the product [Default: %(default)s]")
    xccdf_parser.add_argument("--scap_version", action="store",
                              default="SCAP_1.1", required=False,
                              help="SCAP version [Default: %(default)s]")
    xccdf_parser.add_argument("--xccdf_xmlns", action="store",
                              default=xccdf_xmlns, required=False,
                              help="SCAP version [Default: %(default)s]")
    xccdf_parser.add_argument("--schema", action="store",
                              default=xccdf_xmlns + " xccdf-1.1.4.xsd",
                              required=False,
                              help="Schema namespace and XML schema [Default: %(default)s]")
    xccdf_parser.add_argument("--resolved", action="store",
                              default="false", required=False,
                              help=" [Default: %(default)s]")
    xccdf_parser.add_argument("--lang", action="store",
                              default="en-US", required=False,
                              help="Language of XML file [Default: %(default)s]")
    xccdf_parser.add_argument("directory", metavar="DIRECTORY", nargs="+",
                              help="Location of content to combine into the final document")

    args, unknown = parser.parse_known_args()
    if unknown:
        sys.stderr.write(
            "Unknown arguments " + ",".join(unknown) + ".\n"
        )
        sys.exit(1)

    if len(sys.argv) < 3:
        parser.error(parser.print_help())

    directory = args.directory

    if args.shorthand:
        if args.input_type is "yaml":
            (guide_files, script_files) = read_content_in_dirs(directory)
            guide_files = custom_sort(guide_files, ssg_guide_extensions)
            script_files = custom_sort(script_files, script_extensions)
            xccdf = XCCDFGeneratorFromYAML(args.product, args.schema, args.scap_version,
                                           args.resolved, args.lang)
            xmlfile = xccdf.build((guide_files + script_files), args.shorthand)

        to_save = xmlfile.find('.//Group')
        xmlfile = fix_xml_elements(ET.tostring(to_save))
        print("Generating shorthand.xml")
        write_file("shorthand.xml", xmlfile)


if __name__ == "__main__":
    main()
