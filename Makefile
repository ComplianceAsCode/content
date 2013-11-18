# Define RHEL6 / JBossEAP5 specific variables below
ROOT_DIR ?= $(CURDIR)
RPM_SPEC := $(ROOT_DIR)/scap-security-guide.spec
PKGNAME := $(shell sed -ne 's/Name:\t\t\(.*\)/\1/p' $(RPM_SPEC))
VERSION := $(shell sed -ne 's/Version:\t\(.*\)/\1/p' $(RPM_SPEC))
REDHAT_SSG_RELEASE := $(shell sed -ne 's/^\(.*\)redhatssgrelease\t\(.*\)/\2/p' $(RPM_SPEC))
REDHAT_DIST := $(shell rpm --eval '%{dist}')
RELEASE := $(REDHAT_SSG_RELEASE)$(REDHAT_DIST)
PKG := $(PKGNAME)-$(VERSION)-$(REDHAT_SSG_RELEASE)

ARCH := noarch
TARBALL = $(RPM_TOPDIR)/SOURCES/$(PKG).tar.gz

RPM_DEPS := tarball $(RPM_SPEC) Makefile
RPM_TMPDIR ?= $(ROOT_DIR)/rpmbuild
RPM_TOPDIR ?= $(RPM_TMPDIR)/src/redhat
RPM_BUILDROOT ?= $(RPM_TMPDIR)/rpm-buildroot
RPMBUILD_ARGS := --define '_topdir $(RPM_TOPDIR)'  --define '_tmppath $(RPM_TMPDIR)'

# Define Fedora specific variables below
FEDORA_SPEC := $(ROOT_DIR)/Fedora/scap-security-guide.spec
FEDORA_RPM_DEPS := $(FEDORA_SPEC) Makefile
FEDORA_NAME := $(PKGNAME)
FEDORA_SSG_VERSION := $(shell sed -ne 's/^\(.*\)\tfedorassgversion\t\(.*\)/\2/p' $(FEDORA_SPEC))
FEDORA_RPM_VERSION := $(shell sed -ne 's/Version:\t\(.*\)/\1/p' $(FEDORA_SPEC))
$(eval FEDORA_RPM_VERSION := $(shell echo $(FEDORA_RPM_VERSION) | sed -ne 's/%{fedorassgversion}/$(FEDORA_SSG_VERSION)/p'))
FEDORA_PKG := $(FEDORA_NAME)-$(FEDORA_RPM_VERSION)
FEDORA_TARBALL := $(RPM_TOPDIR)/SOURCES/$(FEDORA_PKG).tar.gz
FEDORA_DIST := $(shell rpm --eval '%{dist}')

# Define custom canned sequences / macros below

MKDIR = test -d $(1) || mkdir -p $(1)

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

# Define Makefile targets below

all: rhel6 openstack rhevm3 rpm zipfile

rhel6:
	cd RHEL6 && $(MAKE)

openstack:
	cd OpenStack && $(MAKE)

rhevm3:
	cd RHEVM3 && $(MAKE)

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

fedora-tarball:
	$(call rpm-prep)

	# rpm-prep creates $(RPM_TMPDIR)/$(PKG) => move it
	# to proper Fedora package location first
	mv $(RPM_TMPDIR)/$(PKG) $(RPM_TMPDIR)/$(FEDORA_PKG)

	# Copy the source tree for Fedora content
	cp -r Fedora $(RPM_TMPDIR)/$(FEDORA_PKG)

	# Don't trust the developers, clean out the build
	# environment before packaging
	cd $(RPM_TMPDIR)/$(FEDORA_PKG)/Fedora && $(MAKE) clean

	# Create the source tar, copy it to $TARBALL
	# (e.g. somewhere in the SOURCES directory)
	cd $(RPM_TMPDIR) && tar -czf $(FEDORA_PKG).tar.gz $(FEDORA_PKG)
	cp $(RPM_TMPDIR)/$(FEDORA_PKG).tar.gz $(FEDORA_TARBALL)

