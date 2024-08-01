from ssg.utils import parse_template_boolean_value


def preprocess(data, lang):
    if data["datatype"] not in ["string", "int"]:
        errmsg = "The template instance of the rule {0} contains invalid datatype. It must be either 'string' or 'int'".format(data["_rule_id"])
        raise ValueError(errmsg)
    data["missing_parameter_pass"] = parse_template_boolean_value(
        data, parameter="missing_parameter_pass", default_value=False)

    is_default_value = parse_template_boolean_value(
        data, parameter="is_default_value", default_value=False)
    if is_default_value:
        data["config_basename"] = "01-complianceascode-reinforce-os-defaults.conf"
    else:
        data["config_basename"] = "00-complianceascode-hardening.conf"

    # set variables used in test scenarios
    if data["datatype"] == "int":
        if not data.get("value"):
            data["wrong_value"] = 123456
            data["correct_value"] = 0
        else:
            data["wrong_value"] = str(int(data["value"]) + 1)
            data["correct_value"] = str(data["value"])
    elif data["datatype"] == "string":
        if not data.get("value"):
            data["wrong_value"] = "wrong_value"
            data["correct_value"] = "correct_value"
        else:
            data["wrong_value"] = "wrong_value"
            data["correct_value"] = str(data["value"])

    return data
