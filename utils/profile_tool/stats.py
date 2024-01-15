import os
import json

from ssg.build_profile import XCCDFBenchmark
from ssg.utils import mkdir_p


OFF_JSON_TO_HTML = False

try:
    from json2html import json2html
except ImportError:
    OFF_JSON_TO_HTML = True


def _process_stats_content(profile, bash_fixes_count, content, content_filepath):
    link = """<a href="{}"><div style="height:100%;width:100%">{}</div></a>"""
    count = len(profile[content])
    if content == "ansible_parity":
        # custom text link for ansible parity
        count = link.format(
            content_filepath,
            "{} out of {} ({}%)".format(
                bash_fixes_count - count,
                bash_fixes_count,
                int(((bash_fixes_count - count) / bash_fixes_count) * 100),
            ),
        )
    count_href_element = link.format(content_filepath, count)
    profile["{}_count".format(content)] = count_href_element


def _filter_profile_for_html_stats(profile, filtered_output, content_path):
    content_list = [
        "rules",
        "missing_stig_ids",
        "missing_cis_refs",
        "missing_hipaa_refs",
        "missing_anssi_refs",
        "missing_ospp_refs",
        "missing_cui_refs",
        "missing_ovals",
        "missing_sces",
        "missing_bash_fixes",
        "missing_ansible_fixes",
        "missing_ignition_fixes",
        "missing_kubernetes_fixes",
        "missing_puppet_fixes",
        "missing_anaconda_fixes",
        "missing_cces",
        "ansible_parity",
        "implemented_checks",
        "implemented_fixes",
        "missing_checks",
        "missing_fixes",
    ]

    bash_fixes_count = profile["rules_count"] - profile["missing_bash_fixes_count"]

    for content in content_list:
        content_file = "{}_{}.txt".format(profile["profile_id"], content)
        content_filepath = os.path.join("content", content_file)
        count = len(profile[content])
        if count > 0:
            _process_stats_content(profile, bash_fixes_count, content, content_filepath)
            with open(os.path.join(content_path, content_file), "w+") as f:
                f.write("\n".join(profile[content]))
        else:
            profile["{}_count".format(content)] = count
        del profile[content]
    filtered_output.append(profile)


def _get_profiles(args):
    benchmark = XCCDFBenchmark(args.benchmark, args.product)
    ret = []
    if args.profile:
        ret.append(benchmark.show_profile_stats(args.profile, args))
    else:
        ret.extend(benchmark.show_all_profile_stats(args))
    return ret


def _generate_html_stats(args, profiles):
    filtered_output = []
    output_path = "./"
    if args.output:
        output_path = args.output
        mkdir_p(output_path)

    content_path = os.path.join(output_path, "content")
    mkdir_p(content_path)

    for profile in profiles:
        _filter_profile_for_html_stats(profile, filtered_output, content_path)

    with open(os.path.join(output_path, "statistics.html"), "w+") as f:
        f.write(json2html.convert(json=json.dumps(filtered_output), escape=False))


def command_stats(args):
    profiles = _get_profiles(args)

    if args.format == "json":
        print(json.dumps(profiles, indent=4))

    elif args.format == "html":
        if OFF_JSON_TO_HTML:
            print("No module named 'json2html'. Please install module to enable this function.")
            return
        _generate_html_stats(args, profiles)

    elif args.format == "csv":
        # we can assume ret has at least one element
        # CSV header
        print(",".join(profiles[0].keys()))
        for line in profiles:
            print(",".join([str(value) for value in line.values()]))
