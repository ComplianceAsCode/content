include ../../VERSION

IN = input
OUT = output
BUILD = build
TRANS = transforms
SHARED = ../../shared
SHARED_OVAL = $(SHARED)/oval
CONF = ../../config
UTILS = utils
DIST = dist

OVAL_5_11 := $(shell oscap --version | grep -q "OVAL Version: 5.11.*"; echo $$?)

ID = ssg
PROD = debian8
PROD_OVAL = $(BUILD)/$(PROD)_oval

all: shorthand2xccdf guide content dist

shorthand-guide:
	xsltproc -o $(OUT)/$(ID)-$(PROD)-shorthand.xml $(IN)/guide.xslt $(IN)/guide.xml
	xmllint --format --output $(OUT)/$(ID)-$(PROD)-shorthand.xml $(OUT)/$(ID)-$(PROD)-shorthand.xml

shorthand2xccdf: shorthand-guide
	xsltproc -o $(OUT)/unlinked-unresolved-$(PROD)-xccdf.xml $(TRANS)/shorthand2xccdf.xslt $(OUT)/$(ID)-$(PROD)-shorthand.xml
	oscap xccdf resolve -o $(OUT)/unlinked-$(PROD)-xccdf.xml $(OUT)/unlinked-unresolved-$(PROD)-xccdf.xml

checks:
	# Make intermediate $(PROD_OVAL) directory to hold final list of OVAL checks for $(PROD)
	mkdir -p $(PROD_OVAL)
	# Search $(SHARED_OVAL) and $(IN)/oval directories to find all product specific OVAL checks,
	# which are regular files (not symlinks). Merge the final list into $(PROD_OVAL) directory
	find $(SHARED_OVAL) $(IN)/oval -maxdepth 1 -type f -name *.xml -exec cp {} $(PROD_OVAL) ';'
	# If openscap on the system supports OVAL-5.11 language version, include also OVAL-5.11 checks
	# add local Debian8 specific templated ovals
	$(MAKE) -C $(IN)/oval/templates all
	$(MAKE) -C $(IN)/oval/templates copy
	# into final list of OVAL checks
ifeq ($(OVAL_5_11), 0)
	find $(IN)/oval/oval_5.11 -maxdepth 1 -type f -name *.xml -exec cp {} $(PROD_OVAL) ';'
	# Update requested debian8 OVAL version in $(CONF)/oval.config to be the 5.11 OVAL language version
	sed -i "s/^\(debian8_oval_version = \).*/\15.11/" $(CONF)/oval\.config
endif

	xmlwf $(PROD_OVAL)/*.xml
	$(SHARED)/$(TRANS)/combineovals.py $(CONF) $(PROD) $(PROD_OVAL) > $(OUT)/unlinked-$(PROD)-oval.xml
	xmllint --format --output $(OUT)/unlinked-$(PROD)-oval.xml $(OUT)/unlinked-$(PROD)-oval.xml

guide: shorthand2xccdf
#       remove auxiliary Groups which are only for use in tables, and not guide output.
#       specifying a nonexistent profile, "allrules," to make oscap print all Rules
	xsltproc -o $(OUT)/unlinked-$(PROD)-xccdf-guide.xml $(TRANS)/xccdf-removeaux.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
	xsltproc -o $(OUT)/unlinked-notest-$(PROD)-xccdf-guide.xml $(TRANS)/xccdf-removetested.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
	oscap xccdf generate guide --profile allrules $(OUT)/unlinked-notest-$(PROD)-xccdf-guide.xml > $(OUT)/$(ID)-$(PROD)-guide.html

content: shorthand2xccdf guide checks
	$(TRANS)/cpe_generate.py $(OUT)/unlinked-$(PROD)-oval.xml $(IN)/oval/platform/$(PROD)-cpe-dictionary.xml $(ID)
	$(TRANS)/relabelids.py unlinked-$(PROD)-xccdf.xml $(ID)

validate-xml:
	oscap xccdf validate-xml $(OUT)/$(ID)-$(PROD)-xccdf.xml
	oscap oval validate-xml $(OUT)/$(ID)-$(PROD)-oval.xml
	oscap oval validate-xml $(OUT)/$(ID)-$(PROD)-cpe-oval.xml

validate: validate-xml
	cd $(OUT); ../$(UTILS)/verify-references.py --rules-with-invalid-checks --ovaldefs-unused $(ID)-$(PROD)-xccdf.xml
	oscap oval validate-xml --schematron $(OUT)/$(ID)-$(PROD)-oval.xml

# items in dist are expected for distribution in an rpm
dist: guide content
	mkdir -p $(DIST)/guide $(DIST)/content
	cp $(OUT)/*-guide.html $(DIST)/guide
	cp $(OUT)/$(ID)-$(PROD)-xccdf.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-oval.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-cpe-dictionary.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-cpe-oval.xml $(DIST)/content

eval-common: content
	oscap xccdf eval --profile common $(OUT)/$(ID)-$(PROD)-xccdf.xml

clean:
	rm -f $(OUT)/*.xml $(OUT)/*.html $(OUT)/*.xhtml $(OUT)/*.pdf  $(OUT)/*.spec $(OUT)/*.tar $(OUT)/*.gz $(OUT)/*.ini $(OUT)/*.csv
	rm -rf $(DIST)/content $(DIST)/guide
	$(MAKE) -C $(IN)/oval/templates clean
	rm -rf $(BUILD)
