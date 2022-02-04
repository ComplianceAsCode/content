from ssg.utils import parse_template_boolean_value

def preprocess(data, lang):
    if lang == "oval":
        data["sign"] = "-?" if data["variable"].endswith("credit") else ""
    data["nonzero_check"] = parse_template_boolean_value(data, parameter="nonzero_check", default_value=False)
    return data
