import ssg.utils


def preprocess(data, lang):
    data["pointid"] = ssg.utils.escape_id(data["mountpoint"])
    if "min_size" in data and lang == "kickstart":
        data["min_size_mb"] = int(int(data["min_size"]) / 1024 / 1024)
        data["name"] = data["mountpoint"].replace("/", "")
    return data
