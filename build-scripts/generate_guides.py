#!/usr/bin/python3

import argparse
import collections
import lxml.etree as ET
import os

from ssg.constants import OSCAP_PROFILE, PREFIX_TO_NS
import ssg.build_guides

BenchmarkData = collections.namedtuple(
    "BenchmarkData", ["title", "profiles", "product"])

OPENSCAP_POSSIBLE_ROOT_DIRS = [
    os.getenv("OPENSCAP_ROOT_DIR"),
    os.getenv("ProgramFiles"),
    os.getenv("XSLT_PREFIX"),
    "/usr",
    "/usr/bin",
    "/usr/sbin",
    "/usr/local",
    "/usr/share/",
    "/usr/local/share",
    "/opt",
    "/opt/local",
]

for root_dir in OPENSCAP_POSSIBLE_ROOT_DIRS:
    if root_dir is None:
        continue
    for subpath in [os.path.join("share", "openscap", "xsl"), "xsl"]:
        file_path = os.path.join(root_dir, subpath, "xccdf-guide.xsl")
        if os.path.exists(file_path):
            XCCDF_GUIDE_XSL = file_path
            break
    else:
        continue
    break
else:
    XCCDF_GUIDE_XSL = None


def get_benchmarks(ds, product):
    benchmarks = {}
    benchmark_xpath = "./ds:component/xccdf-1.2:Benchmark"
    for benchmark_el in ds.xpath(benchmark_xpath, namespaces=PREFIX_TO_NS):
        benchmark_id = benchmark_el.get("id")
        title = benchmark_el.xpath(
            "./xccdf-1.2:title", namespaces=PREFIX_TO_NS)[0].text
        profiles = get_profiles(benchmark_el)
        benchmarks[benchmark_id] = BenchmarkData(title, profiles, product)
    return benchmarks


def get_profiles(benchmark_el):
    profiles = {}
    for profile_el in benchmark_el.xpath(
            "./xccdf-1.2:Profile", namespaces=PREFIX_TO_NS):
        profile_id = profile_el.get("id")
        profile_title = profile_el.xpath(
            "./xccdf-1.2:title", namespaces=PREFIX_TO_NS)[0].text
        profiles[profile_id] = profile_title
    return profiles


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--data-stream", required=True,
        help="Path to a SCAP source data stream, eg. 'ssg-rhel9-ds.xml'")
    parser.add_argument(
        "--oscap-version", required=True,
        help=f"Version of OpenSCAP that owns {XCCDF_GUIDE_XSL}, eg. 1.3.8")
    parser.add_argument(
        "--product", required=True,
        help="Product ID, eg. rhel9")
    parser.add_argument(
        "--output-dir", required=True,
        help="Path to the directory where to generate the output files"
        ", eg. 'build/guides'")
    args = parser.parse_args()
    return args


def make_params(oscap_version, benchmark_id, profile_id):
    params = {
        "oscap-version": ET.XSLT.strparam(oscap_version),
        "benchmark_id": ET.XSLT.strparam(benchmark_id),
        "profile_id": ET.XSLT.strparam(profile_id)
    }
    return params


def make_output_file_name(profile_id, product):
    short_profile_id = profile_id.replace(OSCAP_PROFILE, "")
    output_file_name = "ssg-%s-guide-%s.html" % (product, short_profile_id)
    return output_file_name


def make_output_file_path(profile_id, product, output_dir):
    output_file_name = make_output_file_name(profile_id, product)
    output_file_path = os.path.join(output_dir, output_file_name)
    return output_file_path


def generate_html_guide(ds, transform, params, output_file_path):
    html = transform(ds, **params)
    html.write_output(output_file_path)


def make_index_options(benchmarks):
    index_options = {}
    for benchmark_id, benchmark_data in benchmarks.items():
        options = []
        for profile_id, profile_title in benchmark_data.profiles.items():
            guide_file_name = make_output_file_name(
                profile_id, benchmark_data.product)
            data_benchmark_id = "" if len(benchmarks) == 1 else benchmark_id
            option = (
                f"<option value=\"{guide_file_name}\" data-benchmark-id=\""
                f"{data_benchmark_id}\" data-profile-id=\"{profile_id}\">"
                f"{profile_title}</option>")
            options.append(option)
        index_options[benchmark_id] = options
    return index_options


def make_index_links(benchmarks):
    index_links = []
    for benchmark_id, benchmark_data in benchmarks.items():
        for profile_id, profile_title in benchmark_data.profiles.items():
            guide_file_name = make_output_file_name(
                profile_id, benchmark_data.product)
            a_target = (
                f"<a target=\"guide\" href=\"{guide_file_name}\">"
                f"{profile_title} in {benchmark_id}</a>")
            index_links.append(a_target)
    return index_links


def make_index_initial_src(benchmarks):
    for benchmark_data in benchmarks.values():
        for profile_id in benchmark_data.profiles:
            return make_output_file_name(profile_id, benchmark_data.product)
    return None


def generate_html_index(benchmarks, data_stream, output_dir):
    benchmark_titles = {id_: data.title for id_, data in benchmarks.items()}
    product = list(benchmarks.values())[0].product
    input_basename = os.path.basename(data_stream)
    index_links = make_index_links(benchmarks)
    index_options = make_index_options(benchmarks)
    index_initial_src = make_index_initial_src(benchmarks)
    index_source = ssg.build_guides.build_index(
        benchmark_titles, input_basename, index_links, index_options,
        index_initial_src)
    output_path = make_output_file_path("index", product, output_dir)
    with open(output_path, "wb") as f:
        f.write(index_source.encode("utf-8"))


def generate_html_guides(ds, benchmarks, oscap_version, output_dir):
    xslt = ET.parse(XCCDF_GUIDE_XSL)
    transform = ET.XSLT(xslt)
    for benchmark_id, benchmark_data in benchmarks.items():
        for profile_id in benchmark_data.profiles:
            params = make_params(oscap_version, benchmark_id, profile_id)
            output_file_path = make_output_file_path(
                profile_id, benchmark_data.product, output_dir)
            generate_html_guide(ds, transform, params, output_file_path)


def main():
    args = parse_args()
    ds = ET.parse(args.data_stream)
    benchmarks = get_benchmarks(ds, args.product)
    if not os.path.exists(args.output_dir):
        os.mkdir(args.output_dir)
    generate_html_guides(ds, benchmarks, args.oscap_version, args.output_dir)
    generate_html_index(benchmarks, args.data_stream, args.output_dir)


if __name__ == "__main__":
    main()
