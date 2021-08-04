import ssg.utils


def preprocess(data, lang):
    if lang == "oval":
        pathid = ssg.utils.escape_id(data["path"])
        # remove root slash made into '_'
        pathid = pathid[1:]
        data["pathid"] = pathid
    elif lang == "bash":
        if "syscall_grouping" in data:
            # Make it easier to tranform the syscall_grouping into a Bash array
            data["syscall_grouping"] = " ".join(data["syscall_grouping"])
    return data
