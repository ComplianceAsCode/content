import ssg.utils
import os


def preprocess(data, lang):
    path = data["path"]
    name = ssg.utils.escape_id(os.path.basename(path))
    data["name"] = name
    if lang == "oval":
        data["id"] = data["_rule_id"]
        data["title"] = "Record Any Attempts to Run " + name
        data["path"] = path.replace("/", "\\/")
    elif lang == "kubernetes":
        npath = path.replace("/", "_")
        if npath[0] == '_':
            npath = npath[1:]
        data["normalized_path"] = npath
    elif lang == "bash":
        if "syscall_grouping" in data:
            # Make it easier to tranform the syscall_grouping into a Bash array
            data["syscall_grouping"] = " ".join(data["syscall_grouping"])
    elif lang == "ansible":
        # This template does not use the 'syscall' parameters
        data["syscall"] = []
        data["syscall_grouping"] = []
    return data
