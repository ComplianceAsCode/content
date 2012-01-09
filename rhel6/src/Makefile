INDIR=input
OUTDIR=output
TRANSDIR=transforms
REFS=references

all: shorthand-guide shorthand2xccdf table-nistrefs guide checks content

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
#       SCC WILL RETURN, when it is ready
#       scc -i ${INDIR}/checks/id.ini ${INDIR}/checks/*.sc -o ${OUTDIR}/rhel6-scc-oval.xml


guide: shorthand-guide shorthand2xccdf 
	oscap xccdf generate guide --profile allrules ${OUTDIR}/rhel6-xccdf.xml > ${OUTDIR}/rhel6-guide.html
#       specifying a nonexistent profile, "allrules," to make oscap print all Rules

# this is only here as an example
#xccdf2shorthand:
#	xsltproc -o ${OUTDIR}/rhel5-shorthand.xml ${TRANSDIR}/xccdf2shorthand.xslt ${REFS}/usgcb-rhel5desktop-xccdf.xml
#	tidy -m -xml -utf8 --indent-spaces=0 ${OUTDIR}/rhel5-shorthand.xml

table-nistrefs: shorthand-guide shorthand2xccdf
#	xsltproc -o ${OUTDIR}/rhel6-table-nistrefs.html ${TRANSDIR}/xccdf2table-nistrefs.xslt ${OUTDIR}/rhel6-xccdf.xml
	xsltproc -stringparam profile "desktop_baseline" -o ${OUTDIR}/rhel6-table-nistrefs-desktop.html ${TRANSDIR}/xccdf2table-nistrefs.xslt ${OUTDIR}/rhel6-xccdf.xml
	xsltproc -stringparam profile "server_baseline" -o ${OUTDIR}/rhel6-table-nistrefs-server.html ${TRANSDIR}/xccdf2table-nistrefs.xslt ${OUTDIR}/rhel6-xccdf.xml
	xsltproc -stringparam profile "common" -o ${OUTDIR}/rhel6-table-nistrefs-common.html ${TRANSDIR}/xccdf2table-nistrefs.xslt ${OUTDIR}/rhel6-xccdf.xml

content: shorthand-guide shorthand2xccdf checks
	${TRANSDIR}/relabelids.py rhel6-xccdf.xml scap-security-guide 
# 	the script chdirs to ./output, so refer to files from there.
# 	this creates rhel6-xccdf-scap-security-guide.xml and rhel6-oval-scap-security-guide.xml

validate: 
	xsltproc -o ${OUTDIR}/rhel6-xccdf-valid.xml ${TRANSDIR}/xccdf2oscapvalid.xslt ${OUTDIR}/rhel6-xccdf-scap-security-guide.xml
	oscap xccdf validate-xml ${OUTDIR}/rhel6-xccdf-valid.xml
	oscap oval validate-xml ${OUTDIR}/rhel6-oval-scap-security-guide.xml

eval-test:
	oscap xccdf eval --profile test --results /tmp/results-test.xml output/rhel6-xccdf-valid.xml

eval-common:
	oscap xccdf eval --profile common --results /tmp/results-test.xml output/rhel6-xccdf-valid.xml

clean:
	rm ${OUTDIR}/*.xml ${OUTDIR}/*.html ${OUTDIR}/*.pdf
