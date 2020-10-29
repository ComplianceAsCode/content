import ssg.utils


def preprocess(data, lang):
    if lang == "oval":
        pathid = ssg.utils.escape_id(data["path"])
        # remove root slash made into '_'
        pathid = pathid[1:]
        data["pathid"] = pathid
    return data
