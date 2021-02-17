def preprocess(data, lang):

    if data.get("xccdf_variable") and data.get("embedded_data") == "true":
        values = data.get("values", [{}])
        if len(values) > 1:
            raise ValueError(
                "Only a single value can be checked when querying "
                "for a 'xccdf_value' that returns an embedded value. "
                "Rule ID: {}".format(data["_rule_id"]))
        elif not values[0].get("value"):
            raise ValueError(
                "You should specify a capture regex in the 'value' field "
                "when querying for a 'xccdf_value' that returns an embedded value. "
                "Rule ID: {}".format(data["_rule_id"]))

    if data.get("xccdf_variable") and data.get("embedded_data") != "true":
        if data.get("values"):
            raise ValueError(
                "You cannot specify the 'value' field when querying "
                "for a 'xccdf_value' that doesn't return an embedded value. "
                "Rule ID: {}".format(data["_rule_id"]))

    data["embedded_data"] = data.get("embedded_data", "false") == "true"
    data["ocp_data"] = data.get("ocp_data", "false") == "true"
    return data
