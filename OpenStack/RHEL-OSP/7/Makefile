all: tables guide content dist

SHARED = ../../../shared
include $(SHARED)/product-make.include

PROD = rhel-osp7
OVAL_DIRS = $(IN)/oval
VENDOR = ssgproject

checks:
	# Don't traverse $(SHARED_OVAL) for the case of RHEL-OSP7 product for now
ifeq ($(OVAL_5_11), 0)
	# Search $(SHARED_OVAL_5_11) and $(IN)/oval/oval_5.11 directories to find all product specific
	# OVAL-5.11 checks, which are regular files (not symlinks). Merge the final list into $(PROD_OVAL)
	# directory
	# Don't traverse $(SHARED_OVAL_5_11) for the case of RHEL-OSP7 product for now
	# System supports OVAL-5.11 => propagate 'RUNTIME_OVAL_VERSION' variable into the environment
	$(eval MOD_ENV := env RUNTIME_OVAL_VERSION='5.11')
	$(eval OVAL_DIRS+=$(IN)/oval/oval_5.11)
endif

	find $(OVAL_DIRS) -name "*.xml" | xargs xmlwf
	$(MOD_ENV) $(SHARED)/$(TRANS)/combineovals.py $(CONF) $(PROD) $(OVAL_DIRS) > $(OUT)/unlinked-$(PROD)-oval.xml
	xmllint --format --output $(OUT)/unlinked-$(PROD)-oval.xml $(OUT)/unlinked-$(PROD)-oval.xml

# example, if needed: for converting XCCDF into shorthand
#xccdf2shorthand:
#	xsltproc -o $(XCCDF_OUTPUT_DIR)/$(PROD)-shorthand.xml $(TRANS)/xccdf2shorthand.xslt $(REFS)/usgcb-$(PROD)desktop-xccdf.xml
#	tidy -m -xml -utf8 --indent-spaces=0 $(XCCDF_OUTPUT_DIR)/$(PROD)-shorthand.xml

table-refs: $(OUT)/xccdf-unlinked-empty-groups.xml
	xsltproc -stringparam ref "nist" -o $(OUT)/table-$(PROD)-nistrefs.html $(TRANS)/xccdf2table-byref.xslt $<
	xsltproc -stringparam profile "common" -o $(OUT)/table-$(PROD)-nistrefs-common.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $<
	xsltproc -stringparam profile "ospp-rhel7-server" -o $(OUT)/table-$(PROD)-nistrefs-ospp.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $<

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
#	xsltproc -o $(OUT)/table-$(PROD)-stig.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-$(PROD)-v1r0.6-xccdf.xml
#	xsltproc -o $(OUT)/table-$(PROD)-stig-manual.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-$(PROD)-v1r0.6-xccdf-manual.xml
#	xsltproc -stringparam notes "../$(IN)/auxiliary/transition_notes.xml" -o $(OUT)/table-$(PROD)-stig-manual-withnotes.html \
#		$(TRANS)/xccdf2table-stig.xslt \
#		$(REFS)/disa-stig-$(PROD)-v1r0.6-xccdf-manual.xml
#	temporarily retain an output file showing the short titles as well
	xsltproc -stringparam profile "stig-$(PROD)-server" -stringparam testinfo "y" -o $(OUT)/table-stig-$(PROD)-testinfo.html \
		$(TRANS)/xccdf2table-profileccirefs.xslt $<
	xsltproc -stringparam overlay "../$(IN)/auxiliary/nist_overlay.xml" -o $(OUT)/unlinked-stig-$(PROD)-xccdf.xml \
		$(TRANS)/xccdf-apply-overlay-stig.xslt $<
	xsltproc -o $(OUT)/table-$(PROD)-stig.html $(TRANS)/xccdf2table-stig.xslt $(OUT)/unlinked-stig-$(PROD)-xccdf.xml

tables: table-refs table-idents table-srgmap table-stigs

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
	$(SHARED)/$(TRANS)/datastream_move_ocil_to_ds_checks.py $(OUT)/$(ID)-$(PROD)-ds.xml $(OUT)/$(ID)-$(PROD)-ds.xml
#	Make CentOS variants of XCCDF and Source DataStream
	$(SHARED)/$(UTILS)/enable-derivatives.py --enable-centos -i $(OUT)/$(ID)-$(PROD)-xccdf.xml -o $(OUT)/$(ID)-centos-osp7-xccdf.xml
	$(SHARED)/$(UTILS)/enable-derivatives.py --enable-centos -i $(OUT)/$(ID)-$(PROD)-ds.xml -o $(OUT)/$(ID)-centos-osp7-ds.xml
