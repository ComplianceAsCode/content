import sys
import os.path

from ssg._xml import ElementTree as ET


def load_xml(file_name):
    ''' Loads XML files to memory and parses it into element tree '''
    try:
        it = ET.iterparse(file_name)
        for _, el in it:
            if '}' in el.tag:
                el.tag = el.tag.split('}', 1)[1]  # strip all namespaces
        root = it.root
        return root
    except Exception as e:
        print(e)
        sys.stderr.write("Error while loading file " + file_name + ".\n")
        exit(-1)


def find_oval_objects(oval_refs, oval_files, xccdf_dir):
    ''' Finds OVAL objects according to definitions ID '''
    tests = []
    object_refs = []
    objects = []

    # find tests in definitions
    for def_id, oval_file in oval_refs:
        if oval_file not in oval_files:
            oval_file_path = os.path.join(xccdf_dir, oval_file)
            oval_files[oval_file] = load_xml(oval_file_path)
        oval_root = oval_files[oval_file]
        definition = None
        for d in oval_root.findall(".//definition"):
            if d.attrib.get('id') == def_id:
                definition = d
                break
        if definition is not None:
            for criterion in definition.findall(".//criterion"):
                test_ref = criterion.attrib["test_ref"]
                tests.append(test_ref)

    # find references to objects in tests
    for test in tests:
        test_element = None
        for t in oval_root.findall("tests/*"):
            if t.attrib.get('id') == test:
                test_element = t
                break
        if test_element is not None:
            for object_element in test_element.findall(".//*"):
                if 'object_ref' in object_element.attrib:
                    object_ref = object_element.attrib['object_ref']
                    object_refs.append(object_ref)

    # find objects
    for r in object_refs:
        for obj in oval_root.findall("objects/*"):
            if obj.attrib.get('id') == r:
                objects.append(obj.tag)
                break

    return set(objects)


def print_stats(stats):
    ''' Print statistic of most used objects in input'''
    print("")
    print("Count of used OVAL objects:")
    print("=" * 50)
    stats = stats.items()
    for key, value in reversed(sorted(stats, key=lambda obj: obj[1])):
        print(key.ljust(40) + str(value).rjust(10))
