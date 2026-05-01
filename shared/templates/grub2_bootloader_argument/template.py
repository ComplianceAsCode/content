import ssg.utils

VALID_OPERATIONS = {
    "pattern match",
    "greater than or equal",
}


def preprocess(data, lang):
    # arg_value and arg_variable are mutually exclusive
    if 'arg_value' in data and 'arg_variable' in data:
        raise RuntimeError(
                "ERROR: The template should not set both 'arg_value' and 'arg_variable'.\n"
                "arg_name: {0}\n"
                "arg_variable: {1}".format(data['arg_value'], data['arg_variable']))

    # Fallback to pattern match operation if not set
    if "operation" not in data:
        data["operation"] = "pattern match"

    # Placeholder values substituted into tests/*.sh scenarios via
    # TEST_CORRECT_VALUE / TEST_WRONG_VALUE (e.g. grub2_bootloader_argument_remediation calls)  
    match data["operation"]:
        case "pattern match":
            data["test_correct_value"] = "correct_value"
            data["test_wrong_value"] = "wrong_value"
        case "greater than or equal":
            data["test_correct_value"] = "200"
            data["test_wrong_value"] = "199"
        case _:
            raise RuntimeError(
                f"ERROR: Invalid operation '{data['operation']}' for rule "
                f"'{data['_rule_id']}'. "
                f"Must be one of: {sorted(VALID_OPERATIONS)}"
            )

    # Build ARG_NAME_VALUE ("name=value") used in oval.template comments/metadata,
    # bash.template remediation, and ansible.template remediation.
    # When arg_variable is set the value comes from an XCCDF variable at eval time.
    
    if 'arg_variable' in data or "arg_value" not in data:
        data["arg_name_value"] = data["arg_name"]
    else:
            data["arg_name_value"] = data["arg_name"] + "=" + data["arg_value"]

    if 'is_substring' not in data:
        data["is_substring"] = "false"

    # OVAL-specific: escape dots for regex patterns in oval.template
    # (ESCAPED_ARG_NAME_VALUE in state subexpressions, ESCAPED_ARG_NAME in object patterns)
    data["escaped_arg_name_value"] = data["arg_name_value"].replace(".", "\\.")
    data["escaped_arg_name"] = data["arg_name"].replace(".", "\\.")
    # SANITIZED_ARG_NAME: used as component of OVAL IDs (test_grub2_<name>_*,
    # obj_grub2_<name>_*, state_grub2_<name>_*) and bash bootc .toml filenames
    data["sanitized_arg_name"] = ssg.utils.escape_id(data["arg_name"])
    return data
