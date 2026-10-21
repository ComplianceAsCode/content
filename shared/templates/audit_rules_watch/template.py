import os

import ssg.utils
from ssg.utils import parse_template_boolean_value


def preprocess(data, lang):
    path = data["path"]
    name = ssg.utils.escape_id(os.path.basename(os.path.normpath(path)))
    data["name"] = name
    if lang == "oval":
        data["path_escaped"] = path.replace("/", "\\/")
    if "key" not in data:
        data["key"] = data["_rule_id"]
    data["require_key"] = parse_template_boolean_value(
        data, parameter="require_key", default_value=False)
    if data["path"].endswith("/"):
        data["filter_type"] = "dir"
    else:
        data["filter_type"] = "path"
    return data
