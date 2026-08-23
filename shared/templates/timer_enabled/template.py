def preprocess(data, lang):
    if "packagename" not in data:
        data["packagename"] = data["timername"]
    return data
