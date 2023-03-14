import re


def preprocess(data, lang):
    pattern = r"^\d+:\d+(?:\.\d+(?:\.\d+)?)?$"
    for ver_spec in data["ver_specs"]:
        version = ver_spec["ev_ver"]
        if not re.match(pattern, version):
            msg = (
                "Error in platform package[%s]: version '%s' doesn't match "
                "pattern '%s'" % (data["pkgname"], version, pattern))
            raise ValueError(msg)
    return data
