def preprocess(data, lang):
    if "sep" not in data:
        data["sep"] = " = "

    if "prefix_regex" not in data:
        data["prefix_regex"] = r"^\s*"

    if "sep_regex" not in data:
        data["sep_regex"] = r"\s*=\s*"

    if "app" not in data:
        data["app"] = ""
    return data
