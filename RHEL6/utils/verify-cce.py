#!/usr/bin/python

import sys, os
from lxml import etree

# This script checks the validity of assigned CCEs, lists granted and remaining available CCEs, and checks for duplicates.


xccdf_ns = "http://checklists.nist.gov/xccdf/1.1"


tree = etree.parse('../output/unlinked-rhel6-xccdf.xml')

cces_assigned = tree.findall("//{%s}ident[@system='http://cce.mitre.org']" % xccdf_ns)

assigned_ids = []
granted_ids = []

# print the list of assigned CCEs
print "Assigned CCEs:"
for item in cces_assigned:
    print item.text
    assigned_ids.append(item.text)
print "-------------"

# open the available CCE file
with open('../references/cce-rhel6-avail.txt', 'r') as f:
   for line in f:
       granted_ids = [line.rstrip('\n') for line in f]
#       print granted_ids

# print CCEs that appear in content but are not valid
   for item in assigned_ids:
       if item not in granted_ids:
           print "Invalid CCE: %s" % item

# print CCEs that are available (i.e. in granted but not assigned)
   for item in granted_ids:
       if item not in assigned_ids:
           print "Available CCE: %s" % item

# check for duplicates in the assigned CCE list                
if len(set(assigned_ids)) != len(assigned_ids):
	print "duplicate"

sys.exit()

