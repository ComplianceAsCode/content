from ssg.utils import parse_template_boolean_value


def preprocess(data, lang):
    value = data["value"]
    if value[0] in ("'", '"') and value[0] == value[-1]:
        msg = (
            "Value >>{value}<< of shell variable '{varname}' "
            "has been supplied with quotes, please fix the content - "
            "shell quoting is handled by the check/remediation code."
            .format(value=value, varname=data["parameter"]))
        raise Exception(msg)

    data["missing_parameter_pass"] = parse_template_boolean_value(data, parameter="missing_parameter_pass", default_value=False)
    data["no_quotes"] = parse_template_boolean_value(data, parameter="no_quotes", default_value=False)

    return data
