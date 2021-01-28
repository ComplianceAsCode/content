def preprocess(data, lang):

    if data.get("xccdf_variable") and data.get("embedded_data") == "true":
        if not data.get("values"):
            raise ValueError(
                "You should specify a capture regex in the 'value' field "
                "when querying for a 'xccdf_value' that returns an embedded value. "
                "Rule ID: {}".format(data["_rule_id"]))

    data["embedded_data"] = data.get("embedded_data", "false") == "true"
    data["ocp_data"] = data.get("ocp_data", "false") == "true"
    return data
