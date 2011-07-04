INDIR=input
OUTDIR=output
TRANSDIR=transforms
REFS=references

all: shorthand-guide shorthand2xccdf validate guide

shorthand-guide:
	xsltproc -o ${OUTDIR}/rhel6-shorthand.xml ${INDIR}/guide.xslt ${INDIR}/guide.xml
	tidy -m -i -xml -utf8 ${OUTDIR}/rhel6-shorthand.xml
#	xmllint --format --output ${OUTDIR}/rhel6-shorthand.xml ${OUTDIR}/rhel6-shorthand.xml 

shorthand2xccdf:
	xsltproc -o ${OUTDIR}/rhel6-xccdf.xml ${TRANSDIR}/shorthand2xccdf.xslt ${OUTDIR}/rhel6-shorthand.xml
	tidy -m -i -xml -utf8 ${OUTDIR}/rhel6-xccdf.xml

spreadsheet:
	xsltproc -o ${OUTDIR}/rhel6-spreadsheet.html ${OUTDIR}/xccdf2spreadsheet.xslt ${OUTDIR}/rhel6-xccdf.xml

validate:
	oscap xccdf validate-xml output/rhel6-xccdf.xml

guide: shorthand-guide shorthand2xccdf
	oscap xccdf generate guide ${OUTDIR}/rhel6-xccdf.xml > ${OUTDIR}/rhel6-guide.html

xccdf2shorthand:
	xsltproc -o ${OUTDIR}/rhel5-shorthand.xml ${TRANSDIR}/xccdf2shorthand.xslt ${REFS}/usgcb-rhel5desktop-xccdf.xml
	tidy -m -xml -utf8 --indent-spaces=0 ${OUTDIR}/rhel5-shorthand.xml

clean:
	rm ${OUTPUTDIR}/*
