from ssg.utils import parse_template_boolean_value
from ssg.utils import ensure_file_paths_and_file_regexes_are_correctly_defined


def preprocess(data, lang):
    ensure_file_paths_and_file_regexes_are_correctly_defined(data)

    data["recursive"] = parse_template_boolean_value(data,
                                                     parameter="recursive",
                                                     default_value=False)

    if lang == "oval":
        data["fileid"] = data["_rule_id"].replace("file_owner", "")
    return data
