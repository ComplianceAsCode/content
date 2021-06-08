from ssg.utils import parse_template_boolean_value


def preprocess(data, lang):
    # Default value of default_is_enabled is false;
    # When variable_name is set, this option is disabled.
    # It is not easy to check if the value of an XCCDF Value is the default in a template.
    data["default_is_enabled"] = parse_template_boolean_value(data, parameter="default_is_enabled", default_value=False)
    if data.get("variable_name"):
        data["default_is_enabled"] = False

    if data.get("default_is_enabled") is True:
        data["option_existence"] = "any_exist"
    else:
        data["option_existence"] = "at_least_one_exists"

    if lang == "oval":
        if data.get("variable_name"):
            if 'option_regex_suffix' not in data:
                data['option_regex_suffix'] = r"=(\w+)\b"
            data["option_regex"] = data["option"] + data['option_regex_suffix']
        else:
            data["option_regex"] = data["option"]
    elif lang == "bash":
        if data.get("variable_name"):
            if 'option_regex_suffix' not in data:
                data['option_regex_suffix'] = r"=\w+\b"
            data["option_regex"] = data["option"] + data['option_regex_suffix']
            data["option_value"] = "{opt}=${{{var}}}".format(opt=data["option"],
                                                             var=data["variable_name"])
        else:
            data["option_regex"] = data["option"]
            data["option_value"] = data["option"]

    return data
