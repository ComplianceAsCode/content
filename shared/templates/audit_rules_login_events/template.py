import ssg.utils
import os


def preprocess(data, lang):
    path = data["path"]
    name = ssg.utils.escape_id(os.path.basename(os.path.normpath(path)))
    data["name"] = name
    if lang == "oval":
        data["path"] = path.replace("/", "\\/")
    return data
