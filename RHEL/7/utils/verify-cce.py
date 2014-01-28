#!/usr/bin/python

import sys, os
from lxml import etree

# This script checks the validity of assigned CCEs, lists granted and remaining available CCEs, and checks for duplicates.


xccdf_ns = "http://checklists.nist.gov/xccdf/1.1"


tree = etree.parse('../output/unlinked-rhel7-xccdf.xml')

cces_assigned = tree.findall("//{%s}ident[@system='http://cce.mitre.org']" % xccdf_ns)

assigned_ids = []
granted_ids = []

# print the list of assigned CCEs
print "Assigned CCEs:"
for item in cces_assigned:
	print item.text
	assigned_ids.append(item.text)
print "-------------"

# check for duplicates in the assigned CCE list
dup_assigned_ids = [item for item in cces_assigned if cces_assigned.count(item) > 1]
for item in dup_assigned_ids:
	print "Duplicate assignment of CCE: %s" % item

# open the available CCE file
with open('../references/cce-rhel7-avail.txt', 'r') as f:
	for line in f:
		granted_ids = [line.rstrip('\n') for line in f]

# print CCEs that are available (i.e. in granted but not assigned)
	for item in granted_ids:
		if item not in assigned_ids:
			print "Available CCE: %s" % item

for rule in tree.findall("//{%s}Rule" % xccdf_ns):
#	print "rule is " + rule.get("id")
	items = rule.findall("{%s}ident[@system='http://cce.mitre.org']" % xccdf_ns)
	if len(items) > 1:
		print "Rule with multiple CCEs assigned: %s" % rule.get("id")
	if len(items) == 0:
		print "Rule without  CCE: %s" % rule.get("id")
	for item in items:
		if item.text not in granted_ids:
			print "Invalid CCE: %s in %s" % (item.text, rule.get("id"))

sys.exit()

