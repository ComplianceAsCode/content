from ssg.utils import parse_template_boolean_value

def preprocess(data, lang):
    data["zero_comparison_operation"] = data.get("zero_comparison_operation", None)

    if "greater" in data["operation"]:
        if data["zero_comparison_operation"]:
            if "greater" in data["zero_comparison_operation"]:
                data["test_var_value"] = "-2"
                data["test_correct_value"] = "1"
                data["test_wrong_value"] = "-3"
                data["test_wrong_vs_zero_value"] = "-1"
            elif "less" in data["zero_comparison_operation"]:
                data["test_var_value"] = "-2"
                data["test_correct_value"] = "-1"
                data["test_wrong_value"] = "-3"
                data["test_wrong_vs_zero_value"] = "1"
        else:
            data["test_var_value"] = "0"
            data["test_correct_value"] = "1"
            data["test_wrong_value"] = "-1"

    elif "less" in data["operation"]:
        if data["zero_comparison_operation"]:
            if "greater" in data["zero_comparison_operation"]:
                data["test_var_value"] = "2"
                data["test_correct_value"] = "1"
                data["test_wrong_value"] = "3"
                data["test_wrong_vs_zero_value"] = "-1"
            elif "less" in data["zero_comparison_operation"]:
                data["test_var_value"] = "2"
                data["test_correct_value"] = "-1"
                data["test_wrong_value"] = "3"
                data["test_wrong_vs_zero_value"] = "1"
        else:
            data["test_var_value"] = "0"
            data["test_correct_value"] = "-1"
            data["test_wrong_value"] = "1"
    else:
        data["test_var_value"] = "0"
        data["test_correct_value"] = "0"
        data["test_wrong_value"] = "1"

    return data
