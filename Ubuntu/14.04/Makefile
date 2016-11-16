all: tables guide content dist

SHARED = ../../shared
include $(SHARED)/product-make.include

PROD = ubuntu1404
OVAL_DIRS = $(SHARED_OVAL) $(OUT)/oval templates/static/oval
VENDOR = ssgproject

checks:
	# If openscap on the system supports OVAL-5.11 language version, include also OVAL-5.11 checks
	# add local Ubuntu1404 specific templated ovals
	# into final list of OVAL checks
ifeq ($(OVAL_5_11), 0)
	# System supports OVAL-5.11 => propagate 'RUNTIME_OVAL_VERSION' variable into the environment
	$(eval MOD_ENV := env RUNTIME_OVAL_VERSION='5.11')
	$(eval OVAL_DIRS+=$(SHARED_OVAL_5_11) $(OUT)/oval templates/static/oval_5.11)
endif
	find $(OVAL_DIRS) -name "*.xml" | xargs xmlwf
	$(SHARED)/utils/generate-from-templates.py --oval_version $(OVAL_VERSION) --input ./templates --output $(OUT) --language oval build
	$(MOD_ENV) $(SHARED)/$(UTILS)/combine-ovals.py $(CONF) $(PROD) $(OVAL_DIRS) > $(OUT)/unlinked-$(PROD)-oval.xml
	xmllint --format --output $(OUT)/unlinked-$(PROD)-oval.xml $(OUT)/unlinked-$(PROD)-oval.xml

table-refs: $(OUT)/xccdf-unlinked-empty-groups.xml
	xsltproc -stringparam ref "nist" -o $(OUT)/table-$(PROD)-nistrefs.html $(TRANS)/xccdf2table-byref.xslt $<
	xsltproc -stringparam profile "common" -o $(OUT)/table-$(PROD)-nistrefs-common.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $<
	xsltproc -stringparam profile "ospp-$(PROD)-server" -o $(OUT)/table-$(PROD)-nistrefs-ospp.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $<
	xsltproc -stringparam ref "anssi" -o $(OUT)/table-$(PROD)-anssirefs.html $(TRANS)/xccdf2table-byref.xslt $<
	xsltproc -stringparam profile "common" -o $(OUT)/table-$(PROD)-anssirefs-common.html \
		$(TRANS)/xccdf2table-profileanssirefs.xslt $<

table-idents: $(OUT)/xccdf-unlinked-empty-groups.xml
	xsltproc -o $(OUT)/table-$(PROD)-cces.html $(TRANS)/xccdf2table-cce.xslt $<

table-srgmap: $(OUT)/xccdf-unlinked-empty-groups.xml
# the map-to-items filename must be provided relative to the root of the main document being processed
	xsltproc -stringparam map-to-items "../$<" -o $(OUT)/table-$(PROD)-srgmap.html \
		$(TRANS)/table-srgmap.xslt $(REFS)/disa-os-srg-v1r4.xml
	xsltproc -stringparam flat "y" -stringparam map-to-items "../$<" -o $(OUT)/table-$(PROD)-srgmap-flat.html \
		$(TRANS)/table-srgmap.xslt $(REFS)/disa-os-srg-v1r4.xml
	xmllint --xmlout --html --output $(OUT)/table-$(PROD)-srgmap-flat.xhtml $(OUT)/table-$(PROD)-srgmap-flat.html

table-stigs: $(OUT)/xccdf-unlinked-final.xml table-srgmap checks
	xsltproc -o $(OUT)/table-$(PROD)-stig.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-$(PROD)-v1r0.6-xccdf.xml
	xsltproc -o $(OUT)/table-$(PROD)-stig-manual.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-$(PROD)-v1r0.6-xccdf-manual.xml
#	temporarily retain an output file showing the short titles as well
	xsltproc -stringparam profile "stig-$(PROD)-server" -stringparam testinfo "y" -o $(OUT)/table-stig-$(PROD)-testinfo.html \
		$(TRANS)/xccdf2table-profileccirefs.xslt $<
	xsltproc -stringparam overlay "../$(IN)/auxiliary/stig_overlay.xml" -o $(OUT)/unlinked-stig-$(PROD)-xccdf.xml \
		$(TRANS)/xccdf-apply-overlay-stig.xslt $<
	xsltproc -o $(OUT)/table-$(PROD)-stig.html $(TRANS)/xccdf2table-stig.xslt $(OUT)/unlinked-stig-$(PROD)-xccdf.xml

tables: table-refs table-idents table-srgmap

content: $(OUT)/xccdf-unlinked-final.xml checks
	cp $< $(OUT)/unlinked-$(PROD)-xccdf.xml
