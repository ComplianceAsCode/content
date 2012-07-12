import ConfigParser
import lxml.etree as ET 

# This class is designed to handle the mapping of human-readable names to
# OVAL-style IDs.  This is intentionally similar to code in  
# Tresys SCC, to enable future integration.

ovalns = "{http://oval.mitre.org/XMLSchema/oval-definitions-5}"

keyword_to_abbrev = {
    'definition' : 'def',
    'criteria' : 'crit',
    'test' : 'tst',
    'object' : 'obj',
    'state' : 'ste',
    'variable' : 'var',
}

refattr_to_keyword = {
    "definition_ref" : "definition",
    "test_ref" : "test",
    "object_ref" : "object",
    "state_ref" : "state",
    "var_ref" : "variable",
}

def tagname_to_abbrev(tag):
    tag = tag.split("}")[-1]
    if tag == "extend_definition":
        return tag
    tag = tag.rsplit("_", 1)[-1]
    return keyword_to_abbrev[tag]

class idtranslator:
    def __init__(self, fname, prefix):
        self.fname = fname 
        self.prefix = prefix
        self.config = ConfigParser.ConfigParser()
        f = self.config.read(fname)
        if len(f) == 0:
            self.__setup()

    def __get_next_id(self):
        i = self.config.getint("general", "next_id")
        n = "%d" % (i + 1)
        self.config.set("general", "next_id", n)
        return i

    def save(self):
        fd = open(self.fname, "wb")
        self.config.write(fd)

    def __setup(self):
        self.config.add_section("general")
        self.config.set("general", "id_prefix", self.prefix)
        self.config.set("general", "next_id", "100")
        self.config.add_section("assigned")

    def assign_id(self, tagname, name):
        i = None
        try:
            i = self.config.getint("assigned", name)
        except:
            i = self.__get_next_id()
            self.config.set("assigned", name, str(i))

        pre = self.config.get("general", "id_prefix")
        str_id = "%s:%s:%d" % (pre, tagname_to_abbrev(tagname), i)
        return str_id

    def translate(self, tree):
        for element in tree.getiterator():
            if element.get("id"):
                element.set("id", self.assign_id(element.tag, element.get("id")))
                continue
            if element.tag == ovalns + "filter":
                element.text = self.assign_id("state", element.text)
                continue
            for attr in element.keys():
                if attr in refattr_to_keyword.keys():
                    element.set(attr, self.assign_id(refattr_to_keyword[attr], element.get(attr)))
        self.save()
        # note: the ini file is not tracked by git, see .gitignore
        return tree


