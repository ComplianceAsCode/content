all: tables guide content dist

SHARED = ../shared
include $(SHARED)/product-make.include

PROD = webmin

# will uncomment after PR 452 gets merged
# also put stats into the all: target
# stats:
#	$(SHARED)/$(TRANS)/stats.sh

checks:
	xmlwf $(IN)/oval/*.xml
	$(SHARED)/$(TRANS)/combineovals.py $(CONF) $(PROD) $(IN)/oval > $(OUT)/unlinked-$(PROD)-oval.xml
	xmllint --format --output $(OUT)/unlinked-$(PROD)-oval.xml $(OUT)/unlinked-$(PROD)-oval.xml

# example, if needed: for converting XCCDF into shorthand
#xccdf2shorthand:
#	xsltproc -o $(XCCDF_OUTPUT_DIR)/rhel5-shorthand.xml $(TRANS)/xccdf2shorthand.xslt $(REFS)/usgcb-rhel5desktop-xccdf.xml
#	tidy -m -xml -utf8 --indent-spaces=0 $(XCCDF_OUTPUT_DIR)/rhel5-shorthand.xml

table-refs: $(OUT)/xccdf-unlinked-final.xml
	xsltproc -stringparam ref "nist" -o $(OUT)/table-$(PROD)-nistrefs.html $(TRANS)/xccdf2table-byref.xslt $<
	xsltproc -stringparam profile "common" -o $(OUT)/table-$(PROD)-nistrefs-common.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $<

table-idents: $(OUT)/xccdf-unlinked-final.xml
	xsltproc -o $(OUT)/table-$(PROD)-cces.html $(TRANS)/xccdf2table-cce.xslt $<

table-srgmap: $(OUT)/xccdf-unlinked-final.xml
# the map-to-items filename must be provided relative to the root of the main document being processed
	xsltproc -stringparam map-to-items "../$<" -o $(OUT)/table-$(PROD)-srgmap.html \
		$(TRANS)/table-srgmap.xslt $(REFS)/disa-os-srg-v1r1.xml
	xsltproc -stringparam flat "y" -stringparam map-to-items "../$<" -o $(OUT)/table-$(PROD)-srgmap-flat.html \
		$(TRANS)/table-srgmap.xslt $(REFS)/disa-os-srg-v1r1.xml
	xmllint --xmlout --html --output $(OUT)/table-$(PROD)-srgmap-flat.xhtml $(OUT)/table-$(PROD)-srgmap-flat.html

table-stigs: $(OUT)/xccdf-unlinked-final.xml table-srgmap checks
	xsltproc -o $(OUT)/table-rhel5-stig.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-rhel5-v1r0.6-xccdf.xml
	xsltproc -o $(OUT)/table-rhel5-stig-manual.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-rhel5-v1r0.6-xccdf-manual.xml
#	xsltproc -stringparam notes "../$(IN)/auxiliary/transition_notes.xml" -o $(OUT)/table-rhel5-stig-manual-withnotes.html \
#		$(TRANS)/xccdf2table-stig.xslt \
#		$(REFS)/disa-stig-rhel5-v1r0.6-xccdf-manual.xml
#	temporarily retain an output file showing the short titles as well
	xsltproc -stringparam profile "stig-$(PROD)-server-upstream" -stringparam testinfo "y" -o $(OUT)/table-stig-$(PROD)-testinfo.html \
		$(TRANS)/xccdf2table-profileccirefs.xslt $<
	xsltproc -stringparam overlay "../$(IN)/auxiliary/stig_overlay.xml" -o $(OUT)/unlinked-stig-$(PROD)-xccdf.xml \
		$(TRANS)/xccdf-apply-overlay-stig.xslt $<
	xsltproc -o $(OUT)/table-$(PROD)-stig.html $(TRANS)/xccdf2table-stig.xslt $(OUT)/unlinked-stig-$(PROD)-xccdf.xml

tables: table-refs table-idents table-stigs
#tables: table-refs table-idents table-srgmap table-stigs

content: $(OUT)/xccdf-unlinked-final.xml guide checks
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
#	Once things are relabelled, create a datastream
	xsltproc /usr/share/openscap/xsl/xccdf_1.1_remove_dangling_sub.xsl $(OUT)/$(ID)-$(PROD)-xccdf.xml \
		> $(OUT)/$(ID)-$(PROD)-xccdf-nodangles.xml
	xsltproc --stringparam reverse_DNS org.ssgproject.content /usr/share/openscap/xsl/xccdf_1.1_to_1.2.xsl \
		$(OUT)/$(ID)-$(PROD)-xccdf-nodangles.xml > $(OUT)/$(ID)-$(PROD)-xccdf-1.2.xml
	sed -i '/idref="dangling reference to /d' $(OUT)/$(ID)-$(PROD)-xccdf-1.2.xml
	oscap ds sds-compose $(OUT)/$(ID)-$(PROD)-xccdf-1.2.xml $(OUT)/$(ID)-$(PROD)-ds.xml
#	Add in CPE and OVAL content to datastream
	oscap ds sds-add $(OUT)/$(ID)-$(PROD)-cpe-dictionary.xml $(OUT)/$(ID)-$(PROD)-ds.xml
	oscap ds sds-add $(OUT)/$(ID)-$(PROD)-oval.xml $(OUT)/$(ID)-$(PROD)-ds.xml

content-stig: table-stigs guide checks
	xmllint --format --output $(OUT)/unlinked-stig-$(PROD)-xccdf.xml $(OUT)/unlinked-stig-$(PROD)-xccdf.xml
	$(SHARED)/$(TRANS)/cpe_generate.py $(OUT)/unlinked-$(PROD)-oval.xml $(IN)/oval/platform/$(PROD)-cpe-dictionary.xml disa-predraft
	$(SHARED)/$(TRANS)/relabelids.py unlinked-stig-$(PROD)-xccdf.xml disa-predraft
	xmllint --format --output $(OUT)/disa-predraft-stig-$(PROD)-xccdf.xml $(OUT)/disa-predraft-stig-$(PROD)-xccdf.xml

guide: content
ifeq ($(OPENSCAP_1_1_OR_LATER), 0)
	$(SHARED)/$(UTILS)/build-all-guides.py --input $(OUT)/$(ID)-$(PROD)-ds.xml
else
	@echo "Building guides from XCCDF 1.1, use OpenSCAP 1.1.0 or later for guides from datastreams!"
	$(SHARED)/$(UTILS)/build-all-guides.py --input $(OUT)/$(ID)-$(PROD)-xccdf.xml
endif

submission-stig-check: table-stigs
	cd $(OUT); ../$(SHARED)/$(UTILS)/verify-references.py -p stig-$(PROD)-server-upstream \
		--rules-with-disarefs-outside-profile unlinked-$(PROD)-xccdf-prerefs.xml
#	$(TRANS)/xccdf2csv-stig.py $(OUT)/unlinked-stig-$(PROD)-xccdf.xml > $(OUT)/table-stig.csv

# content-usgcb: coming soon

validate-xml:
	oscap xccdf validate-xml $(OUT)/$(ID)-$(PROD)-xccdf.xml
	oscap oval validate-xml --schematron $(OUT)/$(ID)-$(PROD)-oval.xml
	oscap cpe validate-xml $(OUT)/$(ID)-$(PROD)-cpe-dictionary.xml
	oscap oval validate-xml --schematron $(OUT)/$(ID)-$(PROD)-cpe-oval.xml
	oscap ds sds-validate $(OUT)/$(ID)-$(PROD)-ds.xml

validate: validate-xml
	cd $(OUT); ../$(SHARED)/$(UTILS)/verify-references.py --rules-with-invalid-checks --ovaldefs-unused ssg-$(PROD)-xccdf.xml

eval-test:
	oscap xccdf eval --profile test $(OUT)/$(ID)-$(PROD)-xccdf.xml

eval-common:
	oscap xccdf eval --profile common --oval-results --results /tmp/results-test.xml $(OUT)/$(ID)-$(PROD)-xccdf.xml

# Items in dist are expected for distribution in an rpm
dist: tables guide content
	mkdir -p $(DIST)/content $(DIST)/guide
	cp $(OUT)/$(ID)-$(PROD)-xccdf.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-oval.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-cpe-dictionary.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-cpe-oval.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-ds.xml $(DIST)/content
	cp $(OUT)/*-guide-*.html $(DIST)/guide

clean:
	rm -f $(OUT)/*.xml $(OUT)/*.html $(OUT)/*.xhtml $(OUT)/*.pdf  $(OUT)/*.spec $(OUT)/*.tar $(OUT)/*.gz $(OUT)/*.ini $(OUT)/*.csv
	rm -rf $(DIST)/content