#	Make Scientific Linux variants of XCCDF and Source DataStream
	$(SHARED)/$(UTILS)/enable-derivatives.py --enable-sl -i $(OUT)/$(ID)-$(PROD)-xccdf.xml -o $(OUT)/$(ID)-sl-osp7-xccdf.xml
	$(SHARED)/$(UTILS)/enable-derivatives.py --enable-sl -i $(OUT)/$(ID)-$(PROD)-ds.xml -o $(OUT)/$(ID)-sl-osp7-ds.xml

content-stig: table-stigs guide checks
	xmllint --format --output $(OUT)/unlinked-stig-$(PROD)-xccdf.xml $(OUT)/unlinked-stig-$(PROD)-xccdf.xml
	$(SHARED)/$(UTILS)/cpe-generate.py $(OUT)/unlinked-$(PROD)-oval.xml $(IN)/oval/platform/$(PROD)-cpe-dictionary.xml disa-predraft
	$(SHARED)/$(UTILS)/relabel-ids.py unlinked-stig-$(PROD)-xccdf.xml disa-predraft
	xmllint --format --output $(OUT)/disa-predraft-stig-$(PROD)-xccdf.xml $(OUT)/disa-predraft-stig-$(PROD)-xccdf.xml

guide: content
ifeq ($(OPENSCAP_1_1_OR_LATER), 0)
	$(SHARED)/$(UTILS)/build-all-guides.py --input $(OUT)/$(ID)-$(PROD)-ds.xml
	$(SHARED)/$(UTILS)/build-all-guides.py --input $(OUT)/$(ID)-centos-osp7-ds.xml
	$(SHARED)/$(UTILS)/build-all-guides.py --input $(OUT)/$(ID)-sl-osp7-ds.xml
else
	@echo "Building guides from XCCDF 1.1, use OpenSCAP 1.1.0 or later for guides from datastreams!"
	$(SHARED)/$(UTILS)/build-all-guides.py --input $(OUT)/$(ID)-$(PROD)-xccdf.xml
	$(SHARED)/$(UTILS)/build-all-guides.py --input $(OUT)/$(ID)-centos-osp7-xccdf.xml
	$(SHARED)/$(UTILS)/build-all-guides.py --input $(OUT)/$(ID)-sl-osp7-xccdf.xml
endif

submission-stig-check: table-stigs
	cd $(OUT); ../$(SHARED)/$(UTILS)/verify-references.py -p stig-$(PROD)-server --rules-with-disarefs-outside-profile unlinked-$(PROD)-xccdf-prerefs.xml
#	$(TRANS)/xccdf2csv-stig.py $(OUT)/unlinked-stig-$(PROD)-xccdf.xml > $(OUT)/table-stig.csv

# content-usgcb: coming soon

validate-xml:
	oscap xccdf validate-xml $(OUT)/$(ID)-$(PROD)-xccdf.xml
	oscap oval validate-xml --schematron $(OUT)/$(ID)-$(PROD)-oval.xml
	oscap cpe validate-xml $(OUT)/$(ID)-$(PROD)-cpe-dictionary.xml
	oscap oval validate-xml --schematron $(OUT)/$(ID)-$(PROD)-cpe-oval.xml
	oscap ds sds-validate $(OUT)/$(ID)-$(PROD)-ds.xml
	oscap xccdf validate-xml $(OUT)/$(ID)-centos-osp7-xccdf.xml
	oscap ds sds-validate $(OUT)/$(ID)-centos-osp7-ds.xml
	oscap xccdf validate-xml $(OUT)/$(ID)-sl-osp7-xccdf.xml
	oscap ds sds-validate $(OUT)/$(ID)-sl-osp7-ds.xml

validate: validate-xml
	cd $(OUT); ../$(SHARED)/$(UTILS)/verify-references.py --rules-with-invalid-checks --ovaldefs-unused ssg-$(PROD)-xccdf.xml

# Items in dist are expected for distribution in an rpm
dist: tables guide content
	mkdir -p $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-xccdf.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-oval.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-ocil.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-cpe-dictionary.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-cpe-oval.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-ds.xml $(DIST)/content
	mkdir -p $(DIST)/guide
	cp $(OUT)/*-guide-*.html $(DIST)/guide
	cp $(OUT)/$(ID)-centos-osp7-xccdf.xml $(DIST)/content
	cp $(OUT)/$(ID)-centos-osp7-ds.xml $(DIST)/content
	cp $(OUT)/$(ID)-sl-osp7-xccdf.xml $(DIST)/content
	cp $(OUT)/$(ID)-sl-osp7-ds.xml $(DIST)/content

clean:
	rm -f $(OUT)/*.xml $(OUT)/*.html $(OUT)/*.xhtml $(OUT)/*.pdf  $(OUT)/*.spec $(OUT)/*.tar $(OUT)/*.gz $(OUT)/*.ini $(OUT)/*.csv
	rm -rf $(DIST)/content $(DIST)/guide
	rm -rf $(BUILD)
