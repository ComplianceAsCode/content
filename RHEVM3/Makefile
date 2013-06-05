IN = input
OUT = output
TRANS = transforms
REFS = references
UTILS = utils
DIST = dist

ID = ssg

all: shorthand2xccdf tables guide checks content dist

shorthand-guide:
	xsltproc -o $(OUT)/rhevm3-shorthand.xml $(IN)/guide.xslt $(IN)/guide.xml
	xmllint --format --output $(OUT)/rhevm3-shorthand.xml $(OUT)/rhevm3-shorthand.xml

shorthand2xccdf: shorthand-guide
	xsltproc -o $(OUT)/unlinked-noprofiles-rhevm3-shorthand.xml $(TRANS)/shorthand2xccdf.xslt $(OUT)/rhevm3-shorthand.xml
	xsltproc -o $(OUT)/unlinked-noprofiles-rhevm3-xccdf.xml $(TRANS)/add_xccdf_namespace.xslt $(OUT)/unlinked-noprofiles-rhevm3-shorthand.xml
	xsltproc -stringparam profile "allprofiles" -o $(OUT)/unlinked-rhevm3-xccdf-prerefs.xml \
		$(TRANS)/xccdf-addprofiles.xslt $(OUT)/unlinked-noprofiles-rhevm3-xccdf.xml
	xsltproc -stringparam profile "stig-rhevm3-server" -o $(OUT)/unlinked-rhevm3-xccdf.xml \
		$(TRANS)/xccdf-addrefs.xslt $(OUT)/unlinked-rhevm3-xccdf-prerefs.xml
#   extract manual check instructions from xccdf into an ocil file
	xsltproc -o $(OUT)/unlinked-rhevm3-ocil.xml $(TRANS)/xccdf-create-ocil.xslt $(OUT)/unlinked-rhevm3-xccdf.xml
	xmllint --format --output $(OUT)/unlinked-rhevm3-ocil.xml $(OUT)/unlinked-rhevm3-ocil.xml 
	xsltproc -o $(OUT)/unlinked-ocilrefs-rhevm3-xccdf.xml $(TRANS)/xccdf-ocilcheck2ref.xslt $(OUT)/unlinked-rhevm3-xccdf.xml
	./$(TRANS)/combinefixes.sh $(IN)/fixes/bash/ $(OUT)/bash-remediations.xml
	xsltproc -stringparam fixes "../$(OUT)/bash-remediations.xml" -o $(OUT)/unlinked-rhevm3-xccdf.xml $(TRANS)/xccdf-addfixes.xslt $(OUT)/unlinked-rhevm3-xccdf.xml
	xmllint --format --output $(OUT)/unlinked-rhevm3-xccdf.xml $(OUT)/unlinked-rhevm3-xccdf.xml

