"""
Common functions for building CPEs
"""

from __future__ import absolute_import
from __future__ import print_function
import os
import sys
from collections import namedtuple, defaultdict

from .constants import oval_namespace
from .constants import PREFIX_TO_NS
from .utils import merge_dicts, required_key
from .xml import ElementTree as ET
from .boolean_expression import Algebra, Symbol, Function
from .data_structures import XCCDFEntity

from . import remediations


class CPEDoesNotExist(Exception):
    pass


class ProductCPEs(object):
    """
    Reads from the disk all the yaml CPEs related to a product
    and provides them in a structured way.
    """

    def __init__(self):

        self.cpes_by_id = {}
        self.cpes_by_name = {}
        self.product_cpes = {}
        self.platforms = {}
        self.algebra = Algebra(symbol_cls=CPEALFactRef, function_cls=CPEALLogicalTest)

    def load_product_cpes(self, env_yaml):
        try:
            product_cpes_list = env_yaml["cpes"]
            for cpe in product_cpes_list:
                for cpe_id in cpe.keys():
                    cpe[cpe_id]["id_"] = cpe_id
                    self.product_cpes[cpe_id] = CPEItem.get_instance_from_full_dict(cpe[cpe_id])
                    self.product_cpes[cpe_id].is_product_cpe = True


        except KeyError:
            print("Product %s does not define 'cpes'" % (env_yaml["product"]))
            raise

    def load_content_cpes(self, env_yaml):
        cpes_root = required_key(env_yaml, "cpes_root")
        # we have to "absolutize" the paths the right way, relative to the env_yaml path
        if not os.path.isabs(cpes_root):
            cpes_root = os.path.join(env_yaml["product_dir"], cpes_root)
        self.load_cpes_from_directory_tree(cpes_root, env_yaml)

    def load_cpes_from_directory_tree(self, root_path, env_yaml):
        for dir_item in sorted(os.listdir(root_path)):
            dir_item_path = os.path.join(root_path, dir_item)
            if not os.path.isfile(dir_item_path):
                continue

            _, ext = os.path.splitext(os.path.basename(dir_item_path))
            if ext != '.yml':
                sys.stderr.write(
                    "Encountered file '%s' while looking for content CPEs, "
                    "extension '%s' is unknown. Skipping...\n"
                    % (dir_item, ext)
                )
                continue

            cpe = CPEItem.from_yaml(dir_item_path, env_yaml)
            self.cpes_by_id[cpe.id_] = cpe
            if cpe.is_product_cpe == "true":
                self.product_cpes[cpe.id_] = cpe

        # Add product_cpes to map of CPEs by ID
        self.cpes_by_id = merge_dicts(self.cpes_by_id, self.product_cpes)

        # Generate a CPE map by name,
        # so that we can easily reference them by CPE Name
        # Note: After the shorthand is generated,
        # all references to CPEs are by its name
        for cpe_id, cpe in self.cpes_by_id.items():
            self.cpes_by_name[cpe.name] = cpe

    def add_cpe_item(self, cpe_item):
        self.cpes_by_id[cpe_item.id_] = cpe_item
        self.cpes_by_name[cpe_item.name] = cpe_item


    def _is_name(self, ref):
        return ref.startswith("cpe:")

    def get_cpe(self, ref):
        # THIS IS UGLY, We'd better parse pkg_resources.Requirement.parse(ref)
        # and get proper base id
        ref = ref.split('[', 1)[0]
        try:
            if self._is_name(ref):
                return self.cpes_by_name[ref]
            else:
                return self.cpes_by_id[ref]
        except KeyError:
            raise CPEDoesNotExist("CPE %s is not defined" % (ref))


    def get_cpe_name(self, cpe_id):
        cpe = self.get_cpe(cpe_id)
        return cpe.name

    def get_product_cpe_names(self):
        return [ cpe.name for cpe in self.product_cpes.values() ]



class CPEList(object):
    """
    Represents the cpe-list element from the CPE standard.
    """

    prefix = "cpe-dict"
    ns = PREFIX_TO_NS[prefix]

    def __init__(self):
        self.cpe_items = []

    def add(self, cpe_item):
        self.cpe_items.append(cpe_item)

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


class CPEItem(XCCDFEntity):
    """
    Represents the cpe-item element from the CPE standard.
    """

    KEYS = dict(
        name=lambda: "",
        title=lambda: "",
        conditional=lambda: {},
        template=lambda: {},
        is_product_cpe=lambda: False,
        args=lambda: {},
        ** XCCDFEntity.KEYS
    )

    MANDATORY_KEYS = [
        "name",
        "title",
    ]

    prefix = "cpe-dict"
    ns = PREFIX_TO_NS[prefix]

    def to_xml_element(self, cpe_oval_filename):
        cpe_item = ET.Element("{%s}cpe-item" % CPEItem.ns)
        cpe_item.set('name', self.name)

        cpe_item_title = ET.SubElement(cpe_item, "{%s}title" % CPEItem.ns)
        cpe_item_title.set('xml:lang', "en-us")
        cpe_item_title.text = self.title

        cpe_item_check = ET.SubElement(cpe_item, "{%s}check" % CPEItem.ns)
        cpe_item_check.set('system', oval_namespace)
        cpe_item_check.set('href', cpe_oval_filename)
        cpe_item_check.text = self.conditional.get('oval_id', self.id_)
        return cpe_item


