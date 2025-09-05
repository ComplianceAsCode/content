import ssg.utils


def preprocess(data, lang):
    data["pointid"] = ssg.utils.escape_id(data["mountpoint"])
    return data
