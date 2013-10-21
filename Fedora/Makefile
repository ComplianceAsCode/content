IN = input
OUT = output
TRANS = transforms
UTILS = utils
DIST = dist

ID = ssg
PROD = fedora

FEDORA_GUIDE_XSLT = fedora_guide.xslt
FEDORA_GUIDE_XML = fedora_guide.xml

all: shorthand2xccdf guide content dist

set-fedora-release:
	mkdir -p $(OUT)
#	obtain full Fedora release name and CPE from the system
	$(TRANS)/genguidexslt.py $(OUT)/$(FEDORA_GUIDE_XSLT)
#	update Fedora/input/guide.xml based on retrieved values
	xsltproc -o $(OUT)/$(FEDORA_GUIDE_XML) $(OUT)/$(FEDORA_GUIDE_XSLT) $(IN)/guide.xml

shorthand-guide: set-fedora-release
	xsltproc -o $(OUT)/$(ID)-$(PROD)-shorthand.xml $(IN)/guide.xslt $(OUT)/$(FEDORA_GUIDE_XML)
	xmllint --format --output $(OUT)/$(ID)-$(PROD)-shorthand.xml $(OUT)/$(ID)-$(PROD)-shorthand.xml

shorthand2xccdf: shorthand-guide
	xsltproc -o $(OUT)/unlinked-unresolved-$(PROD)-xccdf.xml $(TRANS)/shorthand2xccdf.xslt $(OUT)/$(ID)-$(PROD)-shorthand.xml
	oscap xccdf resolve -o $(OUT)/unlinked-$(PROD)-xccdf.xml $(OUT)/unlinked-unresolved-$(PROD)-xccdf.xml

checks:
	xmlwf $(IN)/checks/*.xml
	$(TRANS)/combinechecks.py $(IN)/checks > $(OUT)/unlinked-$(PROD)-oval.xml
	xmllint --format --output $(OUT)/unlinked-$(PROD)-oval.xml $(OUT)/unlinked-$(PROD)-oval.xml

guide: shorthand2xccdf
#       remove auxiliary Groups which are only for use in tables, and not guide output.
#       specifying a nonexistent profile, "allrules," to make oscap print all Rules
	xsltproc -o $(OUT)/unlinked-$(PROD)-xccdf-guide.xml $(TRANS)/xccdf-removeaux.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
	xsltproc -o $(OUT)/unlinked-notest-$(PROD)-xccdf-guide.xml $(TRANS)/xccdf-removetested.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
	oscap xccdf generate guide --profile allrules $(OUT)/unlinked-notest-$(PROD)-xccdf-guide.xml > $(OUT)/$(ID)-$(PROD)-guide.html

content: shorthand2xccdf guide checks
	$(TRANS)/cpe_generate.py $(OUT)/unlinked-$(PROD)-oval.xml $(IN)/checks/platform/$(PROD)-cpe-dictionary.xml $(ID)
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
	mkdir -p $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-xccdf.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-oval.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-cpe-dictionary.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-cpe-oval.xml $(DIST)/content

eval-common: content
	oscap xccdf eval --profile common $(OUT)/$(ID)-$(PROD)-xccdf.xml

clean:
	rm -f $(OUT)/*.xml $(OUT)/*.html $(OUT)/*.xhtml $(OUT)/*.pdf  $(OUT)/*.spec $(OUT)/*.tar $(OUT)/*.gz $(OUT)/*.ini $(OUT)/*.csv
	rm -f $(OUT)/$(FEDORA_GUIDE_XSLT)
	rm -rf $(DIST)/content
