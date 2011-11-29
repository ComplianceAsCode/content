INDIR=input
OUTDIR=output
TRANSDIR=transforms
REFS=references

all: shorthand-guide shorthand2xccdf xccdf2table-nistrefs guide checks content

shorthand-guide:
	xsltproc -o ${OUTDIR}/rhel6-shorthand.xml ${INDIR}/guide.xslt ${INDIR}/guide.xml
	xmllint --format --output ${OUTDIR}/rhel6-shorthand.xml ${OUTDIR}/rhel6-shorthand.xml 

shorthand2xccdf:
	xsltproc -o ${OUTDIR}/rhel6-xccdf.xml ${TRANSDIR}/shorthand2xccdf.xslt ${OUTDIR}/rhel6-shorthand.xml
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

xccdf2shorthand:
	xsltproc -o ${OUTDIR}/rhel5-shorthand.xml ${TRANSDIR}/xccdf2shorthand.xslt ${REFS}/usgcb-rhel5desktop-xccdf.xml
	tidy -m -xml -utf8 --indent-spaces=0 ${OUTDIR}/rhel5-shorthand.xml

xccdf-addprofiles:
	xsltproc -stringparam profile "allprofiles" -o ${OUTDIR}/rhel6-xccdf-allprofiles.xml ${TRANSDIR}/xccdf-addprofiles.xslt ${OUTDIR}/rhel6-xccdf.xml

xccdf2table-nistrefs: shorthand-guide shorthand2xccdf xccdf-addprofiles
	xsltproc -o ${OUTDIR}/rhel6-table-nistrefs.html ${TRANSDIR}/xccdf2table-nistrefs.xslt ${OUTDIR}/rhel6-xccdf-allprofiles.xml
	xmllint --format --output ${OUTDIR}/rhel6-xccdf-allprofiles.xml ${OUTDIR}/rhel6-xccdf-allprofiles.xml

content: shorthand-guide shorthand2xccdf xccdf-addprofiles checks
	${TRANSDIR}/relabelids.py rhel6-xccdf-allprofiles.xml scap-security-guide 
# 	the script chdirs to ./output, so refer to files from there

validate:
	oscap xccdf validate-xml output/rhel6-xccdf-scap-security-guide.xml
	oscap oval validate-xml output/rhel6-oval-scap-security-guide.xml

clean:
	rm ${OUTDIR}/*.xml ${OUTDIR}/*.html ${OUTDIR}/*.pdf
