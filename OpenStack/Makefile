IN = input
OUT = output
TRANS = transforms
REFS = references
UTILS = utils
DIST = dist

ID = ssg

OPENSCAP_SVG := $(shell $(TRANS)/oscapsupportssvg.py; echo $$?)

all: shorthand2xccdf tables guide checks content dist

shorthand-guide:
ifeq ($(OPENSCAP_SVG), 0)
	xsltproc -o $(OUT)/guide.xml $(TRANS)/includelogo.xslt $(IN)/guide.xml
	xsltproc -o $(OUT)/openstack-shorthand.xml $(IN)/guide.xslt $(OUT)/guide.xml
else
	xsltproc -o $(OUT)/openstack-shorthand.xml $(IN)/guide.xslt $(IN)/guide.xml
endif
	xmllint --format --output $(OUT)/openstack-shorthand.xml $(OUT)/openstack-shorthand.xml

shorthand2xccdf: shorthand-guide
	xsltproc -o $(OUT)/unlinked-noprofiles-openstack-shorthand.xml $(TRANS)/shorthand2xccdf.xslt $(OUT)/openstack-shorthand.xml
	xsltproc -o $(OUT)/unlinked-noprofiles-openstack-xccdf.xml $(TRANS)/add_xccdf_namespace.xslt $(OUT)/unlinked-noprofiles-openstack-shorthand.xml
	xsltproc -stringparam profile "allprofiles" -o $(OUT)/unlinked-openstack-xccdf-prerefs.xml \
		$(TRANS)/xccdf-addprofiles.xslt $(OUT)/unlinked-noprofiles-openstack-xccdf.xml
	xsltproc -stringparam profile "stig-openstack-server" -o $(OUT)/unlinked-openstack-xccdf.xml \
		$(TRANS)/xccdf-addrefs.xslt $(OUT)/unlinked-openstack-xccdf-prerefs.xml
#   extract manual check instructions from xccdf into an ocil file
	xsltproc -o $(OUT)/unlinked-openstack-ocil.xml $(TRANS)/xccdf-create-ocil.xslt $(OUT)/unlinked-openstack-xccdf.xml
	xmllint --format --output $(OUT)/unlinked-openstack-ocil.xml $(OUT)/unlinked-openstack-ocil.xml 
	xsltproc -o $(OUT)/unlinked-ocilrefs-openstack-xccdf.xml $(TRANS)/xccdf-ocilcheck2ref.xslt $(OUT)/unlinked-openstack-xccdf.xml
	./$(TRANS)/combinefixes.sh $(IN)/fixes/bash/ $(OUT)/bash-remediations.xml
	xsltproc -stringparam fixes "../$(OUT)/bash-remediations.xml" -o $(OUT)/unlinked-openstack-xccdf.xml $(TRANS)/xccdf-addfixes.xslt $(OUT)/unlinked-openstack-xccdf.xml
	xmllint --format --output $(OUT)/unlinked-openstack-xccdf.xml $(OUT)/unlinked-openstack-xccdf.xml

