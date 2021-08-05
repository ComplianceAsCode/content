from ssg.utils import parse_template_boolean_value


def preprocess(data, lang):
    data["check_root_user"] = parse_template_boolean_value(data, parameter="check_root_user", default_value=False)

    return data
