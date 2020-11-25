def preprocess(data, lang):
    value = data["value"]
    if value[0] in ("'", '"') and value[0] == value[-1]:
        msg = (
            "Value >>{value}<< of shell variable '{varname}' "
            "has been supplied with quotes, please fix the content - "
            "shell quoting is handled by the check/remediation code."
            .format(value=value, varname=data["parameter"]))
        raise Exception(msg)
    missing_parameter_pass = data.get("missing_parameter_pass", "false")
    if missing_parameter_pass == "true":
        missing_parameter_pass = True
    elif missing_parameter_pass == "false":
        missing_parameter_pass = False
    data["missing_parameter_pass"] = missing_parameter_pass
    no_quotes = False
    if data["no_quotes"] == "true":
        no_quotes = True
    data["no_quotes"] = no_quotes
    return data
