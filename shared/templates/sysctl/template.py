import ssg.utils


def preprocess(data, lang):
    data["sysctlid"] = ssg.utils.escape_id(data["sysctlvar"])
    if not data.get("sysctlval"):
        data["sysctlval"] = ""
    ipv6_flag = "P"
    if data["sysctlid"].find("ipv6") >= 0:
        ipv6_flag = "I"
    data["flags"] = "SR" + ipv6_flag
    if "operation" not in data:
        data["operation"] = "equals"

    # Configure data for test scenarios
    if data["sysctlval"] == "":
        if data["datatype"] == "int":
            data["sysctl_correct_value"] = "0"
            data["sysctl_wrong_value"] = "1"
        elif data["datatype"] == "string":
            data["sysctl_correct_value"] = "correct_value"
            data["sysctl_wrong_value"] = "wrong_value"
        else:
            raise ValueError(
                "Test scenarios for data type '{0}' are not implemented yet.\n"
                "Please check if rule '{1}' has correct data type and edit "
                "{2} to add tests for it.".format(data["datatype"], data["_rule_id"], __file__))
    else:
        data["sysctl_correct_value"] = data["sysctlval"]
        if data["datatype"] == "int":
            data["sysctl_wrong_value"] = "1" + data["sysctlval"]
        elif data["datatype"] == "string":
            data["sysctl_wrong_value"] = "wrong_value"
        else:
            raise ValueError(
                "Test scenarios for data type '{0}' are not implemented yet.\n"
                "Please check if rule '{1}' has correct data type and edit "
                "{2} to add tests for it.".format(data["datatype"], data["_rule_id"], __file__))
    return data
