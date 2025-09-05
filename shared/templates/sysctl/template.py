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
    return data