class CPEALLogicalTest(Function):

    prefix = "cpe-lang"
    ns = PREFIX_TO_NS[prefix]

    def to_xml_element(self):
        cpe_test = ET.Element("{%s}logical-test" % CPEALLogicalTest.ns)
        cpe_test.set('operator', ('OR' if self.is_or() else 'AND'))
        cpe_test.set('negate', ('true' if self.is_not() else 'false'))
        # logical tests must go first, therefore we separate tests and factrefs
        tests = [t for t in self.args if isinstance(t, CPEALLogicalTest)]
        factrefs = [f for f in self.args if isinstance(f, CPEALFactRef)]
        for obj in tests + factrefs:
            cpe_test.append(obj.to_xml_element())

        return cpe_test

    def add_enriched_cpe_items(self, product_cpes):
        for arg in self.args:
            arg.add_enriched_cpe_items(product_cpes)

    def get_bash_conditional(self, product_cpes, conditionals_path, env_yaml):
        contents = ''
        config = defaultdict(lambda: None)
        op = " "
        if self.is_not():
            contents += "! "
        contents += "( "
        child_condlines = []
        for a in self.args:
            r = a.get_bash_conditional(product_cpes, conditionals_path, env_yaml)
            if r is not None:
                cont = r.contents.strip()
                if cont:
                    child_condlines.append(cont)
        if self.is_or():
            op = " || "
        elif self.is_and():
            op = " && "
        contents += op.join(child_condlines)
        contents += " )"
        return namedtuple('remediation', ['contents', 'config'])(contents=contents, config=config)

    def get_ansible_conditional(self, product_cpes, conditionals_path, env_yaml):
        contents = ''
        config = defaultdict(lambda: None)
        op = " "
        if self.is_not():
            contents += "not "
        contents += "( "
        child_ansible_conds = []
        for a in self.args:
            r = a.get_ansible_conditional(product_cpes, conditionals_path, env_yaml)
            if r is not None:
                cont = r.contents.strip()
                if cont:
                    child_ansible_conds.append(cont)
        if self.is_or():
            op = " or "
        elif self.is_and():
            op = " and "
        contents += op.join(child_ansible_conds)
        contents += " )"
        return namedtuple('remediation', ['contents', 'config'])(contents=contents, config=config)


class CPEALFactRef(Symbol):

    prefix = "cpe-lang"
    ns = PREFIX_TO_NS[prefix]

    def __init__(self, obj):
        super(CPEALFactRef, self).__init__(obj)
        self.cpe_name = obj  # we do not want to modify original name used for platforms
        self.conditional = {}

    def add_enriched_cpe_items(self, product_cpes):
        old_cpe_dict = product_cpes.get_cpe(self.cpe_name).represent_as_dict()
        # ignore remediation snippets for now when templating
        # they will be removed eventually from the CPE item definition
        not_templated_keys = ["conditional"]
        new_cpe_dict = apply_formatting_on_dict_values(
            old_cpe_dict, self.as_dict(), not_templated_keys)
        new_cpe_dict["id_"] = self.as_id()
        new_cpe = CPEItem.get_instance_from_full_dict(new_cpe_dict)
        self.cpe_name = product_cpes.get_cpe_name(self.cpe_name)
        product_cpes.add_cpe_item(new_cpe)

    def to_xml_element(self):
        cpe_factref = ET.Element("{%s}fact-ref" % CPEALFactRef.ns)
        cpe_factref.set('name', self.cpe_name.format(**self.as_dict()))

        return cpe_factref

    def get_bash_conditional(self, product_cpes, conditionals_path, env_yaml):
        cpe = product_cpes.get_cpe(self.as_id())
        cond = cpe.conditional.get("bash", "")
        if cond:
            return remediations.parse_from_string_with_jinja(cond, env_yaml)
        elif conditionals_path is not None:
            templated_conditional_file = os.path.join(conditionals_path, 'bash', self.as_id() +
                                                      remediations.REMEDIATION_TO_EXT_MAP['bash'])
            if os.path.exists(templated_conditional_file):
                return remediations.parse_from_file_without_jinja(templated_conditional_file)
        return None

    def get_ansible_conditional(self, product_cpes, conditionals_path, env_yaml):
        cpe = product_cpes.get_cpe(self.as_id())
        cond = cpe.conditional.get("ansible", "")
        if cond:
            return remediations.parse_from_string_with_jinja(cond, env_yaml)
        elif conditionals_path is not None:
            templated_conditional_file = os.path.join(conditionals_path, "ansible", self.as_id() +
                                                      remediations.REMEDIATION_TO_EXT_MAP[
                                                          'ansible'])
            if os.path.exists(templated_conditional_file):
                return remediations.parse_from_file_without_jinja(templated_conditional_file)
        return None



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
        if getattr(obj, "iter", None) is None:
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
    if getattr(tree_with_refs, "iter", None) is None:
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
    if getattr(tree_with_ids, "iter", None) is None:
        tree_with_ids_iterator = tree_with_ids.getiterator()
    else:
        tree_with_ids_iterator = tree_with_ids.iter()
    for element in tree_with_ids_iterator:
        if element.get("id") in reflist:
            elementlist.append(element)

    return elementlist


def apply_formatting_on_dict_values(source_dict, string_dict, not_templated_keys):
    """
    This works only for dictionaries whose values are dicts or strings
    """
    new_dict = {}
    for k, v in source_dict.items():
        if k not in not_templated_keys:
            if isinstance(v, dict):
                new_dict[k] = apply_formatting_on_dict_values(v, string_dict, not_templated_keys)
            elif isinstance(v, str):
                new_dict[k] = v.format(**string_dict)
        else:
            new_dict[k] = v
    return new_dict
