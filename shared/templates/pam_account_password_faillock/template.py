def preprocess(data, lang):
    if data.get("ext_variable") is None:
        errmsg = ("The template instance of the rule {0} requires the "
                  "ext_variable to be defined".format(data["_rule_id"]))
        raise ValueError(errmsg)

    for var in ["variable_upper_bound", "variable_lower_bound"]:
        data[var] = data.get(var, None)
        if data.get(var) is not None and \
           data.get(var) != "use_ext_variable" and \
           type(data.get(var)) != int:
            errmsg = ("The template instance of the rule {0} requires the "
                      "parameter {1} is either 'use_ext_variable' or "
                      "a number or undefined".format(data["_rule_id"], data["var"]))
            raise ValueError(errmsg)
    return data
