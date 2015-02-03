IN = input
OUT = output
TRANS = transforms
SHARED = ../shared
REFS = references
CONF = ../config
UTILS = utils
DIST = dist

ID = ssg
PROD = openstack

OPENSCAP_SVG := $(shell $(TRANS)/oscapsupportssvg.py; echo $$?)

all: shorthand2xccdf tables guide checks content dist

shorthand-guide:
ifeq ($(OPENSCAP_SVG), 0)
	xsltproc -o $(OUT)/guide.xml $(TRANS)/includelogo.xslt $(IN)/guide.xml
	xsltproc -o $(OUT)/$(PROD)-shorthand.xml $(IN)/guide.xslt $(OUT)/guide.xml
else
	xsltproc -o $(OUT)/$(PROD)-shorthand.xml $(IN)/guide.xslt $(IN)/guide.xml
endif
	xmllint --format --output $(OUT)/$(PROD)-shorthand.xml $(OUT)/$(PROD)-shorthand.xml

shorthand2xccdf: shorthand-guide
	xsltproc -o $(OUT)/unlinked-noprofiles-$(PROD)-shorthand.xml $(TRANS)/shorthand2xccdf.xslt $(OUT)/$(PROD)-shorthand.xml
	xsltproc -o $(OUT)/unlinked-noprofiles-$(PROD)-xccdf.xml $(TRANS)/add_xccdf_namespace.xslt $(OUT)/unlinked-noprofiles-$(PROD)-shorthand.xml
	xsltproc -stringparam profile "allprofiles" -o $(OUT)/unlinked-$(PROD)-xccdf-prerefs.xml \
		$(TRANS)/xccdf-addprofiles.xslt $(OUT)/unlinked-noprofiles-$(PROD)-xccdf.xml
	xsltproc -stringparam profile "stig-$(PROD)-server" -o $(OUT)/unlinked-$(PROD)-xccdf.xml \
		$(TRANS)/xccdf-addrefs.xslt $(OUT)/unlinked-$(PROD)-xccdf-prerefs.xml
#   extract manual check instructions from xccdf into an ocil file
	xsltproc -o $(OUT)/unlinked-$(PROD)-ocil.xml $(TRANS)/xccdf-create-ocil.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
	xmllint --format --output $(OUT)/unlinked-$(PROD)-ocil.xml $(OUT)/unlinked-$(PROD)-ocil.xml
	xsltproc -o $(OUT)/unlinked-ocilrefs-$(PROD)-xccdf.xml $(TRANS)/xccdf-ocilcheck2ref.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
	$(SHARED)/$(TRANS)/combinefixes.py $(IN)/fixes/bash/ $(OUT)/bash-remediations.xml
	xsltproc -stringparam fixes "../$(OUT)/bash-remediations.xml" -o $(OUT)/unlinked-$(PROD)-xccdf.xml $(TRANS)/xccdf-addfixes.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
	xmllint --format --output $(OUT)/unlinked-$(PROD)-xccdf.xml $(OUT)/unlinked-$(PROD)-xccdf.xml

