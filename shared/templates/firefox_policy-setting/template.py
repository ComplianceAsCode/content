from __future__ import print_function
import re


def parameter_insert(_path, parameter, value, tier=0):
    if tier > len(_path):
        return r''
    search_point = r'/"{0}"\s*:\s*/a '.format(_path[tier])
    parameter = r'"{0}": {1},\n'.format(parameter, make_json_boolean(value))
    _result = parameter
    for p in reversed(_path[tier + 1:]):
        _result = ''.join([r'"{0}": '.format(p), r"{\n", _result, r"},\n"])
    # chop off the last newline
    _result = _result[:-2]
    return ''.join([search_point, _result])


def parameter_replace_search_sed(_path, parameter):
    preamble = r''.join([r'"{0}"\s*:'.format(x) + r'\s*\{.*\s*' for x in _path])
    post = r'"' + parameter + r'"\s*:\s*)"?[a-zA-Z_ 0-9]+"?,?(\v.*)'
    return str(''.join(['(', preamble, post]))


def regular_path(path_string):
    path = []
    if len(path_string.strip()) > 0:
        path = re.split(" ", path_string)
    if 'policies' not in path:
        path = ['policies'] + path
    return path


def make_json_boolean(instr):
    if instr in ["false", "true"]:
        return instr.capitalize()
    return "\'{0}\'".format(instr)


def make_json_boolean_oval(instr):
    if instr in ["false", "true"]:
        return instr
    return "\"{0}\"".format(instr)


def parameter_find_oval(_path, parameter, value):
    parameter = r'"{0}"[\s]*:[\s]*{1},?'.format(parameter, make_json_boolean_oval(value))
    _result = parameter
    for p in reversed(_path):
        if p == "policies":
            _result = ''.join([r'"{0}"[\s]*:[\s]*'.format(p),
                               r"\{.*[\s]*",
                               _result,
                               r"[^}]*\}"])
        else:
            _result = ''.join([r'"{0}"[\s]*:[\s]*'.format(p),
                               r"(\{?(\{[^}]*\}?)*|[^}]*)[\s]*",
                               _result,
                               r"[^}]*\}"])
    return _result


def parameter_find_grep(_path, parameter, tier=0):
    if tier >= len(_path):
        return r''
    parameter = r'"{0}"\s*:\s*("?\w+"?),?'.format(parameter)
    _result = parameter
    for p in reversed(_path[tier:]):
        _result = ''.join([r'"{0}"\s*:\s*'.format(p),
                           r"(\{?(\{[^}]*\}?)*|[^}]*)\s*",
                           _result,
                           r"[^}]*\}"])
    return _result


def path_find_grep(_path, tier=0):
    if tier > len(_path):
        return r''
    _result = r''
    for p in list(reversed(_path))[tier:]:
        _result = ''.join([r'"{0}"\s*:\s*'.format(p), r"\{.*\s*", _result])
    return _result


def path_find_python(_path, tier=0):
    if tier > len(_path):
        return r''
    _result = r''
    for p in list(reversed(_path))[tier:]:
        _result = ''.join(["['{0}']".format(p), _result])
    return _result


def preprocess(data, lang):
    for i in range(0, len(data.get("policies", []))):
        # Cache the policy setting to reduce line length
        _policy = data["policies"][i]
        _path = regular_path(_policy.get("path", ""))

        # regex used in OVAL for detection
        _policy["oval_regex"] = parameter_find_oval(_path,
                                                    _policy["parameter"],
                                                    _policy["value"])

        # Regex used in sed replacement item for this policy change.
        _policy["parameter_replace_sed"] = parameter_replace_search_sed(_path,
                                                                        _policy["parameter"])

        # PCRE Regex for grep to see if a path entry exists.
        _policy["path_grep"] = [path_find_grep(_path, x) for x in range(0, len(_path))]

        # PCRE Regex for grep to see if a path entry exists.
        _policy["parameter_grep"] = [parameter_find_grep(_path,
                                                         _policy["parameter"],
                                                         x)
                                     for x in range(0, len(_path))]

        # Sed "append" insertion string.
        _policy["parameter_insert"] = [parameter_insert(_path,
                                                        _policy["parameter"],
                                                        _policy["value"],
                                                        x)
                                       for x in range(0, len(_path))]
        # path without "policies"
        _policy["subpath"] = _path[1:]
        # Precached notation for addressing JSON path
        _policy["path_python"] = [path_find_python(_path, x)
                                  for x in range(0, len(_path))]
        # JSON path as iterable list, sans "policies"
        _policy["subpath_string"] = '_'.join(_path[1:])
        # entire JSON path to be set as an iterable list.
        _policy["path_list"] = _path
        # value with quotes added for simple insertion.
        _policy["value_escaped"] = make_json_boolean(_policy["value"])

        # Reassign the modified policy entry.
        data["policies"][i] = _policy
    return data
