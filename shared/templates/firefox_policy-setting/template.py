from __future__ import print_function
import re
import json


def normalize_policy_path(path_string):
    """Generate a normalized path array from yaml.
       Paths are space-separated key names.
       All firefox policies are under the policies key.
    """
    path = []
    if len(path_string.strip()) > 0:
        path = re.split(" ", path_string)
    if path[0] != 'policies':
        path = ['policies'] + path
    return path


def make_json_boolean_match_regex(json_value):
    if json_value.lower() in ["false", "true"]:
        return r"[{0}{1}]{2}".format(json_value[0].upper(),
                                     json_value[0].lower(),
                                     json_value[1:]
                                     )
    return "\"{0}\"".format(json_value)


def make_json_boolean_remediate(json_value):
    if json_value.lower() in ["false", "true"]:
        return json_value.lower() == "true"
    return "\'{0}\'".format(json_value)


# These regexes work under the complexities currently observed with the Firefox
# policies.json, which is (so far) a subset of JSON that is just nested keys.
# No JSON arrays are supported.
# Remove the moment that OpenSCAP/OVAL spec supports a JSON configuration probe.
OVAL_MATCH_ANY_FOLLOWING = r"[^}]*\}"
OVAL_MATCH_OPEN_BRACES_FOR_BLOCK = r"\{[\s\S]*?"
OVAL_MATCH_ANYTHING_AFTER_OPEN_BRACE = r"\{[\s\S]*"

# Note: str.format() notation.
OVAL_MATCH_JSON_KEY = r'(?="{0}")"{0}"[\s]*:[\s]*'


def regex_escape(_search_string):
    return re.escape(_search_string)


def build_oval_search_regex_for_json_parameter(_path, parameter):
    parameter = r'(?=[^"]){0}"[\s]*:[\s]*([^,}}]+),?'.format(parameter)
    _result = parameter
    for p in reversed(_path):
        depth_match_block = OVAL_MATCH_OPEN_BRACES_FOR_BLOCK
        if p == "policies":
            depth_match_block = OVAL_MATCH_ANYTHING_AFTER_OPEN_BRACE

        _result = ''.join([OVAL_MATCH_JSON_KEY.format(regex_escape(p)),
                           depth_match_block,
                           _result])
    _result = r'^(?i)\{\s*' + _result + r'\s*'
    return _result


def build_python_json_notation(_path, depth=0):
    """Generate the Python call syntax for this path within a given distance
       from the top-level node.

       Parameters:
           _path: the list of the entire path in the JSON document to this
           particular key.
           depth: How far along the path to generate this syntax.
    """
    if depth > len(_path):
        return r''
    _result = r''
    for p in list(reversed(_path))[depth:]:
        _result = ''.join(["['{0}']".format(p), _result])
    return _result


def build_test_json(policy, _test, missing=False, wrong=False):
    """Generate a minimal JSON configuration for this particular policy object, based
       on a correct (set to value), missing, or wrong value.
       Returns a dict() containing this test entry.

       Parameters:
           policy: current policy item to generate for
           _test: dict() that has at least the value {"policies": {} }
    """
    _current = _test.get("policies")
    _key = policy["parameter"]
    _value = make_json_boolean_remediate(policy["value"])

    for p in policy["subpath"]:
        if p not in _current:
            _current[p] = dict()
        _current = _current.get(p)

    if wrong:
        _current[_key] = "VERYVERYBADVALUE"
    elif not missing:
        _current[_key] = _value
    return _test


def preprocess(data, lang):
    """Generate the appropriate regex for each policy path, search values, etc.
       Expects a dict of template arguments:
           path - Space-separated path in JSON to dictate where the parameter is. "policies" is
                  added to the front if not present or used if path is not present.
           parameter - Parameter name to search for the state of the value.
           value - Expected value to use for remediation.
           search_value (optional) - custom regular expression to use in the match for value.
    """
    _test_correct_config = {"policies": {}}
    _test_bad_missing = {"policies": {}}
    _test_bad_wrong = {"policies": {}}
    for i, _policy in enumerate(data.get("policies", [])):
        _path = normalize_policy_path(_policy.get("path", ""))

        # regex used in OVAL for detection
        _policy["oval_regex"] = build_oval_search_regex_for_json_parameter(_path,
                                                                           _policy["parameter"])
        _policy["oval_state"] = make_json_boolean_match_regex(_policy["value"])
        # Implement override for search_value
        if _policy.get("search_value", None):
            _policy["oval_state"] = _policy["search_value"]

        # path without "policies"
        _policy["subpath"] = _path[1:]
        # Precached notation for addressing JSON path
        _policy["path_python"] = [build_python_json_notation(_path, x)
                                  for x in range(0, len(_path) + 1)][:-1]
        # JSON path as iterable list, sans "policies"
        _policy["subpath_string"] = '_'.join(_path[1:])
        # entire JSON path to be set as an iterable list.
        _policy["path_list"] = _path
        # value with quotes added for simple insertion.
        _policy["value_escaped"] = make_json_boolean_remediate(_policy["value"])

        # correct_value.pass tests
        build_test_json(_policy,
                        _test_correct_config,
                        missing=False,
                        wrong=False)

        # missing_value.fail tests
        build_test_json(_policy,
                        _test_bad_missing,
                        missing=True,
                        wrong=False)

        # wrong_value.fail tests
        build_test_json(_policy,
                        _test_bad_wrong,
                        missing=False,
                        wrong=True)

        # Reassign the modified policy entry.
        data["policies"][i] = _policy

    # Pretty-print the output for our test JSON to variables
    # so that it can be used in the test templates.
    data["_correct_config"] = json.dumps(_test_correct_config, indent=4, separators=(',', ': '))
    data["_bad_missing"] = json.dumps(_test_bad_missing, indent=4, separators=(',', ': '))
    data["_bad_wrong"] = json.dumps(_test_bad_wrong, indent=4, separators=(',', ': '))
    return data
