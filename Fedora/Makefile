IN = input
OUT = output
BUILD = build
TRANS = transforms
SHARED = ../shared
SHARED_CHECKS = $(SHARED)/oval
REFS = $(SHARED)/references
CONF = ../config
UTILS = utils
DIST = dist

ID = ssg
PROD = fedora
PROD_CHECKS = $(BUILD)/$(PROD)_checks

OPENSCAP_SVG := $(shell $(SHARED)/$(TRANS)/oscapsupportssvg.py; echo $$?)
OVAL_5_11 := $(shell oscap --version | grep -q "OVAL Version: 5.11.*"; echo $$?)
# OpenSCAP 1.1.0+ supports generating guides from datastreams
OPENSCAP_1_1_OR_LATER := $(shell oscap --version | grep -q -E "OpenSCAP command line tool \(oscap\) 1\.[1-9]+[0-9]*\."; echo $$?)
SHELLCHECK_AVAIL := $(shell which shellcheck >& /dev/null; echo $$?)

all: shorthand2xccdf guide content dist

shorthand-guide:
ifeq ($(OPENSCAP_SVG), 0)
	xsltproc -o $(OUT)/guide.xml $(SHARED)/$(TRANS)/includelogo.xslt $(IN)/guide.xml
	xsltproc -o $(OUT)/$(ID)-$(PROD)-shorthand.xml $(IN)/guide.xslt $(OUT)/guide.xml
else
	xsltproc -o $(OUT)/$(ID)-$(PROD)-shorthand.xml $(IN)/guide.xslt $(IN)/guide.xml
endif
	xmllint --format --output $(OUT)/$(ID)-$(PROD)-shorthand.xml $(OUT)/$(ID)-$(PROD)-shorthand.xml

shorthand2xccdf: shorthand-guide
	xsltproc -o $(OUT)/unlinked-unresolved-$(PROD)-xccdf.xml $(TRANS)/shorthand2xccdf.xslt $(OUT)/$(ID)-$(PROD)-shorthand.xml
	oscap xccdf resolve -o $(OUT)/unlinked-$(PROD)-empty-groups-xccdf.xml $(OUT)/unlinked-unresolved-$(PROD)-xccdf.xml
	$(SHARED)/$(UTILS)/unselect-empty-xccdf-groups.py --input $(OUT)/unlinked-$(PROD)-empty-groups-xccdf.xml --output $(OUT)/unlinked-$(PROD)-xccdf.xml
	oscap xccdf resolve -o $(OUT)/unlinked-$(PROD)-xccdf.xml $(OUT)/unlinked-$(PROD)-xccdf.xml
	# Include fixes
	$(SHARED)/$(TRANS)/combinefixes.py $(IN)/fixes/bash/ $(OUT)/bash-remediations.xml
	xsltproc -stringparam fixes "../$(OUT)/bash-remediations.xml" -o $(OUT)/unlinked-$(PROD)-xccdf.xml $(TRANS)/xccdf-addfixes.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
	xmllint --format --output $(OUT)/unlinked-$(PROD)-xccdf.xml $(OUT)/unlinked-$(PROD)-xccdf.xml

checks:
	# Make intermediate $(PROD_CHECKS) directory to hold final list of OVAL checks for $(PROD)
	mkdir -p $(PROD_CHECKS)
	# Search $(SHARED_CHECKS) and $(IN)/checks directories to find all product specific OVAL checks,
	# which are regular files (not symlinks). Merge the final list into $(PROD_CHECKS) directory
	find $(SHARED_CHECKS) $(IN)/checks -maxdepth 1 -type f -name *.xml -exec cp {} $(PROD_CHECKS) ';'
	# If openscap on the system supports OVAL-5.11 language version, include also OVAL-5.11 checks
	# into final list of OVAL checks
ifeq ($(OVAL_5_11), 0)
	find $(IN)/checks/oval_5.11 -maxdepth 1 -type f -name *.xml -exec cp {} $(PROD_CHECKS) ';'
	# Update requested Fedora OVAL version in $(CONF)/oval.config to be the 5.11 OVAL language version
	sed -i "s/^\(fedora_oval_version = \).*/\15.11/" $(CONF)/oval\.config
