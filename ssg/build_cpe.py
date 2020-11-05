"""
Common functions for building CPEs
"""

from __future__ import absolute_import
from __future__ import print_function
import os

from .constants import oval_namespace
from .constants import PREFIX_TO_NS
from .products import get_all_product_yamls
from .utils import merge_dicts
from .xml import ElementTree as ET
from .yaml import open_raw


YAML_CPE_FILE = os.path.join("shared", "applicability", "cpes.yml")


class CPEDoesNotExist(Exception):
    pass


class Yaml_CPEs(object):
    """
    Reads all the yaml CPEs from cpes.yml.
    """

    def __init__(self):
        self.cpes_by_id = {}
        self.cpes_by_name = {}
        self.product_cpes = {}

        self._load_all_product_cpes()
        self.load_all_cpes()

    def _load_all_product_cpes(self):
        ssg_root = \
            os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
        product_yamls = get_all_product_yamls(ssg_root)

        for product in product_yamls:
            product_id = product["product"]
            try:
                product_cpes_list = product["cpes"]

                self.product_cpes[product_id] = {}
                for cpe in product_cpes_list:
                    for cpe_id in cpe.keys():
                        self.product_cpes[product_id][cpe_id] = cpe[cpe_id]

            except KeyError:
                print("Product %s does not define cpes" % (product_id))
                raise

    def load_all_cpes(self):
        ssg_root = \
            os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
        cpes_path = os.path.join(ssg_root, YAML_CPE_FILE)

        # "cpes" key is here for readability
        cpes_list = open_raw(cpes_path)["cpes"]
        for cpe in cpes_list:
            for cpe_id in cpe.keys():
                self.cpes_by_id[cpe_id] = cpe[cpe_id]

        for product in self.product_cpes:
            self.cpes_by_id = merge_dicts(self.cpes_by_id, self.product_cpes[product])

        # Generate a CPE map by name,
        # so that we can easily reference them by CPE Name
        # Note: After the shorthand is generated,
        # all references to CPEs are by its name
        for cpe_id, cpe in self.cpes_by_id.items():
            self.cpes_by_name[cpe["name"]] = cpe

    def _is_name(self, ref):
        return ref.startswith("cpe:")

    def get_cpe(self, ref):
        try:
            if self._is_name(ref):
                return self.cpes_by_name[ref]
            else:
                return self.cpes_by_id[ref]
        except KeyError:
            raise CPEDoesNotExist("CPE %s is not defined in %s" %(ref, YAML_CPE_FILE))


YAML_CPES = Yaml_CPEs()


def get_cpe_name(cpe_id):
    cpe = YAML_CPES.get_cpe(cpe_id)
    return cpe.get("name")

class CPEList(object):
    """
    Represents the cpe-list element from the CPE standard.
    """

    prefix = "cpe-dict"
    ns = PREFIX_TO_NS[prefix]

    def __init__(self):
        self.cpe_items = []

    def add(self, cpe_name):
        self.cpe_items.append(CPEItem(cpe_name))

    def to_xml_element(self, cpe_oval_file):
        cpe_list = ET.Element("{%s}cpe-list" % CPEList.ns)
        cpe_list.set("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
        cpe_list.set("xsi:schemaLocation",
                     "http://cpe.mitre.org/dictionary/2.0 "
                     "http://cpe.mitre.org/files/cpe-dictionary_2.1.xsd")

        self.cpe_items.sort(key=lambda cpe: cpe.name)
        for cpe_item in self.cpe_items:
            cpe_list.append(cpe_item.to_xml_element(cpe_oval_file))

        return cpe_list

    def to_file(self, file_name, cpe_oval_file):
        root = self.to_xml_element(cpe_oval_file)
        tree = ET.ElementTree(root)
        tree.write(file_name, encoding="utf-8")


class CPEItem(object):
    """
    Represents the cpe-list element from the CPE standard.
    """

    prefix = "cpe-dict"
    ns = PREFIX_TO_NS[prefix]

    def __init__(self, cpe_name):
        cpeitem_data = YAML_CPES.get_cpe(cpe_name)

        self.name = cpeitem_data["name"]
        self.title = cpeitem_data["title"]
        self.check_id = cpeitem_data["check_id"]

    def to_xml_element(self, cpe_oval_filename):
        cpe_item = ET.Element("{%s}cpe-item" % CPEItem.ns)
        cpe_item.set('name', self.name)

        cpe_item_title = ET.SubElement(cpe_item, "{%s}title" % CPEItem.ns)
        cpe_item_title.set('xml:lang', "en-us")
        cpe_item_title.text = self.title

        cpe_item_check = ET.SubElement(cpe_item, "{%s}check" % CPEItem.ns)
        cpe_item_check.set('system', oval_namespace)
        cpe_item_check.set('href', cpe_oval_filename)
        cpe_item_check.text = self.check_id

        return cpe_item


def extract_subelement(objects, sub_elem_type):
    """
    From a collection of element objects, return the value of
    the first attribute of name sub_elem_type found.

    This is useful when the object is a single element and
    we wish to query some external reference identifier
    in the subtree of that element.
    """

    for obj in objects:
        # decide on usage of .iter or .getiterator method of elementtree class.
        # getiterator is deprecated in Python 3.9, but iter is not available in
        # older versions
        if getattr(obj, "iter", None) == None:
            obj_iterator = obj.getiterator()
        else:
            obj_iterator = obj.iter()
        for subelement in obj_iterator:
            if subelement.get(sub_elem_type):
                sub_element = subelement.get(sub_elem_type)
                return sub_element


def extract_env_obj(objects, local_var):
    """
    From a collection of objects, return the object with id matching
    the object_ref of the local variable.

    NOTE: This assumes that a local variable can only reference one object.
    Which is not true, variables can reference multiple objects.
    But this assumption should work for OVAL checks for CPEs,
    as they are not that complicated.
    """

    for obj in objects:
        env_id = extract_subelement(local_var, 'object_ref')
        if env_id == obj.get('id'):
            return obj

    return None


def extract_referred_nodes(tree_with_refs, tree_with_ids, attrname):
    """
    Return the elements in tree_with_ids which are referenced
    from tree_with_refs via the element attribute 'attrname'.
    """

    reflist = []
    elementlist = []


    # decide on usage of .iter or .getiterator method of elementtree class.
    # getiterator is deprecated in Python 3.9, but iter is not available in
    # older versions
    if getattr(tree_with_refs, "iter", None) == None:
        tree_with_refs_iterator = tree_with_refs.getiterator()
    else:
        tree_with_refs_iterator = tree_with_refs.iter()
    for element in tree_with_refs_iterator:
        value = element.get(attrname)
        if value is not None:
            reflist.append(value)

    # decide on usage of .iter or .getiterator method of elementtree class.
    # getiterator is deprecated in Python 3.9, but iter is not available in
    # older versions
    if getattr(tree_with_ids, "iter", None) == None:
        tree_with_ids_iterator = tree_with_ids.getiterator()
    else:
        tree_with_ids_iterator = tree_with_ids.iter()
    for element in tree_with_ids_iterator:
        if element.get("id") in reflist:
            elementlist.append(element)

    return elementlist
