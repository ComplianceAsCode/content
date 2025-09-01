from ssg.utils import parse_template_boolean_value


def preprocess(data, lang):
    if data.get("value") is not None and data.get("xccdf_variable") is not None:
        errmsg = (
            f"The template definition of {data['_rule_id']} specifies both "
            f"value and xccdf_variable. This is forbidden."
        )
        raise ValueError(errmsg)
    data["missing_parameter_pass"] = parse_template_boolean_value(
        data, parameter="missing_parameter_pass", default_value=False)
    if "variable_datatype" not in data:
        data["variable_datatype"] = "string"
    return set_variables_for_test_scenarios(data)


def set_variables_for_test_scenarios(data):
    # if no correct value is specified, we will create one for testing purposes
    if not data.get("test_correct_value"):
        if not data.get("value"):
            # this implies XCCDF variable is used
            data["test_correct_value"] = "test_correct_value"
        else:
            data["test_correct_value"] = str(data["value"])
    # if no wrong value is provided, we will create one for testing purposes
    if not data.get("test_wrong_value"):
        data["test_wrong_value"] = "test_wrong_value"
    return data
