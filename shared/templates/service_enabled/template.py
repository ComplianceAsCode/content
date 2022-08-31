def preprocess(data, lang):
    if "packagename" not in data:
        data["packagename"] = data["servicename"]
    package = data["platform_package_overrides"].get(data["packagename"], data["packagename"])
    if package is not None:
        data["packagename"] = package
    if "daemonname" not in data:
        data["daemonname"] = data["servicename"]
    return data
