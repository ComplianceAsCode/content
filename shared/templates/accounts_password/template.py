from ssg.utils import parse_template_boolean_value

def preprocess(data, lang):
    if lang == "oval":
        data["sign"] = "-?" if data["variable"].endswith("credit") else ""
    data["check_zero_boundary"] = parse_template_boolean_value(data, parameter="check_zero_boundary", default_value=False)
    data["zero_boundary_operator"] = data.get("zero_boundary_operator", "greater than")
    return data
