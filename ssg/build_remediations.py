from __future__ import absolute_import
from __future__ import print_function

import sys
import os
import os.path
import re
import codecs
from collections import defaultdict, namedtuple

from .jinja import process_file as jinja_process_file
from .xml import ElementTree
from .products import parse_name, map_name
from .constants import MULTI_PLATFORM_LIST

REMEDIATION_TO_EXT_MAP = {
    'anaconda': '.anaconda',
    'ansible': '.yml',
    'bash': '.sh',
    'puppet': '.pp'
}

FILE_GENERATED_HASH_COMMENT = '# THIS FILE IS GENERATED'

REMEDIATION_CONFIG_KEYS = ['complexity', 'disruption', 'platform', 'reboot',
                           'strategy']
REMEDIATION_ELM_KEYS = ['complexity', 'disruption', 'reboot', 'strategy']


def is_applicable_for_product(platform, product):
    """Based on the platform dict specifier of the remediation script to
    determine if this remediation script is applicable for this product.
    Return 'True' if so, 'False' otherwise"""

    # If the platform is None, platform must not exist in the config, so exit with False.
    if not platform:
        return False

    product, product_version = parse_name(product)

    # Define general platforms
    multi_platforms = ['multi_platform_all',
                       'multi_platform_' + product]

    # First test if platform isn't for 'multi_platform_all' or
    # 'multi_platform_' + product
    for _platform in multi_platforms:
        if _platform in platform and product in MULTI_PLATFORM_LIST:
            return True

    product_name = ""
    # Get official name for product
    if product_version is not None:
        product_name = map_name(product) + ' ' + product_version
    else:
        product_name = map_name(product)

    # Test if this is for the concrete product version
    for _name_part in platform.split(','):
        if product_name == _name_part.strip():
            return True

    # Remediation script isn't neither a multi platform one, nor isn't
    # applicable for this product => return False to indicate that
    return False


def get_available_functions(build_dir):
    """Parse the content of "$CMAKE_BINARY_DIR/bash-remediation-functions.xml"
    XML file to obtain the list of currently known SCAP Security Guide internal
    remediation functions"""

    # If location of /shared directory is known
    if build_dir is None or not os.path.isdir(build_dir):
        sys.stderr.write("Expected '%s' to be the build directory. It doesn't "
                         "exist or is not a directory." % (build_dir))
        sys.exit(1)

    # Construct the final path of XML file with remediation functions
    xmlfilepath = \
        os.path.join(build_dir, "bash-remediation-functions.xml")

    if not os.path.isfile(xmlfilepath):
        sys.stderr.write("Expected '%s' to contain the remediation functions. "
                         "The file was not found!\n" % (xmlfilepath))
        sys.exit(1)

    remediation_functions = []
    with codecs.open(xmlfilepath, "r", encoding="utf-8") as xmlfile:
        filestring = xmlfile.read()
        # This regex looks implementation dependent but we can rely on
        # ElementTree sorting XML attrs alphabetically. Hidden is guaranteed
        # to be the first attr and ID is guaranteed to be second.
        remediation_functions = re.findall(
            r'<Value hidden=\"true\" id=\"function_(\S+)\"',
            filestring, re.DOTALL
        )

    return remediation_functions


def get_fixgroup_for_type(fixcontent, remediation_type):
    """
    For a given remediation type, return a new subelement of that type.

    Exits if passed an unknown remediation type.
    """
    if remediation_type == 'anaconda':
        return ElementTree.SubElement(
            fixcontent, "fix-group", id="anaconda",
            system="urn:redhat:anaconda:pre",
            xmlns="http://checklists.nist.gov/xccdf/1.1")

    elif remediation_type == 'ansible':
        return ElementTree.SubElement(
            fixcontent, "fix-group", id="ansible",
            system="urn:xccdf:fix:script:ansible",
            xmlns="http://checklists.nist.gov/xccdf/1.1")

    elif remediation_type == 'bash':
        return ElementTree.SubElement(
            fixcontent, "fix-group", id="bash",
            system="urn:xccdf:fix:script:sh",
            xmlns="http://checklists.nist.gov/xccdf/1.1")

    elif remediation_type == 'puppet':
        return ElementTree.SubElement(
            fixcontent, "fix-group", id="puppet",
            system="urn:xccdf:fix:script:puppet",
            xmlns="http://checklists.nist.gov/xccdf/1.1")

    sys.stderr.write("ERROR: Unknown remediation type '%s'!\n"
                     % (remediation_type))
    sys.exit(1)


