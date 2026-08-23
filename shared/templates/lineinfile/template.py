from ssg.utils import parse_template_boolean_value

def preprocess(data, lang):
    data["oval_extend_definitions"] = data.get("oval_extend_definitions", [])
    data["escape_text"] = parse_template_boolean_value(data,
                                                     parameter="escape_text",
                                                     default_value=True)
    return data
