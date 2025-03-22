from ssg.utils import parse_template_boolean_value


def preprocess(data, lang):
    data["missing_parameter_pass"] = parse_template_boolean_value(
        data, parameter="missing_parameter_pass", default_value=False)
    data["no_quotes"] = parse_template_boolean_value(
        data, parameter="no_quotes", default_value=False)
    data["missing_config_file_fail"] = parse_template_boolean_value(
        data, parameter="missing_config_file_fail", default_value=True)
    return data
