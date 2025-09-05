from ssg.utils import parse_template_boolean_value, check_conflict_regex_directory

def _file_owner_groupowner_permissions_regex(data):
    # this avoids code duplicates
    if isinstance(data["filepath"], str):
        data["filepath"] = [data["filepath"]]

    if "file_regex" in data:
        # we can have a list of filepaths, but only one regex
        # instead of declaring the same regex multiple times
        if isinstance(data["file_regex"], str):
            data["file_regex"] = [data["file_regex"]] * len(data["filepath"])

        # if the length of filepaths and file_regex are not the same, then error.
        # in case we have multiple regexes for just one filepath, than we need
        # to declare that filepath multiple times
        if len(data["filepath"]) != len(data["file_regex"]):
            raise ValueError(
                "You should have one file_path per file_regex. Please check "
                "rule '{0}'".format(data["_rule_id"]))

    check_conflict_regex_directory(data)


def map_symbolic_permissions(filemode, allow_stricter_permissions):
    mode_int = int(filemode, 8)
    fields = [
        ('o', 'x'), ('o', 'w'), ('o', 'r'),
        ('g', 'x'), ('g', 'w'), ('g', 'r'),
        ('u', 'x'), ('u', 'w'), ('u', 'r'),
        ('o', 't'), ('g', 's'), ('u', 's')
    ]
    mode_dict = {'u': '', 'g': '', 'o': ''}
    for field in fields:
        if mode_int & 0x01 == 1:
            if not allow_stricter_permissions:
                mode_dict[field[0]] += field[1]
        else:
            if allow_stricter_permissions:
                mode_dict[field[0]] += field[1]
        mode_int = mode_int >> 1
    return mode_dict


def group_symbolic_permissions(mode_dict):
    search_mode = ''
    fix_mode = ''
    for k in mode_dict:
        if mode_dict[k] != '':
            if search_mode != '':
                search_mode += ','
            search_mode += "{}+{}".format(k, mode_dict[k])

            if fix_mode != '':
                fix_mode += ','
            fix_mode += "{}-{}".format(k, mode_dict[k])
    return search_mode, fix_mode


def preprocess(data, lang):
    _file_owner_groupowner_permissions_regex(data)

    data["allow_stricter_permissions"] = parse_template_boolean_value(data, parameter="allow_stricter_permissions", default_value=True)

    data["missing_file_pass"] = parse_template_boolean_value(data, parameter="missing_file_pass", default_value=False)

    data["recursive"] = parse_template_boolean_value(data,
                                                     parameter="recursive",
                                                     default_value=False)

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
                if not data['allow_stricter_permissions']:
                    mode_str = (
                        "<unix:" + field + " datatype=\"boolean\">true</unix:"
                        + field + ">\n" + mode_str)
            else:
                mode_str = (
                    "<unix:" + field + " datatype=\"boolean\">false</unix:"
                    + field + ">\n" + mode_str)
            mode_int = mode_int >> 1
        data["statemode"] = mode_str.rstrip("\n")

    if lang in ["bash", "ansible"]:

        mode_map = map_symbolic_permissions(data["filemode"], data['allow_stricter_permissions'])
        search_mode, fix_mode = group_symbolic_permissions(mode_map)

        data["search_mode"] = search_mode
        if data['allow_stricter_permissions']:
            # overwrite "filemode" with a subtractive symbolic mode
            # e.g., if filemode was "0755", now it is "u-s,g-ws,o-wt"
            # This allows files to keep the permission in which they are already stricter
            data["filemode"] = fix_mode

    return data
