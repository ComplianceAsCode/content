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
        data["fileid"] = data["_rule_id"].replace("file_permissions", "")
        # build the state that describes our mode
        # mode_str maps to STATEMODE in the template
        mode = data["filemode"]
        fields = [
            'oexec', 'owrite', 'oread', 'gexec', 'gwrite', 'gread',
            'uexec', 'uwrite', 'uread', 'sticky', 'sgid', 'suid']
        mode_int = int(mode, 8)
        mode_str = ""
        for field in fields:
            if mode_int & 0x01 == 1:
                mode_str = (
                    "	<unix:" + field + " datatype=\"boolean\">true</unix:"
                    + field + ">\n" + mode_str)
            else:
                mode_str = (
                    "	<unix:" + field + " datatype=\"boolean\">false</unix:"
                    + field + ">\n" + mode_str)
            mode_int = mode_int >> 1
        data["statemode"] = mode_str
    return data
