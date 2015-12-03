include ../../VERSION

IN = input
OUT = output
TRANS = transforms
UTILS = utils
DIST = dist
SHARED:=../../shared
SHARED_OVAL = $(SHARED)/oval
SHARED_REMEDIATIONS = $(SHARED)/remediations/bash
REFS = $(SHARED)/references
CONF = ../../config
REMEDIATIONS:=input/remediations/bash

ID = ssg
PROD = debian8

OPENSCAP_SVG := $(shell $(SHARED)/$(TRANS)/oscapsupportssvg.py; echo $$?)
OVAL_5_11 := $(shell oscap --version | grep -q "OVAL Version: 5.11.*"; echo $$?)

# OpenSCAP 1.1.0+ supports generating guides from datastreams
OPENSCAP_1_1_OR_LATER := $(shell oscap --version | grep -q -E "OpenSCAP command line tool \(oscap\) 1\.[1-9]+[0-9]*\."; echo $$?)

# Don't include the 'test' profile into benchmark by default. Only upon request (e.g. in 'eval-test' target)
# Value '0' means 'test' will be included. Value '1' means 'test' will NOT be included.
INCLUDE_TEST_PROFILE := $(shell false; echo $$?)

all: shorthand2xccdf guide content dist

shorthand-guide:
ifeq ($(OPENSCAP_SVG), 1)
	xsltproc -o $(OUT)/guide.xml $(SHARED)/$(TRANS)/includelogo.xslt $(IN)/guide.xml
	xsltproc --param withtest "$(INCLUDE_TEST_PROFILE)" -o $(OUT)/$(ID)-$(PROD)-shorthand.xml $(IN)/guide.xslt $(OUT)/guide.xml
else
	xsltproc --param withtest "$(INCLUDE_TEST_PROFILE)" -o $(OUT)/$(ID)-$(PROD)-shorthand.xml $(IN)/guide.xslt $(IN)/guide.xml
endif
	xmllint --format --output $(OUT)/$(ID)-$(PROD)-shorthand.xml $(OUT)/$(ID)-$(PROD)-shorthand.xml

shorthand2xccdf: shorthand-guide
	xsltproc --stringparam ssg_version "$(SSG_MAJOR_VERSION).$(SSG_MINOR_VERSION)" -o $(OUT)/unlinked-unresolved-$(PROD)-xccdf.xml $(TRANS)/shorthand2xccdf.xslt $(OUT)/$(ID)-$(PROD)-shorthand.xml
	oscap xccdf resolve -o $(OUT)/unlinked-$(PROD)-empty-groups-xccdf.xml $(OUT)/unlinked-unresolved-$(PROD)-xccdf.xml
	$(SHARED)/$(UTILS)/unselect-empty-xccdf-groups.py --input $(OUT)/unlinked-$(PROD)-empty-groups-xccdf.xml --output $(OUT)/unlinked-$(PROD)-xccdf.xml
	oscap xccdf resolve -o $(OUT)/unlinked-$(PROD)-xccdf.xml $(OUT)/unlinked-$(PROD)-xccdf.xml
	xsltproc -o $(OUT)/unlinked-$(PROD)-ocil.xml $(TRANS)/xccdf-create-ocil.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
	xmllint --format --output $(OUT)/unlinked-$(PROD)-ocil.xml $(OUT)/unlinked-$(PROD)-ocil.xml 
	xsltproc -o $(OUT)/unlinked-ocilrefs-$(PROD)-xccdf.xml $(TRANS)/xccdf-ocilcheck2ref.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
	$(SHARED)/$(TRANS)/combineremediations.py $(CONF) $(PROD) $(REMEDIATIONS) $(OUT)/bash-remediations.xml
	xsltproc -stringparam remediations "$(OUT)/bash-remediations.xml" -o $(OUT)/unlinked-$(PROD)-xccdf.xml $(TRANS)/xccdf-addremediations.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
	xmllint --format --output $(OUT)/unlinked-$(PROD)-xccdf.xml $(OUT)/unlinked-$(PROD)-xccdf.xml

templates:
	$(MAKE) -C input/oval/templates all
	$(MAKE) -C input/oval/templates copy

checks: templates
	cp $(IN)/oval/*.xml $(IN)/oval/templates/output/
	xmlwf $(IN)/oval/templates/output/*.xml
	$(TRANS)/combinechecks.py $(IN)/oval/templates/output > $(OUT)/unlinked-$(PROD)-oval.xml
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
