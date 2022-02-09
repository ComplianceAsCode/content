from ssg.utils import parse_template_boolean_value

def preprocess(data, lang):
    if lang == "oval":
        data["sign"] = "-?" if data["variable"].endswith("credit") else ""
    data["zero_comparison_operation"] = data.get("zero_comparison_operation", None)
    return data
