from __future__ import absolute_import
from __future__ import print_function

import multiprocessing
import errno
import os


class SSGError(RuntimeError):
    pass


def required_key(_dict, _key):
    """
    Returns the value of _key if it is in _dict; otherwise, raise an
    exception stating that it was not found but is required.
    """

    if _key in _dict:
        return _dict[_key]

    raise ValueError("%s is required but was not found in:\n%s" %
                     (_key, repr(_dict)))


def get_cpu_count():
    """
    Returns the most likely estimate of the number of CPUs in the machine
    for threading purposes, gracefully handling errors and possible
    exceptions.
    """

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


def subset_dict(dictionary, keys):
    """
    Restricts dictionary to only have keys from keys. Does not modify either
    dictionary or keys, returning the result instead.
    """

    result = dictionary.copy()
    for original_key in dictionary:
        if original_key not in keys:
            del result[original_key]

    return result


def read_file_list(path):
    """
    Reads the given file path and returns the contents as a list.
    """

    file_contents = open(path, 'r').read().split("\n")
    if file_contents[-1] == '':
        file_contents = file_contents[:-1]
    return file_contents


def write_list_file(path, contents):
    """
    Writes the given contents to path.
    """

    _contents = "\n".join(contents) + "\n"
    _f = open(path, 'w')
    _f.write(_contents)
    _f.flush()
    _f.close()


# Taken from https://stackoverflow.com/a/600612/592892
def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise
