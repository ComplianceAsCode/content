import ConfigParser

# This class is designed to handle the mapping of human-readable names to
# OVAL-style IDs.  This is intentionally designed to be compatible with 
# Tresys SCC, for future integration.


tag_to_abbrev = {
    'definition' : 'def',
    'criteria' : 'crit',
    'test' : 'tst',
    'object' : 'obj',
    'state' : 'ste',
    'variable' : 'var',
}


def tagname_to_abbrev(tag):
    tag = tag.split("}")[-1]
    if tag == "extend_definition":
        return tag
    tag = tag.rsplit("_", 1)[-1]
    return tag_to_abbrev[tag]

class idtranslate:
    def __init__(self, fname, prefix):
        self.fname = fname 
        self.prefix = prefix
        self.config = ConfigParser.ConfigParser()
        print "creating new file perhaps " + fname
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

