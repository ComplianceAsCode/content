from ssg.utils import parse_template_boolean_value


def preprocess(data, lang):
    data["arg_negate"] = parse_template_boolean_value(data, parameter="arg_negate", default_value=False)
    data["arg_is_regex"] = parse_template_boolean_value(data, parameter="arg_is_regex", default_value=False)
    return data
