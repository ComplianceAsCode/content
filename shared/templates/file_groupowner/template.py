def _file_owner_groupowner_permissions_regex(data):
    data["is_directory"] = data["filepath"].endswith("/")
    if "missing_file_pass" not in data:
        data["missing_file_pass"] = False
    if "file_regex" in data and not data["is_directory"]:
        raise ValueError(
            "Used 'file_regex' key in rule '{0}' but filepath '{1}' does not "
            "specify a directory. Append '/' to the filepath or remove the "
            "'file_regex' key.".format(data["_rule_id"], data["filepath"]))


def preprocess(data, lang):
    _file_owner_groupowner_permissions_regex(data)
    if lang == "oval":
        data["fileid"] = data["_rule_id"].replace("file_groupowner", "")
    return data
