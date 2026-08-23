import ssg.utils
from xml.sax.saxutils import unescape


def preprocess(data, lang):
    if lang == "oval":
        pathid = ssg.utils.escape_id(data["filepath"])
        # remove root slash made into '_'
        pathid = pathid[1:]
        data["filepath_id"] = pathid

    # The build system converts "<",">" and "&" for us
    if lang == "bash" or lang == "ansible":
        data["contents"] = unescape(data["contents"])
    return data
