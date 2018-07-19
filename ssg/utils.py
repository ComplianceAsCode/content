from __future__ import absolute_import
from __future__ import print_function

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


def merge_dicts(left, right):
    """
    Merges two dictionaries, keeing left and right as passed. If there are any
    common keys between left and right, the value from right is use.

    Returns the merger of the left and right dictionaries
    """
    result = left.copy()
    result.update(right)
    return result
