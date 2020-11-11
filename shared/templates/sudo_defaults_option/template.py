import ssg.utils
import re


def preprocess(data, lang):
    if "default_is_enabled" not in data:
        data["default_is_enabled"] = "false"

    if data["default_is_enabled"] == "true":
        data["option_existence"] = "any_exist"
    else:
        data["option_existence"] = "at_least_one_exists"

    return data