checks:
	xmlwf $(IN)/checks/*.xml
	$(SHARED)/$(TRANS)/combinechecks.py $(CONF) $(IN)/checks > $(OUT)/unlinked-$(PROD)-oval.xml
	xmllint --format --output $(OUT)/unlinked-$(PROD)-oval.xml $(OUT)/unlinked-$(PROD)-oval.xml

guide: shorthand2xccdf
#	remove auxiliary Groups which are only for use in tables, and not guide output.
#	specifying a nonexistent profile, "allrules," to make oscap print all Rules
	xsltproc -o $(OUT)/unlinked-$(PROD)-xccdf-guide.xml $(TRANS)/xccdf-removeaux.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
#	
#	Begin Guide Creation
#	NOTE:	If you do not follow the $(profile)-guide.html syntax
#		you will manually have to include your guide in the
#		make dist section
#
	oscap xccdf generate guide --profile stig-$(PROD)-server $(OUT)/unlinked-$(PROD)-xccdf-guide.xml > $(OUT)/stig-$(PROD)-server-guide.html

# example, if needed: for converting XCCDF into shorthand
#xccdf2shorthand:
#	xsltproc -o $(XCCDF_OUTPUT_DIR)/rhel5-shorthand.xml $(TRANS)/xccdf2shorthand.xslt $(REFS)/usgcb-rhel5desktop-xccdf.xml
#	tidy -m -xml -utf8 --indent-spaces=0 $(XCCDF_OUTPUT_DIR)/rhel5-shorthand.xml

table-profilenistrefs: shorthand2xccdf
	xsltproc -stringparam profile "desktop" -o $(OUT)/table-$(PROD)-nistrefs-desktop.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
	xsltproc -stringparam profile "server" -o $(OUT)/table-$(PROD)-nistrefs-server.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
	xsltproc -stringparam profile "common" -o $(OUT)/table-$(PROD)-nistrefs-common.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
	xsltproc -stringparam profile "ftp" -o $(OUT)/table-$(PROD)-nistrefs-ftp.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml

table-refs: shorthand2xccdf
	xsltproc -stringparam ref "nist" -o $(OUT)/table-$(PROD)-nistrefs.html $(TRANS)/xccdf2table-byref.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
# break apart references by delimiter:
	xsltproc -stringparam ref "nist" -stringparam delim "," -o $(OUT)/table-$(PROD)-nistrefs-delim.html $(TRANS)/xccdf2table-byref.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
# then sort them:
	xsltproc --html -o $(OUT)/table-$(PROD)-nistrefs-delim-sorted.html $(TRANS)/table-sortbyref.xslt $(OUT)/table-$(PROD)-nistrefs-delim.html

table-idents: shorthand2xccdf
	xsltproc -o $(OUT)/table-$(PROD)-cces.html $(TRANS)/xccdf2table-cce.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
	xsltproc -stringparam ref "../$(REFS)/cce-rhel5.xml" -o $(OUT)/table-$(PROD)-cces-rhel5.html $(TRANS)/xccdf2table-cce.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml

table-srgmap: shorthand2xccdf
# the map-to-items filename must be provided relative to the root of the main document being processed
	xsltproc -stringparam map-to-items "../$(OUT)/unlinked-$(PROD)-xccdf.xml" -o $(OUT)/table-$(PROD)-srgmap.html \
		$(TRANS)/table-srgmap.xslt $(REFS)/U_Application_SRG_V1R1_Manual-xccdf.xml
	xsltproc -stringparam flat "y" -stringparam map-to-items "../$(OUT)/unlinked-$(PROD)-xccdf.xml" -o $(OUT)/table-$(PROD)-srgmap-flat.html \
		$(TRANS)/table-srgmap.xslt $(REFS)/U_Application_SRG_V1R1_Manual-xccdf.xml
	xmllint --xmlout --html --output $(OUT)/table-$(PROD)-srgmap-flat.xhtml $(OUT)/table-$(PROD)-srgmap-flat.html

table-stigs: shorthand2xccdf table-srgmap
#	xsltproc -o $(OUT)/table-rhel5-stig.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-rhel5-v1r0.6-xccdf.xml
#	xsltproc -o $(OUT)/table-rhel5-stig-manual.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-rhel5-v1r0.6-xccdf-manual.xml
#	xsltproc --html -o $(OUT)/table-rhel5-stig-manual-ccisorted.html $(TRANS)/table-sortbyref.xslt $(OUT)/table-rhel5-stig-manual.html
#	xsltproc -stringparam notes "../$(IN)/auxiliary/transition_notes.xml" -o $(OUT)/table-rhel5-stig-manual-withnotes.html \
#		$(TRANS)/xccdf2table-stig.xslt \
#		$(REFS)/disa-stig-rhel5-v1r0.6-xccdf-manual.xml
#	temporarily retain an output file showing the short titles as well
#	xsltproc -stringparam profile "stig-$(PROD)-server" -stringparam testinfo "y" -o $(OUT)/table-stig-$(PROD)-server-shorttitles.html \
#		$(TRANS)/xccdf2table-profileccirefs.xslt \
#		$(OUT)/unlinked-$(PROD)-xccdf.xml
#	xsltproc -stringparam alttitles "../$(IN)/auxiliary/alt-titles-stig.xml" -o $(OUT)/unlinked-stig-$(PROD)-xccdf.xml \
#		$(TRANS)/xccdf-alt-titles.xslt \
#		$(OUT)/unlinked-$(PROD)-xccdf.xml
#	xsltproc -stringparam profile "stig-$(PROD)-server" -o $(OUT)/table-stig-$(PROD)-server.html \
#		$(TRANS)/xccdf2table-profileccirefs.xslt \
#		$(OUT)/unlinked-stig-$(PROD)-xccdf.xml
#	xsltproc --html -o $(OUT)/table-stig-$(PROD)-server.html $(TRANS)/table-add-vulnids.xslt $(OUT)/table-stig-$(PROD)-server.html
#	xsltproc -stringparam profile "stig-$(PROD)-server" -stringparam format "flat" -o $(OUT)/table-stig-$(PROD)-server-flat.html \
#		$(TRANS)/xccdf2table-profileccirefs.xslt \
#		$(OUT)/unlinked-stig-$(PROD)-xccdf.xml
#	xsltproc --novalid --html -o $(OUT)/table-stig-$(PROD)-server-flat-srgs.html $(TRANS)/table-add-srgitems.xslt $(OUT)/table-stig-$(PROD)-server-flat.html
#	xsltproc --novalid --html -o $(OUT)/table-stig-$(PROD)-server-srgs.html $(TRANS)/table-add-srgitems.xslt $(OUT)/table-stig-$(PROD)-server.html
#	xsltproc --html -o $(OUT)/table-stig-$(PROD)-server-flat.html $(TRANS)/table-add-vulnids.xslt $(OUT)/table-stig-$(PROD)-server-flat.html

tables: table-refs table-idents table-profilenistrefs table-srgmap table-stigs

alt-titles: shorthand2xccdf
	$(UTILS)/sync-alt-titles.py -p stig-$(PROD)-server -f $(IN)/auxiliary/alt-titles-stig.xml $(OUT)/unlinked-$(PROD)-xccdf.xml
	XMLLINT_INDENT="" xmllint --format --output $(IN)/auxiliary/alt-titles-stig.xml $(IN)/auxiliary/alt-titles-stig.xml

content: shorthand2xccdf guide checks
#	the relabelids.py script chdirs to ./output, so refer to files from there.
#	its second argument controls the IDs, as well as the output filenames.
#	thus, with ID set to ssg, this creates ssg-$(PROD)-xccdf.xml and ssg-$(PROD)-oval.xml.
	$(SHARED)/$(TRANS)/cpe_generate.py $(OUT)/unlinked-$(PROD)-oval.xml $(IN)/checks/platform/$(PROD)-cpe-dictionary.xml $(ID)
	$(SHARED)/$(TRANS)/relabelids.py unlinked-$(PROD)-xccdf.xml $(ID)
	$(SHARED)/$(TRANS)/relabelids.py unlinked-ocilrefs-$(PROD)-xccdf.xml $(ID)

# not ready until oscap resolve behavior resolved
content-stig: shorthand2xccdf guide checks
	xsltproc -stringparam alttitles "../$(IN)/auxiliary/alt-titles-stig.xml" -o $(OUT)/unlinked-$(PROD)-xccdf.xml \
		$(TRANS)/xccdf-alt-titles.xslt \
		$(OUT)/unlinked-$(PROD)-xccdf.xml
	oscap xccdf resolve -o $(OUT)/unlinked-resolved-$(PROD)-xccdf.xml $(OUT)/unlinked-$(PROD)-xccdf.xml
	xsltproc -stringparam profile "stig-$(PROD)-server" -o $(OUT)/unlinked-stig-$(PROD)-xccdf.xml \
		$(TRANS)/xccdf2stigformat.xslt $(OUT)/unlinked-resolved-$(PROD)-xccdf.xml
	xsltproc -o $(OUT)/table-stig-$(PROD)-server-stigformat.html \
		$(TRANS)/xccdf2table-stig.xslt $(OUT)/unlinked-stig-$(PROD)-xccdf.xml
	xmllint --format --output $(OUT)/unlinked-stig-$(PROD)-xccdf.xml $(OUT)/unlinked-stig-$(PROD)-xccdf.xml
	$(SHARED)/$(TRANS)/cpe_generate.py $(OUT)/unlinked-$(PROD)-oval.xml $(IN)/checks/platform/$(PROD)-cpe-dictionary.xml disa-predraft
	$(SHARED)/$(TRANS)/relabelids.py unlinked-stig-$(PROD)-xccdf.xml disa-predraft
	xmllint --format --output $(OUT)/disa-predraft-stig-$(PROD)-xccdf.xml $(OUT)/disa-predraft-stig-$(PROD)-xccdf.xml

submission-stig-check: table-stigs
	cd output; ../$(UTILS)/verify-references.py -p stig-$(PROD)-server --rules-with-disarefs-outside-profile unlinked-$(PROD)-xccdf-prerefs.xml
#	$(TRANS)/xccdf2csv-stig.py $(OUT)/unlinked-stig-$(PROD)-xccdf.xml > $(OUT)/table-stig.csv

# content-usgcb: coming soon

validate:
	oscap xccdf validate-xml $(OUT)/$(ID)-$(PROD)-xccdf.xml
	oscap oval validate-xml $(OUT)/$(ID)-$(PROD)-oval.xml
	oscap oval validate-xml $(OUT)/$(ID)-$(PROD)-cpe-oval.xml

eval-test:
	oscap xccdf eval --profile test $(OUT)/$(ID)-$(PROD)-xccdf.xml

eval-ftp:
	oscap xccdf eval --profile ftp $(OUT)/$(ID)-$(PROD)-xccdf.xml

eval-common:
	oscap xccdf eval --profile common --oval-results --results /tmp/results-test.xml $(OUT)/$(ID)-$(PROD)-xccdf.xml

# items in dist are expected for distribution in an rpm
dist: tables guide content
	mkdir -p $(DIST)/guide $(DIST)/content $(DIST)/policytables
	cp $(OUT)/*-guide.html $(DIST)/guide
	cp $(OUT)/$(ID)-$(PROD)-xccdf.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-oval.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-cpe-dictionary.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-cpe-oval.xml $(DIST)/content
	cp $(OUT)/table-$(PROD)-* $(DIST)/policytables

#install:
#	cp -r $(PROD)/src/dist/* /usr/share/scap-security-guide/$(PROD)

clean:
	rm -f $(OUT)/*.xml $(OUT)/*.html $(OUT)/*.pdf  $(OUT)/*.spec $(OUT)/*.tar $(OUT)/*.gz $(OUT)/*.ini
	rm -rf $(DIST)/content $(DIST)/policytables $(DIST)/guide