def is_supported_filename(remediation_type, filename):
    """
    Checks if filename has a supported extension for remediation_type.

    Exits when remediation_type is of an unknown type.
    """
    if remediation_type in REMEDIATION_TO_EXT_MAP:
        return filename.endswith(REMEDIATION_TO_EXT_MAP[remediation_type])

    sys.stderr.write("ERROR: Unknown remediation type '%s'!\n"
                     % (remediation_type))
    sys.exit(1)


def get_populate_replacement(remediation_type, text):
    """
    Return varname, fixtextcontribution
    """

    if remediation_type == 'bash':
        # Extract variable name
        varname = re.search(r'\npopulate (\S+)\n',
                            text, re.DOTALL).group(1)
        # Define fix text part to contribute to main fix text
        fixtextcontribution = '\n%s="' % varname
        return (varname, fixtextcontribution)

    sys.stderr.write("ERROR: Unknown remediation type '%s'!\n"
                     % (remediation_type))
    sys.exit(1)


def _split_remediation_content_and_metadata(fix_file_lines):
    remediation_contents = []
    config = defaultdict(lambda: None)

    # Assignment automatically escapes shell characters for XML
    for line in fix_file_lines:
        if line.startswith(FILE_GENERATED_HASH_COMMENT):
            continue

        if line.startswith('#') and line.count('=') == 1:
            (key, value) = line.strip('#').split('=')
            if key.strip() in REMEDIATION_CONFIG_KEYS:
                config[key.strip()] = value.strip()
                continue

        # If our parsed line wasn't a config item, add it to the
        # returned file contents. This includes when the line
        # begins with a '#' and contains an equals sign, but
        # the "key" isn't one of the known keys from
        # REMEDIATION_CONFIG_KEYS.
        remediation_contents.append(line)

    remediation = namedtuple('remediation', ['contents', 'config'])
    return remediation(remediation_contents, config)


def parse_from_file_with_jinja(file_path, env_yaml):
    """
    Parses a remediation from a file. As remediations contain jinja macros,
    we need a env_yaml context to process these. In practice, no remediations
    use jinja in the configuration, so for extracting only the configuration,
    env_yaml can be an abritrary product.yml dictionary.

    If the logic of configuration parsing changes significantly, please also
    update ssg.fixes.parse_platform(...).
    """

    fix_file_lines = jinja_process_file(file_path, env_yaml).splitlines()
    return _split_remediation_content_and_metadata(fix_file_lines)


def parse_from_file_without_jinja(file_path):
    """
    Parses a remediation from a file. Doesn't process the Jinja macros.
    This function is useful in build phases in which all the Jinja macros
    are already resolved.
    """
    with open(file_path, "r") as f:
        lines = f.read().splitlines()
        return _split_remediation_content_and_metadata(lines)


def process_fix(fixes, remediation_type, env_yaml, product, file_path, fix_name):
    """
    Process a fix, adding it to fixes iff the file is of a valid extension
    for the remediation type and the fix is valid for the current product.

    Note that platform is a required field in the contents of the fix.
    """

    if not is_supported_filename(remediation_type, file_path):
        return

    result = parse_from_file_with_jinja(file_path, env_yaml)

    if not result.config['platform']:
        raise RuntimeError(
            "The '%s' remediation script does not contain the "
            "platform identifier!" % (file_path))

    if is_applicable_for_product(result.config['platform'], product):
        fixes[fix_name] = result


