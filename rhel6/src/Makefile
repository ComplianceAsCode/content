VERSION := 0.1
RELEASE := 1
IN = input
OUT = output
TRANS = transforms
REFS = references
PKGNAME := scap-security-guide
DIST := $(PKGNAME)-$(VERSION)

ARCH := noarch
VENDOR := scap-security-guide
PACKAGER := scap-security-guide

###################################################
# Used for rolling an RPM

RPM_SPEC := $(IN)/rpmbuild/scap-security-guide-alpha.spec

ROOT_DIR ?= $(CURDIR)
OUTPUT_DIR ?= $(ROOT_DIR)
SRPM_OUTPUT_DIR ?= $(OUTPUT_DIR)

# This file will be created by tar'ing up $(OUT)/
TARBALL = $(SRPM_OUTPUT_DIR)/$(DIST).tar.gz

RPM_DEPS := $(TARBALL) $(RPM_SPEC) Makefile

RPM_TMPDIR ?= $(ROOT_DIR)/tmp
RPM_TOPDIR ?= $(RPM_TMPDIR)/src/redhat
RPM_BUILDROOT ?= $(RPM_TMPDIR)/rpm-buildroot

MKDIR = test -d $(1) || mkdir -p $(1)

RPMBUILD_ARGS := --define '_topdir $(RPM_TOPDIR)'  --define '_tmppath $(RPM_TMPDIR)'

define rpm-prep
	 $(call MKDIR,$(RPM_TOPDIR)/SOURCES)
	 $(call MKDIR,$(RPM_TOPDIR)/SPECS)
	 $(call MKDIR,$(RPM_TOPDIR)/BUILD)
	 $(call MKDIR,$(RPM_TOPDIR)/RPMS/$(ARCH))
	 $(call MKDIR,$(RPM_TOPDIR)/SRPMS)
endef


all: shorthand-guide shorthand2xccdf tables guide checks content dist rpm

shorthand-guide:
	xsltproc -o $(OUT)/rhel6-shorthand.xml $(IN)/guide.xslt $(IN)/guide.xml
	xmllint --format --output $(OUT)/rhel6-shorthand.xml $(OUT)/rhel6-shorthand.xml

shorthand2xccdf:
	xsltproc -o $(OUT)/rhel6-xccdf-noprofiles.xml $(TRANS)/shorthand2xccdf.xslt $(OUT)/rhel6-shorthand.xml
	xsltproc -stringparam profile "allprofiles" -o $(OUT)/rhel6-xccdf.xml $(TRANS)/xccdf-addprofiles.xslt $(OUT)/rhel6-xccdf-noprofiles.xml
	xsltproc -stringparam fixes "../$(IN)/fixes/bash-ks.xml" -o $(OUT)/rhel6-xccdf.xml $(TRANS)/xccdf-addfixes.xslt $(OUT)/rhel6-xccdf.xml
#	xsltproc -stringparam fixes "../$(IN)/fixes/puppet-example.xml" -o $(OUT)/rhel6-xccdf.html $(TRANS)/xccdf-addfixes.xslt $(OUT)/rhel6-xccdf.xml
	xmllint --format --output $(OUT)/rhel6-xccdf.xml $(OUT)/rhel6-xccdf.xml

