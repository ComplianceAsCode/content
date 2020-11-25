def preprocess(data, lang):
    data["ocp_data"] = data.get("ocp_data", "false") == "true"
    return data
