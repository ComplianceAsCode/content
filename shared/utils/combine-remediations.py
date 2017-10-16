#!/usr/bin/env python2

import sys
import os
import os.path
import re
import errno
import argparse

try:
    from xml.etree import cElementTree as ElementTree
except ImportError:
    import cElementTree as ElementTree

# Put shared python modules in path
sys.path.insert(0, os.path.join(
        os.path.dirname(os.path.dirname(os.path.realpath(__file__))),
        "modules"))
from map_product_module import map_product, parse_product_name, multi_product_list


FILE_GENERATED = '# THIS FILE IS GENERATED'


def fix_is_applicable_for_product(platform, product):
    """Based on the platform dict specifier of the remediation script to
    determine if this remediation script is applicable for this product.
    Return 'True' if so, 'False' otherwise"""

    product, product_version = parse_product_name(product)

    # Define general platforms
    multi_platforms = ['multi_platform_all',
                       'multi_platform_' + product]

    # First test if platform isn't for 'multi_platform_all' or
    # 'multi_platform_' + product
    result = False
    for mp in multi_platforms:
        if mp in platform and product in multi_product_list:
            result = True

    product_name = ""
    # Get official name for product
    if product_version is not None:
        product_name = map_product(product) + ' ' + product_version
    else:
        product_name = map_product(product)

    # Test if this is for the concrete product version
    for pf in platform.split(','):
        if product_name == pf.strip():
            result = True

    # Remediation script isn't neither a multi platform one, nor isn't
    # applicable for this product => return False to indicate that
    return product_name, result


def get_available_remediation_functions(build_dir):
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
    with open(xmlfilepath, "r") as xmlfile:
        filestring = xmlfile.read()
        # This regex looks implementation dependent but we can rely on
        # ElementTree sorting XML attrs alphabetically. Hidden is guaranteed
        # to be the first attr and ID is guaranteed to be second.
        remediation_functions = re.findall(
            '<Value hidden=\"true\" id=\"function_(\S+)\"',
            filestring, re.DOTALL
        )

    return remediation_functions


def get_fixgroup_for_remediation_type(fixcontent, remediation_type):
    if remediation_type == 'anaconda':
        return ElementTree.SubElement(fixcontent, "fix-group", id="anaconda",
                                system="urn:redhat:anaconda:pre",
                                xmlns="http://checklists.nist.gov/xccdf/1.1")

    if remediation_type == 'ansible':
        return ElementTree.SubElement(fixcontent, "fix-group", id="ansible",
                                system="urn:xccdf:fix:script:ansible",
                                xmlns="http://checklists.nist.gov/xccdf/1.1")

    elif remediation_type == 'bash':
        return ElementTree.SubElement(fixcontent, "fix-group", id="bash",
                                system="urn:xccdf:fix:script:sh",
                                xmlns="http://checklists.nist.gov/xccdf/1.1")

    elif remediation_type == 'puppet':
        return ElementTree.SubElement(fixcontent, "fix-group", id="puppet",
                                system="urn:xccdf:fix:script:puppet",
                                xmlns="http://checklists.nist.gov/xccdf/1.1")

    sys.stderr.write("ERROR: Unknown remediation type '%s'!\n"
                     % (remediation_type))
    sys.exit(1)


def is_supported_filename(remediation_type, filename):
    if remediation_type == 'anaconda':
        return filename.endswith('.anaconda')

    elif remediation_type == 'ansible':
        return filename.endswith('.yml')

    elif remediation_type == 'bash':
        return filename.endswith('.sh')

    elif remediation_type == 'puppet':
        return filename.endswith('.pp')

    sys.stderr.write("ERROR: Unknown remediation type '%s'!\n"
                     % (remediation_type))
    sys.exit(1)


