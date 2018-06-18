def extract_subelement(objects, sub_elem_type):
    for obj in objects:
        for subelement in obj.getiterator():
            if subelement.get(sub_elem_type):
                sub_element = subelement.get(sub_elem_type)
                return sub_element


def extract_env_obj(objects, local_var):
    for obj in objects:
        env_id = extract_subelement(local_var, 'object_ref')
        if env_id == obj.get('id'):
            return obj


def extract_referred_nodes(tree_with_refs, tree_with_ids, attrname):
    reflist = []
    elementlist = []
    iter = tree_with_refs.getiterator()
    for element in iter:
        value = element.get(attrname)
        if value is not None:
            reflist.append(value)

    iter = tree_with_ids.getiterator()
    for element in iter:
        if element.get("id") in reflist:
            elementlist.append(element)
    return elementlist
