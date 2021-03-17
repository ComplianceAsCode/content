from ssg.utils import parse_template_boolean_value


def preprocess(data, lang):
    data["missing_parameter_pass"] = parse_template_boolean_value(data, parameter="missing_parameter_pass", default_value=False)
    return data
