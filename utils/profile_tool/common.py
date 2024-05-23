import json


def generate_output(dict_, format, csv_header):
    f_string = "{}: {}"

    if format == "json":
        print(json.dumps(dict_, indent=4))
        return
    elif format == "csv":
        print(csv_header)
        f_string = "{},{}"

    for rule_id, rule_count in dict_.items():
        print(f_string.format(rule_id, rule_count))


def _format_value_b(value_b, delim):
    str_ = ""
    if len(value_b) != 0:
        values = ", ".join([f"{key}: {value}" for key, value in value_b.items()])
        str_ = f"{delim}{values}"
    return str_


def merge_dicts(dict_a, dict_b, delim):
    out = {}
    for key, value in dict_a.items():
        value_b = dict_b.get(key, {})
        out[key] = str(value) + _format_value_b(value_b, delim)
    return out


def remove_zero_counts(dict_):
    return {key: value for key, value in dict_.items() if value != 0}
