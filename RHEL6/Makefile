IN = input
OUT = output
TRANS = transforms
REFS = references
UTILS = utils
DIST = dist
ID = scap-security-guide

all: shorthand-guide shorthand2xccdf tables guide checks content dist

shorthand-guide:
	xsltproc -o $(OUT)/rhel6-shorthand.xml $(IN)/guide.xslt $(IN)/guide.xml
	xmllint --format --output $(OUT)/rhel6-shorthand.xml $(OUT)/rhel6-shorthand.xml

shorthand2xccdf: shorthand-guide
	xsltproc -o $(OUT)/rhel6-xccdf-noprofiles.xml $(TRANS)/shorthand2xccdf.xslt $(OUT)/rhel6-shorthand.xml
	xsltproc -stringparam profile "allprofiles" -o $(OUT)/rhel6-xccdf.xml $(TRANS)/xccdf-addprofiles.xslt $(OUT)/rhel6-xccdf-noprofiles.xml
#	xsltproc -stringparam fixes "../$(IN)/fixes/bash-ks.xml" -o $(OUT)/rhel6-xccdf.xml $(TRANS)/xccdf-addfixes.xslt $(OUT)/rhel6-xccdf.xml
#	xsltproc -stringparam fixes "../$(IN)/fixes/puppet-example.xml" -o $(OUT)/rhel6-xccdf.html $(TRANS)/xccdf-addfixes.xslt $(OUT)/rhel6-xccdf.xml
	xmllint --format --output $(OUT)/rhel6-xccdf.xml $(OUT)/rhel6-xccdf.xml