checks:
	xmlwf $(IN)/checks/*.xml
	$(TRANS)/combinechecks.py $(IN)/checks > $(OUT)/unlinked-openstack-oval.xml
	xmllint --format --output $(OUT)/unlinked-openstack-oval.xml $(OUT)/unlinked-openstack-oval.xml

guide: shorthand2xccdf
#	remove auxiliary Groups which are only for use in tables, and not guide output.
#	specifying a nonexistent profile, "allrules," to make oscap print all Rules
	xsltproc -o $(OUT)/unlinked-openstack-xccdf-guide.xml $(TRANS)/xccdf-removeaux.xslt $(OUT)/unlinked-openstack-xccdf.xml
#	
#	Begin Guide Creation
#	NOTE:	If you do not follow the $(profile)-guide.html syntax
#		you will manually have to include your guide in the 
#		make dist section
#
	oscap xccdf generate guide --profile stig-openstack-server $(OUT)/unlinked-openstack-xccdf-guide.xml > $(OUT)/stig-openstack-server-guide.html

# example, if needed: for converting XCCDF into shorthand
#xccdf2shorthand:
#	xsltproc -o $(XCCDF_OUTPUT_DIR)/rhel5-shorthand.xml $(TRANS)/xccdf2shorthand.xslt $(REFS)/usgcb-rhel5desktop-xccdf.xml
#	tidy -m -xml -utf8 --indent-spaces=0 $(XCCDF_OUTPUT_DIR)/rhel5-shorthand.xml

table-profilenistrefs: shorthand2xccdf
	xsltproc -stringparam profile "desktop" -o $(OUT)/table-openstack-nistrefs-desktop.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/unlinked-openstack-xccdf.xml
	xsltproc -stringparam profile "server" -o $(OUT)/table-openstack-nistrefs-server.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/unlinked-openstack-xccdf.xml
	xsltproc -stringparam profile "common" -o $(OUT)/table-openstack-nistrefs-common.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/unlinked-openstack-xccdf.xml
	xsltproc -stringparam profile "ftp" -o $(OUT)/table-openstack-nistrefs-ftp.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/unlinked-openstack-xccdf.xml

table-refs: shorthand2xccdf
	xsltproc -stringparam ref "nist" -o $(OUT)/table-openstack-nistrefs.html $(TRANS)/xccdf2table-byref.xslt $(OUT)/unlinked-openstack-xccdf.xml
# break apart references by delimiter:
	xsltproc -stringparam ref "nist" -stringparam delim "," -o $(OUT)/table-openstack-nistrefs-delim.html $(TRANS)/xccdf2table-byref.xslt $(OUT)/unlinked-openstack-xccdf.xml
# then sort them:
	xsltproc --html -o $(OUT)/table-openstack-nistrefs-delim-sorted.html $(TRANS)/table-sortbyref.xslt $(OUT)/table-openstack-nistrefs-delim.html

table-idents: shorthand2xccdf
	xsltproc -o $(OUT)/table-openstack-cces.html $(TRANS)/xccdf2table-cce.xslt $(OUT)/unlinked-openstack-xccdf.xml
	xsltproc -stringparam ref "../$(REFS)/cce-rhel5.xml" -o $(OUT)/table-openstack-cces-rhel5.html $(TRANS)/xccdf2table-cce.xslt $(OUT)/unlinked-openstack-xccdf.xml

table-srgmap: shorthand2xccdf
# the map-to-items filename must be provided relative to the root of the main document being processed
	xsltproc -stringparam map-to-items "../$(OUT)/unlinked-openstack-xccdf.xml" -o $(OUT)/table-openstack-srgmap.html \
		$(TRANS)/table-srgmap.xslt $(REFS)/U_Application_SRG_V1R1_Manual-xccdf.xml
	xsltproc -stringparam flat "y" -stringparam map-to-items "../$(OUT)/unlinked-openstack-xccdf.xml" -o $(OUT)/table-openstack-srgmap-flat.html \
		$(TRANS)/table-srgmap.xslt $(REFS)/U_Application_SRG_V1R1_Manual-xccdf.xml
	xmllint --xmlout --html --output $(OUT)/table-openstack-srgmap-flat.xhtml $(OUT)/table-openstack-srgmap-flat.html

table-stigs: shorthand2xccdf table-srgmap
#	xsltproc -o $(OUT)/table-rhel5-stig.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-rhel5-v1r0.6-xccdf.xml  
#	xsltproc -o $(OUT)/table-rhel5-stig-manual.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-rhel5-v1r0.6-xccdf-manual.xml  
#	xsltproc --html -o $(OUT)/table-rhel5-stig-manual-ccisorted.html $(TRANS)/table-sortbyref.xslt $(OUT)/table-rhel5-stig-manual.html 
#	xsltproc -stringparam notes "../$(IN)/auxiliary/transition_notes.xml" -o $(OUT)/table-rhel5-stig-manual-withnotes.html \
#		$(TRANS)/xccdf2table-stig.xslt \
#		$(REFS)/disa-stig-rhel5-v1r0.6-xccdf-manual.xml
#	temporarily retain an output file showing the short titles as well
#	xsltproc -stringparam profile "stig-openstack-server" -stringparam testinfo "y" -o $(OUT)/table-stig-openstack-server-shorttitles.html \
#		$(TRANS)/xccdf2table-profileccirefs.xslt \
#		$(OUT)/unlinked-openstack-xccdf.xml  
#	xsltproc -stringparam alttitles "../$(IN)/auxiliary/alt-titles-stig.xml" -o $(OUT)/unlinked-stig-openstack-xccdf.xml \
#		$(TRANS)/xccdf-alt-titles.xslt \
#		$(OUT)/unlinked-openstack-xccdf.xml
#	xsltproc -stringparam profile "stig-openstack-server" -o $(OUT)/table-stig-openstack-server.html \
#		$(TRANS)/xccdf2table-profileccirefs.xslt \
#		$(OUT)/unlinked-stig-openstack-xccdf.xml  
#	xsltproc --html -o $(OUT)/table-stig-openstack-server.html $(TRANS)/table-add-vulnids.xslt $(OUT)/table-stig-openstack-server.html
#	xsltproc -stringparam profile "stig-openstack-server" -stringparam format "flat" -o $(OUT)/table-stig-openstack-server-flat.html \
#		$(TRANS)/xccdf2table-profileccirefs.xslt \
#		$(OUT)/unlinked-stig-openstack-xccdf.xml  
#	xsltproc --novalid --html -o $(OUT)/table-stig-openstack-server-flat-srgs.html $(TRANS)/table-add-srgitems.xslt $(OUT)/table-stig-openstack-server-flat.html
#	xsltproc --novalid --html -o $(OUT)/table-stig-openstack-server-srgs.html $(TRANS)/table-add-srgitems.xslt $(OUT)/table-stig-openstack-server.html
#	xsltproc --html -o $(OUT)/table-stig-openstack-server-flat.html $(TRANS)/table-add-vulnids.xslt $(OUT)/table-stig-openstack-server-flat.html

tables: table-refs table-idents table-profilenistrefs table-srgmap table-stigs

alt-titles: shorthand2xccdf
	$(UTILS)/sync-alt-titles.py -p stig-openstack-server -f $(IN)/auxiliary/alt-titles-stig.xml $(OUT)/unlinked-openstack-xccdf.xml
	XMLLINT_INDENT="" xmllint --format --output $(IN)/auxiliary/alt-titles-stig.xml $(IN)/auxiliary/alt-titles-stig.xml 

content: shorthand2xccdf guide checks
#	the relabelids.py script chdirs to ./output, so refer to files from there.
#	its second argument controls the IDs, as well as the output filenames.
#	thus, with ID set to ssg, this creates ssg-openstack-xccdf.xml and ssg-openstack-oval.xml.
	$(TRANS)/cpe_generate.py $(OUT)/unlinked-openstack-oval.xml $(IN)/checks/platform/openstack-cpe-dictionary.xml $(ID)
	$(TRANS)/relabelids.py unlinked-openstack-xccdf.xml $(ID)
	$(TRANS)/relabelids.py unlinked-ocilrefs-openstack-xccdf.xml $(ID)

# not ready until oscap resolve behavior resolved
content-stig: shorthand2xccdf guide checks
	xsltproc -stringparam alttitles "../$(IN)/auxiliary/alt-titles-stig.xml" -o $(OUT)/unlinked-openstack-xccdf.xml \
		$(TRANS)/xccdf-alt-titles.xslt \
		$(OUT)/unlinked-openstack-xccdf.xml
	oscap xccdf resolve -o $(OUT)/unlinked-resolved-openstack-xccdf.xml $(OUT)/unlinked-openstack-xccdf.xml
	xsltproc -stringparam profile "stig-openstack-server" -o $(OUT)/unlinked-stig-openstack-xccdf.xml \
		$(TRANS)/xccdf2stigformat.xslt $(OUT)/unlinked-resolved-openstack-xccdf.xml 
	xsltproc -o $(OUT)/table-stig-openstack-server-stigformat.html \
		$(TRANS)/xccdf2table-stig.xslt $(OUT)/unlinked-stig-openstack-xccdf.xml
	xmllint --format --output $(OUT)/unlinked-stig-openstack-xccdf.xml $(OUT)/unlinked-stig-openstack-xccdf.xml 
	$(TRANS)/cpe_generate.py $(OUT)/unlinked-openstack-oval.xml $(IN)/checks/platform/openstack-cpe-dictionary.xml disa-predraft
	$(TRANS)/relabelids.py unlinked-stig-openstack-xccdf.xml disa-predraft
	xmllint --format --output $(OUT)/disa-predraft-stig-openstack-xccdf.xml $(OUT)/disa-predraft-stig-openstack-xccdf.xml

submission-stig-check: table-stigs
	cd output; ../$(UTILS)/verify-references.py -p stig-openstack-server --rules-with-disarefs-outside-profile unlinked-openstack-xccdf-prerefs.xml
#	$(TRANS)/xccdf2csv-stig.py $(OUT)/unlinked-stig-openstack-xccdf.xml > $(OUT)/table-stig.csv

# content-usgcb: coming soon

validate:
	oscap xccdf validate-xml $(OUT)/$(ID)-openstack-xccdf.xml
	oscap oval validate-xml $(OUT)/$(ID)-openstack-oval.xml
	oscap oval validate-xml $(OUT)/$(ID)-openstack-cpe-oval.xml

eval-test:
	oscap xccdf eval --profile test $(OUT)/$(ID)-openstack-xccdf.xml

eval-ftp:
	oscap xccdf eval --profile ftp $(OUT)/$(ID)-openstack-xccdf.xml

eval-common:
	oscap xccdf eval --profile common --oval-results --results /tmp/results-test.xml $(OUT)/$(ID)-openstack-xccdf.xml

# items in dist are expected for distribution in an rpm
dist: tables guide content
	mkdir -p $(DIST)/guide $(DIST)/content $(DIST)/policytables
	cp $(OUT)/*-guide.html $(DIST)/guide
	cp $(OUT)/$(ID)-openstack-xccdf.xml $(DIST)/content
	cp $(OUT)/$(ID)-openstack-oval.xml $(DIST)/content
	cp $(OUT)/$(ID)-openstack-cpe-dictionary.xml $(DIST)/content
	cp $(OUT)/$(ID)-openstack-cpe-oval.xml $(DIST)/content
	cp $(OUT)/table-openstack-* $(DIST)/policytables

#install:
#	cp -r openstack/src/dist/* /usr/share/scap-security-guide/openstack

clean:
	rm -f $(OUT)/*.xml $(OUT)/*.html $(OUT)/*.pdf  $(OUT)/*.spec $(OUT)/*.tar $(OUT)/*.gz $(OUT)/*.ini
	rm -rf $(DIST)/content $(DIST)/policytables $(DIST)/guide
