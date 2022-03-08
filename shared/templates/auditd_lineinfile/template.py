from ssg.utils import parse_template_boolean_value


def preprocess(data, lang):
    data["missing_parameter_pass"] = parse_template_boolean_value(data, parameter="missing_parameter_pass", default_value=False)
    if "value_regex" not in data:
        data["value_regex"] = data["value"]
    return data
