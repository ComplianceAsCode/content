"""This class is designed to handle the mapping of meaningful, human-readable
names to IDs in the formats required by the SCAP checking systems, such as
OVAL and OCIL."""

import ConfigParser
import sys
import lxml.etree as ET

oval_ns = "http://oval.mitre.org/XMLSchema/oval-definitions-5"
oval_cs = "http://oval.mitre.org/XMLSchema/oval-definitions-5"
ocil_ns = "http://scap.nist.gov/schema/ocil/2.0"
ocil_cs = "http://scap.nist.gov/schema/ocil/2"

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

    if tag[:1] == "{":
        namespace, name = tag[1:].split("}", 1)
        return namespace.split("#")[0], name
    else:
        return (None, tag)


def namespace_to_prefix(tag):
    namespace, name = split_namespace(tag)
    if namespace == ocil_ns:
        return "ocil"
    if namespace == oval_ns:
        return "oval"
    sys.exit("Error: unknown checksystem referenced in tag : %s" % tag)


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
    sys.exit("Error: unknown checksystem referenced in tag : %s" % tag)


class idtranslator:
    def __init__(self, fname, content_id):
        self.fname = fname
        self.content_id = content_id
        self.config = ConfigParser.ConfigParser()
        conf = self.config.read(fname)
        if len(conf) == 0:
            self.__setup()

    def __get_next_id(self):
        idnum = self.config.getint("general", "next_id")
        num = "%d" % (idnum + 1)
        self.config.set("general", "next_id", num)
        return idnum

    def save(self):
        conf = open(self.fname, "wb")
        self.config.write(conf)

    def __setup(self):
        self.config.add_section("general")
        self.config.set("general", "next_id", "100")
        self.config.add_section("assigned")

    def assign_id(self, tagname, name):
        idnum = None
        try:
            idnum = self.config.getint("assigned", name)
        except:
            idnum = self.__get_next_id()
            self.config.set("assigned", name, str(idnum))

        str_id = "%s:%s:%s:%d" % (namespace_to_prefix(tagname),
                                  self.content_id, tagname_to_abbrev(tagname),
                                  idnum)
        return str_id

    def translate(self, tree, store_defname=False):
        for element in tree.getiterator():
            idname = element.get("id")
            if idname:
                # store the old name if requested (for OVAL definitions)
                if store_defname and element.tag == "{" + oval_ns + "}definition":
                    metadata = element.find("{" + oval_ns + "}metadata")
                    if metadata is None:
                        metadata = ET.SubElement(element, "metadata")
                    defnam = ET.SubElement(metadata, "reference",
                                           ref_id=idname, source=self.content_id)
                # set the element to the new identifier
                element.set("id", self.assign_id(element.tag, idname))
                # continue
            if element.tag == "{" + oval_ns + "}filter":
                element.text = self.assign_id("{" + oval_ns + "}state",
                                              element.text)
                continue
            if element.tag == "{" + oval_ns + "#independent}var_ref":
                element.text = self.assign_id("{" + oval_ns + "}variable",
                                              element.text)
                continue
            for attr in element.keys():
                if attr in ovalrefattr_to_tag.keys():
                    element.set(attr, self.assign_id("{" + oval_ns + "}" +
                                ovalrefattr_to_tag[attr], element.get(attr)))
                if attr in ocilrefattr_to_tag.keys():
                    element.set(attr, self.assign_id("{" + ocil_ns + "}" +
                                ocilrefattr_to_tag[attr], element.get(attr)))
            if element.tag == "{" + ocil_ns + "}test_action_ref":
                element.text = self.assign_id("{" + ocil_ns + "}action",
                                              element.text)

        self.save()
        # note: the ini file is not tracked by git, see .gitignore
        return tree
