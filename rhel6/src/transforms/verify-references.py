#!/usr/bin/python

import sys, os, optparse
import lxml.etree as ET

#
# This script can verify consistency of references (linkage) between XCCDF and
# OVAL, and also search based on other criteria such as existence of policy
# references in XCCDF.
#

xccdf_ns = "http://checklists.nist.gov/xccdf/1.1" 
oval_ns = "http://oval.mitre.org/XMLSchema/oval-definitions-5"

# we use this string to look for NIST references within the XCCDF rules
nist_ref_href = "http://csrc.nist.gov/publications/nistpubs/800-53-Rev3/sp800-53-rev3-final.pdf"

def parse_options():
	usage = "usage: %prog [options] xccdf_file"
	parser = optparse.OptionParser(usage=usage, version="%prog ")
	# only some options are on by default
	parser.add_option("--rules-with-invalid-checks", default=False, action="store_true", dest="rules_with_invalid_checks",
					  help="print XCCDF Rules that reference an invalid/nonexistent check")
	parser.add_option("--rules-without-checks", default=False, action="store_true", dest="rules_without_checks",
					  help="print XCCDF Rules that do not include a check")
	parser.add_option("--rules-without-severity", default=False, action="store_true", dest="rules_without_severity",
					  help="print XCCDF Rules that do not include a severity")
	parser.add_option("--rules-without-nistrefs", default=False, action="store_true", dest="rules_without_nistrefs",
					  help="print XCCDF Rules which do not include any NIST 800-53 references")
	parser.add_option("--ovaldefs-unused", default=False, action="store_true", dest="ovaldefs_unused",
					  help="print OVAL definitions which are not used by any XCCDF Rule")
	parser.add_option("--all-checks", default=False, action="store_true", dest="all_checks",
					  help="perform all checks on the given XCCDF file")
	(options, args) = parser.parse_args()
	if len(args) < 1:
		parser.print_help()
		sys.exit(1)
	return (options, args)

def get_ovalfiles(checks):
	# iterate over all checks, grab the OVAL files referenced within
	ovalfiles = set()
	for check in checks:
		if check.get("system") == oval_ns:
			checkcontentref = check.find("./{%s}check-content-ref" % xccdf_ns)
			ovalfiles.add(checkcontentref.get("href"))
		else:
			print "Non-OVAL checking system found: " + check.get("system")
	return ovalfiles


def main():
	(options, args) = parse_options()
	xccdffilename = args[0]

	# extract all of the rules within the xccdf
	xccdftree = ET.parse(xccdffilename)
	rules = xccdftree.findall(".//{%s}Rule" % xccdf_ns)
		
	# step over xccdf file, and find referenced oval files
	checks = xccdftree.findall(".//{%s}check" % xccdf_ns)
	ovalfiles = get_ovalfiles(checks)

	# this script only supports the inclusion of one OVAL file
	if len(ovalfiles) > 1:
		sys.exit("Referencing more than one OVAL file is not yet supported by this script.")

	# find important elements within the XCCDF and the OVAL
	ovalfile = ovalfiles.pop()
	ovaltree = ET.parse(ovalfile) 
	ovaldefs = ovaltree.findall(".//{%s}definition" % oval_ns)
	ovaldef_ids = [ovaldef.get("id") for ovaldef in ovaldefs] 
	check_content_refs = xccdftree.findall(".//{%s}check-content-ref" % xccdf_ns)

	# now we can actually do the verification work here
	if options.rules_with_invalid_checks or options.all_checks:
		for check_content_ref in check_content_refs:
			refname = check_content_ref.get("name")
			if refname not in ovaldef_ids:
				rule = check_content_ref.getparent().getparent() 
				print "Invalid OVAL definition referenced by XCCDF Rule: " + rule.get("id")

	if options.rules_without_checks or options.all_checks:
		for rule in rules:
			check = rule.find("./{%s}check" % xccdf_ns) 
			if check is None:
				print "No reference to OVAL definition in XCCDF Rule: " + rule.get("id")

	if options.rules_without_severity or options.all_checks:
		for rule in rules:
			if rule.get("severity") is None:
				print "No severity assigned to XCCDF Rule: " + rule.get("id")

	if options.rules_without_nistrefs or options.all_checks:
		for rule in rules:
			# find all references in the current rule
			refs = rule.findall(".//{%s}reference" % xccdf_ns)
			if refs is None:
				print "No reference assigned to XCCDF Rule: " + rule.get("id")
			else:
				# loop through the references and make sure at least one of them is a NIST reference
				ref_href_list = [ref.get("href") for ref in refs]
				# print warning if rules does not have a NIST reference
				if (not nist_ref_href in ref_href_list):
					print "No valid NIST reference in XCCDF Rule: " + rule.get("id")

	if options.ovaldefs_unused or options.all_checks:
		# create a list of all of the OVAL checks that are defined in the oval file
		oval_checks_list = [ovaldef.get("id") for ovaldef in ovaldefs]
		# now loop through the xccdf rules; if a rule references an oval check we remove the oval check from our list
		for check_content in check_content_refs:
			# remove from the list
			if (check_content.get("name") in oval_checks_list):
				oval_checks_list.remove(check_content.get("name"))
		# the list should now contain the OVAL checks that are not referenced by any XCCDF rule
		oval_checks_list.sort()
		for oval_id in oval_checks_list:
			print "XCCDF does not reference OVAL Check: %s" % oval_id

	sys.exit(0)

if __name__ == "__main__":
	main()

