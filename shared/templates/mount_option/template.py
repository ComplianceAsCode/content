from ssg.utils import parse_template_boolean_value

import ssg.utils
import re


def _mount_option(data, lang):
    if lang == "oval":
        data["pointid"] = ssg.utils.escape_id(data["mountpoint"])
        data["pointregex"] = ssg.utils.escape_regex(data["mountpoint"])
    else:
        data["mountoption"] = re.sub(" ", ",", data["mountoption"])
    return data


def preprocess(data, lang):
    data["fstab_entry_is_optional"] = parse_template_boolean_value(data,
                                                              parameter="fstab_entry_is_optional",
                                                              default_value=True)
    if lang == "oval":
        data["mountoptionid"] = data["mountoption"].split()[0]
    return _mount_option(data, lang)
