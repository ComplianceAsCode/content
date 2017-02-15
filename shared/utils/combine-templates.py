#!/usr/bin/python3
import glob
import os
import re

"""
	One-shot script, should be removed
	Run it from root repo directory
"""

# Stop if not in root
if not os.path.isfile("shared/utils/combine-templates.py"):
	exit(1)

products = [
	"./shared",
	"./Chromium",
	"./Fedora",
	"./Firefox",
	"./RHEL/5",
	"./RHEL/6",
	"./RHEL/7",
	"./RHEVM3",
	"./Webmin",
	"./Debian/8",
	"./JBoss/EAP/5",
	"./JBoss/Fuse/6",
	"./OpenStack/RHEL-OSP/7",
	"./OpenSUSE",
	"./SUSE/11",
	"./SUSE/12",
	"./WRLinux",
	"./Ubuntu/14.04",
	"./Ubuntu/16.04",
]

def get_templates_path(product_path):
	masks=[
		os.path.join(product_path,"templates","template_*"),
		os.path.join(product_path,"templates","oval_5.11_templates","template_*")
	]

	for mask in masks:
		for path in glob.glob(mask):
			yield path

def get_lang_of_template(template_path):
	lang="oval"
	if "BASH" in template_path:
		lang="bash"
	elif "ANSIBLE" in template_path:
		lang="ansible"
	elif "ANACONDA" in template_path:
		lang="anaconda"
	elif "PUPPET" in template_path:
		lang="puppet"
	return lang

def oval_version_of_filename(filename):
	if "oval_5.11" in filename:
		return "oval_5.11"
	else:
		return "oval_5.10"

def get_target_for_template(template_path):
	name = re.sub('.*template_(?:(?:PUPPET|BASH|OVAL|ANACONDA|ANSIBLE)_)?(.*)', r'\1', template_path)
	lang = get_lang_of_template(template_path)
	if "sysctl_" in name:
		return os.path.join("shared","templates","sysctl",lang + "_" + name[len("sysctl_"):])
	else:
		return os.path.join("shared","templates",name,lang)



def generate_header(product_path, template_file):
	header  = "#" * 80 + "\n"
	header += "# product: " + product_path[2:] + "\n"
	header += "# oval-version: " + oval_version_of_filename(template_file) + "\n"
	header += "#" * 80 + "\n"
	return header

def move_template(product_path, template_file, target_file):

	# create parent directory for template
	os.makedirs(os.path.dirname(target_file), exist_ok=True)

	# read old template
	with open(template_file, 'r') as content_file:
		previous_content = content_file.read()

	# remove old template
	os.remove(template_file)

	# write data to new location
	with open(target_file,"a") as f:
		f.write(generate_header(product_path, template_file))
		f.write(previous_content)
		f.write("\n\n\n")


for product_path in products:
	for template_path in get_templates_path(product_path):
		template_target = get_target_for_template(template_path)
		print(template_path + " => " + template_target)
		move_template(product_path, template_path, template_target)


