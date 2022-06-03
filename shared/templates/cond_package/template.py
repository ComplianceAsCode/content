import re

from ssg.constants import OP_TO_ANSIBLE

def preprocess(data, lang):
    if "evr" in data:
        evr = data["evr"]
        if evr and not re.match(r'\d:\d[\d\w+.]*-\d[\d\w+.]*', evr, 0):
            raise RuntimeError(
                "ERROR: input violation: evr key should be in "
                "epoch:version-release format, but package {0} has set "
                "evr to {1}".format(data["pkgname"], evr))
    if lang == "ansible":
        if "specs" in data:
            for spec in data["specs"]:
                spec["evr_op"] = OP_TO_ANSIBLE[spec["evr_op"]]
    return data
