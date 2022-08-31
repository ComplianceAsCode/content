def preprocess(data, lang):
    package = data["platform_package_overrides"].get(data["pkgname"], data["pkgname"])
    if package is not None:
        data["pkgname"] = package
    return data
