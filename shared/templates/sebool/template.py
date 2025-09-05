def preprocess(data, lang):
    sebool_bool = data.get("sebool_bool", None)
    if sebool_bool is not None and sebool_bool not in ["true", "false"]:
        raise ValueError(
            "ERROR: key sebool_bool in rule {0} contains forbidden "
            "value '{1}'.".format(data["_rule_id"], sebool_bool)
        )
    return data
