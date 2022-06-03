#!/usr/bin/env python

from ssg.constants import OP_TO_ANSIBLE


def preprocess(data, lang):
    if lang == "ansible":
        if "specs" in data:
            for spec in data["specs"]:
                spec["evr_op"] = OP_TO_ANSIBLE[spec["evr_op"]]
    return data