zipfile:
	# Create a zipfile release, since many SCAP
	# tools desire content in that format
	# (Note: By default zip will store the full path
	#	 relative to the current directory, need
	#	 to cd into $(RPM_TMPDIR)
	cp RHEL6/output/ssg-* $(RPM_TOPDIR)/ZIP/
	cp JBossEAP5/eap5-* $(RPM_TOPDIR)/ZIP/
	# Originally attempted to `cd $(RPM_TOPDIR)/ZIP` and
	# make the zip from there, however it still placed it
	# at working directory. Should look into this sometime
	#
	#cd $(RPM_TOPDIR)/ZIP
	#zip -r $(PKG)-$(RELEASE).zip . * -j
	zip -r $(PKG)-$(RELEASE).zip $(RPM_TOPDIR)/ZIP/* -j
	mv $(PKG)-$(RELEASE).zip $(RPM_TOPDIR)/ZIP/

srpm: $(RPM_DEPS)
	# Obtain the source from RedHat's spec file
	$(eval SOURCE := $(shell sed -ne 's/Source0:\t\(.*\)/\1/p' $(RPM_SPEC)))
	# Substitute %{name}, %{version}, and %{redhatssgrelease} with their actual values
	$(eval SOURCE := $(shell echo $(SOURCE) | sed -ne "s/%{name}/$(PKGNAME)/p"))
	$(eval SOURCE := $(shell echo $(SOURCE) | sed -ne "s/%{version}/$(VERSION)/p"))
	$(eval SOURCE := $(shell echo $(SOURCE) | sed -ne "s/%{redhatssgrelease}/$(REDHAT_SSG_RELEASE)/p"))
	# Download the tarball
	@echo "Downloading the $(SOURCE) tarball..."
	@wget -O $(TARBALL) $(SOURCE)
	@echo "Copying the SPEC file to proper location..."
	cat $(RPM_SPEC) > $(RPM_TOPDIR)/SPECS/$(notdir $(RPM_SPEC))
	@echo "Building $(PKGNAME) SRPM..."
	cd $(RPM_TOPDIR) && rpmbuild $(RPMBUILD_ARGS) --target=$(ARCH) -bs SPECS/$(notdir $(RPM_SPEC)) --nodeps

fedora-srpm: $(FEDORA_RPM_DEPS)
	# Create the necessary directory structure
	$(call rpm-prep)
	# Obtain the source from Fedora's spec file
	$(eval FEDORA_SOURCE := $(shell sed -ne 's/Source0:\t\(.*\)/\1/p' $(FEDORA_SPEC)))
	# Substitute %{name} and %{version} with their actual values
	$(eval FEDORA_SOURCE := $(shell echo $(FEDORA_SOURCE) | sed -ne "s/%{name}/$(FEDORA_NAME)/p"))
	$(eval FEDORA_SOURCE := $(shell echo $(FEDORA_SOURCE) | sed -ne "s/%{version}/$(FEDORA_RPM_VERSION)/p"))
	# Download the tarball
	@echo "Downloading the $(FEDORA_SOURCE) tarball..."
	@wget -O $(FEDORA_TARBALL) $(FEDORA_SOURCE)
	@echo "Copying the SPEC file to proper location..."
	cat $(FEDORA_SPEC) > $(RPM_TOPDIR)/SPECS/$(notdir $(FEDORA_SPEC))
	@echo "Building Fedora source $(PKGNAME) RPM package..."
	cd $(RPM_TOPDIR) && rpmbuild $(RPMBUILD_ARGS) --target=$(ARCH) -bs SPECS/$(notdir $(FEDORA_SPEC)) --nodeps

rpm: srpm
	 @echo "Building $(PKG) RPM..."
	 cd $(RPM_TOPDIR)/SRPMS && rpmbuild --rebuild --target=$(ARCH) $(RPMBUILD_ARGS) --buildroot $(RPM_BUILDROOT) -bb $(PKG)$(REDHAT_DIST).src.rpm

fedora-rpm: fedora-srpm
	$(eval FEDORA_RPM_RELEASE := $(shell sed -ne 's/Release:\t\(.*\)/\1/p' $(FEDORA_SPEC)))
	$(eval FEDORA_RPM_RELEASE := $(shell echo $(FEDORA_RPM_RELEASE) | sed -ne 's/%{?dist}/$(FEDORA_DIST)/p'))
	@echo "Building Fedora $(FEDORA_PKG) RPM package..."
	cd $(RPM_TOPDIR)/SRPMS && rpmbuild --rebuild --target=$(ARCH) $(RPMBUILD_ARGS) --buildroot $(RPM_BUILDROOT) -bb $(FEDORA_PKG)-$(FEDORA_RPM_RELEASE).src.rpm

clean:
	rm -rf $(RPM_TMPDIR)
	cd RHEL6 && $(MAKE) clean
	cd OpenStack && $(MAKE) clean
	cd RHEVM3 && $(MAKE) clean
	cd Fedora && $(MAKE) clean

.PHONY: rhel6 tarball srpm rpm clean all
