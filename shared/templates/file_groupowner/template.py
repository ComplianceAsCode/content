from ssg.utils import parse_template_boolean_value

def _file_owner_groupowner_permissions_regex(data):
    if isinstance(data["filepath"], list):
        for f in data["filepath"]:
            data["is_directory"] = f.endswith("/")
            if "file_regex" in data and not data["is_directory"]:
                raise ValueError(
                    "Used 'file_regex' key in rule '{0}' but filepath '{1}' does not "
                    "specify a directory. Append '/' to the filepath or remove the "
                    "'file_regex' key.".format(data["_rule_id"], data["filepath"]))
    else:
        data["is_directory"] = data["filepath"].endswith("/")
        if "file_regex" in data and not data["is_directory"]:
            raise ValueError(
                "Used 'file_regex' key in rule '{0}' but filepath '{1}' does not "
                "specify a directory. Append '/' to the filepath or remove the "
                "'file_regex' key.".format(data["_rule_id"], data["filepath"]))


def preprocess(data, lang):
    _file_owner_groupowner_permissions_regex(data)

    data["missing_file_pass"] = parse_template_boolean_value(data, parameter="missing_file_pass", default_value=False)

    if lang == "oval":
        data["fileid"] = data["_rule_id"].replace("file_groupowner", "")
    return data
