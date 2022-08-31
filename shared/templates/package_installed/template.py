import re


def preprocess(data, lang):
    package = data["platform_package_overrides"].get(data["pkgname"], data["pkgname"])
    if package is not None:
        data["pkgname"] = package
    if "evr" in data:
        evr = data["evr"]
        if evr and not re.match(r'\d:\d[\d\w+.]*-\d[\d\w+.]*', evr, 0):
            raise RuntimeError(
                "ERROR: input violation: evr key should be in "
                "epoch:version-release format, but package {0} has set "
                "evr to {1}".format(data["pkgname"], evr))
    return data
