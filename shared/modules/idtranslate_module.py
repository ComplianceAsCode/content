try:
    from xml.etree import cElementTree as ElementTree
except ImportError:
    import cElementTree as ElementTree


oval_ns = "http://oval.mitre.org/XMLSchema/oval-definitions-5"
ocil_ns = "http://scap.nist.gov/schema/ocil/2.0"

ovaltag_to_abbrev = {
    'definition': 'def',
    'criteria': 'crit',
    'test': 'tst',
    'object': 'obj',
    'state': 'ste',
    'variable': 'var',
}

ociltag_to_abbrev = {
    'questionnaire': 'questionnaire',
    'action': 'testaction',
    'question': 'question',
    'artifact': 'artifact',
    'variable': 'variable',
}

ovalrefattr_to_tag = {
    "definition_ref": "definition",
    "test_ref": "test",
    "object_ref": "object",
    "state_ref": "state",
    "var_ref": "variable",
}

ocilrefattr_to_tag = {
    "question_ref": "question",
}

ocilrefchild_to_tag = {
    "test_action_ref": "action",
}


def split_namespace(tag):
    """returns a tuple of (namespace,name) removing any fragment id
    from namespace"""

    if tag[0] == "{":
        namespace, name = tag[1:].split("}", 1)
        return namespace.split("#")[0], name
    else:
        return (None, tag)


def namespace_to_prefix(tag):
    namespace, _ = split_namespace(tag)
    if namespace == ocil_ns:
        return "ocil"
    if namespace == oval_ns:
        return "oval"

    raise RuntimeError(
        "Error: unknown checksystem referenced in tag : %s" % tag
    )


def tagname_to_abbrev(tag):
    namespace, tag = split_namespace(tag)
    if tag == "extend_definition":
        return tag
    # grab the last part of the tag name to determine its type
    tag = tag.rsplit("_", 1)[-1]
    if namespace == ocil_ns:
        return ociltag_to_abbrev[tag]
    if namespace == oval_ns:
        return ovaltag_to_abbrev[tag]

    raise RuntimeError(
        "Error: unknown checksystem referenced in tag : %s" % tag
    )


class IDTranslator(object):
    """This class is designed to handle the mapping of meaningful, human-readable
    names to IDs in the formats required by the SCAP checking systems, such as
    OVAL and OCIL."""

    def __init__(self, content_id):
        self.content_id = content_id

    def generate_id(self, tagname, name):
        return "%s:%s-%s:%s:1" % (
            namespace_to_prefix(tagname),
            self.content_id, name,
            tagname_to_abbrev(tagname)
        )

    def translate(self, tree, store_defname=False):
        for element in tree.getiterator():
            idname = element.get("id")
            if idname:
                # store the old name if requested (for OVAL definitions)
                if store_defname and \
                        element.tag == "{%s}definition" % oval_ns:
                    metadata = element.find("{%s}metadata" % oval_ns)
                    if metadata is None:
                        metadata = ElementTree.SubElement(element, "metadata")
                    defnam = ElementTree.Element(
                        "reference", ref_id=idname, source=self.content_id)
                    metadata.append(defnam)

                # set the element to the new identifier
                element.set("id", self.generate_id(element.tag, idname))
                # continue
            if element.tag == "{%s}filter" % oval_ns:
                element.text = self.generate_id("{%s}state" % oval_ns,
                                                element.text)
                continue
            if element.tag == "{%s#independent}var_ref" % oval_ns:
                element.text = self.generate_id("{%s}variable" % oval_ns,
                                                element.text)
                continue
            for attr in element.keys():
                if attr in ovalrefattr_to_tag.keys():
                    element.set(attr, self.generate_id(
                        "{%s}%s" % (oval_ns, ovalrefattr_to_tag[attr]),
                        element.get(attr)))
                if attr in ocilrefattr_to_tag.keys():
                    element.set(attr, self.generate_id(
                        "{%s}%s" % (ocil_ns, ocilrefattr_to_tag[attr]),
                        element.get(attr)))
            if element.tag == "{%s}test_action_ref" % ocil_ns:
                element.text = self.generate_id("{%s}action" % ocil_ns,
                                                element.text)

        return tree
