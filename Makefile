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

# Define custom canned sequences / macros below

# Define Makefile targets below

all: validate-buildsystem fedora rhel5 rhel6 rhel7 rhel-osp7 rhevm3 webmin firefox jre chromium debian8 rpm
dist: chromium-dist firefox-dist fedora-dist jre-dist rhel6-dist rhel7-dist debian8-dist
jenkins: clean all validate dist

fedora:
	cd Fedora/ && $(MAKE)

fedora-dist:
	cd Fedora/ && $(MAKE) dist

rhel5:
	cd RHEL/5/ && $(MAKE)

rhel6:
	cd RHEL/6/ && $(MAKE)

rhel6-dist:
	cd RHEL/6/ && $(MAKE) dist

rhel7:
	cd RHEL/7/ && $(MAKE)

rhel7-dist:
	cd RHEL/7/ && $(MAKE) dist

debian8:
	cd Debian/8/ && $(MAKE)

debian8-dist:
	cd Debian/8/ && $(MAKE) dist

rhel-osp7:
	cd OpenStack/RHEL-OSP/7 && $(MAKE)

rhevm3:
	cd RHEVM3 && $(MAKE)

jre:
	cd JRE/ && $(MAKE)

jre-dist:
	cd JRE/ && $(MAKE) dist

firefox:
	cd Firefox/ && $(MAKE)

firefox-dist:
	cd Firefox/ && $(MAKE) dist

webmin:
	cd Webmin/ && $(MAKE)

chromium:
	cd Chromium/ && $(MAKE)

chromium-dist:
	cd Chromium/ && $(MAKE) dist

validate-buildsystem:
	for makefile in `find -name Makefile`; do \
		if grep '[[:space:]]\+$$' $$makefile; then \
			echo "Trailing Whitespace in $$makefile"; \
			exit 1; \
		fi \
	done

validate: fedora rhel5 rhel6 rhel7 debian8 rhel-osp7 rhevm3 chromium firefox jre
	cd Fedora/ && $(MAKE) validate
	cd RHEL/6/ && $(MAKE) validate
	#cd Debian/8/ && $(MAKE) validate
	cd Chromium/ && $(MAKE) validate
	cd Firefox/ && $(MAKE) validate
	cd JRE/ && $(MAKE) validate
	cd OpenStack/RHEL-OSP/7/ && $(MAKE) validate
	# Enable below when content validates correctly
	#cd RHEL/5/ && $(MAKE) validate
	#cd RHEL/7/ && $(MAKE) validate
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
	cp BUILD.md Contributors.md LICENSE VERSION README.md  $(RPMBUILD)/$(PKG)/
	cp -r config/ $(RPMBUILD)/$(PKG)
	cp -r docs/ $(RPMBUILD)/$(PKG)
	cp -r shared/ $(RPMBUILD)/$(PKG)
	cp -r --preserve=links --parents RHEL/5/ $(RPMBUILD)/$(PKG)
	cp -r --preserve=links --parents RHEL/6/ $(RPMBUILD)/$(PKG)
	cp -r --preserve=links --parents RHEL/7/ $(RPMBUILD)/$(PKG)
	cp -r --preserve=links --parents Debian/8/ $(RPMBUILD)/$(PKG)
	cp -r --preserve=links --parents Fedora/ $(RPMBUILD)/$(PKG)
	cp -r --preserve=links --parents JRE/ $(RPMBUILD)/$(PKG)
	cp -r --preserve=links --parents Firefox/ $(RPMBUILD)/$(PKG)
	cp -r --preserve=links --parents Webmin/ $(RPMBUILD)/$(PKG)
	cp -r --preserve=links --parents Chromium $(RPMBUILD)/$(PKG)
	cp -r JBossEAP5 $(RPMBUILD)/$(PKG)

	# Don't trust the developers, clean out the build
	# environment before packaging
	(cd $(RPMBUILD)/$(PKG)/RHEL/5/ && $(MAKE) clean)
	(cd $(RPMBUILD)/$(PKG)/RHEL/6/ && $(MAKE) clean)
	(cd $(RPMBUILD)/$(PKG)/RHEL/7/ && $(MAKE) clean)
	(cd $(RPMBUILD)/$(PKG)/Debian/8/ && $(MAKE) clean)
	(cd $(RPMBUILD)/$(PKG)/Fedora/ && $(MAKE) clean)
	(cd $(RPMBUILD)/$(PKG)/Chromium/ && $(MAKE) clean)
	(cd $(RPMBUILD)/$(PKG)/JRE/ && $(MAKE) clean)
	(cd $(RPMBUILD)/$(PKG)/Firefox/ && $(MAKE) clean)
	(cd $(RPMBUILD)/$(PKG)/Webmin/ && $(MAKE) clean)

	# Create the source tar, copy it to TARBALL
	# (e.g. somewhere in the SOURCES directory)
	cd $(RPMBUILD) && tar -czf $(PKG).tar.gz $(PKG)
	cp $(RPMBUILD)/$(PKG).tar.gz $(TARBALL)

