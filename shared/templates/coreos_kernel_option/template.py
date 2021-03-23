from ssg.utils import parse_template_boolean_value


def preprocess(data, lang):
    data["arg_negate"] = parse_template_boolean_value(data, parameter="arg_negate", default_value=False)
    return data
