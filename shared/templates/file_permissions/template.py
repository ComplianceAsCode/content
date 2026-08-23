from ssg.utils import parse_template_boolean_value
from ssg.utils import ensure_file_paths_and_file_regexes_are_correctly_defined

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
    ensure_file_paths_and_file_regexes_are_correctly_defined(data)

    data["allow_stricter_permissions"] = parse_template_boolean_value(data, parameter="allow_stricter_permissions", default_value=True)

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
