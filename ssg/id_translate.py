"""
Common functions for processing ID Translations in SSG
"""

from __future__ import absolute_import
from __future__ import print_function

from .xml import ElementTree
from .constants import oval_namespace as oval_ns
from .constants import ocil_namespace as ocil_ns
from .constants import OVALTAG_TO_ABBREV, OCILTAG_TO_ABBREV
from .constants import OVALREFATTR_TO_TAG, OCILREFATTR_TO_TAG


def _split_namespace(tag):
    """
    Splits an XML tag into its namespace and name components.

    Args:
        tag (str): The XML tag to split. If the tag contains a namespace, it should be in the
                   format '{namespace}name'.

    Returns:
        tuple: A tuple containing the namespace and the tag name. If the tag does not contain a
               namespace, the namespace will be None. Any fragment identifier in the namespace
               will be removed.
    """
    if tag[0] == "{":
        namespace, name = tag[1:].split("}", 1)
        return (namespace.split("#", 1)[0], name)

    return (None, tag)


def _namespace_to_prefix(tag):
    """
    Convert a namespace in a tag to its corresponding prefix.

    Args:
        tag (str): The tag containing the namespace to be converted.

    Returns:
        str: The prefix corresponding to the namespace.

    Raises:
        RuntimeError: If the namespace in the tag is unknown.

    """
    namespace, _ = _split_namespace(tag)
    if namespace == ocil_ns:
        return "ocil"
    if namespace == oval_ns:
        return "oval"

    raise RuntimeError(
        "Error: unknown checksystem referenced in tag : %s" % tag
    )


def _tagname_to_abbrev(tag):
    """
    Convert a tag name to its abbreviated form based on its namespace.

    Args:
        tag (str): The tag name to be converted, which may include a namespace.

    Returns:
        str: The abbreviated form of the tag name.

    Raises:
        RuntimeError: If the tag's namespace is unknown.

    Notes:
        - If the tag is "extend_definition", it is returned as is.
        - The tag name is split by the last underscore to determine its type.
        - The namespace is used to look up the abbreviation in the corresponding dictionary.
    """
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
    """
    IDTranslator is a class designed to handle the mapping of meaningful, human-readable names to
    IDs in the formats required by the SCAP checking systems, such as OVAL and OCIL.

    Attributes:
        content_id (str): The content identifier used in generating IDs.
    """
    def __init__(self, content_id):
        self.content_id = content_id

    def generate_id(self, tagname, name):
        """
        Generates a unique identifier string based on the provided tag name and name.

        Args:
            tagname (str): The tag name to be used in the identifier.
            name (str): The name to be used in the identifier.

        Returns:
            str: A unique identifier string in the format
                 "<namespace_prefix>:<content_id>-<name>:<tagname_abbrev>:1".
        """
        return "%s:%s-%s:%s:1" % (
            _namespace_to_prefix(tagname),
            self.content_id, name,
            _tagname_to_abbrev(tagname)
        )

    def translate(self, tree, store_defname=False):
        """
        Translates the IDs of elements in an XML tree to new identifiers.

        Args:
            tree (ElementTree.Element): The XML tree to be processed.
            store_defname (bool, optional): If True, stores the old name in the metadata for OVAL
                                            definitions. Defaults to False.

        Returns:
            ElementTree.Element: The processed XML tree with updated IDs.

        The function iterates through each element in the provided XML tree and performs the
        following actions based on the element's tag and attributes:
        - If the element has an "id" attribute, it generates a new ID and sets it.
        - If `store_defname` is True and the element is an OVAL definition, it stores the old ID
          in the metadata.
        - For specific tags like "filter", "var_ref", and "object_reference", it updates the text
          content with a new ID.
        - For attributes that match keys in `OVALREFATTR_TO_TAG` or `OCILREFATTR_TO_TAG`, it
          updates the attribute value with a new ID.
        - For the "test_action_ref" tag, it updates the text content with a new ID.
        """
        for element in tree.iter():
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

    def translate_oval_document(self, oval_document, store_defname=False):
        """
        Translates and validates an OVAL document.

        This method translates the IDs in the given OVAL document and validates its references.

        Args:
            oval_document: The OVAL document to be translated and validated.
            store_defname (bool, optional): If True, stores the definition name during
                                            translation. Defaults to False.

        Returns:
            The translated and validated OVAL document.
        """
        oval_document.translate_id(self, store_defname)
        oval_document.validate_references()
        return oval_document
