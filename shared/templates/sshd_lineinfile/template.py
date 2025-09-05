from ssg.utils import parse_template_boolean_value


def set_variables_for_test_scenarios(data):
    if data["datatype"] == "int":
        if not data.get("value"):
            # this implies XCCDF variable is used
            data["wrong_value"] = 321
            data["correct_value"] = 123
        else:
            data["wrong_value"] = str(int(data["value"]) + 1)
            data["correct_value"] = str(data["value"])
    elif data["datatype"] == "string":
        if not data.get("value"):
            # this implies XCCDF variable is used
            if data['xccdf_variable'] == 'var_sshd_set_maxstartups':
                data["wrong_value"] = "30:10:110"
                data["correct_value"] = "10:30:60"
            else:
                data["wrong_value"] = "wrong_value"
                data["correct_value"] = "correct_value"
        else:
            data["wrong_value"] = "wrong_value"
            data["correct_value"] = str(data["value"])

    return data


def preprocess(data, lang):
    if data.get("value") is not None and data.get("xccdf_variable") is not None:
        errmsg = ("The template definition of {0} specifies both value and xccdf_variable."
                  "This is forbidden.".format(data["_rule_id"]))
        raise ValueError(errmsg)
    if data["datatype"] not in ["string", "int"]:
        errmsg = ("The template instance of the rule {0} contains invalid datatype."
                  "It must be either 'string' or 'int'".format(data["_rule_id"]))
        raise ValueError(errmsg)
    data["missing_parameter_pass"] = parse_template_boolean_value(
        data, parameter="missing_parameter_pass", default_value=False)

    is_default_value = parse_template_boolean_value(
        data, parameter="is_default_value", default_value=False)
    if is_default_value:
        data["config_basename"] = "01-complianceascode-reinforce-os-defaults.conf"
    else:
        data["config_basename"] = "00-complianceascode-hardening.conf"

    return set_variables_for_test_scenarios(data)
