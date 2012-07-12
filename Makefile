VERSION := 0.1
RELEASE := 1
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
endef

all: rhel6 rpm

rhel6:
	cd RHEL6 && $(MAKE)

tarball:
	$(call rpm-prep)
	cp -r RHEL6 $(RPM_TMPDIR)/$(PKG)	
	cd $(RPM_TMPDIR)/$(PKG)/RHEL6 && $(MAKE) clean
	cd $(RPM_TMPDIR) && tar -czf $(PKG).tar.gz $(PKG)
	cp $(RPM_TMPDIR)/$(PKG).tar.gz $(TARBALL)

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