zipfile: dist
	# ZIP only contains source datastreams and kickstarts, people who
	# want sources to build from should get the tarball instead.
	rm -rf $(PKG)
	mkdir $(PKG)
	cp README.md $(PKG)/
	cp Contributors.md $(PKG)/
	cp LICENSE $(PKG)/
	cp */dist/content/*-ds.xml $(PKG)/
	cp */*/dist/content/*-ds.xml $(PKG)/
	mkdir $(PKG)/kickstart
	cp RHEL/{6,7}/kickstart/*-ks.cfg $(PKG)/kickstart/
	zip -r $(PKG).zip $(PKG)/
	rm -r $(PKG)/

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
	cd RHEL/5 && $(MAKE) clean
	cd RHEL/6 && $(MAKE) clean
	cd RHEL/7 && $(MAKE) clean
	cd Debian/8 && $(MAKE) clean
	cd OpenStack/RHEL-OSP/7 && $(MAKE) clean
	cd RHEVM3 && $(MAKE) clean
	cd Fedora && $(MAKE) clean
	cd JRE && $(MAKE) clean
	cd Firefox && $(MAKE) clean
	cd Webmin && $(MAKE) clean
	cd Chromium && $(MAKE) clean
	rm -f scap-security-guide.spec

install: dist
	install -d $(PREFIX)/$(DATADIR)/xml/scap/ssg/content/
	install -d $(PREFIX)/$(DATADIR)/scap-security-guide
	install -d $(PREFIX)/$(DATADIR)/scap-security-guide/kickstart
	install -d $(PREFIX)/$(MANDIR)/en/man8/
	install -d $(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	install -m 0644 Fedora/dist/content/* $(PREFIX)/$(DATADIR)/xml/scap/ssg/content/
	install -m 0644 Fedora/dist/guide/* $(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	install -m 0644 RHEL/6/dist/content/* $(PREFIX)/$(DATADIR)/xml/scap/ssg/content/
	install -m 0644 shared/remediations/bash/templates/remediation_functions $(PREFIX)/$(DATADIR)/scap-security-guide/
	install -m 0644 RHEL/6/kickstart/*-ks.cfg $(PREFIX)/$(DATADIR)/scap-security-guide/kickstart
	install -m 0644 RHEL/7/kickstart/*-ks.cfg $(PREFIX)/$(DATADIR)/scap-security-guide/kickstart
	install -m 0644 RHEL/6/dist/guide/* $(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	install -m 0644 RHEL/7/dist/content/* $(PREFIX)/$(DATADIR)/xml/scap/ssg/content/
	install -m 0644 RHEL/7/dist/guide/* $(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	install -m 0644 Chromium/dist/content/* $(PREFIX)/$(DATADIR)/xml/scap/ssg/content/
	install -m 0644 Chromium/dist/guide/* $(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	install -m 0644 Firefox/dist/content/* $(PREFIX)/$(DATADIR)/xml/scap/ssg/content/
	install -m 0644 Firefox/dist/guide/* $(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	install -m 0644 JRE/dist/content/* $(PREFIX)/$(DATADIR)/xml/scap/ssg/content/
	install -m 0644 JRE/dist/guide/* $(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	install -m 0644 Debian/8/dist/content/* $(PREFIX)/$(DATADIR)/xml/scap/ssg/content/
	install -m 0644 Debian/8/dist/guide/* $(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	install -m 0644 docs/scap-security-guide.8 $(PREFIX)/$(MANDIR)/en/man8/
	install -m 0644 LICENSE $(PREFIX)/$(DOCDIR)/scap-security-guide
	install -m 0644 README.md $(PREFIX)/$(DOCDIR)/scap-security-guide

.PHONY: rhel5 rhel6 rhel7 debian8 jre firefox webmin tarball srpm rpm clean all
	rm -f scap-security-guide.spec
