import ssg.utils
import re


def preprocess(data, lang):
    # Default value of default_is_enabled is false;
    # When variable_name is set, this option is disabled.
    # It is not easy to check if the value of an XCCDF Value is the default in a template.
    if "default_is_enabled" not in data or "variable_name" in data:
        data["default_is_enabled"] = "false"

    if data["default_is_enabled"] == "true":
        data["option_existence"] = "any_exist"
    else:
        data["option_existence"] = "at_least_one_exists"

    if lang == "oval":
        if "variable_name" in data:
            data["option_regex"] = data["option"] + r"=(\w+)"
        else:
            data["option_regex"] = data["option"]
    elif lang == "bash":
        if "variable_name" in data:
            data["option_regex"] = data["option"] + r"=\w+"
            data["option_value"] = "{opt}=${{{var}}}".format(opt=data["option"],
                                                             var=data["variable_name"])
        else:
            data["option_regex"] = data["option"]
            data["option_value"] = data["option"]

    return data
