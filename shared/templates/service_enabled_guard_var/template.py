def preprocess(data, lang):
    if "packagename" not in data:
        data["packagename"] = data["servicename"]
    if "daemonname" not in data:
        data["daemonname"] = data["servicename"]
    return data
