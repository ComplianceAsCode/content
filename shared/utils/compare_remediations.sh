#!/bin/bash
if [ "$#" -lt 2 ];
then
	echo "Usage:"
	echo -e "\t$0 <original repo> <updated repo> [meld]"
	echo ""
	echo -e "\tBoth repositories have to be already compiled! (make)"
	echo -e "\tCompare <fix> elements from original DS with fixes in updated DSs"
	exit 1
fi

originalRepo="$1/"
updatedRepo="$2/"
meld="$3"

# Get list of remediations in pretty & sorted xml
function extractRemediations() {
	xsltproc $(dirname "$0")/getRemediations.xsl "$1"  | tee /tmp/res.xml | \
	    xmllint --c14n11 /dev/stdin | \
    	xmllint -format /dev/stdin | \
    	sed 's;^\s*#.*$;;g' | \
    	sed '/^\s*$/d'
	# remove comments
	# empty lines
}

function compareFile() {
	local originalFile="$1"
	toCompare=$(echo "$originalFile" | sed -E "s;^$originalRepo;$updatedRepo;")
	echo "-----------------------------------------------------------------"
	echo "$originalFile <=> $toCompare" 
	echo "-----------------------------------------------------------------"
	
	extractRemediations "$originalFile" > /tmp/original
	extractRemediations "$toCompare"	> /tmp/new
	
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

find "$originalRepo" -name "*-ds.xml" | grep output | while read originalFile;
do
	compareFile "$originalFile"
done

