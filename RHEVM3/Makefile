all: tables guide checks content dist

SHARED = ../shared
include $(SHARED)/product-make.include

# todo: remove this local override of REFS variable
REFS = references

PROD = rhevm3

checks:
	xmlwf $(IN)/oval/*.xml
	$(SHARED)/$(TRANS)/combineovals.py $(CONF) $(PROD) $(IN)/oval > $(OUT)/unlinked-$(PROD)-oval.xml
	xmllint --format --output $(OUT)/unlinked-$(PROD)-oval.xml $(OUT)/unlinked-$(PROD)-oval.xml

# example, if needed: for converting XCCDF into shorthand
#xccdf2shorthand:
#	xsltproc -o $(XCCDF_OUTPUT_DIR)/rhel5-shorthand.xml $(TRANS)/xccdf2shorthand.xslt $(REFS)/usgcb-rhel5desktop-xccdf.xml
#	tidy -m -xml -utf8 --indent-spaces=0 $(XCCDF_OUTPUT_DIR)/rhel5-shorthand.xml

table-profilenistrefs: $(OUT)/xccdf-unlinked-final.xml
	xsltproc -stringparam profile "desktop" -o $(OUT)/table-$(PROD)-nistrefs-desktop.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $<
	xsltproc -stringparam profile "server" -o $(OUT)/table-$(PROD)-nistrefs-server.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $<
	xsltproc -stringparam profile "common" -o $(OUT)/table-$(PROD)-nistrefs-common.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $<
	xsltproc -stringparam profile "ftp" -o $(OUT)/table-$(PROD)-nistrefs-ftp.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $<

table-refs: $(OUT)/xccdf-unlinked-final.xml
	xsltproc -stringparam ref "nist" -o $(OUT)/table-$(PROD)-nistrefs.html $(TRANS)/xccdf2table-byref.xslt $<
# break apart references by delimiter:
	xsltproc -stringparam ref "nist" -stringparam delim "," -o $(OUT)/table-$(PROD)-nistrefs-delim.html $(TRANS)/xccdf2table-byref.xslt $<
# then sort them:
	xsltproc --html -o $(OUT)/table-$(PROD)-nistrefs-delim-sorted.html $(TRANS)/table-sortbyref.xslt $(OUT)/table-$(PROD)-nistrefs-delim.html

table-idents: $(OUT)/xccdf-unlinked-final.xml
	xsltproc -o $(OUT)/table-$(PROD)-cces.html $(TRANS)/xccdf2table-cce.xslt $<
	xsltproc -stringparam ref "../$(REFS)/cce-rhel5.xml" -o $(OUT)/table-$(PROD)-cces-rhel5.html $(TRANS)/xccdf2table-cce.xslt $<

table-srgmap: $(OUT)/xccdf-unlinked-final.xml
# the map-to-items filename must be provided relative to the root of the main document being processed
	xsltproc -stringparam map-to-items "../$<" -o $(OUT)/table-$(PROD)-srgmap.html \
		$(TRANS)/table-srgmap.xslt $(REFS)/U_Application_SRG_V1R1_Manual-xccdf.xml
	xsltproc -stringparam flat "y" -stringparam map-to-items "../$<" -o $(OUT)/table-$(PROD)-srgmap-flat.html \
		$(TRANS)/table-srgmap.xslt $(REFS)/U_Application_SRG_V1R1_Manual-xccdf.xml
	xmllint --xmlout --html --output $(OUT)/table-$(PROD)-srgmap-flat.xhtml $(OUT)/table-$(PROD)-srgmap-flat.html

table-stigs: $(OUT)/xccdf-unlinked-final.xml table-srgmap checks
	xsltproc -stringparam alttitles "../$(IN)/auxiliary/alt-titles-stig.xml" -o $< \
		$(TRANS)/xccdf-alt-titles.xslt \
		$<
	xsltproc -stringparam profile "stig-$(PROD)-server" -o $(OUT)/unlinked-stig-$(PROD)-xccdf.xml \
		$(TRANS)/xccdf2stigformat.xslt $<
	xsltproc -o $(OUT)/table-stig-$(PROD)-server-stigformat.html \
		$(TRANS)/xccdf2table-stig.xslt $(OUT)/unlinked-stig-$(PROD)-xccdf.xml

tables: table-refs table-idents table-profilenistrefs table-srgmap

alt-titles: $(OUT)/xccdf-unlinked-final.xml
	$(UTILS)/sync-alt-titles.py -p stig-$(PROD)-server -f $(IN)/auxiliary/alt-titles-stig.xml $<
	XMLLINT_INDENT="" xmllint --format --output $(IN)/auxiliary/alt-titles-stig.xml $(IN)/auxiliary/alt-titles-stig.xml

content: $(OUT)/xccdf-unlinked-final.xml checks
	cp $< $(OUT)/unlinked-$(PROD)-xccdf.xml
#	Remove auxiliary Groups which are only for use in tables, and not guide output.
	xsltproc -o $(OUT)/unlinked-$(PROD)-xccdf-guide.xml $(TRANS)/xccdf-removeaux.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
#	The relabelids.py script chdirs to ./output, so refer to files from there.
#	Its second argument controls the IDs, as well as the output filenames.
#	Thus, with ID set to ssg, this creates ssg-$(PROD)-xccdf.xml and ssg-$(PROD)-oval.xml.
	$(SHARED)/$(TRANS)/cpe_generate.py $(OUT)/unlinked-$(PROD)-oval.xml $(IN)/oval/platform/$(PROD)-cpe-dictionary.xml $(ID)
	$(SHARED)/$(TRANS)/relabelids.py unlinked-$(PROD)-xccdf.xml $(ID)
	$(SHARED)/$(TRANS)/relabelids.py xccdf-unlinked-ocilrefs.xml $(ID)
#	Expand 'test_attestation' URLs in OVAL document to valid SSG Contributors wiki link (fixes RHBZ#1155809 for OVAL)
	xsltproc -o $(OUT)/$(ID)-$(PROD)-oval.xml $(TRANS)/oval-fix-test-attestation-urls.xslt $(OUT)/$(ID)-$(PROD)-oval.xml

# not ready until oscap resolve behavior resolved
content-stig: table-stigs guide checks
	xmllint --format --output $(OUT)/unlinked-stig-$(PROD)-xccdf.xml $(OUT)/unlinked-stig-$(PROD)-xccdf.xml
	$(SHARED)/$(TRANS)/cpe_generate.py $(OUT)/unlinked-$(PROD)-oval.xml $(IN)/oval/platform/$(PROD)-cpe-dictionary.xml disa-predraft
	$(SHARED)/$(TRANS)/relabelids.py unlinked-stig-$(PROD)-xccdf.xml disa-predraft
	xmllint --format --output $(OUT)/disa-predraft-stig-$(PROD)-xccdf.xml $(OUT)/disa-predraft-stig-$(PROD)-xccdf.xml

guide: content
	# TODO: Build datastreams, generate guides from datastreams if possible
	$(SHARED)/$(UTILS)/build-all-guides.py --input $(OUT)/$(ID)-$(PROD)-xccdf.xml

submission-stig-check: table-stigs
	cd $(OUT); ../$(SHARED)/$(UTILS)/verify-references.py -p stig-$(PROD)-server \
		--rules-with-disarefs-outside-profile unlinked-$(PROD)-xccdf-prerefs.xml
#	$(TRANS)/xccdf2csv-stig.py $(OUT)/unlinked-stig-$(PROD)-xccdf.xml > $(OUT)/table-stig.csv

validate-xml:
	oscap xccdf validate-xml $(OUT)/$(ID)-$(PROD)-xccdf.xml
	oscap oval validate-xml --schematron $(OUT)/$(ID)-$(PROD)-oval.xml
	oscap cpe validate-xml $(OUT)/$(ID)-$(PROD)-cpe-dictionary.xml
	oscap oval validate-xml --schematron $(OUT)/$(ID)-$(PROD)-cpe-oval.xml

validate: validate-xml
	cd $(OUT); ../$(SHARED)/$(UTILS)/verify-references.py --rules-with-invalid-checks --ovaldefs-unused ssg-$(PROD)-xccdf.xml

eval-test:
	oscap xccdf eval --profile test $(OUT)/$(ID)-$(PROD)-xccdf.xml

eval-ftp:
	oscap xccdf eval --profile ftp $(OUT)/$(ID)-$(PROD)-xccdf.xml

eval-common:
	oscap xccdf eval --profile common --oval-results --results /tmp/results-test.xml $(OUT)/$(ID)-$(PROD)-xccdf.xml

# Items in dist are expected for distribution in an rpm
dist: tables guide content
	mkdir -p $(DIST)/guide $(DIST)/content $(DIST)/policytables
	cp $(OUT)/*-guide-*.html $(DIST)/guide
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
