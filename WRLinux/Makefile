all: guide content dist

SHARED = ../shared
include $(SHARED)/product-make.include

PROD = wrlinux
VENDOR = ssgproject

checks: standard-oval-build

content: $(OUT)/xccdf-unlinked-final.xml checks
	cp $< $(OUT)/unlinked-$(PROD)-xccdf.xml
#	Remove auxiliary Groups which are only for use in tables, and not guide output.
	xsltproc -o $(OUT)/unlinked-$(PROD)-xccdf-guide.xml $(TRANS)/xccdf-removeaux.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
	$(SHARED)/$(TRANS)/cpe_generate.py $(OUT)/unlinked-$(PROD)-oval.xml $(IN)/oval/platform/$(PROD)-cpe-dictionary.xml $(ID)
	$(SHARED)/$(TRANS)/relabelids.py unlinked-$(PROD)-xccdf.xml $(ID)
#	Once things are relabelled, create a datastream
	xsltproc --stringparam reverse_DNS org.$(VENDOR).content /usr/share/openscap/xsl/xccdf_1.1_to_1.2.xsl \
		$(OUT)/$(ID)-$(PROD)-xccdf.xml > $(OUT)/$(ID)-$(PROD)-xccdf-1.2.xml
#	Update @style attribute of <xccdf:Benchmark> to "SCAP_1.2". Fixes #1059
	sed -i 's/style="SCAP_1.1"/style="SCAP_1.2"/' $(OUT)/$(ID)-$(PROD)-xccdf-1.2.xml
	oscap ds sds-compose $(OUT)/$(ID)-$(PROD)-xccdf-1.2.xml $(OUT)/$(ID)-$(PROD)-ds.xml
#	Update @schematron-version attribute in datastream to "1.2". Fixes #1191
#	(Workaround for https://github.com/OpenSCAP/openscap/issues/383)
	sed -i 's/schematron-version="[0-9].[0-9]"/schematron-version="1.2"/' $(OUT)/$(ID)-$(PROD)-ds.xml
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

validate: validate-xml validate-bash
ifeq ($(OVAL_5_11), 0)
	cd $(OUT); ../$(SHARED)/$(UTILS)/verify-references.py --rules-with-invalid-checks --ovaldefs-unused $(ID)-$(PROD)-xccdf.xml
else
	# If we are building against oscap version not supporting OVAL-5.11 language version yet,
	# don't call verify-references.py with "--rules-with-invalid-checks" argument, since the
	# OVAL checks using the 5.11 OVAL version will not be included in that case
	@echo -e "\nWarning:\n"
	@echo -e "\tWRLinux content build using oscap not supporting OVAL-5.11 language version detected!"
	@echo -e "\tSince the OVAL-5.11 WRLinux OVAL checks are missing, will skip test for referenced,"
	@echo -e "\tbut undefined OVAL definitions during content validation. Consider building WRLinux"
	@echo -e "\tcontent with version OpenSCAP-1.2.2, or newer in order to perform full content validation!\n"
	cd $(OUT); ../$(SHARED)/$(UTILS)/verify-references.py --ovaldefs-unused $(ID)-$(PROD)-xccdf.xml
endif

# Items in dist are expected for distribution in an rpm
dist: guide content
	mkdir -p $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-xccdf.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-oval.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-ocil.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-ds.xml $(DIST)/content
	mkdir -p $(DIST)/guide
	cp $(OUT)/*-guide-*.html $(DIST)/guide

clean:
	rm -f $(OUT)/*.xml $(OUT)/*.html $(OUT)/*.xhtml $(OUT)/*.pdf  $(OUT)/*.spec $(OUT)/*.tar $(OUT)/*.gz $(OUT)/*.ini $(OUT)/*.csv
	rm -f $(IN)/remediations/bash/templates/output/*.sh
	$(SHARED)/utils/generate-from-templates.py --output ./templates clean
	rm -rf $(DIST)/content $(DIST)/guide
	rm -rf $(BUILD)
