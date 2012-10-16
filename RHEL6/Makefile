IN = input
OUT = output
TRANS = transforms
REFS = references
UTILS = utils
DIST = dist

ID = ssg

all: shorthand2xccdf tables guide checks content dist

shorthand-guide:
	xsltproc -o $(OUT)/rhel6-shorthand.xml $(IN)/guide.xslt $(IN)/guide.xml
	xmllint --format --output $(OUT)/rhel6-shorthand.xml $(OUT)/rhel6-shorthand.xml

shorthand2xccdf: shorthand-guide
	xsltproc -o $(OUT)/unlinked-noprofiles-rhel6-xccdf.xml $(TRANS)/shorthand2xccdf.xslt $(OUT)/rhel6-shorthand.xml
	xsltproc -stringparam profile "allprofiles" -o $(OUT)/unlinked-rhel6-xccdf.xml \
		$(TRANS)/xccdf-addprofiles.xslt $(OUT)/unlinked-noprofiles-rhel6-xccdf.xml
	xsltproc -stringparam profile "stig-server" -o $(OUT)/unlinked-rhel6-xccdf.xml \
		$(TRANS)/xccdf-addrefs.xslt $(OUT)/unlinked-rhel6-xccdf.xml
#   extract manual check instructions from xccdf into an ocil file
	xsltproc -o $(OUT)/unlinked-rhel6-ocil.xml $(TRANS)/xccdf-create-ocil.xslt $(OUT)/unlinked-rhel6-xccdf.xml
	xmllint --format --output $(OUT)/unlinked-rhel6-ocil.xml $(OUT)/unlinked-rhel6-ocil.xml 
	xsltproc -o $(OUT)/unlinked-ocilrefs-rhel6-xccdf.xml $(TRANS)/xccdf-ocilcheck2ref.xslt $(OUT)/unlinked-rhel6-xccdf.xml
#	xsltproc -stringparam fixes "../$(IN)/fixes/bash-ks.xml" -o $(OUT)/unlinked-rhel6-xccdf.xml $(TRANS)/xccdf-addfixes.xslt $(OUT)/unlinked-rhel6-xccdf.xml
	xmllint --format --output $(OUT)/unlinked-rhel6-xccdf.xml $(OUT)/unlinked-rhel6-xccdf.xml