def write_fixes_to_xml(remediation_type, build_dir, output_path, fixes):
    """
    Builds a fix-content XML tree from the contents of fixes
    and writes it to output_path.
    """

    fixcontent = ElementTree.Element("fix-content", system="urn:xccdf:fix:script:sh",
                                     xmlns="http://checklists.nist.gov/xccdf/1.1")
    fixgroup = get_fixgroup_for_type(fixcontent, remediation_type)

    remediation_functions = get_available_functions(build_dir)

    for fix_name in fixes:
        fix_contents, config = fixes[fix_name]

        fix_elm = ElementTree.SubElement(fixgroup, "fix")
        fix_elm.set("rule", fix_name)

        for key in REMEDIATION_ELM_KEYS:
            if config[key]:
                fix_elm.set(key, config[key])

        fix_elm.text = "\n".join(fix_contents)
        fix_elm.text += "\n"

        # Expand shell variables and remediation functions
        # into corresponding XCCDF <sub> elements
        expand_xccdf_subs(fix_elm, remediation_type, remediation_functions)

    tree = ElementTree.ElementTree(fixcontent)
    tree.write(output_path)


def write_fixes_to_dir(fixes, remediation_type, output_dir):
    """
    Writes fixes as files to output_dir, each fix as a separate file
    """
    try:
        extension = REMEDIATION_TO_EXT_MAP[remediation_type]
    except KeyError:
        raise ValueError("Unknown remediation type %s." % remediation_type)

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    for fix_name in fixes:
        fix_contents, config = fixes[fix_name]
        fix_path = os.path.join(output_dir, fix_name + extension)
        with open(fix_path, "w") as f:
            for k, v in config.items():
                f.write("# %s = %s\n" % (k, v))
            f.write("\n".join(fix_contents))


