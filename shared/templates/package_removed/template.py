def preprocess(data, lang):
    if isinstance(data["pkgname"], list):
        data["packages"] = data["pkgname"]
    else:
        data["packages"] = [data["pkgname"]]
    return data
