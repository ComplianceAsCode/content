all: guide content dist

# Do not remove exporting of SHARED variable!!! (since
# shared/transforms/combineremediations.py helper
# requires its value to be available)
export SHARED = ../shared
include $(SHARED)/product-make.include

PROD = docker
VENDOR = ssgproject

checks:
	xmlwf $(IN)/oval/*.xml
	$(SHARED)/$(TRANS)/combineovals.py $(CONF) $(PROD) $(IN)/oval > $(OUT)/unlinked-$(PROD)-oval.xml
	xmllint --format --output $(OUT)/unlinked-$(PROD)-oval.xml $(OUT)/unlinked-$(PROD)-oval.xml

content: $(OUT)/xccdf-unlinked-final.xml checks
	cp $< $(OUT)/unlinked-$(PROD)-xccdf.xml
#	Remove auxiliary Groups which are only for use in tables, and not guide output.
	xsltproc -o $(OUT)/unlinked-$(PROD)-xccdf-guide.xml $(TRANS)/xccdf-removeaux.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
#	The relabelids.py script chdirs to ./output, so refer to files from there.
#	its second argument controls the IDs, as well as the output filenames.
#	thus, with ID set to ssg, this creates ssg-$(PROD)-xccdf.xml and ssg-$(PROD)-oval.xml.
	$(SHARED)/$(TRANS)/cpe_generate.py $(OUT)/unlinked-$(PROD)-oval.xml $(IN)/oval/platform/$(PROD)-cpe-dictionary.xml $(ID)
	$(SHARED)/$(TRANS)/relabelids.py unlinked-$(PROD)-xccdf.xml $(ID)
	$(SHARED)/$(TRANS)/relabelids.py xccdf-unlinked-ocilrefs.xml $(ID)
#	Expand 'test_attestation' URLs in OVAL document to valid SSG Contributors wiki link (fixes RHBZ#1155809 for OVAL)
	xsltproc -o $(OUT)/$(ID)-$(PROD)-oval.xml $(TRANS)/oval-fix-test-attestation-urls.xslt $(OUT)/$(ID)-$(PROD)-oval.xml
#	Once things are relabelled, create a datastream
	xsltproc /usr/share/openscap/xsl/xccdf_1.1_remove_dangling_sub.xsl $(OUT)/$(ID)-$(PROD)-xccdf.xml \
		> $(OUT)/$(ID)-$(PROD)-xccdf-nodangles.xml
	xsltproc --stringparam reverse_DNS org.$(VENDOR).content /usr/share/openscap/xsl/xccdf_1.1_to_1.2.xsl \
		$(OUT)/$(ID)-$(PROD)-xccdf-nodangles.xml > $(OUT)/$(ID)-$(PROD)-xccdf-1.2.xml
	sed -i '/idref="dangling reference to /d' $(OUT)/$(ID)-$(PROD)-xccdf-1.2.xml
#	Update @style attribute of <xccdf:Benchmark> to "SCAP_1.2". Fixes #1059
	sed -i 's/style="SCAP_1.1"/style="SCAP_1.2"/' $(OUT)/$(ID)-$(PROD)-xccdf-1.2.xml
	oscap ds sds-compose $(OUT)/$(ID)-$(PROD)-xccdf-1.2.xml $(OUT)/$(ID)-$(PROD)-ds.xml
#	Update @schematron-version attribute in datastream to "1.2". Fixes #1191
#	(Workaround for https://github.com/OpenSCAP/openscap/issues/383)
	sed -i 's/schematron-version="[0-9].[0-9]"/schematron-version="1.2"/' $(OUT)/$(ID)-$(PROD)-ds.xml
#	Add in CPE and OVAL content to datastream
	oscap ds sds-add $(OUT)/$(ID)-$(PROD)-cpe-dictionary.xml $(OUT)/$(ID)-$(PROD)-ds.xml
	oscap ds sds-add $(OUT)/$(ID)-$(PROD)-oval.xml $(OUT)/$(ID)-$(PROD)-ds.xml
	# Fixes https://github.com/OpenSCAP/scap-security-guide/issues/1100
	# Fixes https://github.com/OpenSCAP/scap-security-guide/issues/1101
	$(SHARED)/$(TRANS)/datastream_move_ocil_to_ds_checks.py $(OUT)/$(ID)-$(PROD)-ds.xml $(OUT)/$(ID)-$(PROD)-ds.xml

guide: content
ifeq ($(OPENSCAP_1_1_OR_LATER), 0)
	$(SHARED)/$(UTILS)/build-all-guides.py --input $(OUT)/$(ID)-$(PROD)-ds.xml
else
	@echo "Building guides from XCCDF 1.1, use OpenSCAP 1.1.0 or later for guides from datastreams!"
	$(SHARED)/$(UTILS)/build-all-guides.py --input $(OUT)/$(ID)-$(PROD)-xccdf.xml
endif

validate-xml:
	oscap xccdf validate-xml $(OUT)/$(ID)-$(PROD)-xccdf.xml
	oscap oval validate-xml --schematron $(OUT)/$(ID)-$(PROD)-oval.xml
	oscap ds sds-validate $(OUT)/$(ID)-$(PROD)-ds.xml

validate: validate-xml
	cd $(OUT); ../$(SHARED)/$(UTILS)/verify-references.py --rules-with-invalid-checks --ovaldefs-unused ssg-$(PROD)-xccdf.xml

eval-common:
	oscap xccdf eval --profile common --oval-results --results /tmp/results-test.xml $(OUT)/$(ID)-$(PROD)-xccdf.xml

# Items in dist are expected for distribution in an rpm
dist: guide content
	mkdir -p $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-xccdf.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-oval.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-ds.xml $(DIST)/content
	mkdir -p $(DIST)/guide
	cp $(OUT)/*-guide-*.html $(DIST)/guide

clean:
	rm -f $(OUT)/*.xml $(OUT)/*.html $(OUT)/*.xhtml $(OUT)/*.pdf  $(OUT)/*.spec $(OUT)/*.tar $(OUT)/*.gz $(OUT)/*.ini $(OUT)/*.csv
	rm -rf $(DIST)/content $(DIST)/guide
	rm -rf $(BUILD)
