from ssg.utils import parse_template_boolean_value
from ssg.utils import ensure_file_paths_and_file_regexes_are_correctly_defined


def preprocess(data, lang):
    ensure_file_paths_and_file_regexes_are_correctly_defined(data)

    data["recursive"] = parse_template_boolean_value(data,
                                                     parameter="recursive",
                                                     default_value=False)

    try:
        int(data["uid_or_name"])
        data["owner_represented_with_uid"] = True
    except ValueError:
        data["owner_represented_with_uid"] = False

    if not data["owner_represented_with_uid"]:
        owners = data["uid_or_name"].split("|")
        if any(element.isnumeric() for element in owners):
            raise ValueError("uid_or_name list cannot contain uids when there are multiple owners")

    if lang == "oval":
        data["fileid"] = data["_rule_id"].replace("file_owner", "")
    return data