checks:
	xmlwf $(IN)/checks/*.xml
	$(TRANS)/combinechecks.py $(IN)/checks > $(OUT)/unlinked-rhel6-oval.xml
	xmllint --format --output $(OUT)/unlinked-rhel6-oval.xml $(OUT)/unlinked-rhel6-oval.xml

guide: shorthand2xccdf
#	remove auxiliary Groups which are only for use in tables, and not guide output.
#	specifying a nonexistent profile, "allrules," to make oscap print all Rules
	xsltproc -o $(OUT)/unlinked-rhel6-xccdf.xml $(TRANS)/xccdf-removeaux.xslt $(OUT)/unlinked-rhel6-xccdf.xml
	oscap xccdf generate guide --profile allrules $(OUT)/unlinked-rhel6-xccdf.xml > $(OUT)/rhel6-guide.html

# example, if needed: for converting XCCDF into shorthand
#xccdf2shorthand:
#	xsltproc -o $(XCCDF_OUTPUT_DIR)/rhel5-shorthand.xml $(TRANS)/xccdf2shorthand.xslt $(REFS)/usgcb-rhel5desktop-xccdf.xml
#	tidy -m -xml -utf8 --indent-spaces=0 $(XCCDF_OUTPUT_DIR)/rhel5-shorthand.xml

table-profilenistrefs: shorthand2xccdf
	xsltproc -stringparam profile "desktop" -o $(OUT)/table-rhel6-nistrefs-desktop.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/unlinked-rhel6-xccdf.xml
	xsltproc -stringparam profile "server" -o $(OUT)/table-rhel6-nistrefs-server.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/unlinked-rhel6-xccdf.xml
	xsltproc -stringparam profile "common" -o $(OUT)/table-rhel6-nistrefs-common.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/unlinked-rhel6-xccdf.xml
	xsltproc -stringparam profile "ftp" -o $(OUT)/table-rhel6-nistrefs-ftp.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/unlinked-rhel6-xccdf.xml

table-refs: shorthand2xccdf
	xsltproc -stringparam ref "nist" -o $(OUT)/table-rhel6-nistrefs.html $(TRANS)/xccdf2table-byref.xslt $(OUT)/unlinked-rhel6-xccdf.xml
# break apart references by delimiter:
	xsltproc -stringparam ref "nist" -stringparam delim "," -o $(OUT)/table-rhel6-nistrefs-delim.html $(TRANS)/xccdf2table-byref.xslt $(OUT)/unlinked-rhel6-xccdf.xml
# then sort them:
	xsltproc --html -o $(OUT)/table-rhel6-nistrefs-delim-sorted.html $(TRANS)/table-sortbyref.xslt $(OUT)/table-rhel6-nistrefs-delim.html

table-idents: shorthand2xccdf
	xsltproc -o $(OUT)/table-rhel6-cces.html $(TRANS)/xccdf2table-cce.xslt $(OUT)/unlinked-rhel6-xccdf.xml
	xsltproc -stringparam ref "../$(REFS)/cce-rhel5.xml" -o $(OUT)/table-rhel6-cces-rhel5.html $(TRANS)/xccdf2table-cce.xslt $(OUT)/unlinked-rhel6-xccdf.xml

table-srgmap: shorthand2xccdf
# the map-to-items filename must be provided relative to the root of the main document being processed
	xsltproc -stringparam map-to-items "../$(OUT)/unlinked-rhel6-xccdf.xml" -o $(OUT)/table-rhel6-srgmap.html \
		$(TRANS)/table-srgmap.xslt $(REFS)/disa-os-srg-v1r1.xml
	xsltproc -stringparam flat "y" -stringparam map-to-items "../$(OUT)/unlinked-rhel6-xccdf.xml" -o $(OUT)/table-rhel6-srgmap-flat.html \
		$(TRANS)/table-srgmap.xslt $(REFS)/disa-os-srg-v1r1.xml

table-stigs: shorthand2xccdf
	xsltproc -o $(OUT)/table-rhel5-stig.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-rhel5-v1r0.6-xccdf.xml  
	xsltproc -o $(OUT)/table-rhel5-stig-manual.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-rhel5-v1r0.6-xccdf-manual.xml  
	xsltproc --html -o $(OUT)/table-rhel5-stig-manual-ccisorted.html $(TRANS)/table-sortbyref.xslt $(OUT)/table-rhel5-stig-manual.html 
	xsltproc -stringparam notes "../$(IN)/auxiliary/transition_notes.xml" -o $(OUT)/table-rhel5-stig-manual-withnotes.html \
		$(TRANS)/xccdf2table-stig.xslt \
		$(REFS)/disa-stig-rhel5-v1r0.6-xccdf-manual.xml
#	temporarily retain an output file showing the short titles as well
	xsltproc -stringparam profile "stig-server" -stringparam testinfo "y" -o $(OUT)/table-rhel6-stig-server-shorttitles.html \
		$(TRANS)/xccdf2table-profileccirefs.xslt \
		$(OUT)/unlinked-rhel6-xccdf.xml  
	xsltproc -stringparam alttitles "../$(IN)/auxiliary/alt-titles-stig.xml" -o $(OUT)/unlinked-stig-rhel6-xccdf.xml \
		$(TRANS)/xccdf-alt-titles.xslt \
		$(OUT)/unlinked-rhel6-xccdf.xml
	xsltproc -stringparam profile "stig-server" -o $(OUT)/table-rhel6-stig-server.html \
		$(TRANS)/xccdf2table-profileccirefs.xslt \
		$(OUT)/unlinked-stig-rhel6-xccdf.xml  

tables: table-refs table-idents table-profilenistrefs table-srgmap table-stigs

alt-titles: shorthand2xccdf
	$(UTILS)/sync-alt-titles.py -p stig-server -f $(IN)/auxiliary/alt-titles-stig.xml $(OUT)/unlinked-rhel6-xccdf.xml
	XMLLINT_INDENT="" xmllint --format --output $(IN)/auxiliary/alt-titles-stig.xml $(IN)/auxiliary/alt-titles-stig.xml 

content: shorthand2xccdf guide checks
#	the relabelids.py script chdirs to ./output, so refer to files from there.
#	its second argument controls the IDs, as well as the output filenames.
#	thus, with ID set to ssg, this creates ssg-rhel6-xccdf.xml and ssg-rhel6-oval.xml.
	$(TRANS)/cpe_generate.py $(OUT)/unlinked-rhel6-oval.xml $(IN)/checks/platform/rhel6-cpe-dictionary.xml $(ID)
	$(TRANS)/relabelids.py unlinked-rhel6-xccdf.xml $(ID)
	$(TRANS)/relabelids.py unlinked-ocilrefs-rhel6-xccdf.xml $(ID)

# not ready until oscap resolve behavior resolved
content-stig: shorthand2xccdf guide checks
	xsltproc -stringparam alttitles "../$(IN)/auxiliary/alt-titles-stig.xml" -o $(OUT)/unlinked-rhel6-xccdf.xml \
		$(TRANS)/xccdf-alt-titles.xslt \
		$(OUT)/unlinked-rhel6-xccdf.xml
	oscap xccdf resolve -o $(OUT)/unlinked-resolved-rhel6-xccdf.xml $(OUT)/unlinked-rhel6-xccdf.xml
	xsltproc -stringparam profile "stig-server" -o $(OUT)/unlinked-stig-rhel6-xccdf.xml \
		$(TRANS)/xccdf2stigformat.xslt $(OUT)/unlinked-resolved-rhel6-xccdf.xml 
	xsltproc -o $(OUT)/table-rhel6-stig-server-stigformat.html \
		$(TRANS)/xccdf2table-stig.xslt $(OUT)/unlinked-stig-rhel6-xccdf.xml
	xmllint --format --output $(OUT)/disa-predraft-stig-rhel6-xccdf.xml $(OUT)/unlinked-stig
	$(TRANS)/cpe_generate.py $(OUT)/unlinked-rhel6-oval.xml $(IN)/checks/platform/rhel6-cpe-dictionary.xml disa-predraft
	$(TRANS)/relabelids.py unlinked-stig-rhel6-xccdf.xml disa-predraft
	xmllint --format --output $(OUT)/disa-predraft-stig-rhel6-xccdf.xml $(OUT)/disa-predraft-stig-rhel6-xccdf.xml

submission-stig: content-stig
	$(TRANS)/xccdf2csv-stig.py $(OUT)/unlinked-stig-rhel6-xccdf.xml > $(OUT)/table-rhel6-stig.csv

# content-usgcb: coming soon

validate:
	oscap xccdf validate-xml $(OUT)/$(ID)-rhel6-xccdf.xml
	oscap oval validate-xml $(OUT)/$(ID)-rhel6-oval.xml
	oscap oval validate-xml $(OUT)/$(ID)-rhel6-cpe-oval.xml

eval-test:
	oscap xccdf eval --profile test $(OUT)/$(ID)-rhel6-xccdf.xml

eval-ftp:
	oscap xccdf eval --profile ftp $(OUT)/$(ID)-rhel6-xccdf.xml

eval-common:
	oscap xccdf eval --profile common --oval-results --results /tmp/results-test.xml $(OUT)/$(ID)-rhel6-xccdf.xml

# items in dist are expected for distribution in an rpm
dist: tables guide content
	mkdir -p $(DIST)/guide $(DIST)/content $(DIST)/policytables
	cp $(OUT)/rhel6-guide.html $(DIST)/guide
	cp $(OUT)/$(ID)-rhel6-xccdf.xml $(DIST)/content
	cp $(OUT)/$(ID)-rhel6-oval.xml $(DIST)/content
	cp $(OUT)/$(ID)-rhel6-cpe-dictionary.xml $(DIST)/content
	cp $(OUT)/$(ID)-rhel6-cpe-oval.xml $(DIST)/content
	cp $(OUT)/table-rhel6-* $(DIST)/policytables

#install:
#	cp -r rhel6/src/dist/* /usr/share/scap-security-guide/rhel6

clean:
	rm -f $(OUT)/*.xml $(OUT)/*.html $(OUT)/*.pdf  $(OUT)/*.spec $(OUT)/*.tar $(OUT)/*.gz $(OUT)/*.ini
	rm -rf $(DIST)/content $(DIST)/policytables $(DIST)/guide
