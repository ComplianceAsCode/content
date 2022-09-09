from ssg.utils import parse_template_boolean_value

def preprocess(data, lang):
    data["zero_comparison_operation"] = data.get("zero_comparison_operation", None)
    return data
