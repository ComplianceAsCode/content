def preprocess(data, lang):
    if "packagename" not in data:
        data["packagename"] = data["servicename"]
    return data
