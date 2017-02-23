include VERSION

# Define RHEL6 / JBossEAP5 specific variables below
ROOT_DIR ?= $(CURDIR)
RPMBUILD ?= $(ROOT_DIR)/rpmbuild
RPM_SPEC := $(ROOT_DIR)/scap-security-guide.spec
PKGNAME := $(SSG_PROJECT_NAME)
OS_DIST := $(shell rpm --eval '%{dist}')

ARCH := noarch
RPMBUILD_ARGS := --define '_topdir $(RPMBUILD)'  --define '_tmppath $(RPMBUILD)'

DATESTR:=$(shell date -u +'%Y%m%d%H%M')
RPM_DATESTR := $(shell date -u +'%a %b %d %Y')

ifeq ($(SSG_VERSION_IS_GIT_SNAPSHOT),"yes")
GIT_VERSION:=$(shell git show --pretty=format:"%h" --stat HEAD 2>/dev/null|head -1)
ifneq ($(GIT_VERSION),)
SSG_VERSION=$(SSG_MAJOR_VERSION).$(SSG_MINOR_VERSION).$(SSG_RELEASE_VERSION).$(DATESTR)GIT$(GIT_VERSION)
endif # in a git tree and git returned a version
endif # git

ifndef SSG_VERSION
SSG_VERSION=$(SSG_MAJOR_VERSION).$(SSG_MINOR_VERSION)
endif

PKG := $(PKGNAME)-$(SSG_VERSION)
TARBALL = $(RPMBUILD)/SOURCES/$(PKG).tar.gz

PREFIX=$(DESTDIR)/usr
DATADIR=share
MANDIR=$(DATADIR)/man
DOCDIR=$(DATADIR)/doc

tarball:
	@# Copy in the source trees for both RHEL
	@# and JBossEAP5 content
	mkdir -p tarball/$(PKG)
	cp Makefile tarball/$(PKG)/
	cp CMakeLists.txt tarball/$(PKG)/
	cp BUILD.md Contributors.md LICENSE VERSION README.md tarball/$(PKG)/
	cp -r config/ tarball/$(PKG)
	cp -r docs/ tarball/$(PKG)
	cp -r shared/ tarball/$(PKG)
	cp -r cmake/ tarball/$(PKG)
	cp -r --preserve=links --parents Chromium/ tarball/$(PKG)
	cp -r --preserve=links --parents Debian/ tarball/$(PKG)
	cp -r --preserve=links --parents Fedora/ tarball/$(PKG)
	cp -r --preserve=links --parents Firefox/ tarball/$(PKG)
	cp -r --preserve=links --parents JBoss/ tarball/$(PKG)
	cp -r --preserve=links --parents JBossEAP5/ tarball/$(PKG)
	cp -r --preserve=links --parents JRE/ tarball/$(PKG)
	cp -r --preserve=links --parents OpenStack/ tarball/$(PKG)
	cp -r --preserve=links --parents OpenSUSE/ tarball/$(PKG)
	cp -r --preserve=links --parents RHEL/ tarball/$(PKG)
	cp -r --preserve=links --parents RHEVM3/ tarball/$(PKG)
	cp -r --preserve=links --parents SUSE/ tarball/$(PKG)
	cp -r --preserve=links --parents Ubuntu/ tarball/$(PKG)
	cp -r --preserve=links --parents Webmin/ tarball/$(PKG)
	cp -r --preserve=links --parents WRLinux/ tarball/$(PKG)

	cd tarball && tar -czf $(PKG).tar.gz $(PKG)
	@echo "Tarball is ready at tarball/$(PKG).tar.gz"

rpmroot:
	mkdir -p $(RPMBUILD)/BUILD
	mkdir -p $(RPMBUILD)/RPMS
	mkdir -p $(RPMBUILD)/SOURCES
	mkdir -p $(RPMBUILD)/SPECS
	mkdir -p $(RPMBUILD)/SRPMS
	mkdir -p $(RPMBUILD)/ZIPS
	mkdir -p $(RPMBUILD)/BUILDROOT

version-update:
	@echo -e "\nUpdating $(RPM_SPEC) version, release, and changelog..."
	sed -e s/__NAME__/$(PKGNAME)/ \
		$(RPM_SPEC).in > $(RPM_SPEC)
	sed -i s/__VERSION__/$(SSG_VERSION)/ \
		$(RPM_SPEC)
	sed -i s/__RELEASE__/$(SSG_RELEASE_VERSION)/ \
		$(RPM_SPEC)
	sed -i 's/__DATE__/$(SSG_RELEASE_DATE)/' \
		$(RPM_SPEC)
	sed -i 's/__REL_MANAGER__/$(SSG_REL_MANAGER)/' \
		$(RPM_SPEC)
	sed -i 's/__REL_MANAGER_MAIL__/$(SSG_REL_MANAGER_MAIL)/' \
		$(RPM_SPEC)

srpm: tarball version-update rpmroot
	cat $(RPM_SPEC) > $(RPMBUILD)/SPECS/$(notdir $(RPM_SPEC))
	cp tarball/$(PKG).tar.gz $(RPMBUILD)/SOURCES/
	@echo -e "\nBuilding $(PKGNAME) SRPM..."
	cd $(RPMBUILD) && rpmbuild $(RPMBUILD_ARGS) --target=$(ARCH) -bs SPECS/$(notdir $(RPM_SPEC)) --nodeps

rpm: srpm
	@echo -e "\nBuilding $(PKGNAME) RPM..."
	cd $(RPMBUILD)/SRPMS && rpmbuild --rebuild --target=$(ARCH) $(RPMBUILD_ARGS) --buildroot $(RPMBUILD)/BUILDROOT -bb $(PKG)-$(SSG_RELEASE_VERSION)$(OS_DIST).src.rpm

.PHONY: tarball srpm rpm
	rm -f scap-security-guide.spec
