from ssg.utils import parse_template_boolean_value


def preprocess(data, lang):
    if "packagename" not in data:
        data["packagename"] = data["servicename"]
    if "daemonname" not in data:
        data["daemonname"] = data["servicename"]
    if "mask_service" not in data:
        data["mask_service"] = "true"
    data["allow_disabled"] = parse_template_boolean_value(
        data, parameter="allow_disabled", default_value=False)
    return data