def get_populate_replacement(remediation_type, text):
    """
    Return varname, fixtextcontribution
    """

    if remediation_type == 'bash':
        # Extract variable name
        varname = re.search('\npopulate (\S+)\n',
                            text, re.DOTALL).group(1)
        # Define fix text part to contribute to main fix text
        fixtextcontribution = '\n%s="' % varname
        return (varname, fixtextcontribution)

    sys.stderr.write("ERROR: Unknown remediation type '%s'!\n"
                     % (remediation_type))
    sys.exit(1)


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

        fix_text = re.sub(
            r"- \(xccdf-var\s+(\S+)\)",
            r"- name: XCCDF Value \1 # promote to variable\n"
            r"  set_fact:\n"
            r"    \1: (ansible-populate \1)\n"
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
        parts = re.split(pattern, fix.text)
        fix.text = parts[0]

        return

    elif remediation_type == "bash":
        # This remediation script doesn't utilize internal remediation functions
        # Skip it without any further processing
        if 'remediation_functions' not in fix.text:
            return

        # This remediation script utilizes some of internal remediation functions
        # Expand shell variables and remediation functions calls with <xccdf:sub>
        # elements
        pattern = '\n+(\s*(?:' + '|'.join(remediation_functions) + ')[^\n]*)\n'
        patcomp = re.compile(pattern, re.DOTALL)
        fixparts = re.split(patcomp, fix.text)
        if fixparts[0] is not None:
            # Split the portion of fix.text from fix start to first call of
            # remediation function into two parts:
            # * head        to hold inclusion of the remediation functions
            # * tail        to hold part of the fix.text after inclusion,
            #               but before first call of remediation function
            try:
                rfpattern = '(.*remediation_functions)(.*)'
                rfpatcomp = re.compile(rfpattern, re.DOTALL)
                _, head, tail, _ = re.split(rfpatcomp, fixparts[0], maxsplit=2)
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
                        varname, fixtextcontrib = get_populate_replacement(
                                remediation_type,
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
                        funcname = re.search('\n\s*(\S+)(| .*)\n',
                                                fixparts[idx],
                                                re.DOTALL).group(1)
                        # Define new XCCDF <sub> element for the function
                        xccdffuncsub = ElementTree.Element("sub",
                                                        idref='function_%s' % \
                                                        funcname)
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
                            if re.search('.*\n$', fix.text) is None:
                                fix.text += '\n'
                        # If xccdffuncsub isn't the first child (first
                        # <xccdf:sub> being added), and tail of previous
                        # child doesn't end up with newline, append the newline
                        # to the tail of previous child
                        else:
                            previouselem = fix[list(fix).index(xccdffuncsub) - 1]
                            if re.search('.*\n$', previouselem.tail) is None:
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
        for f in remediation_functions:
            # Then efine expected XCCDF sub element form for this function
            funcxccdfsub = "<sub idref=\"function_%s\"" % f
            # Finally perform the sanity check -- if function was properly XCCDF
            # substituted both the original function call and XCCDF <sub> element
            # for that function need to be present in the modified text of the fix
            # Otherwise something went wrong, thus exit with failure
            if f in modfixtext and funcxccdfsub not in modfixtext:
                sys.stderr.write("Error performing XCCDF <sub> substitution "
                                 "for function %s in %s fix. Exiting...\n"
                                 % (f, fix.get("rule")))
                sys.exit(1)
    else:
        sys.stderr.write("Unknown remediation type '%s'\n" % (remediation_type))
        sys.exit(1)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--product", required=True,
                   help="which product are we building for? example: rhel7")
    p.add_argument("--remediation_type", required=True,
                   help="language or type of the remediations we are combining."
                   "example: ansible")
    p.add_argument("--build_dir", required=True,
                   help="where is the cmake build directory. pass value of "
                   "$CMAKE_BINARY_DIR.")
    p.add_argument("--output", type=argparse.FileType('w'), required=True)
    p.add_argument("fixdirs", metavar="FIX_DIR", nargs="+",
                   help="directory(ies) from which we will collect "
                   "remediations to combine.")

    args, unknown = p.parse_known_args()
    if unknown:
        sys.stderr.write(
            "Unknown positional arguments " + ",".join(unknown) + ".\n"
        )
        sys.exit(1)

    fixcontent = ElementTree.Element(
        "fix-content", system="urn:xccdf:fix:script:sh",
        xmlns="http://checklists.nist.gov/xccdf/1.1")
    fixgroup = get_fixgroup_for_remediation_type(fixcontent,
                                                 args.remediation_type)
    fixes = dict()

    remediation_functions = get_available_remediation_functions(args.build_dir)

    included_fixes_count = 0
    for fixdir in args.fixdirs:
        try:
            for filename in os.listdir(fixdir):
                if not is_supported_filename(args.remediation_type, filename):
                    continue

                # Create and populate new fix element based on shell file
                fixname = os.path.splitext(filename)[0]

                mod_file = []
                config = {}
                with open(os.path.join(fixdir, filename), 'r') as fix_file:
                    # Assignment automatically escapes shell characters for XML
                    for line in fix_file.readlines():
                        if line.startswith('#'):
                            try:
                                (key, value) = line.strip('#').split('=')
                                if key.strip() in ['complexity', 'disruption',
                                                   'platform', 'reboot',
                                                   'strategy']:
                                    config[key.strip()] = value.strip()
                                else:
                                    if not line.startswith(FILE_GENERATED):
                                        mod_file.append(line)
                            except ValueError:
                                if not line.startswith(FILE_GENERATED):
                                    mod_file.append(line)
                        else:
                            mod_file.append(line)

                complexity = None
                disruption = None
                reboot = None
                script_platform = None
                strategy = None

                if 'complexity' in config:
                    complexity = config['complexity']
                if 'disruption' in config:
                    disruption = config['disruption']
                if 'platform' in config:
                    script_platform = config['platform']
                if 'complexity' in config:
                    reboot = config['reboot']
                if 'complexity' in config:
                    strategy = config['strategy']

                if script_platform:
                    product_name, result = fix_is_applicable_for_product(
                        script_platform, args.product)
                    if result:
                        if fixname in fixes:
                            fix = fixes[fixname]
                            for child in list(fix):
                                fix.remove(child)
                        else:
                            fix = ElementTree.SubElement(fixgroup, "fix")
                            fix.set("rule", fixname)
                            if complexity is not None:
                                fix.set("complexity", complexity)
                            if disruption is not None:
                                fix.set("disruption", disruption)
                            if reboot is not None:
                                fix.set("reboot", reboot)
                            if strategy is not None:
                                fix.set("strategy", strategy)
                            fixes[fixname] = fix
                            included_fixes_count += 1

                        fix.text = "".join(mod_file)

                        # Expand shell variables and remediation functions
                        # into corresponding XCCDF <sub> elements
                        expand_xccdf_subs(
                            fix, args.remediation_type,
                            remediation_functions
                        )
                else:
                    sys.stderr.write("Skipping '%s' remediation script. "
                                        "The platform identifier in the "
                                        "script is missing!\n" % (filename))
        except OSError as e:
            if e.errno != errno.ENOENT:
                raise
            else:
                sys.stderr.write("Not merging remediation scripts from the "
                                 "'%s' directory as the directory does not "
                                 "exist.\n" % (fixdir))

    sys.stderr.write("Merged %d %s remediations.\n"
                     % (included_fixes_count, args.remediation_type))
    tree = ElementTree.ElementTree(fixcontent)
    tree.write(args.output)

    sys.exit(0)

if __name__ == "__main__":
    main()
