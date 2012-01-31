INDIR=input
OUTDIR=output
TRANSDIR=transforms
REFS=references

all: shorthand-guide shorthand2xccdf table-profilenistrefs table-refs guide checks content

shorthand-guide:
	xsltproc -o ${OUTDIR}/rhel6-shorthand.xml ${INDIR}/guide.xslt ${INDIR}/guide.xml
	xmllint --format --output ${OUTDIR}/rhel6-shorthand.xml ${OUTDIR}/rhel6-shorthand.xml 

shorthand2xccdf:
	xsltproc -o ${OUTDIR}/rhel6-xccdf-noprofiles.xml ${TRANSDIR}/shorthand2xccdf.xslt ${OUTDIR}/rhel6-shorthand.xml
	xsltproc -stringparam profile "allprofiles" -o ${OUTDIR}/rhel6-xccdf.xml ${TRANSDIR}/xccdf-addprofiles.xslt ${OUTDIR}/rhel6-xccdf-noprofiles.xml
	xmllint --format --output ${OUTDIR}/rhel6-xccdf.xml ${OUTDIR}/rhel6-xccdf.xml 

checks:
	xmlwf ${INDIR}/checks/*.xml
	${TRANSDIR}/combinechecks.py ${INDIR}/checks > ${OUTDIR}/rhel6-oval.xml
	xmllint --format --output ${OUTDIR}/rhel6-oval.xml ${OUTDIR}/rhel6-oval.xml 
#       SCC might return someday


guide: shorthand-guide shorthand2xccdf 
	oscap xccdf generate guide --profile allrules ${OUTDIR}/rhel6-xccdf.xml > ${OUTDIR}/rhel6-guide.html
#       specifying a nonexistent profile, "allrules," to make oscap print all Rules

# example, if needed: for converting XCCDF into shorthand
#xccdf2shorthand:
#	xsltproc -o ${OUTDIR}/rhel5-shorthand.xml ${TRANSDIR}/xccdf2shorthand.xslt ${REFS}/usgcb-rhel5desktop-xccdf.xml
#	tidy -m -xml -utf8 --indent-spaces=0 ${OUTDIR}/rhel5-shorthand.xml

table-profilenistrefs: shorthand-guide shorthand2xccdf
#	xsltproc -o ${OUTDIR}/rhel6-table-nistrefs.html ${TRANSDIR}/xccdf2table-nistrefs.xslt ${OUTDIR}/rhel6-xccdf.xml
	xsltproc -stringparam profile "desktop" -o ${OUTDIR}/rhel6-table-nistrefs-desktop.html ${TRANSDIR}/xccdf2table-profilenistrefs.xslt ${OUTDIR}/rhel6-xccdf.xml
	xsltproc -stringparam profile "server" -o ${OUTDIR}/rhel6-table-nistrefs-server.html ${TRANSDIR}/xccdf2table-profilenistrefs.xslt ${OUTDIR}/rhel6-xccdf.xml
	xsltproc -stringparam profile "common" -o ${OUTDIR}/rhel6-table-nistrefs-common.html ${TRANSDIR}/xccdf2table-profilenistrefs.xslt ${OUTDIR}/rhel6-xccdf.xml

table-refs: shorthand-guide shorthand2xccdf
	xsltproc -stringparam ref "nist" -o ${OUTDIR}/rhel6-table-nistrefs.html ${TRANSDIR}/xccdf2table-byref.xslt ${OUTDIR}/rhel6-xccdf.xml
	xsltproc -stringparam ref "cnss" -o ${OUTDIR}/rhel6-table-cnssrefs.html ${TRANSDIR}/xccdf2table-byref.xslt ${OUTDIR}/rhel6-xccdf.xml
	xsltproc -stringparam ref "dcid" -o ${OUTDIR}/rhel6-table-dcidrefs.html ${TRANSDIR}/xccdf2table-byref.xslt ${OUTDIR}/rhel6-xccdf.xml

content: shorthand-guide shorthand2xccdf checks
	${TRANSDIR}/relabelids.py rhel6-xccdf.xml scap-security-guide 
# 	the script chdirs to ./output, so refer to files from there.
# 	this creates rhel6-xccdf-scap-security-guide.xml and rhel6-oval-scap-security-guide.xml

validate: 
	oscap xccdf validate-xml ${OUTDIR}/rhel6-xccdf-scap-security-guide.xml
	oscap oval validate-xml ${OUTDIR}/rhel6-oval-scap-security-guide.xml

eval-test:
	oscap xccdf eval --profile test output/rhel6-xccdf-scap-security-guide.xml

eval-common:
	oscap xccdf eval --profile common --results /tmp/results-test.xml output/rhel6-xccdf-scap-security-guide.xml

clean:
	rm -f ${OUTDIR}/*.xml ${OUTDIR}/*.html ${OUTDIR}/*.pdf
