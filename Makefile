VERSION := 0.1
RELEASE := 10.el6
PKGNAME := scap-security-guide
PKG := $(PKGNAME)-$(VERSION)

ARCH := noarch
VENDOR := scap-security-guide
PACKAGER := scap-security-guide

ROOT_DIR ?= $(CURDIR)

RPM_SPEC := $(ROOT_DIR)/scap-security-guide.spec

TARBALL = $(RPM_TOPDIR)/SOURCES/$(PKG).tar.gz

RPM_DEPS := tarball $(RPM_SPEC) Makefile

RPM_TMPDIR ?= $(ROOT_DIR)/rpmbuild
RPM_TOPDIR ?= $(RPM_TMPDIR)/src/redhat
RPM_BUILDROOT ?= $(RPM_TMPDIR)/rpm-buildroot


MKDIR = test -d $(1) || mkdir -p $(1)

RPMBUILD_ARGS := --define '_topdir $(RPM_TOPDIR)'  --define '_tmppath $(RPM_TMPDIR)'

define rpm-prep
	$(call MKDIR,$(RPM_TMPDIR)/$(PKG))
	$(call MKDIR,$(RPM_BUILDROOT))
	$(call MKDIR,$(RPM_TOPDIR)/SOURCES)
	$(call MKDIR,$(RPM_TOPDIR)/SPECS)
	$(call MKDIR,$(RPM_TOPDIR)/BUILD)
	$(call MKDIR,$(RPM_TOPDIR)/RPMS/$(ARCH))
	$(call MKDIR,$(RPM_TOPDIR)/SRPMS)
	$(call MKDIR,$(RPM_TOPDIR)/ZIP)
endef

all: rhel6 rpm zipfile

rhel6:
	cd RHEL6 && $(MAKE)

tarball:
	$(call rpm-prep)

	# Copy in the source trees for both RHEL6
	# and JBossEAP5 content
	cp -r RHEL6 $(RPM_TMPDIR)/$(PKG)
	cp -r JBossEAP5 $(RPM_TMPDIR)/$(PKG)

	# Don't trust the developers, clean out the build
	# environment before packaging
	cd $(RPM_TMPDIR)/$(PKG)/RHEL6 && $(MAKE) clean

	# Create the source tar, copy it to $TARBALL
	# (e.g. somewhere in the SOURCES directory)
	cd $(RPM_TMPDIR) && tar -czf $(PKG).tar.gz $(PKG)
	cp $(RPM_TMPDIR)/$(PKG).tar.gz $(TARBALL)

zipfile:
	# Create a zipfile release, since many SCAP
	# tools desire content in that format
	# (Note: By default zip will store the full path
	#	 relative to the current directory, need
	#	 to cd into $(RPM_TMPDIR)
	cp RHEL6/output/ssg-* $(RPM_TOPDIR)/ZIP/
	cp JBossEAP5/eap5-* $(RPM_TOPDIR)/ZIP/
	# Originally attempted to `cd $(RPM_TOPDIR/ZIP` and
	# make the zip from there, however it still placed it
	# at working directory. Should look into this sometime
	#
	#cd $(RPM_TOPDIR)/ZIP
	#zip -r $(PKG)-$(RELEASE).zip . * -j
	zip -r $(PKG)-$(RELEASE).zip $(RPM_TOPDIR)/ZIP/* -j
	mv $(PKG)-$(RELEASE).zip $(RPM_TOPDIR)/ZIP/

srpm: $(RPM_DEPS)
	@echo "Building $(PKGNAME) SRPM..."
	echo -e "%define arch $(ARCH)\n%define pkgname $(PKGNAME)\n%define _sysconfdir /etc\n%define version $(VERSION)\n%define release $(RELEASE)\n%define vendor $(VENDOR)\n%define packager $(PACKAGER)" > $(RPM_TOPDIR)/SPECS/$(notdir $(RPM_SPEC))
	cat $(RPM_SPEC) >> $(RPM_TOPDIR)/SPECS/$(notdir $(RPM_SPEC))
	cd $(RPM_TOPDIR) && rpmbuild $(RPMBUILD_ARGS) --target=$(ARCH) -bs SPECS/$(notdir $(RPM_SPEC)) --nodeps

rpm: srpm
	 @echo "Building $(PKG) RPM..."
	 cd $(RPM_TOPDIR)/SRPMS && rpmbuild --rebuild --target=$(ARCH) $(RPMBUILD_ARGS) --buildroot $(RPM_BUILDROOT) -bb $(PKG)-$(RELEASE).src.rpm

clean:
	rm -rf $(RPM_TMPDIR)
	cd RHEL6 && $(MAKE) clean

.PHONY: rhel6 tarball srpm rpm clean all
