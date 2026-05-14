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


def validate_rule_template_arguments(data, rule_id):
    """Validate and set defaults for rule.yml template arguments.

    Sets operation/datatype defaults for non-variable rules, requires
    explicit values for arg_variable rules, then validates all combinations.
    """
    arg_value    = data.get("arg_value")
    arg_variable = data.get("arg_variable")

    # arg_value and arg_variable are mutually exclusive
    if arg_value is not None and arg_variable is not None:
        raise RuntimeError(
            f"The template must not set both 'arg_value' and 'arg_variable'.\n"
            f"arg_name: {arg_value}\n"
            f"arg_variable: {arg_variable}"
        )

    # arg_value must be quoted in rule.yml.  YAML auto-parses unquoted
    # scalars: 8192 becomes int, on/off become bool True/False.  The
    # template needs a string to build regexes and config file content —
    # a silent int or bool would produce wrong patterns downstream.
    if arg_value is not None and type(arg_value) is not str:
        raise TypeError(
            f"arg_value must be a quoted string in rule.yml, got "
            f"{type(arg_value).__name__}: {arg_value!r} "
            f"for rule '{rule_id}'"
        )

    # arg_variable rules must set operation and datatype explicitly.
    # The .var file defines the XCCDF variable type (string/number) and
    # operator (equals/greater than or equal/...).  The OVAL state must
    # use matching datatype and operation, but template.py cannot read
    # .var files — so we force the rule author to declare both in
    # rule.yml and keep them in sync with the .var file manually.
    # Non-variable rules get safe defaults (equals/string).
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
    else:
        if "operation" not in data:
            data["operation"] = "equals"
        if "datatype" not in data:
            data["datatype"] = "string"

    # From here on, operation and datatype are always present
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

    # Any arg_value is a valid string, but int needs a parseable number
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

    # --- Test scenario values ---
    #
    # Automatus test scripts write values into GRUB config files, then oscap
    # scans and the result is compared to the filename (.pass.sh / .fail.sh).
    # Works because OVAL checks file contents directly — no service reload.
    #
    # arg_value rules:    value known at build time, compute real pass/fail.
    # arg_variable rules: value is an XCCDF variable resolved at scan time.
    #   template.py has no access to .var files, so we use
    #   arbitrary dummies (99999 for int).  Test scripts emit a directive
    #   (# variables = var_name=value) that makes Automatus XSLT-patch the
    #   datastream so oscap resolves the variable to the dummy.
    #   Same approach as sysctl/template.py.
    # flag-only GRUB argument (nousb): no value, skip.
    #
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

    # else: flag-only argument (e.g. nousb) — no value, no test values needed

    return data
