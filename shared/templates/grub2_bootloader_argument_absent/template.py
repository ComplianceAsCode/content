import ssg.utils


def preprocess(data, lang):
    if lang == "oval":
        # replace . with _, this is used in test / object / state ids
        data["sanitized_arg_name"] = ssg.utils.escape_id(data["arg_name"])
    return data
