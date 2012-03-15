IN=input
OUT=output
TRANS=transforms
REFS=references

all: shorthand-guide shorthand2xccdf table-profilenistrefs table-refs guide checks content

shorthand-guide:
	xsltproc -o ${OUT}/rhel6-shorthand.xml ${IN}/guide.xslt ${IN}/guide.xml
	xmllint --format --output ${OUT}/rhel6-shorthand.xml ${OUT}/rhel6-shorthand.xml 

shorthand2xccdf:
	xsltproc -o ${OUT}/rhel6-xccdf-noprofiles.xml ${TRANS}/shorthand2xccdf.xslt ${OUT}/rhel6-shorthand.xml
	xsltproc -stringparam profile "allprofiles" -o ${OUT}/rhel6-xccdf.xml ${TRANS}/xccdf-addprofiles.xslt ${OUT}/rhel6-xccdf-noprofiles.xml
	xmllint --format --output ${OUT}/rhel6-xccdf.xml ${OUT}/rhel6-xccdf.xml 

checks:
	xmlwf ${IN}/checks/*.xml
	${TRANS}/combinechecks.py ${IN}/checks > ${OUT}/rhel6-oval.xml
	xmllint --format --output ${OUT}/rhel6-oval.xml ${OUT}/rhel6-oval.xml 
#       SCC might return someday


guide: shorthand-guide shorthand2xccdf 
	oscap xccdf generate guide --profile allrules ${OUT}/rhel6-xccdf.xml > ${OUT}/rhel6-guide.html
#       specifying a nonexistent profile, "allrules," to make oscap print all Rules

# example, if needed: for converting XCCDF into shorthand
#xccdf2shorthand:
#	xsltproc -o ${OUT}/rhel5-shorthand.xml ${TRANS}/xccdf2shorthand.xslt ${REFS}/usgcb-rhel5desktop-xccdf.xml
#	tidy -m -xml -utf8 --indent-spaces=0 ${OUT}/rhel5-shorthand.xml

table-profilenistrefs: shorthand-guide shorthand2xccdf
#	xsltproc -o ${OUT}/rhel6-table-nistrefs.html ${TRANS}/xccdf2table-nistrefs.xslt ${OUT}/rhel6-xccdf.xml
	xsltproc -stringparam profile "desktop" -o ${OUT}/rhel6-table-nistrefs-desktop.html ${TRANS}/xccdf2table-profilenistrefs.xslt ${OUT}/rhel6-xccdf.xml
	xsltproc -stringparam profile "server" -o ${OUT}/rhel6-table-nistrefs-server.html ${TRANS}/xccdf2table-profilenistrefs.xslt ${OUT}/rhel6-xccdf.xml
	xsltproc -stringparam profile "common" -o ${OUT}/rhel6-table-nistrefs-common.html ${TRANS}/xccdf2table-profilenistrefs.xslt ${OUT}/rhel6-xccdf.xml
	xsltproc -stringparam profile "ftp" -o ${OUT}/rhel6-table-nistrefs-ftp.html ${TRANS}/xccdf2table-profilenistrefs.xslt ${OUT}/rhel6-xccdf.xml

table-refs: shorthand-guide shorthand2xccdf
	xsltproc -stringparam ref "nist" -o ${OUT}/rhel6-table-nistrefs.html ${TRANS}/xccdf2table-byref.xslt ${OUT}/rhel6-xccdf.xml
	xsltproc -stringparam ref "cnss" -o ${OUT}/rhel6-table-cnssrefs.html ${TRANS}/xccdf2table-byref.xslt ${OUT}/rhel6-xccdf.xml
	xsltproc -stringparam ref "dcid" -o ${OUT}/rhel6-table-dcidrefs.html ${TRANS}/xccdf2table-byref.xslt ${OUT}/rhel6-xccdf.xml
# break apart references by delimiter:
	xsltproc -stringparam ref "nist" -stringparam delim "," -o ${OUT}/rhel6-table-nistrefs-delim.html ${TRANS}/xccdf2table-byref.xslt ${OUT}/rhel6-xccdf.xml
# then sort them:
	xsltproc --html -o ${OUT}/rhel6-table-nistrefs-delim-sorted.html ${TRANS}/table-sortbyref.xslt ${OUT}/rhel6-table-nistrefs-delim.html

content: shorthand-guide shorthand2xccdf checks
	${TRANS}/relabelids.py rhel6-xccdf.xml scap-security-guide 
# 	the script chdirs to ./output, so refer to files from there.
# 	this creates rhel6-xccdf-scap-security-guide.xml and rhel6-oval-scap-security-guide.xml

validate: 
	oscap xccdf validate-xml ${OUT}/rhel6-xccdf-scap-security-guide.xml
	oscap oval validate-xml ${OUT}/rhel6-oval-scap-security-guide.xml

eval-test:
	oscap xccdf eval --profile test output/rhel6-xccdf-scap-security-guide.xml

eval-ftp:
	oscap xccdf eval --profile ftp output/rhel6-xccdf-scap-security-guide.xml

eval-common:
	oscap xccdf eval --profile common --results /tmp/results-test.xml output/rhel6-xccdf-scap-security-guide.xml

clean:
	rm -f ${OUT}/*.xml ${OUT}/*.html ${OUT}/*.pdf
