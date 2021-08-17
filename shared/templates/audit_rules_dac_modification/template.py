from ssg.utils import parse_template_boolean_value


def preprocess(data, lang):
    data["check_root_user"] = parse_template_boolean_value(data, parameter="check_root_user", default_value=False)
    if lang == "bash":
        if "syscall_grouping" in data:
            # Make it easier to tranform the syscall_grouping into a Bash array
            data["syscall_grouping"] = " ".join(data["syscall_grouping"])
    elif lang == "ansible":
        if "attr" in data:
            # Tranform the syscall into a Ansible list
            data["attr"] = [data["attr"]]
        if "syscall_grouping" not in data:
            # Ensure that syscall_grouping is a list
            data["syscall_grouping"] = []

    return data
