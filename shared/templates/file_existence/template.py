from ssg.utils import parse_template_boolean_value


def preprocess(data, lang):
    data["exists"] = parse_template_boolean_value(data, parameter="exists", default_value=False)
    return data
