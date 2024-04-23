def preprocess(data, lang):
    if "key" not in data:
        data["key"] = data["_rule_id"]
    return data
