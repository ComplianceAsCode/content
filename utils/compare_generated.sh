#!/bin/bash

if [ "$#" -lt 3 ];
then
	echo "Usage:"
	echo -e "\t$0 <original repo build folder> <updated repo build folder> <fixes/ovals> [meld]"
	echo ""
	echo -e "\tBoth repositories have to be already compiled! (make)"
	echo -e "\tCompare <fix> elements from original DS with fixes in updated DSs"
	echo -e "\t[meld]\tUse meld tool to show differences"
	echo -e "\tThis script assumes that build folders are children of the repo git root."
	exit 1
fi

originalBuild="$1/"
updatedBuild="$2/"
target="$3"
meld="$4"

# Params check
[ "$target" != "ovals" ] && [ "$target" != "fixes" ] && {
	echo "Unknown target '$target'" >&1
	exit 1
}

[ "$meld" == "meld" ] && {
	rpm --quiet -q meld || {
		echo "Please install \"meld\" package" >&2
	}
}

# Get list of entities in pretty & sorted xml
function extractContent() {
	local filename="$1"

	if [ "$target" == "ovals" ];
	then
		xsltproc $(dirname "$0")/../shared/transforms/xccdf-get-only-ovals-sorted.xslt "$filename"
	else
		xsltproc $(dirname "$0")/../shared/transforms/xccdf-get-only-remediations-sorted.xslt "$filename"
	fi | \
		xmllint --c14n11 /dev/stdin | \
		xmllint -format /dev/stdin | \
		sed 's;^\s*#.*$;;g' | \
		sed '/^\s*$/d'
		# remove bash comments from output
		# remove empty lines
}

function compareFile() {
	local originalFile="$1"
	toCompare=$(sed "s;^$originalBuild;$updatedBuild;" <<< "$originalFile")
	echo "-----------------------------------------------------------------"
	echo "$originalFile <=> $toCompare" 
	echo "-----------------------------------------------------------------"

	extractContent "$originalFile" > /tmp/original
	extractContent "$toCompare"    > /tmp/new

	local ret=0
	if [ "$meld" == "meld" ];
	then
		diff /tmp/original /tmp/new -q || {
			meld /tmp/original /tmp/new
		}
		ret=$?
	else
		diff /tmp/original /tmp/new
		ret=$?
	fi
	return $ret
}

#compareFile ./original/Fedora/output/ssg-fedora-ds.xml
#exit

find "$originalBuild" -name "*-ds.xml" | while read originalFile;
do
	compareFile "$originalFile"
	if [ "x$?" != "x0" ]; then
		exit 1
	fi
done
