import ssg.utils


def validate_sysctlval_type(data):
    # Testing type helps logic in OVAL, remediations and tests
    # We test none, string and what is left is list.
    if data["sysctlval"] is None:
        return True

    if isinstance(data["sysctlval"], list):
        if len(data["sysctlval"]) == 0:
            raise ValueError(
                "The sysctlval parameter of {0} is an empty list".format(
                    data["_rule_id"]))
        for val in data["sysctlval"]:
            if isinstance(data["sysctlval"], str):
                return False
    elif not(isinstance(data["sysctlval"], str)):
        return False

    return True


def validate(data):
    if not validate_sysctlval_type(data):
        raise ValueError(
            "The 'sysctlval' parameter of {0} must be either not set,"
            " string or, list of strings".format(
                data["_rule_id"]))

    # Configure data for test scenarios
    if data["datatype"] not in ["string", "int"]:
        raise ValueError(
            "Test scenarios for data type '{0}' are not implemented yet.\n"
            "Please check if rule '{1}' has correct data type and edit "
            "{2} to add tests for it.".format(
                data["datatype"], data["_rule_id"], __file__))


def preprocess(data, lang):
    data["sysctlid"] = ssg.utils.escape_id(data["sysctlvar"])
    if "sysctlval" not in data:
        data["sysctlval"] = None
    ipv6_flag = "P"
    if data["sysctlid"].find("ipv6") >= 0:
        ipv6_flag = "I"
    data["flags"] = "SR" + ipv6_flag
    if "operation" not in data:
        data["operation"] = "equals"

    if data["sysctlval"] is None:
        if data["datatype"] == "int":
            data["sysctl_correct_value"] = "0"
            data["sysctl_wrong_value"] = "1"
        elif data["datatype"] == "string":
            data["sysctl_correct_value"] = "correct_value"
            data["sysctl_wrong_value"] = "wrong_value"
        if "correct_sysctlval_for_testing" in data:
            data["sysctl_correct_value"] = data["correct_sysctlval_for_testing"]
        if "wrong_sysctlval_for_testing" in data:
            data["sysctl_wrong_value"] = data["wrong_sysctlval_for_testing"]
    elif isinstance(data["sysctlval"], list):
        data["sysctl_correct_value"] = data["sysctlval"][0]
        data["sysctl_wrong_value"] = data["wrong_sysctlval_for_testing"]
    else:
        data["sysctl_correct_value"] = data["sysctlval"]
        if data["datatype"] == "int":
            data["sysctl_wrong_value"] = str((int(data["sysctlval"]) + 1) % 2)
        elif data["datatype"] == "string":
            data["sysctl_wrong_value"] = "wrong_value"

    validate(data)

    return data
