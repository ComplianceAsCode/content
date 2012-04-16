IN=input
OUT=output
TRANS=transforms
REFS=references
DIST=scap-security-guide-alpha

all: shorthand-guide shorthand2xccdf tables guide checks content dist rpm

shorthand-guide:
	xsltproc -o ${OUT}/rhel6-shorthand.xml ${IN}/guide.xslt ${IN}/guide.xml
	xmllint --format --output ${OUT}/rhel6-shorthand.xml ${OUT}/rhel6-shorthand.xml 

shorthand2xccdf:
	xsltproc -o ${OUT}/rhel6-xccdf-noprofiles.xml ${TRANS}/shorthand2xccdf.xslt ${OUT}/rhel6-shorthand.xml
	xsltproc -stringparam profile "allprofiles" -o ${OUT}/rhel6-xccdf.xml ${TRANS}/xccdf-addprofiles.xslt ${OUT}/rhel6-xccdf-noprofiles.xml
	xsltproc -stringparam fixes "../${IN}/fixes/bash-ks.xml" -o ${OUT}/rhel6-xccdf.xml ${TRANS}/xccdf-addfixes.xslt ${OUT}/rhel6-xccdf.xml
#	xsltproc -stringparam fixes "../${IN}/fixes/puppet-example.xml" -o ${OUT}/rhel6-xccdf.html ${TRANS}/xccdf-addfixes.xslt ${OUT}/rhel6-xccdf.xml
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
#	xsltproc -o ${XCCDF_OUTPUT_DIR}/rhel5-shorthand.xml ${TRANS}/xccdf2shorthand.xslt ${REFS}/usgcb-rhel5desktop-xccdf.xml
#	tidy -m -xml -utf8 --indent-spaces=0 ${XCCDF_OUTPUT_DIR}/rhel5-shorthand.xml

table-profilenistrefs: shorthand-guide shorthand2xccdf
#	xsltproc -o ${POLICYMAPPING_OUTPUT_DIR}/rhel6-table-nistrefs.html ${TRANS}/xccdf2table-nistrefs.xslt ${XCCDF_OUTPUT_DIR}/rhel6-xccdf.xml
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

table-srgmap: shorthand-guide shorthand2xccdf
# the map-to-rules filename must be provided relative to the root of the main document being processed
	xsltproc -stringparam map-to-rules "../${OUT}/rhel6-xccdf.xml" -o ${OUT}/rhel6-table-srgmap.html ${TRANS}/table-srgmap.xslt ${REFS}/disa-os-srg-v1r1.xml

tables: table-refs table-profilenistrefs table-srgmap

content: shorthand-guide shorthand2xccdf checks
# 	the relabelids.py script chdirs to ./output, so refer to files from there.
# 	the second argument controls the IDs, as well as the output filenames.
# 	thus, this creates rhel6-xccdf-scap-security-guide.xml and rhel6-oval-scap-security-guide.xml.
	${TRANS}/relabelids.py rhel6-xccdf.xml scap-security-guide 

validate: 
	oscap xccdf validate-xml ${OUT}/rhel6-xccdf-scap-security-guide.xml
	oscap oval validate-xml ${OUT}/rhel6-oval-scap-security-guide.xml

eval-test:
	oscap xccdf eval --profile test ${OUT}/rhel6-xccdf-scap-security-guide.xml

eval-ftp:
	oscap xccdf eval --profile ftp ${OUT}/rhel6-xccdf-scap-security-guide.xml

eval-common:
	oscap xccdf eval --profile common --results /tmp/results-test.xml ${OUT}/rhel6-xccdf-scap-security-guide.xml

dist: content guide tables
	cp -r ${IN}/dist_template/ ${DIST}/
	cp ${OUT}/rhel6-guide.html ${DIST}/guide
	cp ${OUT}/rhel6-xccdf-scap-security-guide.xml ${DIST}/content
	cp ${OUT}/rhel6-oval-scap-security-guide.xml ${DIST}/content
	cp ${OUT}/rhel6-table-nistrefs-delim-sorted.html ${DIST}/policytables
	cp ${OUT}/rhel6-table-nistrefs.html ${DIST}/policytables
	cp ${OUT}/rhel6-table-cnssrefs.html ${DIST}/policytables
	cp ${OUT}/rhel6-table-dcidrefs.html ${DIST}/policytables

rpm: dist

	# A few quick notes on preparing your system to build the SSG RPMs:
	# (1) May the flies of a thousand horses annoy you for eternity
	#     if you build an RPM as root. Don't do it!
	# (2) This build process assumes you have your rpmbuild structure setup
	# 	$ sudo yum -y install rpm-build
	# 	$ mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
	# (3) The value if ${DIST} in this Makefile needs to match
	#     the %{name}-%{version} string from the .spec file, i.e.
	#     scap-security-guide-alpha
	# (4) If you're making an RPM, chances are the code has changed. Make
	#     sure you update the %changelog in the .spec to reflect what's new

	# copy template .spec over to rpmbuild
	cp ${IN}/rpmbuild/scap-security-guide-alpha.spec ${OUT}/

	# tar up the sources
	tar -zcvf ${OUT}/scap-security-guide-alpha.tar.gz ${DIST}
	mv ${OUT}/scap-security-guide-alpha.tar.gz ~/rpmbuild/SOURCES/
	
	# let's see if a build works
	rpmbuild -ba ${OUT}/scap-security-guide-alpha.spec

	# Our RPM(s) will be waiting for us in ${HOMEDIR}, so copy them back
	mv ~/rpmbuild/RPMS/ ${OUT}/


clean:
	rm -f ${OUT}/*.xml ${OUT}/*.html ${OUT}/*.pdf  ${OUT}/*.spec ${OUT}/*.tar ${OUT}/*.gz ${OUT}/*.ini
	rm -rf ${DIST}/
	rm -rf ${OUT}/RPMS/
