from ssg.utils import parse_template_boolean_value


def preprocess(data, lang):
    if data.get("value") is not None and data.get("xccdf_variable") is not None:
        errmsg = (
            f"The template definition of {data["_rule_id"]} specifies both "
            f"value and xccdf_variable. This is forbidden."
        )
        raise ValueError(errmsg)
    data["missing_parameter_pass"] = parse_template_boolean_value(
        data, parameter="missing_parameter_pass", default_value=False)
    return set_variables_for_test_scenarios(data)


def set_variables_for_test_scenarios(data):
    if not data.get("value"):
        # this implies XCCDF variable is used
        data["wrong_value"] = "wrong_value"
        data["correct_value"] = "correct_value"
    else:
        data["wrong_value"] = "wrong_value"
        data["correct_value"] = str(data["value"])
    return data
