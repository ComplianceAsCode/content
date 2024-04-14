def preprocess(data, lang):
    if "packagename" not in data:
        data["packagename"] = data["servicename"]
    if "daemonname" not in data:
        data["daemonname"] = data["servicename"]
    if "mask_service" not in data:
        data["mask_service"] = "true"
    return data