def expand_xccdf_subs(fix, remediation_type, remediation_functions):
    """For those remediation scripts utilizing some of the internal SCAP
    Security Guide remediation functions expand the selected shell variables
    and remediation functions calls with <xccdf:sub> element

    This routine translates any instance of the 'populate' function call in
    the form of:

            populate variable_name

    into

            variable_name="<sub idref="variable_name"/>"

    Also transforms any instance of the 'ansible-populate' function call in the
    form of:
            (ansible-populate variable_name)
    into

            <sub idref="variable_name"/>

    Also transforms any instance of some other known remediation function (e.g.
    'replace_or_append' etc.) from the form of:

            function_name "arg1" "arg2" ... "argN"

    into:

            <sub idref="function_function_name"/>
            function_name "arg1" "arg2" ... "argN"
    """

    if remediation_type == "ansible":
        fix_text = fix.text

        if "(ansible-populate " in fix_text:
            raise RuntimeError(
                "(ansible-populate VAR) has been deprecated. Please use "
                "(xccdf-var VAR) instead. Keep in mind that the latter will "
                "make an ansible variable out of XCCDF Value as opposed to "
                "substituting directly."
            )

        # If you change this string make sure it still matches the pattern
        # defined in OpenSCAP. Otherwise you break variable handling in
        # 'oscap xccdf generate fix' and the variables won't be customizable!
        # https://github.com/OpenSCAP/openscap/blob/1.2.17/src/XCCDF_POLICY/xccdf_policy_remediate.c#L588
        #   const char *pattern =
        #     "- name: XCCDF Value [^ ]+ # promote to variable\n  set_fact:\n"
        #     "    ([^:]+): (.+)\n  tags:\n    - always\n";
        # We use !!str typecast to prevent treating values as different types
        # eg. yes as a bool or 077 as an octal number
        fix_text = re.sub(
            r"- \(xccdf-var\s+(\S+)\)",
            r"- name: XCCDF Value \1 # promote to variable\n"
            r"  set_fact:\n"
            r"    \1: !!str (ansible-populate \1)\n"
            r"  tags:\n"
            r"    - always",
            fix_text
        )

        pattern = r'\(ansible-populate\s*(\S+)\)'

        # we will get list what looks like
        # [text, varname, text, varname, ..., text]
        parts = re.split(pattern, fix_text)

        fix.text = parts[0]  # add first "text"
        for index in range(1, len(parts), 2):
            varname = parts[index]
            text_between_vars = parts[index + 1]

            # we cannot combine elements and text easily
            # so text is in ".tail" of element
            xccdfvarsub = ElementTree.SubElement(fix, "sub", idref=varname)
            xccdfvarsub.tail = text_between_vars
        return

    elif remediation_type == "puppet":
        pattern = r'\(puppet-populate\s*(\S+)\)'

        # we will get list what looks like
        # [text, varname, text, varname, ..., text]
        parts = re.split(pattern, fix.text)

        fix.text = parts[0]  # add first "text"
        for index in range(1, len(parts), 2):
            varname = parts[index]
            text_between_vars = parts[index + 1]

            # we cannot combine elements and text easily
            # so text is in ".tail" of element
            xccdfvarsub = ElementTree.SubElement(fix, "sub", idref=varname)
            xccdfvarsub.tail = text_between_vars
        return

    elif remediation_type == "anaconda":
        pattern = r'\(anaconda-populate\s*(\S+)\)'

        # we will get list what looks like
        # [text, varname, text, varname, ..., text]
        parts = re.split(pattern, fix.text)

        fix.text = parts[0]  # add first "text"
        for index in range(1, len(parts), 2):
            varname = parts[index]
            text_between_vars = parts[index + 1]

            # we cannot combine elements and text easily
            # so text is in ".tail" of element
            xccdfvarsub = ElementTree.SubElement(fix, "sub", idref=varname)
            xccdfvarsub.tail = text_between_vars
        return

    elif remediation_type == "bash":
        # This remediation script doesn't utilize internal remediation functions
        # Skip it without any further processing
        if 'remediation_functions' not in fix.text:
            return

        # This remediation script utilizes some of internal remediation functions
        # Expand shell variables and remediation functions calls with <xccdf:sub>
        # elements
        pattern = r'\n+(\s*(?:' + r'|'.join(remediation_functions) + r')[^\n]*)\n'
        patcomp = re.compile(pattern, re.DOTALL)
        fixparts = re.split(patcomp, fix.text)
        if fixparts[0] is not None:
            # Split the portion of fix.text from fix start to first call of
            # remediation function, keeping only the third part:
            # * tail        to hold part of the fix.text after inclusion,
            #               but before first call of remediation function
            try:
                rfpattern = '(.*remediation_functions)(.*)'
                rfpatcomp = re.compile(rfpattern, re.DOTALL)
                _, _, tail, _ = re.split(rfpatcomp, fixparts[0], maxsplit=2)
            except ValueError:
                sys.stderr.write("Processing fix.text for: %s rule\n"
                                 % fix.get('rule'))
                sys.stderr.write("Unable to extract part of the fix.text "
                                 "after inclusion of remediation functions."
                                 " Aborting..\n")
                sys.exit(1)
            # If the 'tail' is not empty, make it new fix.text.
            # Otherwise use ''
            fix.text = tail if tail is not None else ''
            # Drop the first element of 'fixparts' since it has been processed
            fixparts.pop(0)
            # Perform sanity check on new 'fixparts' list content (to continue
            # successfully 'fixparts' has to contain even count of elements)
            if len(fixparts) % 2 != 0:
                sys.stderr.write("Error performing XCCDF expansion on "
                                 "remediation script: %s\n"
                                 % fix.get("rule"))
                sys.stderr.write("Invalid count of elements. Exiting!\n")
                sys.exit(1)
            # Process remaining 'fixparts' elements in pairs
            # First pair element is remediation function to be XCCDF expanded
            # Second pair element (if not empty) is the portion of the original
            # fix text to be used in newly added sublement's tail
            for idx in range(0, len(fixparts), 2):
                # We previously removed enclosing newlines when creating
                # fixparts list. Add them back and reuse the above 'pattern'
                fixparts[idx] = "\n%s\n" % fixparts[idx]
                # Sanity check (verify the first field truly contains call of
                # some of the remediation functions)
                if re.match(pattern, fixparts[idx], re.DOTALL) is not None:
                    # This chunk contains call of 'populate' function
                    if "populate" in fixparts[idx]:
                        varname, fixtextcontrib = get_populate_replacement(remediation_type,
                                                                           fixparts[idx])
                        # Define new XCCDF <sub> element for the variable
                        xccdfvarsub = ElementTree.Element("sub", idref=varname)

                        # If this is first sub element,
                        # the textcontribution needs to go to fix text
                        # otherwise, append to last subelement
                        nfixchildren = len(list(fix))
                        if nfixchildren == 0:
                            fix.text += fixtextcontrib
                        else:
                            previouselem = fix[nfixchildren-1]
                            previouselem.tail += fixtextcontrib

                        # If second pair element is not empty, append it as
                        # tail for the subelement (prefixed with closing '"')
                        if fixparts[idx + 1] is not None:
                            xccdfvarsub.tail = '"' + '\n' + fixparts[idx + 1]
                        # Otherwise append just enclosing '"'
                        else:
                            xccdfvarsub.tail = '"' + '\n'
                        # Append the new subelement to the fix element
                        fix.append(xccdfvarsub)
                    # This chunk contains call of other remediation function
                    else:
                        # Extract remediation function name
                        funcname = re.search(r'\n\s*(\S+)(| .*)\n',
                                             fixparts[idx],
                                             re.DOTALL).group(1)
                        # Define new XCCDF <sub> element for the function
                        xccdffuncsub = ElementTree.Element(
                            "sub", idref='function_%s' % funcname)
                        # Append original function call into tail of the
                        # subelement
                        xccdffuncsub.tail = fixparts[idx]
                        # If the second element of the pair is not empty,
                        # append it to the tail of the subelement too
                        if fixparts[idx + 1] is not None:
                            xccdffuncsub.tail += fixparts[idx + 1]
                        # Append the new subelement to the fix element
                        fix.append(xccdffuncsub)
                        # Ensure the newly added <xccdf:sub> element for the
                        # function will be always inserted at newline
                        # If xccdffuncsub is the first <xccdf:sub> element
                        # being added as child of <fix> and fix.text doesn't
                        # end up with newline character, append the newline
                        # to the fix.text
                        if list(fix).index(xccdffuncsub) == 0:
                            if re.search(r'.*\n$', fix.text) is None:
                                fix.text += '\n'
                        # If xccdffuncsub isn't the first child (first
                        # <xccdf:sub> being added), and tail of previous
                        # child doesn't end up with newline, append the newline
                        # to the tail of previous child
                        else:
                            previouselem = fix[list(fix).index(xccdffuncsub) - 1]
                            if re.search(r'.*\n$', previouselem.tail) is None:
                                previouselem.tail += '\n'

        # Perform a sanity check if all known remediation function calls have been
        # properly XCCDF substituted. Exit with failure if some wasn't

        # First concat output form of modified fix text (including text appended
        # to all children of the fix)
        modfix = [fix.text]
        for child in fix.getchildren():
            if child is not None and child.text is not None:
                modfix.append(child.text)
        modfixtext = "".join(modfix)
        for func in remediation_functions:
            # Then efine expected XCCDF sub element form for this function
            funcxccdfsub = "<sub idref=\"function_%s\"" % func
            # Finally perform the sanity check -- if function was properly XCCDF
            # substituted both the original function call and XCCDF <sub> element
            # for that function need to be present in the modified text of the fix
            # Otherwise something went wrong, thus exit with failure
            if func in modfixtext and funcxccdfsub not in modfixtext:
                sys.stderr.write("Error performing XCCDF <sub> substitution "
                                 "for function %s in %s fix. Exiting...\n"
                                 % (func, fix.get("rule")))
                sys.exit(1)
    else:
        sys.stderr.write("Unknown remediation type '%s'\n" % (remediation_type))
        sys.exit(1)
