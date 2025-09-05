from __future__ import absolute_import
from __future__ import print_function

from .xml import ElementTree
from .constants import oval_namespace as oval_ns
from .constants import ocil_namespace as ocil_ns
from .constants import OVALTAG_TO_ABBREV, OCILTAG_TO_ABBREV
from .constants import OVALREFATTR_TO_TAG, OCILREFATTR_TO_TAG


def _split_namespace(tag):
    """returns a tuple of (namespace, tag),
    removing any fragment id from namespace
    """

    if tag[0] == "{":
        namespace, name = tag[1:].split("}", 1)
        return (namespace.split("#", 1)[0], name)

    return (None, tag)


def _namespace_to_prefix(tag):
    namespace, _ = _split_namespace(tag)
    if namespace == ocil_ns:
        return "ocil"
    if namespace == oval_ns:
        return "oval"

    raise RuntimeError(
        "Error: unknown checksystem referenced in tag : %s" % tag
    )


def _tagname_to_abbrev(tag):
    namespace, tag = _split_namespace(tag)
    if tag == "extend_definition":
        return tag
    # grab the last part of the tag name to determine its type
    tag = tag.rsplit("_", 1)[-1]
    if namespace == ocil_ns:
        return OCILTAG_TO_ABBREV[tag]
    if namespace == oval_ns:
        return OVALTAG_TO_ABBREV[tag]

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
            _namespace_to_prefix(tagname),
            self.content_id, name,
            _tagname_to_abbrev(tagname)
        )

    def translate(self, tree, store_defname=False):
        # decide on usage of .iter or .getiterator method of elementtree class.
        # getiterator is deprecated in Python 3.9, but iter is not available in
        # older versions
        if getattr(tree, "iter", None) == None:
            tree_iterator = tree.getiterator()
        else:
            tree_iterator = tree.iter()
        for element in tree_iterator:
            idname = element.get("id")
            if idname:
                # store the old name if requested (for OVAL definitions)
                if store_defname and \
                        element.tag == "{%s}definition" % oval_ns:
                    metadata = element.find("{%s}metadata" % oval_ns)
                    if metadata is None:
                        metadata = ElementTree.SubElement(element, "metadata")
                    defnam = ElementTree.Element(
                        "{%s}reference" % oval_ns, ref_id=idname, source=self.content_id)
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
            if element.tag == "{%s}object_reference" % oval_ns:
                element.text = self.generate_id("{%s}object" % oval_ns,
                                                element.text)
                continue
            for attr in element.keys():
                if attr in OVALREFATTR_TO_TAG.keys():
                    element.set(attr, self.generate_id(
                        "{%s}%s" % (oval_ns, OVALREFATTR_TO_TAG[attr]),
                        element.get(attr)))
                if attr in OCILREFATTR_TO_TAG.keys():
                    element.set(attr, self.generate_id(
                        "{%s}%s" % (ocil_ns, OCILREFATTR_TO_TAG[attr]),
                        element.get(attr)))
            if element.tag == "{%s}test_action_ref" % ocil_ns:
                element.text = self.generate_id("{%s}action" % ocil_ns,
                                                element.text)

        return tree