#	Remove auxiliary Groups which are only for use in tables, and not guide output.
	xsltproc -o $(OUT)/unlinked-$(PROD)-xccdf-guide.xml $(TRANS)/xccdf-removeaux.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
#	The relabel-ids.py script chdirs to ./output, so refer to files from there.
#	Its second argument controls the IDs, as well as the output filenames.
#	Thus, with ID set to ssg, this creates ssg-$(PROD)-xccdf.xml and ssg-$(PROD)-oval.xml.
	$(SHARED)/$(UTILS)/cpe-generate.py $(OUT)/unlinked-$(PROD)-oval.xml $(IN)/oval/platform/$(PROD)-cpe-dictionary.xml $(ID)
	$(SHARED)/$(UTILS)/relabel-ids.py unlinked-$(PROD)-xccdf.xml $(ID)
	$(SHARED)/$(UTILS)/relabel-ids.py xccdf-unlinked-ocilrefs.xml $(ID)
#	Once things are relabelled, create a datastream
	xsltproc --stringparam reverse_DNS org.$(VENDOR).content /usr/share/openscap/xsl/xccdf_1.1_to_1.2.xsl \
		$(OUT)/$(ID)-$(PROD)-xccdf.xml > $(OUT)/$(ID)-$(PROD)-xccdf-1.2.xml
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
	$(SHARED)/$(UTILS)/sds-move-ocil-to-checks.py $(OUT)/$(ID)-$(PROD)-ds.xml $(OUT)/$(ID)-$(PROD)-ds.xml

guide: content
ifeq ($(OPENSCAP_1_1_OR_LATER), 0)
	$(SHARED)/$(UTILS)/build-all-guides.py --input $(OUT)/$(ID)-$(PROD)-ds.xml
else
	@echo "Building guides from XCCDF 1.1, use OpenSCAP 1.1.0 or later for guides from datastreams!"
	$(SHARED)/$(UTILS)/build-all-guides.py --input $(OUT)/$(ID)-$(PROD)-xccdf.xml
endif

validate-xml:
	oscap xccdf validate-xml $(OUT)/$(ID)-$(PROD)-xccdf.xml
	oscap oval validate-xml $(OUT)/$(ID)-$(PROD)-oval.xml
	oscap cpe validate-xml $(OUT)/$(ID)-$(PROD)-cpe-dictionary.xml
#	not yet clean. To be updated
#	oscap oval validate-xml $(OUT)/$(ID)-$(PROD)-cpe-oval.xml
#	oscap ds sds-validate $(OUT)/$(ID)-$(PROD)-ds.xml

validate: validate-xml
ifeq ($(OVAL_5_11), 0)
	cd $(OUT); ../$(SHARED)/$(UTILS)/verify-references.py --rules-with-invalid-checks --ovaldefs-unused $(ID)-$(PROD)-xccdf.xml
else
	# If we are building against oscap version not supporting OVAL-5.11 language version yet,
	# don't call verify-references.py with "--rules-with-invalid-checks" argument, since the
	# OVAL checks using the 5.11 OVAL version will not be included in that case
	@echo -e "\nWarning:\n"
	@echo -e "\tUbuntu 1404 content build using oscap not supporting OVAL-5.11 language version detected!"
	@echo -e "\tSince the OVAL-5.11 Fedora OVAL checks are missing, will skip test for referenced,"
	@echo -e "\tbut undefined OVAL definitions during content validation. Consider building Ubuntu 1404"
	@echo -e "\tcontent with version OpenSCAP-1.2.2, or newer in order to perform full content validation!\n"
	cd $(OUT); ../$(SHARED)/$(UTILS)/verify-references.py --ovaldefs-unused $(ID)-$(PROD)-xccdf.xml
endif
	oscap oval validate-xml --schematron $(OUT)/$(ID)-$(PROD)-oval.xml

# Items in dist are expected for distribution in an rpm
dist: guide content
	mkdir -p $(DIST)/guide $(DIST)/content
	cp $(OUT)/*-guide-*.html $(DIST)/guide
	cp $(OUT)/$(ID)-$(PROD)-xccdf.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-oval.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-ocil.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-cpe-dictionary.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-cpe-oval.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-ds.xml $(DIST)/content

clean:
	rm -f $(OUT)/*.xml $(OUT)/*.html $(OUT)/*.xhtml $(OUT)/*.pdf  $(OUT)/*.spec $(OUT)/*.tar $(OUT)/*.gz $(OUT)/*.ini $(OUT)/*.csv
	rm -rf $(DIST)/content $(DIST)/guide
	rm -rf $(OUT)/bash $(OUT)/ansible $(OUT)/oval
	rm -rf $(BUILD)
