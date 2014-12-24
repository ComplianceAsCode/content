IN = input
OUT = output
TRANS = transforms
SHARED = ../shared
REFS = $(SHARED)/references
CONF = ../config
UTILS = utils
DIST = dist

ID = ssg
PROD = fedora

OPENSCAP_SVG := $(shell $(TRANS)/oscapsupportssvg.py; echo $$?)

all: shorthand2xccdf guide content dist

shorthand-guide:
ifeq ($(OPENSCAP_SVG), 0)
	xsltproc -o $(OUT)/guide.xml $(TRANS)/includelogo.xslt $(IN)/guide.xml
	xsltproc -o $(OUT)/$(ID)-$(PROD)-shorthand.xml $(IN)/guide.xslt $(OUT)/guide.xml
else
	xsltproc -o $(OUT)/$(ID)-$(PROD)-shorthand.xml $(IN)/guide.xslt $(IN)/guide.xml
endif
	xmllint --format --output $(OUT)/$(ID)-$(PROD)-shorthand.xml $(OUT)/$(ID)-$(PROD)-shorthand.xml

shorthand2xccdf: shorthand-guide
	xsltproc -o $(OUT)/unlinked-unresolved-$(PROD)-xccdf.xml $(TRANS)/shorthand2xccdf.xslt $(OUT)/$(ID)-$(PROD)-shorthand.xml
	oscap xccdf resolve -o $(OUT)/unlinked-$(PROD)-xccdf.xml $(OUT)/unlinked-unresolved-$(PROD)-xccdf.xml
	# Include fixes
	$(SHARED)/$(TRANS)/combinefixes.py $(IN)/fixes/bash/ $(OUT)/bash-remediations.xml
	xsltproc -stringparam fixes "../$(OUT)/bash-remediations.xml" -o $(OUT)/unlinked-$(PROD)-xccdf.xml $(TRANS)/xccdf-addfixes.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
	xmllint --format --output $(OUT)/unlinked-$(PROD)-xccdf.xml $(OUT)/unlinked-$(PROD)-xccdf.xml

checks:
	xmlwf $(IN)/checks/*.xml
	$(SHARED)/$(TRANS)/combinechecks.py $(CONF) $(IN)/checks > $(OUT)/unlinked-$(PROD)-oval.xml
	xmllint --format --output $(OUT)/unlinked-$(PROD)-oval.xml $(OUT)/unlinked-$(PROD)-oval.xml

guide: shorthand2xccdf
#       remove auxiliary Groups which are only for use in tables, and not guide output.
	xsltproc -o $(OUT)/unlinked-$(PROD)-xccdf-guide.xml $(TRANS)/xccdf-removeaux.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
	xsltproc -o $(OUT)/unlinked-notest-$(PROD)-xccdf-guide.xml $(TRANS)/xccdf-removetested.xslt $(OUT)/unlinked-$(PROD)-xccdf.xml
#       OpenSCAP-1.1.1 expects exact profile name in order to include also rules into guide
#       Create guide for common profile
	oscap xccdf generate guide --profile common $(OUT)/unlinked-notest-$(PROD)-xccdf-guide.xml > $(OUT)/$(ID)-$(PROD)-common-guide.html

content: shorthand2xccdf guide checks
	$(SHARED)/$(TRANS)/cpe_generate.py $(OUT)/unlinked-$(PROD)-oval.xml $(IN)/checks/platform/$(PROD)-cpe-dictionary.xml $(ID)
	$(SHARED)/$(TRANS)/relabelids.py unlinked-$(PROD)-xccdf.xml $(ID)
#       Once things are relabelled, create a datastream
	xsltproc /usr/share/openscap/xsl/xccdf_1.1_remove_dangling_sub.xsl $(OUT)/$(ID)-$(PROD)-xccdf.xml \
		> $(OUT)/$(ID)-$(PROD)-xccdf-nodangles.xml
	xsltproc --stringparam reverse_DNS org.ssgproject.content /usr/share/openscap/xsl/xccdf_1.1_to_1.2.xsl \
		$(OUT)/$(ID)-$(PROD)-xccdf-nodangles.xml > $(OUT)/$(ID)-$(PROD)-xccdf-1.2.xml
	sed -i '/idref="dangling reference to /d' $(OUT)/$(ID)-$(PROD)-xccdf-1.2.xml
	oscap ds sds-compose $(OUT)/$(ID)-$(PROD)-xccdf-1.2.xml $(OUT)/$(ID)-$(PROD)-ds.xml
#       Add in CPE and OVAL content to datastream
	oscap ds sds-add $(OUT)/$(ID)-$(PROD)-cpe-dictionary.xml $(OUT)/$(ID)-$(PROD)-ds.xml
	oscap ds sds-add $(OUT)/$(ID)-$(PROD)-oval.xml $(OUT)/$(ID)-$(PROD)-ds.xml


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
	cp $(OUT)/$(ID)-$(PROD)-ds.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-cpe-dictionary.xml $(DIST)/content
	cp $(OUT)/$(ID)-$(PROD)-cpe-oval.xml $(DIST)/content

eval-common: content
	oscap xccdf eval --profile common $(OUT)/$(ID)-$(PROD)-xccdf.xml

clean:
	rm -f $(OUT)/*.xml $(OUT)/*.html $(OUT)/*.xhtml $(OUT)/*.pdf  $(OUT)/*.spec $(OUT)/*.tar $(OUT)/*.gz $(OUT)/*.ini $(OUT)/*.csv
	rm -f $(IN)/fixes/bash/templates/output/*.sh
	rm -rf $(DIST)/content