checks:
	xmlwf $(IN)/checks/*.xml
	$(TRANS)/combinechecks.py $(IN)/checks > $(OUT)/rhel6-oval.xml
	xmllint --format --output $(OUT)/rhel6-oval.xml $(OUT)/rhel6-oval.xml


guide: shorthand-guide shorthand2xccdf
#	remove auxiliary Groups which are only for use in tables, and not guide output.
#	specifying a nonexistent profile, "allrules," to make oscap print all Rules
	xsltproc -o $(OUT)/rhel6-xccdf.xml $(TRANS)/xccdf-removeaux.xslt $(OUT)/rhel6-xccdf.xml
	oscap xccdf generate guide --profile allrules $(OUT)/rhel6-xccdf.xml > $(OUT)/rhel6-guide.html

# example, if needed: for converting XCCDF into shorthand
#xccdf2shorthand:
#	xsltproc -o $(XCCDF_OUTPUT_DIR)/rhel5-shorthand.xml $(TRANS)/xccdf2shorthand.xslt $(REFS)/usgcb-rhel5desktop-xccdf.xml
#	tidy -m -xml -utf8 --indent-spaces=0 $(XCCDF_OUTPUT_DIR)/rhel5-shorthand.xml

table-profilenistrefs: shorthand-guide shorthand2xccdf
#	xsltproc -o $(POLICYMAPPING_OUTPUT_DIR)/rhel6-table-nistrefs.html $(TRANS)/xccdf2table-nistrefs.xslt $(XCCDF_OUTPUT_DIR)/rhel6-xccdf.xml
	xsltproc -stringparam profile "desktop" -o $(OUT)/rhel6-table-nistrefs-desktop.html $(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/rhel6-xccdf.xml
	xsltproc -stringparam profile "server" -o $(OUT)/rhel6-table-nistrefs-server.html $(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/rhel6-xccdf.xml
	xsltproc -stringparam profile "common" -o $(OUT)/rhel6-table-nistrefs-common.html $(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/rhel6-xccdf.xml
	xsltproc -stringparam profile "ftp" -o $(OUT)/rhel6-table-nistrefs-ftp.html $(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/rhel6-xccdf.xml

table-refs: shorthand-guide shorthand2xccdf
	xsltproc -stringparam ref "nist" -o $(OUT)/rhel6-table-nistrefs.html $(TRANS)/xccdf2table-byref.xslt $(OUT)/rhel6-xccdf.xml
# break apart references by delimiter:
	xsltproc -stringparam ref "nist" -stringparam delim "," -o $(OUT)/rhel6-table-nistrefs-delim.html $(TRANS)/xccdf2table-byref.xslt $(OUT)/rhel6-xccdf.xml
# then sort them:
	xsltproc --html -o $(OUT)/rhel6-table-nistrefs-delim-sorted.html $(TRANS)/table-sortbyref.xslt $(OUT)/rhel6-table-nistrefs-delim.html

table-idents: shorthand-guide shorthand2xccdf
	xsltproc -o $(OUT)/rhel6-table-cces.html $(TRANS)/xccdf2table-cce.xslt $(OUT)/rhel6-xccdf.xml
	xsltproc -stringparam ref "../$(REFS)/cce-rhel5.xml" -o $(OUT)/rhel6-table-cces-rhel5.html $(TRANS)/xccdf2table-cce.xslt $(OUT)/rhel6-xccdf.xml


table-srgmap: shorthand-guide shorthand2xccdf
# the map-to-items filename must be provided relative to the root of the main document being processed
	xsltproc -stringparam map-to-items "../$(OUT)/rhel6-xccdf.xml" -o $(OUT)/rhel6-table-srgmap.html $(TRANS)/table-srgmap.xslt $(REFS)/disa-os-srg-v1r1.xml

table-stigs:
	xsltproc -o $(OUT)/rhel5-table-stig.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-rhel5-v1r0.6-xccdf.xml  
	xsltproc -o $(OUT)/rhel5-table-stig-manual.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-rhel5-v1r0.6-xccdf-manual.xml  
	xsltproc --html -o $(OUT)/rhel5-table-stig-manual-ccisorted.html $(TRANS)/table-sortbyref.xslt $(OUT)/rhel5-table-stig-manual.html 
	xsltproc -stringparam notes "../$(IN)/auxiliary/transition_notes.xml" -o $(OUT)/rhel5-table-stig-manual-withnotes.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-rhel5-v1r0.6-xccdf-manual.xml
	xsltproc -o $(OUT)/rhel6-xccdf-stigformat.xml $(TRANS)/xccdf2stigformat.xslt $(OUT)/rhel6-xccdf.xml 
#	temporarily retain an output file showing the short titles as well, for convenience
	xsltproc -stringparam profile "stig-server" -o $(OUT)/rhel6-table-stig-server-shorttitles.html $(TRANS)/xccdf2table-profileccirefs.xslt $(OUT)/rhel6-xccdf-stigformat.xml  
	xsltproc -stringparam alttitles "../$(IN)/auxiliary/alt-titles-stig.xml" -o $(OUT)/rhel6-xccdf-stigformat.xml $(TRANS)/xccdf-alt-titles.xslt $(OUT)/rhel6-xccdf-stigformat.xml  
	xsltproc -stringparam profile "stig-server" -o $(OUT)/rhel6-table-stig-server.html $(TRANS)/xccdf2table-profileccirefs.xslt $(OUT)/rhel6-xccdf-stigformat.xml  

tables: table-idents table-refs table-profilenistrefs table-srgmap table-stigs

alt-titles: shorthand2xccdf
	$(UTILS)/sync-alt-titles.py -p stig-server -f $(IN)/auxiliary/alt-titles-stig.xml $(OUT)/rhel6-xccdf.xml
	XMLLINT_INDENT="" xmllint --format --output $(IN)/auxiliary/alt-titles-stig.xml $(IN)/auxiliary/alt-titles-stig.xml 

content: shorthand-guide shorthand2xccdf guide checks
#	the relabelids.py script chdirs to ./output, so refer to files from there.
#	its second argument controls the IDs, as well as the output filenames.
#	thus, with ID set to scap-security-guide, this creates rhel6-xccdf-scap-security-guide.xml and rhel6-oval-scap-security-guide.xml.
	$(TRANS)/cpe_generate.py $(OUT)/rhel6-oval.xml $(IN)/checks/platform/rhel6-cpe-dictionary.xml $(ID)
	$(TRANS)/relabelids.py rhel6-xccdf.xml $(ID)

validate:
	oscap xccdf validate-xml $(OUT)/rhel6-xccdf-$(ID).xml
	oscap oval validate-xml $(OUT)/rhel6-oval-$(ID).xml
	oscap oval validate-xml $(OUT)/rhel6-cpe-oval-$(ID).xml

eval-test:
	oscap xccdf eval --profile test $(OUT)/rhel6-xccdf-$(ID).xml

eval-ftp:
	oscap xccdf eval --profile ftp $(OUT)/rhel6-xccdf-$(ID).xml

eval-common:
	oscap xccdf eval --profile common --results /tmp/results-test.xml $(OUT)/rhel6-xccdf-$(ID).xml

# items in dist are expected for distribution in an rpm
dist: tables guide content
	mkdir -p $(DIST)/guide $(DIST)/content $(DIST)/policytables
	cp $(OUT)/rhel6-guide.html $(DIST)/guide
	cp $(OUT)/rhel6-xccdf-$(ID).xml $(DIST)/content
	cp $(OUT)/rhel6-oval-$(ID).xml $(DIST)/content
	cp $(OUT)/rhel6-cpe-dictionary-$(ID).xml $(DIST)/content
	cp $(OUT)/rhel6-cpe-oval-$(ID).xml $(DIST)/content
	cp $(OUT)/rhel6-table-* $(DIST)/policytables

#install:
#	cp -r rhel6/src/dist/* /usr/share/scap-security-guide/rhel6

clean:
	rm -f $(OUT)/*.xml $(OUT)/*.html $(OUT)/*.pdf  $(OUT)/*.spec $(OUT)/*.tar $(OUT)/*.gz $(OUT)/*.ini
	rm -rf $(DIST)/content $(DIST)/policytables $(DIST)/guide