endif
	xmlwf $(PROD_CHECKS)/*.xml
	$(SHARED)/$(TRANS)/combinechecks.py $(CONF) $(PROD) $(PROD_CHECKS) > $(OUT)/unlinked-$(PROD)-oval.xml
	xmllint --format --output $(OUT)/unlinked-$(PROD)-oval.xml $(OUT)/unlinked-$(PROD)-oval.xml

content: shorthand2xccdf guide checks
#   remove auxiliary Groups which are only for use in tables, and not guide output.
	xsltproc -o $(OUT)/unlinked-$(PROD)-xccdf-guide.xml $(TRANS)/xccdf-removeaux.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
	$(SHARED)/$(TRANS)/relabelids.py unlinked-$(PROD)-xccdf.xml $(ID)
#	Expand 'test_attestation' URLs in OVAL document to valid SSG Contributors wiki link (fixes RHBZ#1155809 for OVAL)
	xsltproc -o $(OUT)/$(ID)-$(PROD)-oval.xml $(TRANS)/oval-fix-test-attestation-urls.xslt $(OUT)/$(ID)-$(PROD)-oval.xml
#	Once things are relabelled, create a datastream
	xsltproc /usr/share/openscap/xsl/xccdf_1.1_remove_dangling_sub.xsl $(OUT)/$(ID)-$(PROD)-xccdf.xml \
		> $(OUT)/$(ID)-$(PROD)-xccdf-nodangles.xml
	xsltproc --stringparam reverse_DNS org.ssgproject.content /usr/share/openscap/xsl/xccdf_1.1_to_1.2.xsl \
		$(OUT)/$(ID)-$(PROD)-xccdf-nodangles.xml > $(OUT)/$(ID)-$(PROD)-xccdf-1.2.xml
	sed -i '/idref="dangling reference to /d' $(OUT)/$(ID)-$(PROD)-xccdf-1.2.xml
	oscap ds sds-compose $(OUT)/$(ID)-$(PROD)-xccdf-1.2.xml $(OUT)/$(ID)-$(PROD)-ds.xml

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
ifeq ($(SHELLCHECK_AVAIL), 0)
	cd $(IN)/fixes/bash; shellcheck -s bash *.sh
else
	@echo "Skipping ShellCheck analysis, ensure shellcheck executable is present in the PATH!"
endif
ifeq ($(OVAL_5_11), 0)
	cd $(OUT); ../$(UTILS)/verify-references.py --rules-with-invalid-checks --ovaldefs-unused $(ID)-$(PROD)-xccdf.xml
else
	# If we are building against oscap version not supporting OVAL-5.11 language version yet,
	# don't call verify-references.py with "--rules-with-invalid-checks" argument, since the
	# OVAL checks using the 5.11 OVAL version will not be included in that case
	@echo -e "\nWarning:\n"
	@echo -e "\tFedora content build using oscap not supporting OVAL-5.11 language version detected!"
	@echo -e "\tSince the OVAL-5.11 Fedora OVAL checks are missing, will skip test for referenced,"
	@echo -e "\tbut undefined OVAL definitions during content validation. Consider building Fedora"
	@echo -e "\tcontent with version OpenSCAP-1.2.2, or newer in order to perform full content validation!\n"
	cd $(OUT); ../$(UTILS)/verify-references.py --ovaldefs-unused $(ID)-$(PROD)-xccdf.xml
endif

# items in dist are expected for distribution in an rpm
dist: guide content
	mkdir -p $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-xccdf.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-oval.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-ds.xml $(DIST)/content
	mkdir -p $(DIST)/guide
	cp $(OUT)/*-guide-*.html $(DIST)/guide

eval-common: content
	oscap xccdf eval --profile common $(OUT)/$(ID)-$(PROD)-xccdf.xml

clean:
	rm -f $(OUT)/*.xml $(OUT)/*.html $(OUT)/*.xhtml $(OUT)/*.pdf  $(OUT)/*.spec $(OUT)/*.tar $(OUT)/*.gz $(OUT)/*.ini $(OUT)/*.csv
	rm -f $(IN)/fixes/bash/templates/output/*.sh
	rm -rf $(DIST)/content
	rm -rf $(BUILD)
