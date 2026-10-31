import ssg.utils
import os


def preprocess(data, lang):
    path = data["path"]
    name = ssg.utils.escape_id(os.path.basename(os.path.normpath(path)))
    data["name"] = name
    if lang == "oval":
        # Normalize away a trailing slash so it can be made optional in the
        # OVAL pattern (via '/?'). This lets the check accept the watched path
        # with or without a trailing slash regardless of how the rule is
        # written on disk (e.g. both '-F dir=/etc/sudoers.d' and
        # '-F path=/etc/sudoers.d/').
        normalized_path = path.rstrip("/") or "/"
        data["path_escaped"] = normalized_path.replace("/", "\\/")
    if "key" not in data:
        data["key"] = data["_rule_id"]
    if data["path"].endswith("/"):
        data["filter_type"] = "dir"
    else:
        data["filter_type"] = "path"
    return data
