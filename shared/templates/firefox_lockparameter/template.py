
def preprocess(data, lang):
    data["oval_extend_definitions"] = data.get("oval_extend_definitions", [])
    return data
