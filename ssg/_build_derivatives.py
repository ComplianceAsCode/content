import re
from ssg._xml import ElementTree


def add_cpes(elem, namespace, mapping):
    """
    Adds derivative CPEs next to RHEL ones, checks XCCDF elements of given
    namespace.
    """

    affected = False

    for child in list(elem):
        affected = affected or add_cpes(child, namespace, mapping)

    # precompute this so that we can affect the tree while iterating
    children = list(elem.findall(".//{%s}platform" % (namespace)))

    for child in children:
        idref = child.get("idref")
        if idref in mapping:
            new_platform = ElementTree.Element("{%s}platform" % (namespace))
            new_platform.set("idref", mapping[idref])
            # this is done for the newline and indentation
            new_platform.tail = child.tail

            index = list(elem).index(child)
            # insert it right after the respective RHEL CPE
            elem.insert(index + 1, new_platform)

            affected = True

    return affected


def add_notice(benchmark, namespace, notice, warning):
    """
    Adds derivative notice as the first notice to given benchmark.
    """

    index = -1
    prev_element = None
    existing_notices = list(benchmark.findall("./{%s}notice" % (namespace)))
    if len(existing_notices) > 0:
        prev_element = existing_notices[0]
        # insert before the first notice
        index = list(benchmark).index(prev_element)
    else:
        existing_descriptions = list(
            benchmark.findall("./{%s}description" % (namespace))
        )
        prev_element = existing_descriptions[-1]
        # insert after the last description
        index = list(benchmark).index(prev_element) + 1

    if index == -1:
        raise RuntimeError(
            "Can't find existing notices or description in benchmark '%s'." %
            (benchmark)
        )

    elem = ElementTree.Element("{%s}notice" % (namespace))
    elem.set("id", warning)
    elem.append(notice)
    # this is done for the newline and indentation
    elem.tail = prev_element.tail
    benchmark.insert(index, elem)

    return True


def remove_idents(tree_root, namespace, prod="RHEL"):
    ident_exp = '.*' + prod + '-*'
    ref_exp = prod + '-*'
    for rule in tree_root.findall(".//{%s}Rule" % (namespace)):
        for ident in rule.findall(".//{%s}ident" % (namespace)):
            if ident is not None:
                if (re.search('CCE-*', ident.text) or
                        re.search(ident_exp, ident.text)):
                    rule.remove(ident)

        for ref in rule.findall(".//{%s}reference" % (namespace)):
            if ref.text is not None:
                if re.search(ref_exp, ref.text):
                    rule.remove(ref)


def scrape_benchmarks(root, namespace, dest):
    dest.extend([
        (namespace, elem)
        for elem in list(root.findall(".//{%s}Benchmark" % (namespace)))
    ])
    if root.tag == "{%s}Benchmark" % (namespace):
        dest.append((namespace, root))
