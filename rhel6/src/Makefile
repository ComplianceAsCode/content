IN=input
OUT=output
TRANS=transforms
REFS=references
XCCDF_OUTPUT_DIR=${OUT}/XCCDF
XCCDF_OUTPUT_SHORT=XCCDF

## NOTE: The location of the OVAL file is also coded into the
## shorthand2xccdf.xslt file. If you change the OVAL_OUTPUT_DIR,
## make sure you also change the "ovalfile" variable in 
## transforms/shorthand2xccdf.xslt.
OVAL_OUTPUT_DIR=${OUT}/OVAL
HTML_OUTPUT_DIR=${OUT}/HTML
POLICYMAPPING_OUTPUT_DIR=${OUT}/PolicyMappings

all: shorthand-guide shorthand2xccdf table-profilenistrefs table-refs guide checks content

shorthand-guide:
	xsltproc -o ${XCCDF_OUTPUT_DIR}/rhel6-shorthand.xml ${IN}/guide.xslt ${IN}/guide.xml
	xmllint --format --output ${XCCDF_OUTPUT_DIR}/rhel6-shorthand.xml ${XCCDF_OUTPUT_DIR}/rhel6-shorthand.xml 

shorthand2xccdf:
	xsltproc -o ${XCCDF_OUTPUT_DIR}/rhel6-xccdf-noprofiles.xml ${TRANS}/shorthand2xccdf.xslt ${XCCDF_OUTPUT_DIR}/rhel6-shorthand.xml
	xsltproc -stringparam profile "allprofiles" -o ${XCCDF_OUTPUT_DIR}/rhel6-xccdf.xml ${TRANS}/xccdf-addprofiles.xslt ${XCCDF_OUTPUT_DIR}/rhel6-xccdf-noprofiles.xml
	xmllint --format --output ${XCCDF_OUTPUT_DIR}/rhel6-xccdf.xml ${XCCDF_OUTPUT_DIR}/rhel6-xccdf.xml 

checks:
	mkdir ${OVAL_OUTPUT_DIR}
	xmlwf ${IN}/checks/*.xml
	${TRANS}/combinechecks.py ${IN}/checks > ${OVAL_OUTPUT_DIR}/rhel6-oval.xml
	xmllint --format --output ${OVAL_OUTPUT_DIR}/rhel6-oval.xml ${OVAL_OUTPUT_DIR}/rhel6-oval.xml 
#       SCC might return someday


guide: shorthand-guide shorthand2xccdf 
	mkdir ${HTML_OUTPUT_DIR}
	oscap xccdf generate guide --profile allrules ${XCCDF_OUTPUT_DIR}/rhel6-xccdf.xml > ${HTML_OUTPUT_DIR}/rhel6-guide.html
#       specifying a nonexistent profile, "allrules," to make oscap print all Rules

# example, if needed: for converting XCCDF into shorthand
#xccdf2shorthand:
#	xsltproc -o ${XCCDF_OUTPUT_DIR}/rhel5-shorthand.xml ${TRANS}/xccdf2shorthand.xslt ${REFS}/usgcb-rhel5desktop-xccdf.xml
#	tidy -m -xml -utf8 --indent-spaces=0 ${XCCDF_OUTPUT_DIR}/rhel5-shorthand.xml

table-profilenistrefs: shorthand-guide shorthand2xccdf
#	xsltproc -o ${POLICYMAPPING_OUTPUT_DIR}/rhel6-table-nistrefs.html ${TRANS}/xccdf2table-nistrefs.xslt ${XCCDF_OUTPUT_DIR}/rhel6-xccdf.xml
	xsltproc -stringparam profile "desktop" -o ${POLICYMAPPING_OUTPUT_DIR}/rhel6-table-nistrefs-desktop.html ${TRANS}/xccdf2table-profilenistrefs.xslt ${XCCDF_OUTPUT_DIR}/rhel6-xccdf.xml
	xsltproc -stringparam profile "server" -o ${POLICYMAPPING_OUTPUT_DIR}/rhel6-table-nistrefs-server.html ${TRANS}/xccdf2table-profilenistrefs.xslt ${XCCDF_OUTPUT_DIR}/rhel6-xccdf.xml
	xsltproc -stringparam profile "common" -o ${POLICYMAPPING_OUTPUT_DIR}/rhel6-table-nistrefs-common.html ${TRANS}/xccdf2table-profilenistrefs.xslt ${XCCDF_OUTPUT_DIR}/rhel6-xccdf.xml
	xsltproc -stringparam profile "ftp" -o ${POLICYMAPPING_OUTPUT_DIR}/rhel6-table-nistrefs-ftp.html ${TRANS}/xccdf2table-profilenistrefs.xslt ${XCCDF_OUTPUT_DIR}/rhel6-xccdf.xml

table-refs: shorthand-guide shorthand2xccdf
	xsltproc -stringparam ref "nist" -o ${POLICYMAPPING_OUTPUT_DIR}/rhel6-table-nistrefs.html ${TRANS}/xccdf2table-byref.xslt ${XCCDF_OUTPUT_DIR}/rhel6-xccdf.xml
	xsltproc -stringparam ref "cnss" -o ${POLICYMAPPING_OUTPUT_DIR}/rhel6-table-cnssrefs.html ${TRANS}/xccdf2table-byref.xslt ${XCCDF_OUTPUT_DIR}/rhel6-xccdf.xml
	xsltproc -stringparam ref "dcid" -o ${POLICYMAPPING_OUTPUT_DIR}/rhel6-table-dcidrefs.html ${TRANS}/xccdf2table-byref.xslt ${XCCDF_OUTPUT_DIR}/rhel6-xccdf.xml
# break apart references by delimiter:
	xsltproc -stringparam ref "nist" -stringparam delim "," -o ${POLICYMAPPING_OUTPUT_DIR}/rhel6-table-nistrefs-delim.html ${TRANS}/xccdf2table-byref.xslt ${XCCDF_OUTPUT_DIR}/rhel6-xccdf.xml
# then sort them:
	xsltproc --html -o ${POLICYMAPPING_OUTPUT_DIR}/rhel6-table-nistrefs-delim-sorted.html ${TRANS}/table-sortbyref.xslt ${POLICYMAPPING_OUTPUT_DIR}/rhel6-table-nistrefs-delim.html

content: shorthand-guide shorthand2xccdf checks
	${TRANS}/relabelids.py ${XCCDF_OUTPUT_SHORT}/rhel6-xccdf.xml scap-security-guide 
# 	the script chdirs to ./output, so refer to files from there.
# 	this creates rhel6-xccdf-scap-security-guide.xml and rhel6-oval-scap-security-guide.xml
	rm ${OUT}/*.ini

validate: 
	oscap xccdf validate-xml ${XCCDF_OUTPUT_DIR}/rhel6-xccdf-scap-security-guide.xml
	oscap oval validate-xml ${XCCDF_OUTPUT_DIR}/rhel6-oval-scap-security-guide.xml

eval-test:
	oscap xccdf eval --profile test ${XCCDF_OUTPUT_DIR}/rhel6-xccdf-scap-security-guide.xml

eval-ftp:
	oscap xccdf eval --profile ftp ${XCCDF_OUTPUT_DIR}/rhel6-xccdf-scap-security-guide.xml

eval-common:
	oscap xccdf eval --profile common --results /tmp/results-test.xml ${XCCDF_OUTPUT_DIR}/rhel6-xccdf-scap-security-guide.xml

clean:
#	rm -f ${OUT}/*.xml ${OUT}/*.html ${OUT}/*.pdf
	rm -rf ${OUT}/
