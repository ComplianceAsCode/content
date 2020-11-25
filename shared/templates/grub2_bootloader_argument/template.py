import ssg.utils


def preprocess(data, lang):
    data["arg_name_value"] = data["arg_name"] + "=" + data["arg_value"]
    if lang == "oval":
        # escape dot, this is used in oval regex
        data["escaped_arg_name_value"] = data["arg_name_value"].replace(".", "\\.")
        # replace . with _, this is used in test / object / state ids
        data["sanitized_arg_name"] = ssg.utils.escape_id(data["arg_name"])
    return data
