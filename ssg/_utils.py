import os
import re
import multiprocessing


class SSGError(RuntimeError):
    pass


def required_key(_dict, _key):
    if _key in _dict:
        return _dict[_key]

    raise ValueError("%s is required but was not found in:\n%s" %
                     (_key, repr(_dict)))


def get_cpu_count():
    try:
        return max(1, multiprocessing.cpu_count())

    except NotImplementedError:
        # 2 CPUs is the most probable
        return 2


def yes_no_prompt():
    prompt = "Would you like to proceed? (Y/N): "

    input_func = input
    try:
        if raw_input:
            input_func = raw_input
    except NameError:
        # Known exception on Python 3
        pass

    while True:
        data = input_func(prompt).lower()

        if data in ("yes", "y"):
            return True
        elif data in ("n", "no"):
            return False


def recursive_globi(mask):
    """
    Simple replacement of glob.globi(mask, recursive=true)
    Reason: Older Python versions support
    """

    parts = mask.split("**/")

    if not len(parts) == 2:
        raise NotImplementedError

    search_root = parts[0]

    # instead of '*' use regex '.*'
    path_mask = parts[1].replace("*", ".*")
    re_path_mask = re.compile(path_mask + "$")

    for root, dirnames, filenames in os.walk(search_root):
        paths = filenames + dirnames
        for path in paths:
            full_path = os.path.join(root, path)
            if re_path_mask.search(full_path):
                yield full_path
