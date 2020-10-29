import ssg.utils
import re


def _mount_option(data, lang):
    if lang == "oval":
        data["pointid"] = ssg.utils.escape_id(data["mountpoint"])
    else:
        data["mountoption"] = re.sub(" ", ",", data["mountoption"])
    return data


def preprocess(data, lang):
    return _mount_option(data, lang)
