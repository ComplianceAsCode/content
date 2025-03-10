def set_variables_for_test_scenarios(data):
    if not data.get("value"):
        # this implies XCCDF variable is used
        data["correct_value"] = "correct_value"
    else:
        data["correct_value"] = str(data["value"])

    return data


def preprocess(data, lang):
    if data.get("value") is not None and data.get("xccdf_variable") is not None:
        errmsg = ("The template definition of {0} specifies both value and xccdf_variable."
                  "This is forbidden.".format(data["_rule_id"]))
        raise ValueError(errmsg)
    if "sep" not in data:
        data["sep"] = " = "

    if "prefix_regex" not in data:
        data["prefix_regex"] = r"^\s*"

    if "sep_regex" not in data:
        data["sep_regex"] = r"\s*=\s*"

    if "app" not in data:
        data["app"] = ""
    data = set_variables_for_test_scenarios(data)
    return data
