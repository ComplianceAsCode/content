import os
import os.path
import re
import sys
import argparse
import datetime
import yaml



try:
    from xml.etree import cElementTree as ET
except ImportError:
    import cElementTree as ET

try:
    set
except NameError:
    # for python2
    from sets import Set as set

variable_formatting_types = {
        "bold": "b",
        "italics": "i",
        "config_item": "tt",
        "code": "pre",
        "config_value": "tt",
        }


def string_between_variables(string, variable1, variable2):
    pretext = string.find(variable1)
    if pretext == -1:
        return ""
    posttext = string.rfind(variable2)
    if posttext == -1:
        return ""
    between_text = pretext + len(variable1)
    if between_text >= posttext:
        return ""
    return string[between_text:posttext]


def string_before_variable(string, variable):
    before_variable = string.find(variable)
    if before_variable == -1:
        return ""
    return string[0:before_variable]


def string_after_variable(string, variable):
    rfind_variable = string.rfind(variable)
    if rfind_variable == -1:
        return ""
    after_variable = rfind_variable + len(variable)
    if after_variable >= len(string):
        return ""
    return string[after_variable:]


def transform_text_variables(element, string):
    # This needs to be refactored and cleaned up
    variables = []

    line = [line for line in string.splitlines()]
    for index in range(0, len(line)):
        for variable_type, element_type in sorted(variable_formatting_types.items()):
            variable = "".join(re.findall(("%s=\".*?\"" % variable_type), line[index], re.MULTILINE))
            if len(variable) > 0:
                d = {element_type: variable}
                variables.append(d)

    var_length = len(variables)
    if var_length > 0:
        for index in range(0, var_length):
            if index == 0:
                element.text = string_before_variable(string, "".join(variables[0].values()))
            for element_type, variable in variables[index].items():
                xccdfelem = ET.SubElement(element, element_type)
                xccdfelem.text = "".join(re.findall("\w+=\"(.*?)\"", variable, re.MULTILINE))
                try:
                    xccdfelem.tail = string_between_variables(string,
                                                              "".join(variables[index].values()),
                                                              "".join(variables[index + 1].values()))
                except IndexError as e:
                    xccdfelem.tail = string_after_variable(string, variable)
    else:
        element.text = string


#    var_length = len(variables)
#    if var_length > 0:
#        element.text = string_before_variable(string, variables[0])
#        for index in range(0, var_length):
#
#                xccdfelem = ET.SubElement(element, element_type)
#                xccdfelem.text = "".join(re.findall(("%s=\"(.*?)\"" % variable_type), variables[index]))
#                if index > 1 and var_length == 1:
#                    xccdfelem.tail = "".join(re.findall(("%s=\"(.*?)\"" % variable_type), variables[index]))
#                    xccdfelem.tail = string_after_variable(string, variables[index])
#                if var_length > 1:
#                    try:
#                        xccdfelem.tail = string_between_variables(string, variables[index], variables[index + 1])
#                       #print string_between_variables(string, variables[index], variables[index + 1])
#                    except IndexError as e:
#                        break

    return element
