#!/usr/bin/python

import os
import sys
import shutil
from distutils.util import strtobool
from optparse import OptionParser, OptionGroup

SSGTOPDIR = "../../"

input_list = ['auxiliary', 'intro', 'profiles']
oval_list = ['platform', 'templates', 'oval_5.11']
remediations_list = ['bash', 'bash/templates']
xccdf_list = ['services', 'system', 'system/accounts', 'system/accounts/restrictions',
             'xccdf/system/network', 'system/permissions', 'system/software']


input_dir = {'input': input_list, 'input/oval': oval_list, 'input/remediations': remediations_list, 'input/xccdf': xccdf_list}
other_dirs = ['output', 'transforms', 'utils', 'dist']
additional_dirs = ['tests', 'kickstart']

python_templates = {}
xslt_templates = {}
xml_templates = {}
makefile_templates = {}

def create_directies(versions, product, aux_dirs):
    product_list = []

    for version in versions:
        new_product = SSGTOPDIR + product + '/' + str(version)
        for key, value in input_dir.iteritems():
            for dirs in value:
                product_list.append(new_product + '/' + key + '/' + dirs)

        for other in other_dirs:
            product_list.append(new_product + '/' + other)

        for aux in aux_dirs:
            product_list.append(new_product + '/' + aux)

    print("\nCreating new directory structure for product '%s'" % product)
    for listing in product_list:
        if not os.path.exists(listing):
            print("    Creating %s" % listing)
            os.makedirs(listing, 0755)


def copy_templates():
    pass


def update_templates(options):
    pass


def create_product(options):
    aux_remove = []

    if not options.product:
        product = raw_input("Enter the name of the product to add (e.g. Debian, RHEL, Openstack, etc.): ")
    else:
        product = options.product

    if not options.product_versions:
        versions = raw_input("Enter the product version(s) that will be targeted.\n"
                             "Use commas to separate if multiple versions (e.g. 6,7,8): ")
        versions = versions.split(",")
    else:
        versions = options.product_versions

    if not options.aux:
        for aux in additional_dirs:
            create = strtobool(raw_input("Do you want to create the '%s' directory? (Y/N): " % aux).lower())
            if not create:
                aux_remove.append(aux)
        aux_dirs = [n for n in additional_dirs if n not in aux_remove]
    else:
        aux_dirs = additional_dirs
    
    create_directies(versions, product, aux_dirs)


def remove_product(options):
    versions = 0

    if not options.product:
        product = raw_input("Enter the name of the product to remove (e.g. Debian, RHEL, Openstack, etc.): ")
    else:
        product = options.product

    if options.product_versions:
        versions = options.product_versions

    if not versions or len(versions) < 2:
        product_path = SSGTOPDIR + product
        if not os.path.exists(product_path):
            sys.exit("\nThe '%s' product tree does not exist! Exiting..." % product)
        else:
            print("\nRemoving '%s' from the SSG development tree" % product)
            shutil.rmtree(product_path)
    else:
        print('')
        for version in versions:
            
            product_path = SSGTOPDIR + product + "/" + str(version)
            if not os.path.exists(product_path):
                print("The '%s' product version '%s' does not exist! Skipping..." % (product, str(version)))
            else:
                remove = strtobool(raw_input("\nThis operation is IRREVERSIBLE! Are you sure you want to continue? (Y/N): ").lower())
                if not remove:
                    sys.exit(1)
                else:
                    print("Removing '%s' version %s from the SSG development tree" % (product, str(version)))
                    shutil.rmtree(product_path)
    print('')


def parse_options():
    usage = "usage: %prog [OPTIONS]"
    parser = OptionParser(usage=usage)
    parser.add_option("-p", "--product", default=False,
                      action="store", dest="product",
                      help="name of new SSG product")
    parser.add_option("-v", "--product-version", default=[], metavar="product_version",
                      action="append", dest="product_versions", type="int",
                      help="version of new SSG product")
    
    create_group = OptionGroup(parser, "Create SSG Product")
    create_group.add_option("-c", "--create", default=False,
                      action="store_true", dest="create",
                      help="create new product in SSG development tree")
    create_group.add_option("-o", "--optional", dest="aux", action="store_true",
                      help="create 'tests' and 'kickstart' directories")
    parser.add_option_group(create_group)

    update_group = OptionGroup(parser, "Update SSG Product(s)")
    update_group.add_option("-u", "--update", default=False,
                      action="store_true", dest="update",
                      help="update product templates from [shared/templates]")
    update_group.add_option("-a", "--update-all", dest="update_all", action="store_true",
                      help="update all product templates from [shared/templates]")
    parser.add_option_group(update_group)

    remove_group = OptionGroup(parser, "Remove SSG Product")
    remove_group.add_option("-d", "--delete", default=False,
                      action="store_true", dest="remove",
                      help="remove product from the SSG development tree")
    parser.add_option_group(remove_group)

    (options, args) = parser.parse_args()

    if options.create and options.update:
        print("Cannot create a new product and update at the same time!\n")
        sys.exit(parser.print_help())
  
    if options.create and options.remove:
        print("Cannot create a new product and delete at the same time!\n")
        sys.exit(parser.print_help())

    if options.remove and options.update:
        print("Cannot update a product and delete at the same time!\n")
        sys.exit(parser.print_help())

    if options.create:
        create_product(options)
        print("\nComplete!\n")
    if options.remove:
        remove_product(options)
    if options.update:
        update_templates(options)

    if len(sys.argv) < 2:
        sys.exit(parser.print_help())

    return (options, args)

def main():
    (options, args) = parse_options()


if __name__ == "__main__":
    main()

