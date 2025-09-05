#!/usr/bin/env python

from __future__ import print_function

import argparse
import re
import sys

import yaml


COMMENT_KEYS = set((
    "platform",
    "reboot",
    "strategy",
    "complexity",
    "disruption",
))

TAGS = set((
    "strategy",
    "complexity",
    "disruption",
    "severity",
))


def make_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("input", nargs="+")
    parser.add_argument("--verbose", "-v", action="store_true")
    parser.add_argument("--cce", action="store_true", help="Require CCEs to be defined as well")
    return parser


def validate_comments(fname, args):
    caught_comments = set()
    regex = re.compile(
        r"# ({keys}) = .*"
        .format(keys="|".join(COMMENT_KEYS)))
    with open(fname, "r") as lines:
        for line in lines:
            found = re.search(regex, line)
            if found:
                caught_comments.add(found.group(1))
    assert COMMENT_KEYS == caught_comments, (
        "Did not found key(s) in comments: {keys}"
        .format(keys=", ".join(COMMENT_KEYS.difference(caught_comments))))

    if args.verbose:
        print("Comment-based metadata OK")


def validate_playbook(playbook, args):
    assert "name" in playbook, "playbook doesn't have a name"
    assert "hosts" in playbook, "playbook doesn't have the hosts entry"
    assert playbook["hosts"] == "@@HOSTS@@", "playbook's hosts is not set to @@HOSTS@@"
    assert "become" in playbook, "playbook doesn't have a become key"
    assert playbook["become"], "become in the playbook is not set to a true-ish value"
    if "vars" in playbook:
        assert playbook["vars"], "there are no variables under the 'vars' key of the playbook"
    assert "tasks" in playbook, "there are no tasks in the playbook"

    first_task = playbook["tasks"][0]
    if "block" in first_task:
        first_task = first_task["block"][0]

    assert "name" in first_task, "The first task doesn't have name"
    assert "tags" in playbook, "the playbook doesn't have tags"

    if args.verbose:
        print("Basic playbook properties OK")

    caught_tags = set()
    tag_regex = re.compile(
        r".*_({keys})"
        .format(keys="|".join(TAGS)))
    cce_regex = re.compile(r"CCE-[0-9]+-[0-9]+")
    for tag in playbook["tags"]:
        assert "@" not in tag, \
            "A playbook tag {tag} contains @, which is unexpected.".format(tag=tag)

        found = re.search(tag_regex, tag)
        if found:
            caught_tags.add(found.group(1))

        if re.search(cce_regex, tag):
            caught_tags.add("CCE")

    tags_not_caught = TAGS.difference(caught_tags)
    assert not tags_not_caught, \
        "Missing tags: {stray}".format(stray=", ".join(tags_not_caught))

    if args.verbose:
        print("Playbook tags OK")

    if args.cce:
        assert "CCE" in caught_tags, "There is no CCE tag in the playbook"

        if args.verbose:
            print("Playbook CCE OK")


def validate_yaml(fname, args):
    stream = open(fname, "r")
    data = yaml.load(stream, Loader=yaml.Loader)
    for playbook in data:
        validate_playbook(playbook, args)


def validate_input(fname, args):
    if args.verbose:
        print("Analyzing {fname}".format(fname=fname))
    try:
        validate_comments(fname, args)
        validate_yaml(fname, args)
        if args.verbose:
            print("Analysis OK")
    except AssertionError as err:
        msg = (
            "Error processing {fname}: {err}"
            .format(fname=fname, err=err)
        )
        print(msg, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    parser = make_parser()
    args = parser.parse_args()

    ret = 0
    for fname in args.input:
        current_ret = validate_input(fname, args)
        ret = max(current_ret, ret)
    sys.exit(ret)