checks:
	xmlwf $(IN)/checks/*.xml
	$(TRANS)/combinechecks.py $(IN)/checks > $(OUT)/unlinked-rhevm3-oval.xml
	xmllint --format --output $(OUT)/unlinked-rhevm3-oval.xml $(OUT)/unlinked-rhevm3-oval.xml

guide: shorthand2xccdf
#	remove auxiliary Groups which are only for use in tables, and not guide output.
#	specifying a nonexistent profile, "allrules," to make oscap print all Rules
	xsltproc -o $(OUT)/unlinked-rhevm3-xccdf-guide.xml $(TRANS)/xccdf-removeaux.xslt $(OUT)/unlinked-rhevm3-xccdf.xml
#	
#	Begin Guide Creation
#	NOTE:	If you do not follow the $(profile)-guide.html syntax
#		you will manually have to include your guide in the 
#		make dist section
#
	oscap xccdf generate guide --profile stig-rhevm3-server $(OUT)/unlinked-rhevm3-xccdf-guide.xml > $(OUT)/stig-rhevm3-server-guide.html

# example, if needed: for converting XCCDF into shorthand
#xccdf2shorthand:
#	xsltproc -o $(XCCDF_OUTPUT_DIR)/rhel5-shorthand.xml $(TRANS)/xccdf2shorthand.xslt $(REFS)/usgcb-rhel5desktop-xccdf.xml
#	tidy -m -xml -utf8 --indent-spaces=0 $(XCCDF_OUTPUT_DIR)/rhel5-shorthand.xml

table-profilenistrefs: shorthand2xccdf
	xsltproc -stringparam profile "desktop" -o $(OUT)/table-rhevm3-nistrefs-desktop.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/unlinked-rhevm3-xccdf.xml
	xsltproc -stringparam profile "server" -o $(OUT)/table-rhevm3-nistrefs-server.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/unlinked-rhevm3-xccdf.xml
	xsltproc -stringparam profile "common" -o $(OUT)/table-rhevm3-nistrefs-common.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/unlinked-rhevm3-xccdf.xml
	xsltproc -stringparam profile "ftp" -o $(OUT)/table-rhevm3-nistrefs-ftp.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/unlinked-rhevm3-xccdf.xml

table-refs: shorthand2xccdf
	xsltproc -stringparam ref "nist" -o $(OUT)/table-rhevm3-nistrefs.html $(TRANS)/xccdf2table-byref.xslt $(OUT)/unlinked-rhevm3-xccdf.xml
# break apart references by delimiter:
	xsltproc -stringparam ref "nist" -stringparam delim "," -o $(OUT)/table-rhevm3-nistrefs-delim.html $(TRANS)/xccdf2table-byref.xslt $(OUT)/unlinked-rhevm3-xccdf.xml
# then sort them:
	xsltproc --html -o $(OUT)/table-rhevm3-nistrefs-delim-sorted.html $(TRANS)/table-sortbyref.xslt $(OUT)/table-rhevm3-nistrefs-delim.html

table-idents: shorthand2xccdf
	xsltproc -o $(OUT)/table-rhevm3-cces.html $(TRANS)/xccdf2table-cce.xslt $(OUT)/unlinked-rhevm3-xccdf.xml
	xsltproc -stringparam ref "../$(REFS)/cce-rhel5.xml" -o $(OUT)/table-rhevm3-cces-rhel5.html $(TRANS)/xccdf2table-cce.xslt $(OUT)/unlinked-rhevm3-xccdf.xml

table-srgmap: shorthand2xccdf
# the map-to-items filename must be provided relative to the root of the main document being processed
	xsltproc -stringparam map-to-items "../$(OUT)/unlinked-rhevm3-xccdf.xml" -o $(OUT)/table-rhevm3-srgmap.html \
		$(TRANS)/table-srgmap.xslt $(REFS)/U_Application_SRG_V1R1_Manual-xccdf.xml
	xsltproc -stringparam flat "y" -stringparam map-to-items "../$(OUT)/unlinked-rhevm3-xccdf.xml" -o $(OUT)/table-rhevm3-srgmap-flat.html \
		$(TRANS)/table-srgmap.xslt $(REFS)/U_Application_SRG_V1R1_Manual-xccdf.xml
	xmllint --xmlout --html --output $(OUT)/table-rhevm3-srgmap-flat.xhtml $(OUT)/table-rhevm3-srgmap-flat.html

table-stigs: shorthand2xccdf table-srgmap
#	xsltproc -o $(OUT)/table-rhel5-stig.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-rhel5-v1r0.6-xccdf.xml  
#	xsltproc -o $(OUT)/table-rhel5-stig-manual.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-rhel5-v1r0.6-xccdf-manual.xml  
#	xsltproc --html -o $(OUT)/table-rhel5-stig-manual-ccisorted.html $(TRANS)/table-sortbyref.xslt $(OUT)/table-rhel5-stig-manual.html 
#	xsltproc -stringparam notes "../$(IN)/auxiliary/transition_notes.xml" -o $(OUT)/table-rhel5-stig-manual-withnotes.html \
#		$(TRANS)/xccdf2table-stig.xslt \
#		$(REFS)/disa-stig-rhel5-v1r0.6-xccdf-manual.xml
#	temporarily retain an output file showing the short titles as well
#	xsltproc -stringparam profile "stig-rhevm3-server" -stringparam testinfo "y" -o $(OUT)/table-stig-rhevm3-server-shorttitles.html \
#		$(TRANS)/xccdf2table-profileccirefs.xslt \
#		$(OUT)/unlinked-rhevm3-xccdf.xml  
#	xsltproc -stringparam alttitles "../$(IN)/auxiliary/alt-titles-stig.xml" -o $(OUT)/unlinked-stig-rhevm3-xccdf.xml \
#		$(TRANS)/xccdf-alt-titles.xslt \
#		$(OUT)/unlinked-rhevm3-xccdf.xml
#	xsltproc -stringparam profile "stig-rhevm3-server" -o $(OUT)/table-stig-rhevm3-server.html \
#		$(TRANS)/xccdf2table-profileccirefs.xslt \
#		$(OUT)/unlinked-stig-rhevm3-xccdf.xml  
#	xsltproc --html -o $(OUT)/table-stig-rhevm3-server.html $(TRANS)/table-add-vulnids.xslt $(OUT)/table-stig-rhevm3-server.html
#	xsltproc -stringparam profile "stig-rhevm3-server" -stringparam format "flat" -o $(OUT)/table-stig-rhevm3-server-flat.html \
#		$(TRANS)/xccdf2table-profileccirefs.xslt \
#		$(OUT)/unlinked-stig-rhevm3-xccdf.xml  
#	xsltproc --novalid --html -o $(OUT)/table-stig-rhevm3-server-flat-srgs.html $(TRANS)/table-add-srgitems.xslt $(OUT)/table-stig-rhevm3-server-flat.html
#	xsltproc --novalid --html -o $(OUT)/table-stig-rhevm3-server-srgs.html $(TRANS)/table-add-srgitems.xslt $(OUT)/table-stig-rhevm3-server.html
#	xsltproc --html -o $(OUT)/table-stig-rhevm3-server-flat.html $(TRANS)/table-add-vulnids.xslt $(OUT)/table-stig-rhevm3-server-flat.html

tables: table-refs table-idents table-profilenistrefs table-srgmap table-stigs

alt-titles: shorthand2xccdf
	$(UTILS)/sync-alt-titles.py -p stig-rhevm3-server -f $(IN)/auxiliary/alt-titles-stig.xml $(OUT)/unlinked-rhevm3-xccdf.xml
	XMLLINT_INDENT="" xmllint --format --output $(IN)/auxiliary/alt-titles-stig.xml $(IN)/auxiliary/alt-titles-stig.xml 

content: shorthand2xccdf guide checks
#	the relabelids.py script chdirs to ./output, so refer to files from there.
#	its second argument controls the IDs, as well as the output filenames.
#	thus, with ID set to ssg, this creates ssg-rhevm3-xccdf.xml and ssg-rhevm3-oval.xml.
	$(TRANS)/cpe_generate.py $(OUT)/unlinked-rhevm3-oval.xml $(IN)/checks/platform/rhevm3-cpe-dictionary.xml $(ID)
	$(TRANS)/relabelids.py unlinked-rhevm3-xccdf.xml $(ID)
	$(TRANS)/relabelids.py unlinked-ocilrefs-rhevm3-xccdf.xml $(ID)

# not ready until oscap resolve behavior resolved
content-stig: shorthand2xccdf guide checks
	xsltproc -stringparam alttitles "../$(IN)/auxiliary/alt-titles-stig.xml" -o $(OUT)/unlinked-rhevm3-xccdf.xml \
		$(TRANS)/xccdf-alt-titles.xslt \
		$(OUT)/unlinked-rhevm3-xccdf.xml
	oscap xccdf resolve -o $(OUT)/unlinked-resolved-rhevm3-xccdf.xml $(OUT)/unlinked-rhevm3-xccdf.xml
	xsltproc -stringparam profile "stig-rhevm3-server" -o $(OUT)/unlinked-stig-rhevm3-xccdf.xml \
		$(TRANS)/xccdf2stigformat.xslt $(OUT)/unlinked-resolved-rhevm3-xccdf.xml 
	xsltproc -o $(OUT)/table-stig-rhevm3-server-stigformat.html \
		$(TRANS)/xccdf2table-stig.xslt $(OUT)/unlinked-stig-rhevm3-xccdf.xml
	xmllint --format --output $(OUT)/unlinked-stig-rhevm3-xccdf.xml $(OUT)/unlinked-stig-rhevm3-xccdf.xml 
	$(TRANS)/cpe_generate.py $(OUT)/unlinked-rhevm3-oval.xml $(IN)/checks/platform/rhevm3-cpe-dictionary.xml disa-predraft
	$(TRANS)/relabelids.py unlinked-stig-rhevm3-xccdf.xml disa-predraft
	xmllint --format --output $(OUT)/disa-predraft-stig-rhevm3-xccdf.xml $(OUT)/disa-predraft-stig-rhevm3-xccdf.xml

submission-stig-check: table-stigs
	cd output; ../$(UTILS)/verify-references.py -p stig-rhevm3-server --rules-with-disarefs-outside-profile unlinked-rhevm3-xccdf-prerefs.xml
#	$(TRANS)/xccdf2csv-stig.py $(OUT)/unlinked-stig-rhevm3-xccdf.xml > $(OUT)/table-stig.csv

# content-usgcb: coming soon

validate:
	oscap xccdf validate-xml $(OUT)/$(ID)-rhevm3-xccdf.xml
	oscap oval validate-xml $(OUT)/$(ID)-rhevm3-oval.xml
	oscap oval validate-xml $(OUT)/$(ID)-rhevm3-cpe-oval.xml

eval-test:
	oscap xccdf eval --profile test $(OUT)/$(ID)-rhevm3-xccdf.xml

eval-ftp:
	oscap xccdf eval --profile ftp $(OUT)/$(ID)-rhevm3-xccdf.xml

eval-common:
	oscap xccdf eval --profile common --oval-results --results /tmp/results-test.xml $(OUT)/$(ID)-rhevm3-xccdf.xml

# items in dist are expected for distribution in an rpm
dist: tables guide content
	mkdir -p $(DIST)/guide $(DIST)/content $(DIST)/policytables
	cp $(OUT)/*-guide.html $(DIST)/guide
	cp $(OUT)/$(ID)-rhevm3-xccdf.xml $(DIST)/content
	cp $(OUT)/$(ID)-rhevm3-oval.xml $(DIST)/content
	cp $(OUT)/$(ID)-rhevm3-cpe-dictionary.xml $(DIST)/content
	cp $(OUT)/$(ID)-rhevm3-cpe-oval.xml $(DIST)/content
	cp $(OUT)/table-rhevm3-* $(DIST)/policytables

#install:
#	cp -r rhevm3/src/dist/* /usr/share/scap-security-guide/rhevm3

clean:
	rm -f $(OUT)/*.xml $(OUT)/*.html $(OUT)/*.pdf  $(OUT)/*.spec $(OUT)/*.tar $(OUT)/*.gz $(OUT)/*.ini
	rm -rf $(DIST)/content $(DIST)/policytables $(DIST)/guide
