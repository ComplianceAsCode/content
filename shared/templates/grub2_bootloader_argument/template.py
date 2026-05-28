import ssg.utils


# Valid (datatype, operation) combinations for the OVAL ``<ind:subexpression>``
# element.  Ordering operations on strings would do lexicographic comparison,
# which is never what we want for kernel boot arguments.  Pattern match on int
# is equally nonsensical.
VALID_OPERATIONS_BY_DATATYPE = {
    "string": [
        "equals",
        "not equal",
        "pattern match",
    ],
    "int": [
        "equals",
        "not equal",
        "greater than",
        "less than",
        "greater than or equal",
        "less than or equal",
    ],
}

VALID_DATATYPES = list(VALID_OPERATIONS_BY_DATATYPE.keys())


def set_default_operation_and_datatype(data):
    if "operation" not in data:
        data["operation"] = "equals"
    if "datatype" not in data:
        data["datatype"] = "string"


def validate_rule_template_arguments(data, rule_id):
    """Validate variables used in the rule.yml and set required defaults if missing."""
    arg_value    = data.get("arg_value")
    arg_variable = data.get("arg_variable")

    if arg_value is not None:
        # arg_value and arg_variable are mutually exclusive
        if arg_variable is not None:
            raise RuntimeError(
                f"The template must not set both 'arg_value' and 'arg_variable'.\n"
                f"arg_value: {arg_value}\n"
                f"arg_variable: {arg_variable}"
            )

        # Require `arg_value` to be written as a quoted string in `rule.yml`.
        # - arg_name_value and the templates expect it to be a string.
        # - This check mainly catches unquoted numbers, as `ssg/yaml.py` keeps
        #   words such as `true` and `on` as strings, not booleans.
        if type(arg_value) is not str:
            raise TypeError(
                f"arg_value must be written as a quoted string in rule.yml. "
                f"Got {type(arg_value).__name__}: {arg_value!r} "
                f"for rule '{rule_id}'"
            )

    # If arg_variable is set:
    #   - operation must be explicit
    #   - datatype must be explicit
    #   - both must match the values in the `.var` file. `template.py` cannot read
    #     `.var` files, so the rule author must keep `rule.yml` in sync manually.
    if arg_variable is not None:
        if "operation" not in data:
            raise ValueError(
                f"Missing 'operation' in rule '{rule_id}'. "
                f"Required because arg_variable '{arg_variable}' is used — "
                f"set it to match the 'operator' field in "
                f"'{arg_variable}.var'."
            )
        if "datatype" not in data:
            raise ValueError(
                f"Missing 'datatype' in rule '{rule_id}'. "
                f"Required because arg_variable '{arg_variable}' is used — "
                f"set it to match the 'type' field in "
                f"'{arg_variable}.var'."
            )

    # If rule.yml does not set operation or datatype, use the defaults.
    if "operation" not in data or "datatype" not in data:
        set_default_operation_and_datatype(data)

    operation = data["operation"]
    datatype  = data["datatype"]

    # Validate datatype/operation combination
    if datatype not in VALID_DATATYPES:
        raise ValueError(
            f"Unsupported datatype '{datatype}' for rule '{rule_id}'. "
            f"Must be one of: {VALID_DATATYPES}"
        )

    valid_ops = VALID_OPERATIONS_BY_DATATYPE[datatype]
    if operation not in valid_ops:
        raise ValueError(
            f"Operation '{operation}' is not valid with "
            f"datatype '{datatype}' for rule '{rule_id}'. "
            f"Valid operations for '{datatype}': {valid_ops}"
        )

    # If datatype is `int`, `arg_value` must be an integer.
    if datatype == "int" and arg_value is not None:
        try:
            int(arg_value)
        except ValueError as err:
            raise ValueError(
                f"datatype is 'int' but arg_value '{arg_value}' "
                f"is not a valid integer for rule '{rule_id}'."
            ) from err


def preprocess(data, lang):
    """Preprocess template variables before rendering.

    Validates, sets defaults, escapes names for OVAL regex, and computes
    test scenario values.
    """
    rule_id = data.get("_rule_id", "unknown_rule_id") # default set to trace errors easier

    validate_rule_template_arguments(data, rule_id)

    arg_name     = data["arg_name"]
    arg_value    = data.get("arg_value")
    arg_variable = data.get("arg_variable")
    operation    = data["operation"]
    datatype     = data["datatype"]

    # --- Build derived variables ---

    # ARG_NAME_VALUE:
    #   arg_name and arg_value          -> "arg_name=arg_value"
    #   arg_variable or just arg_name   -> "arg_name" (arg_variable is injected in OVAL)
    data["arg_name_value"] = (
        f"{arg_name}={arg_value}" if arg_value is not None
        else arg_name
    )

    if lang == "oval":
        # Dots in arg names must be escaped in OVAL regex patterns
        # (e.g. ipv6.disable -> ipv6\.disable)
        data["arg_name_escaped_dots"] = arg_name.replace(".", "\\.")

    # Dots replaced by underscores
    # (e.g. ipv6.disable -> ipv6_disable)
    data["arg_name_underscored"] = ssg.utils.escape_id(arg_name)

    # --- Test values for template tests ---

    # If `arg_value` is set, it can be used to compute real test values.
    # If `arg_variable` is set, its value cannot be resolved from the XCCDF var.
    #   Therefore, we need to use dummy values for the test scenarios.
    if arg_variable is not None:
        if datatype == "int":
            data["test_value_pass"]    = "99999"
            data["test_value_fail"]    = "99998"
            data["value_below"]        = "99998"
            data["value_at_threshold"] = "99999"
            data["value_above"]        = "100000"
        else:
            # string variable — arbitrary placeholders
            data["test_value_pass"] = "correct_value"
            data["test_value_fail"] = "wrong_value"

    elif arg_value is not None:
        # arg_value rules: value is known at build time, compute real test values
        if datatype == "int":
            threshold          = int(arg_value)
            value_below        = threshold - 1
            value_at_threshold = threshold
            value_above        = threshold + 1

            data["value_below"]        = value_below
            data["value_at_threshold"] = value_at_threshold
            data["value_above"]        = value_above

            if operation == "equals":
                correct, wrong = value_at_threshold, value_above
            elif operation == "greater than or equal":
                correct, wrong = value_at_threshold, value_below
            else:
                raise ValueError(
                    f"No test values defined for int operation "
                    f"'{operation}' in rule '{rule_id}'"
                )
        else:
            # string with known value
            if operation in ("equals", "pattern match"):
                correct, wrong = arg_value, "wrong_value"
            else:
                raise ValueError(
                    f"No test values defined for string operation "
                    f"'{operation}' in rule '{rule_id}'"
                )

        data["test_value_pass"] = correct
        data["test_value_fail"] = wrong

    # else: only arg_name is set (e.g. nousb), no test values needed

    return data
