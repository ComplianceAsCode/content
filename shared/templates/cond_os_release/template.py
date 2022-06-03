#!/usr/bin/env python

OP_TO_ANSIBLE = {
    'equals': '==',
    'not equal': '!=',
    'greater than': '>',
    'less than': '<',
    'greater than or equal': '>=',
    'less than or equal': '<='
}

def preprocess(data, lang):
    if lang == "ansible":
        if "specs" in data:
            for spec in data["specs"]:
                spec["evr_op"] = OP_TO_ANSIBLE[spec["evr_op"]]
    return data
