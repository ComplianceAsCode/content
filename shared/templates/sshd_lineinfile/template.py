from ssg.utils import parse_template_boolean_value


def preprocess(data, lang):
    data["missing_parameter_pass"] = parse_template_boolean_value(
        data, parameter="missing_parameter_pass", default_value=False)

    is_default_value = parse_template_boolean_value(
        data, parameter="is_default_value", default_value=False)
    if is_default_value:
        data["config_basename"] = "01-complianceascode-reinforce-os-defaults.conf"
    else:
        data["config_basename"] = "00-complianceascode-hardening.conf"
    return data
