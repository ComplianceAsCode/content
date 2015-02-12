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

# Define custom canned sequences / macros below

# Define Makefile targets below

all: fedora rhel6 rhel7 openstack rhevm3 rpm zipfile

fedora:
	cd Fedora/ && $(MAKE)

rhel6:
	cd RHEL/6/ && $(MAKE)

rhel7:
	cd RHEL/7/ && $(MAKE)

openstack:
	cd OpenStack && $(MAKE)

rhevm3:
	cd RHEVM3 && $(MAKE)

validate: fedora rhel6 rhel7 openstack rhevm3
	cd Fedora/ && $(MAKE) validate
	cd RHEL/6/ && $(MAKE) validate
	# Enable below when content validates correctly
	#cd RHEL/7/ && $(MAKE) validate
	#cd OpenStack && $(MAKE) validate
	#cd RHEVM3 && $(MAKE) validate

rpmroot:
	mkdir -p $(RPMBUILD)/BUILD
	mkdir -p $(RPMBUILD)/RPMS
	mkdir -p $(RPMBUILD)/SOURCES
	mkdir -p $(RPMBUILD)/SPECS
	mkdir -p $(RPMBUILD)/SRPMS
	mkdir -p $(RPMBUILD)/ZIPS
	mkdir -p $(RPMBUILD)/BUILDROOT

tarball: rpmroot
	# Copy in the source trees for both RHEL
	# and JBossEAP5 content
	mkdir -p $(RPMBUILD)/$(PKG)
	cp {BUILD.md,Contributors.md,LICENSE,README.md} $(RPMBUILD)/$(PKG)
	cp -r config/ $(RPMBUILD)/$(PKG)
	cp -r shared/ $(RPMBUILD)/$(PKG)
	cp -r --preserve=links --parents RHEL/6/ $(RPMBUILD)/$(PKG)
	cp -r --preserve=links --parents RHEL/7/ $(RPMBUILD)/$(PKG)
	cp -r --preserve=links --parents Fedora/ $(RPMBUILD)/$(PKG)
	cp -r JBossEAP5 $(RPMBUILD)/$(PKG)

	# Don't trust the developers, clean out the build
	# environment before packaging
	(cd $(RPMBUILD)/$(PKG)/RHEL/6/ && $(MAKE) clean)
	(cd $(RPMBUILD)/$(PKG)/RHEL/7/ && $(MAKE) clean)
	(cd $(RPMBUILD)/$(PKG)/Fedora/ && $(MAKE) clean)

	# Create the source tar, copy it to TARBALL
	# (e.g. somewhere in the SOURCES directory)
	cd $(RPMBUILD) && tar -czf $(PKG).tar.gz $(PKG)
	cp $(RPMBUILD)/$(PKG).tar.gz $(TARBALL)

zipfile: rhel6 rpmroot
	# Create a zipfile release, since many SCAP
	# tools desire content in that format
	# (Note: By default zip will store the full path
	#	 relative to the current directory, need
	#	 to cd into $(RPMBUILD)
	cp RHEL/6/output/ssg-* $(RPMBUILD)/ZIPS/
	cp JBossEAP5/eap5-* $(RPMBUILD)/ZIPS/
	# Originally attempted to `cd $(RPMBUILD)/ZIPS` and
	# make the zip from there, however it still placed it
	# at working directory. Should look into this sometime
	#
	#cd $(RPMBUILD)/ZIPS
	#zip -r $(PKG).zip . * -j
	zip -r $(PKG).zip $(RPMBUILD)/ZIPS/* -j
	mv $(PKG).zip $(RPMBUILD)/ZIPS/

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

srpm: tarball version-update
	cat $(RPM_SPEC) > $(RPMBUILD)/SPECS/$(notdir $(RPM_SPEC))
	@echo -e "\nBuilding $(PKGNAME) SRPM..."
	cd $(RPMBUILD) && rpmbuild $(RPMBUILD_ARGS) --target=$(ARCH) -bs SPECS/$(notdir $(RPM_SPEC)) --nodeps

rpm: srpm
	@echo -e "\nBuilding $(PKGNAME) RPM..."
	cd $(RPMBUILD)/SRPMS && rpmbuild --rebuild --target=$(ARCH) $(RPMBUILD_ARGS) --buildroot $(RPMBUILD)/BUILDROOT -bb $(PKG)-$(SSG_RELEASE_VERSION)$(OS_DIST).src.rpm

git-tag:
	@echo -e "\nUpdating $(RPM_SPEC) changelog to reflect new release"
	sed -i '/\%changelog/{n;s/__DATE__/$(RPM_DATESTR)/}' $(RPM_SPEC).in
	sed -i '/\%changelog/{n;s/__REL_MANAGER__/$(SSG_REL_MANAGER)/}' $(RPM_SPEC).in
	sed -i '/\%changelog/{n;s/__REL_MANAGER_MAIL__/$(SSG_REL_MANAGER_MAIL)/}' $(RPM_SPEC).in
	sed -i '/\%changelog/{n;s/__VERSION__/$(SSG_VERSION)/}' $(RPM_SPEC).in
	sed -i '/\%changelog/{n;s/__RELEASE__/$(SSG_RELEASE_VERSION)/}' $(RPM_SPEC).in
	sed -i '/new/{s/__VERSION__/$(SSG_VERSION)/}' $(RPM_SPEC).in
	sed -i '/\%changelog/a\* __DATE__ __REL_MANAGER__ <__REL_MANAGER_MAIL__> __VERSION__-__RELEASE__\n- Make new __VERSION__ release\n' $(RPM_SPEC).in
	@echo -e "\nTagging $(PKGNAME) to new release $(NEW_RELEASE)"
	$(eval NEW_RELEASE:=$(shell git describe $(git rev-list --tags --max-count=1) | awk -F . '{printf "%s.%i.%i", $$1, $$2, $$3 + 1}' | sed 's/^.//'))
	$(eval NEW_MINOR_RELEASE:=$(shell echo $(NEW_RELEASE) | awk -F . '{printf "%i", $$3}'))
	@echo -e "\nUpdating VERSION to new minor release $(NEW_RELEASE)"
	sed -i 's/SSG_MINOR_VERSION.*/SSG_MINOR_VERSION = $(NEW_MINOR_RELEASE)/' $(ROOT_DIR)/VERSION
	sed -i 's/SSG_RELEASE_DATE.*/SSG_RELEASE_DATE = $(RPM_DATESTR)/' $(ROOT_DIR)/VERSION
	@echo -e "\nTagging to new release $(NEW_RELEASE)"
	git add $(RPM_SPEC).in $(ROOT_DIR)/VERSION
	git commit -m "Make new $(NEW_RELEASE) release"
	git tag -a -m "Version $(NEW_RELEASE)" v$(NEW_RELEASE)
clean:
	rm -rf $(RPMBUILD)
	cd RHEL/6 && $(MAKE) clean
	cd RHEL/7 && $(MAKE) clean
	cd OpenStack && $(MAKE) clean
	cd RHEVM3 && $(MAKE) clean
	cd Fedora && $(MAKE) clean
	rm -f scap-security-guide.spec

.PHONY: rhel6 tarball srpm rpm clean all
