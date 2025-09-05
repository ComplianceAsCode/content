def preprocess(data, lang):
    missing_parameter_pass = data["missing_parameter_pass"]
    if missing_parameter_pass == "true":
        missing_parameter_pass = True
    elif missing_parameter_pass == "false":
        missing_parameter_pass = False
    data["missing_parameter_pass"] = missing_parameter_pass
    return data
