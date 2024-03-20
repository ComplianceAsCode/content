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
