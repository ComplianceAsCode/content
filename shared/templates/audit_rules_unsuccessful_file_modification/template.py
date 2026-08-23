def _audit_rules_unsuccessful_file_modification(data, lang):
    if lang == "bash":
        if "syscall_grouping" in data:
            # Make it easier to tranform the syscall_grouping into a Bash array
            data["syscall_grouping"] = " ".join(data["syscall_grouping"])
    elif lang == "ansible":
        if "name" in data:
            # Tranform the syscall into a Ansible list
            # The syscall is under 'name'
            data["name"] = [data["name"]]
        if "syscall_grouping" not in data:
            # Ensure that syscall_grouping is a list
            data["syscall_grouping"] = []
    return data


def preprocess(data, lang):
    return _audit_rules_unsuccessful_file_modification(data, lang)
