#!/bin/bash
if [ "$#" -lt 2 ];
then
	echo "Usage:"
	echo -e "\t$0 <original repo> <updated repo> <fixes/oval> [meld]"
	echo ""
	echo -e "\tBoth repositories have to be already compiled! (make)"
	echo -e "\tCompare <fix> elements from original DS with fixes in updated DSs"
	echo -e "\t[meld]\tUse meld tool to show differences"
	exit 1
fi

originalRepo="$1/"
updatedRepo="$2/"
target="$3"
meld="$4"

# Params check
[ "$target" != "oval" ] && [ "$target" != "remediations" ] && {
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

	if [ "$target" == "oval" ];
	then
		xsltproc $(dirname "$0")/../transforms/xccdf-get-only-ovals-sorted.xslt "$filename"
	else
		xsltproc $(dirname "$0")/../transforms/xccdf-get-only-remediations-sorted.xslt "$filename"
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
	toCompare=$(sed "s;^$originalRepo;$updatedRepo;" <<< "$originalFile")
	echo "-----------------------------------------------------------------"
	echo "$originalFile <=> $toCompare" 
	echo "-----------------------------------------------------------------"

	extractContent "$originalFile" > /tmp/original
	extractContent "$toCompare"    > /tmp/new

	if [ "$meld" == "meld" ];
	then
		diff /tmp/original /tmp/new -q || {
			meld /tmp/original /tmp/new
		}
	else
		diff /tmp/original /tmp/new
	fi
}

#compareFile ./original/Fedora/output/ssg-fedora-ds.xml
#exit

find "$originalRepo/build" -name "*-ds.xml" | while read originalFile;
do
	compareFile "$originalFile"
done

