import ssg.utils


def preprocess(data, lang):
    if 'arg_value' in data and 'arg_variable' in data:
        raise RuntimeError(
                "ERROR: The template should not set both 'arg_value' and 'arg_variable'.\n"
                "arg_name: {0}\n"
                "arg_variable: {1}".format(data['arg_value'], data['arg_variable']))

    if 'arg_variable' in data:
        data["arg_name_value"] = data["arg_name"]
    else:
        data["arg_name_value"] = data["arg_name"] + "=" + data["arg_value"]

    if 'is_substring' not in data:
        data["is_substring"] = "false"

    if lang == "oval":
        # escape dot, this is used in oval regex
        data["escaped_arg_name_value"] = data["arg_name_value"].replace(".", "\\.")
        data["escaped_arg_name"] = data["arg_name"].replace(".", "\\.")
        # replace . with _, this is used in test / object / state ids

    data["sanitized_arg_name"] = ssg.utils.escape_id(data["arg_name"])
    return data
