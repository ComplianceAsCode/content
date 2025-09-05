
import os


def preprocess(data, lang):
    data["lock_path"] = os.path.join(data["path"], "locks")
    data["dconf_database_directory"] = os.path.basename(os.path.normpath(data["path"]))
    return data
