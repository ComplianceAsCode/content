from ssg.utils import parse_template_boolean_value


def preprocess(data, lang):

    embedded_data = parse_template_boolean_value(data, parameter="embedded_data", default_value=False)
    data["embedded_data"] = embedded_data

    regex_data = parse_template_boolean_value(data, parameter="regex_data", default_value=False)
    data["regex_data"] = regex_data
    data["filepath_suffix"] = data.get("filepath_suffix")

    if data.get("xccdf_variable") and embedded_data:
        values = data.get("values", [{}])
        if len(values) > 1:
            raise ValueError(
                "Only a single value can be checked when querying "
                "for a 'xccdf_value' that returns an embedded value. "
                "Rule ID: {}".format(data["_rule_id"]))
        elif not values[0].get("value"):
            raise ValueError(
                "You should specify a capture regex in the 'value' field "
                "when querying for a 'xccdf_value' that returns an embedded value. "
                "Rule ID: {}".format(data["_rule_id"]))

    if data.get("xccdf_variable") and not embedded_data:
        if data.get("values"):
            raise ValueError(
                "You cannot specify the 'value' field when querying "
                "for a 'xccdf_value' that doesn't return an embedded value. "
                "Rule ID: {}".format(data["_rule_id"]))

    data["ocp_data"] = parse_template_boolean_value(data, parameter="ocp_data", default_value=False)

    return data