checks:
	xmlwf $(IN)/checks/*.xml
	$(TRANS)/combinechecks.py $(IN)/checks > $(OUT)/rhel6-oval.xml
	xmllint --format --output $(OUT)/rhel6-oval.xml $(OUT)/rhel6-oval.xml
#	SCC might return someday


guide: shorthand-guide shorthand2xccdf
#	remove auxiliary Groups which are only for use in tables, and not guide output.
#	specifying a nonexistent profile, "allrules," to make oscap print all Rules
	xsltproc -o $(OUT)/rhel6-xccdf.xml $(TRANS)/xccdf-removeaux.xslt $(OUT)/rhel6-xccdf.xml
	oscap xccdf generate guide --profile allrules $(OUT)/rhel6-xccdf.xml > $(OUT)/rhel6-guide.html

# example, if needed: for converting XCCDF into shorthand
#xccdf2shorthand:
#	xsltproc -o $(XCCDF_OUTPUT_DIR)/rhel5-shorthand.xml $(TRANS)/xccdf2shorthand.xslt $(REFS)/usgcb-rhel5desktop-xccdf.xml
#	tidy -m -xml -utf8 --indent-spaces=0 $(XCCDF_OUTPUT_DIR)/rhel5-shorthand.xml

table-profilenistrefs: shorthand-guide shorthand2xccdf
	xsltproc -stringparam profile "desktop" -o $(OUT)/rhel6-table-nistrefs-desktop.html $(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/rhel6-xccdf.xml
	xsltproc -stringparam profile "server" -o $(OUT)/rhel6-table-nistrefs-server.html $(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/rhel6-xccdf.xml
	xsltproc -stringparam profile "common" -o $(OUT)/rhel6-table-nistrefs-common.html $(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/rhel6-xccdf.xml
	xsltproc -stringparam profile "ftp" -o $(OUT)/rhel6-table-nistrefs-ftp.html $(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/rhel6-xccdf.xml

table-profileccirefs: shorthand-guide shorthand2xccdf
	xsltproc -stringparam profile "stig-server" -o $(OUT)/rhel6-table-stig-server.html $(TRANS)/xccdf2table-profileccirefs.xslt $(OUT)/rhel6-xccdf.xml

table-refs: shorthand-guide shorthand2xccdf
	xsltproc -stringparam ref "nist" -o $(OUT)/rhel6-table-nistrefs.html $(TRANS)/xccdf2table-byref.xslt $(OUT)/rhel6-xccdf.xml
	xsltproc -stringparam ref "cnss" -o $(OUT)/rhel6-table-cnssrefs.html $(TRANS)/xccdf2table-byref.xslt $(OUT)/rhel6-xccdf.xml
	xsltproc -stringparam ref "dcid" -o $(OUT)/rhel6-table-dcidrefs.html $(TRANS)/xccdf2table-byref.xslt $(OUT)/rhel6-xccdf.xml
# break apart references by delimiter:
	xsltproc -stringparam ref "nist" -stringparam delim "," -o $(OUT)/rhel6-table-nistrefs-delim.html $(TRANS)/xccdf2table-byref.xslt $(OUT)/rhel6-xccdf.xml
# then sort them:
	xsltproc --html -o $(OUT)/rhel6-table-nistrefs-delim-sorted.html $(TRANS)/table-sortbyref.xslt $(OUT)/rhel6-table-nistrefs-delim.html

table-srgmap: shorthand-guide shorthand2xccdf
# the map-to-items filename must be provided relative to the root of the main document being processed
	xsltproc -stringparam map-to-items "../$(OUT)/rhel6-xccdf.xml" -o $(OUT)/rhel6-table-srgmap.html $(TRANS)/table-srgmap.xslt $(REFS)/disa-os-srg-v1r1.xml

table-stig-rhel5:
	xsltproc -o $(OUT)/rhel5-table-stig.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-rhel5-v1r0.6-xccdf.xml  
	xsltproc -o $(OUT)/rhel5-table-stig-manual.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-rhel5-v1r0.6-xccdf-manual.xml  

tables: table-profilenistrefs table-profileccirefs table-refs table-srgmap table-stig-rhel5

content: shorthand-guide shorthand2xccdf guide checks
#	the relabelids.py script chdirs to ./output, so refer to files from there.
#	the second argument controls the IDs, as well as the output filenames.
#	thus, this creates rhel6-xccdf-scap-security-guide.xml and rhel6-oval-scap-security-guide.xml.
	$(TRANS)/relabelids.py rhel6-xccdf.xml scap-security-guide

validate:
	oscap xccdf validate-xml $(OUT)/rhel6-xccdf-scap-security-guide.xml
	oscap oval validate-xml $(OUT)/rhel6-oval-scap-security-guide.xml

eval-test:
	oscap xccdf eval --profile test $(OUT)/rhel6-xccdf-scap-security-guide.xml

eval-ftp:
	oscap xccdf eval --profile ftp $(OUT)/rhel6-xccdf-scap-security-guide.xml

eval-common:
	oscap xccdf eval --profile common --results /tmp/results-test.xml $(OUT)/rhel6-xccdf-scap-security-guide.xml

dist: tables guide content
	$(call MKDIR,$(DIST)/guide)
	$(call MKDIR,$(DIST)/content)
	$(call MKDIR,$(DIST)/policytables)
	cp -r $(IN)/dist_template/ $(DIST)/
	cp $(OUT)/rhel6-guide.html $(DIST)/guide
	cp $(OUT)/rhel6-xccdf-scap-security-guide.xml $(DIST)/content
	cp $(OUT)/rhel6-oval-scap-security-guide.xml $(DIST)/content
	cp $(OUT)/rhel6-table-* $(DIST)/policytables

tarball: $(TARBALL)

$(TARBALL): dist $(DIST)
	tar -czf $@ $(DIST)

srpm: $(SRPM_OUTPUT_DIR)/$(DIST)-$(RELEASE).src.rpm

$(SRPM_OUTPUT_DIR)/$(DIST)-$(RELEASE).src.rpm: $(RPM_DEPS)
	echo "Building $(PKGNAME) SRPM..."
	$(call rpm-prep)
	cp $(TARBALL) $(RPM_TOPDIR)/SOURCES/
	echo -e "%define arch $(ARCH)\n%define pkgname $(PKGNAME)\n%define _sysconfdir /etc\n%define version $(VERSION)\n%define release $(RELEASE)\n%define vendor $(VENDOR)\n%define packager $(PACKAGER)" > $(RPM_TOPDIR)/SPECS/$(notdir $(RPM_SPEC))
	cat $(RPM_SPEC) >> $(RPM_TOPDIR)/SPECS/$(notdir $(RPM_SPEC))
	cd $(RPM_TOPDIR) && rpmbuild $(RPMBUILD_ARGS) --target=$(ARCH) -bs SPECS/$(notdir $(RPM_SPEC)) --nodeps
	mv  $(RPM_TOPDIR)/SRPMS/$(DIST)-$(RELEASE).src.rpm $(SRPM_OUTPUT_DIR)

rpm: $(OUTPUT_DIR)/$(DIST)-$(RELEASE).$(ARCH).rpm

$(OUTPUT_DIR)/$(DIST)-$(RELEASE).$(ARCH).rpm: $(SRPM_OUTPUT_DIR)/$(DIST)-$(RELEASE).src.rpm
	 @echo "Building $(DIST) RPM..."
	 $(call rpm-prep)
	 cd $(RPM_TOPDIR)/SRPMS && rpmbuild --rebuild --target=$(ARCH) $(RPMBUILD_ARGS) --buildroot $(RPM_BUILDROOT) -bb $<
	 mv  $(RPM_TOPDIR)/RPMS/$(ARCH)/$(DIST)-$(RELEASE)*.rpm $(OUTPUT_DIR)

clean:
	rm -f $(OUT)/*.xml $(OUT)/*.html $(OUT)/*.pdf  $(OUT)/*.spec $(OUT)/*.tar $(OUT)/*.gz $(OUT)/*.ini
	rm -rf $(DIST)/
	rm -rf $(RPM_TMPDIR)

bare: clean
	rm -rf $(TARBALL) $(OUTPUT_DIR)/$(notdir $(OUTPUT_DIR)/$(DIST)-$(RELEASE).$(ARCH).rpm)
	rm -rf $(OUTPUT_DIR)/$(notdir $(SRPM_OUTPUT_DIR)/$(DIST)-$(RELEASE).src.rpm)

.PHONY: rpm srpm tarball clean all shorthand-guide shorthand2xccdf checks guide table-profilenistrefs table-refs table-srgmap tables content validate eval-test eval-ftp eval-common
