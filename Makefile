include VERSION

# Define RHEL6 / JBossEAP5 specific variables below
ROOT_DIR ?= $(CURDIR)
RPMBUILD ?= $(ROOT_DIR)/rpmbuild
RPM_SPEC := $(ROOT_DIR)/scap-security-guide.spec
DEBBUILD ?= $(ROOT_DIR)/debbuild
DEB_SPEC := $(ROOT_DIR)/deb.control
DEB_CHANGELOG :=$(ROOT_DIR)/deb.changelog
DEBPATH ?= $(DEBBUILD)/$(PKGNAME)-$(SSG_VERSION)/
PKGNAME := $(SSG_PROJECT_NAME)
OS_DIST := $(shell rpm --eval '%{dist}')

ARCH := noarch
RPMBUILD_ARGS := --define '_topdir $(RPMBUILD)' --define '_tmppath $(RPMBUILD)'

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

all: validate-buildsystem fedora fuse6 rhel5 rhel6 rhel7 rhel-osp7 rhevm3 webmin firefox jre chromium debian8 wrlinux
dist: chromium-dist firefox-dist fedora-dist fuse6-dist jre-dist rhel6-dist rhel7-dist rhel-osp7-dist debian8-dist wrlinux-dist
jenkins: all validate dist

fedora:
	cd Fedora/ && $(MAKE)

fedora-dist:
	cd Fedora/ && $(MAKE) dist

fuse6:
	cd JBoss/Fuse/6/ && $(MAKE)

fuse6-dist:
	cd JBoss/Fuse/6/ && $(MAKE) dist

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

ubuntu1604:
	cd Ubuntu/16.04/ && $(MAKE)

ubuntu1604-dist:
	cd Ubuntu/16.04/ && $(MAKE) dist

wrlinux:
	cd WRLinux/ && $(MAKE)

wrlinux-dist:
	cd WRLinux/ && $(MAKE) dist

rhel-osp7:
	cd OpenStack/RHEL-OSP/7 && $(MAKE)

rhel-osp7-dist:
	cd OpenStack/RHEL-OSP/7 && $(MAKE) dist

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

opensuse:
	cd OpenSUSE/ && $(MAKE)

opensuse-dist:
	cd OpenSUSE && $(MAKE) dist

suse11:
	cd SUSE/11 && $(MAKE)

suse11-dist:
	cd SUSE/11 && $(MAKE) dist

suse12:
	cd SUSE/12 && $(MAKE)

suse12-dist:
	cd SUSE/12 && $(MAKE) dist

validate-buildsystem:
	for makefile in `find -name Makefile`; do \
		if grep '[[:space:]]\+$$' $$makefile; then \
			echo "Trailing Whitespace in $$makefile"; \
			exit 1; \
		fi \
	done

validate-wrlinux: wrlinux
	# Enable below when content validates correctly
	# cd WRLinux/ && $(MAKE) validate

validate-fedora: fedora
	cd Fedora/ && $(MAKE) validate

validate-rhel5: rhel5
	cd RHEL/5/ && $(MAKE) validate

validate-rhel6: rhel6
	cd RHEL/6/ && $(MAKE) validate

validate-rhel7: rhel7
	cd RHEL/7/ && $(MAKE) validate

validate-debian8: debian8

validate-ubuntu1604: ubuntu1604
	# Enable below when content validates correctly
	#cd Debian/8/ && $(MAKE) validate

validate-rhel-osp7: rhel-osp7
	cd OpenStack/RHEL-OSP/7/ && $(MAKE) validate

validate-rhevm3: rhevm3
	# Enable below when content validates correctly
	#cd RHEVM3 && $(MAKE) validate

validate-chromium: chromium
	cd Chromium/ && $(MAKE) validate

validate-firefox: firefox
	cd Firefox/ && $(MAKE) validate

validate-fuse6: fuse6
	cd JBoss/Fuse/6 && $(MAKE) validate

validate-jre: jre
	cd JRE/ && $(MAKE) validate

validate-opensuse: opensuse
	# Enable below when content validates correctly
	#cd OpenSUSE/ && $(MAKE) validate

validate-suse11: suse11
	# Enable below when content validates correctly
	#cd SUSE/11 && $(MAKE) validate

validate-suse12: suse12
	# Enable below when content validates correctly
	#cd SUSE/12 && $(MAKE) validate

validate: validate-fedora validate-fuse6 validate-rhel5 validate-rhel6 validate-rhel7 validate-debian8 validate-ubuntu1604 validate-wrlinux validate-rhel-osp7 validate-rhevm3 validate-chromium validate-firefox validate-jre

tarball:
	@# Copy in the source trees for both RHEL
	@# and JBossEAP5 content
	mkdir -p tarball/$(PKG)
	cp Makefile tarball/$(PKG)/
	cp BUILD.md Contributors.md LICENSE VERSION README.md tarball/$(PKG)/
	cp -r config/ tarball/$(PKG)
	cp -r docs/ tarball/$(PKG)
	cp -r shared/ tarball/$(PKG)
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
	cp -r --preserve=links --parents Webmin/ tarball/$(PKG)
	cp -r --preserve=links --parents WRLinux/ tarball/$(PKG)

	@# Don't trust the developers, clean out the build
	@# environment before packaging
	(cd tarball/$(PKG)/RHEL/5/ && $(MAKE) clean)
	(cd tarball/$(PKG)/RHEL/6/ && $(MAKE) clean)
	(cd tarball/$(PKG)/RHEL/7/ && $(MAKE) clean)
	(cd tarball/$(PKG)/Debian/8/ && $(MAKE) clean)
	(cd tarball/$(PKG)/WRLinux/ && $(MAKE) clean)
	(cd tarball/$(PKG)/Fedora/ && $(MAKE) clean)
	(cd tarball/$(PKG)/Chromium/ && $(MAKE) clean)
	(cd tarball/$(PKG)/JRE/ && $(MAKE) clean)
	(cd tarball/$(PKG)/Firefox/ && $(MAKE) clean)
	(cd tarball/$(PKG)/JBoss/Fuse/6/ && $(MAKE) clean)
	(cd tarball/$(PKG)/Webmin/ && $(MAKE) clean)

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

debroot:
	mkdir -p $(DEBBUILD)/DEBS
	mkdir -p $(DEBPATH)/DEBIAN
	mkdir -p $(DEBPATH)/$(PREFIX)/$(DATADIR)/scap/ssg
	mkdir -p $(DEBPATH)/$(PREFIX)/$(DATADIR)/scap-security-guide/kickstart
	mkdir -p $(DEBPATH)/$(PREFIX)/$(MANDIR)/en/man8
	mkdir -p $(DEBPATH)/$(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	mkdir -p $(DEBPATH)/$(PREFIX)/$(DOCDIR)/scap-security-guide/tables

zipfile: dist
	@# ZIP only contains source datastreams and kickstarts, people who
	@# want sources to build from should get the tarball instead.
	rm -rf zipfile/$(PKG)
	mkdir -p zipfile/$(PKG)
	cp README.md zipfile/$(PKG)/
	cp Contributors.md zipfile/$(PKG)/
	cp LICENSE zipfile/$(PKG)/
	cp */dist/content/*-ds.xml zipfile/$(PKG)/
	cp */*/dist/content/*-ds.xml zipfile/$(PKG)/
	cp */*/*/dist/content/*-ds.xml zipfile/$(PKG)/
	mkdir zipfile/$(PKG)/kickstart
	cp RHEL/{6,7}/kickstart/*-ks.cfg zipfile/$(PKG)/kickstart/
	(cd zipfile && zip -r $(PKG).zip $(PKG)/)
	@echo "ZIP file is ready at zipfile/$(PKG).zip"

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

	@echo -e "\nUpdating $(DEB_SPEC) version, release, and changelog..."
	sed -e s/__NAME__/$(PKGNAME)/g \
		$(DEB_SPEC).in > $(DEB_SPEC)
	sed -i s/__VERSION__/$(SSG_VERSION)/ \
		$(DEB_SPEC)
	sed -i s/__RELEASE__/$(SSG_RELEASE_VERSION)/ \
		$(DEB_SPEC)
	sed -i 's/__DATE__/$(SSG_RELEASE_DATE)/' \
		$(DEB_SPEC)
	sed -i 's/__REL_MANAGER__/$(SSG_REL_MANAGER)/' \
		$(DEB_SPEC)
	sed -i 's/__REL_MANAGER_MAIL__/$(SSG_REL_MANAGER_MAIL)/' \
		$(DEB_SPEC)
	sed -e s/__NAME__/$(PKGNAME)/g \
		$(DEB_CHANGELOG).in >> $(DEB_CHANGELOG)
	sed -i s/__VERSION__/$(SSG_VERSION)/ \
		$(DEB_CHANGELOG)
	sed -i s/__RELEASE__/$(SSG_RELEASE_VERSION)/ \
		$(DEB_CHANGELOG)
	sed -i 's/__DATE__/$(SSG_RELEASE_DATE)/' \
		$(DEB_CHANGELOG)
	sed -i 's/__REL_MANAGER__/$(SSG_REL_MANAGER)/' \
		$(DEB_CHANGELOG)
	sed -i 's/__REL_MANAGER_MAIL__/$(SSG_REL_MANAGER_MAIL)/' \
		$(DEB_CHANGELOG)

deb: debian8 tarball version-update debroot
	cp $(DEB_SPEC) $(DEBPATH)/DEBIAN/control
	chmod 0755 $(DEBPATH)/DEBIAN/
	install -m 0644 $(ROOT_DIR)/Debian/8/dist/content/* $(DEBPATH)/$(PREFIX)/$(DATADIR)/scap/ssg/
	install -m 0644 $(ROOT_DIR)/Debian/8/dist/guide/* $(DEBPATH)/$(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	install -m 0644 $(ROOT_DIR)/docs/scap-security-guide.8 $(DEBPATH)/$(PREFIX)/$(MANDIR)/en/man8/
	install -m 0644 $(ROOT_DIR)/LICENSE $(DEBPATH)/$(PREFIX)/$(DOCDIR)/scap-security-guide/copyright
	install -m 0644 $(ROOT_DIR)/README.md $(DEBPATH)/$(PREFIX)/$(DOCDIR)/scap-security-guide
	install -m 0644 $(DEB_CHANGELOG) $(DEBPATH)/$(PREFIX)/$(DOCDIR)/scap-security-guide/changelog
	gzip -n9 $(DEBPATH)/$(PREFIX)/$(MANDIR)/en/man8/scap-security-guide.8
	gzip -n9 $(DEBPATH)/$(PREFIX)/$(DOCDIR)/scap-security-guide/changelog
	dpkg-deb --build $(DEBPATH) $(DEBBUILD)/DEBS/$(PKGNAME)-$(SSG_VERSION).deb
	#lintian --no-tag-display-limit -c $(DEBBUILD)/DEBS/$(PKGNAME)-$(SSG_VERSION).deb

srpm: tarball version-update rpmroot
	cat $(RPM_SPEC) > $(RPMBUILD)/SPECS/$(notdir $(RPM_SPEC))
	cp tarball/$(PKG).tar.gz $(RPMBUILD)/SOURCES/
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
	rm -rf $(DEBBUILD)
	rm -rf tarball/
	rm -rf zipfile/
	rm -rf shared/output
	cd RHEL/5 && $(MAKE) clean
	cd RHEL/6 && $(MAKE) clean
	cd RHEL/7 && $(MAKE) clean
	cd Debian/8 && $(MAKE) clean
	cd WRLinux && $(MAKE) clean
	cd OpenStack/RHEL-OSP/7 && $(MAKE) clean
	cd RHEVM3 && $(MAKE) clean
	cd Fedora && $(MAKE) clean
	cd JBoss/Fuse/6 && $(MAKE) clean
	cd JRE && $(MAKE) clean
	cd Firefox && $(MAKE) clean
	cd Webmin && $(MAKE) clean
	cd Chromium && $(MAKE) clean
	rm -f $(RPM_SPEC)
	rm -f $(DEB_SPEC)
	rm -f $(DEB_CHANGELOG)

install: dist
	install -d $(PREFIX)/$(DATADIR)/scap/ssg
	install -d $(PREFIX)/$(DATADIR)/scap-security-guide
	install -d $(PREFIX)/$(DATADIR)/scap-security-guide/kickstart
	install -d $(PREFIX)/$(MANDIR)/en/man8/
	install -d $(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	install -d $(PREFIX)/$(DOCDIR)/scap-security-guide/tables
	install -m 0644 Fedora/dist/content/* $(PREFIX)/$(DATADIR)/scap/ssg/
	install -m 0644 Fedora/dist/guide/* $(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	install -m 0644 RHEL/6/dist/content/* $(PREFIX)/$(DATADIR)/scap/ssg/
	install -m 0644 RHEL/6/kickstart/*-ks.cfg $(PREFIX)/$(DATADIR)/scap-security-guide/kickstart
	install -m 0644 RHEL/6/dist/guide/* $(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	install -m 0644 RHEL/6/dist/tables/* $(PREFIX)/$(DOCDIR)/scap-security-guide/tables
	install -m 0644 RHEL/7/kickstart/*-ks.cfg $(PREFIX)/$(DATADIR)/scap-security-guide/kickstart
	install -m 0644 RHEL/7/dist/content/* $(PREFIX)/$(DATADIR)/scap/ssg/
	install -m 0644 RHEL/7/dist/guide/* $(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	install -m 0644 RHEL/7/dist/tables/* $(PREFIX)/$(DOCDIR)/scap-security-guide/tables
	install -m 0644 OpenStack/RHEL-OSP/7/dist/content/* $(PREFIX)/$(DATADIR)/scap/ssg/
	install -m 0644 OpenStack/RHEL-OSP/7/dist/guide/* $(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	install -m 0644 Chromium/dist/content/* $(PREFIX)/$(DATADIR)/scap/ssg/
	install -m 0644 Chromium/dist/guide/* $(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	install -m 0644 Firefox/dist/content/* $(PREFIX)/$(DATADIR)/scap/ssg/
	install -m 0644 Firefox/dist/guide/* $(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	install -m 0644 JBoss/Fuse/6/dist/content/* $(PREFIX)/$(DATADIR)/scap/ssg/
	install -m 0644 JBoss/Fuse/6/dist/guide/* $(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	install -m 0644 JRE/dist/content/* $(PREFIX)/$(DATADIR)/scap/ssg/
	install -m 0644 JRE/dist/guide/* $(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	install -m 0644 Debian/8/dist/content/* $(PREFIX)/$(DATADIR)/scap/ssg/
	install -m 0644 Debian/8/dist/guide/* $(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	install -m 0644 WRLinux/dist/content/* $(PREFIX)/$(DATADIR)/scap/ssg/
	install -m 0644 WRLinux/dist/guide/* $(PREFIX)/$(DOCDIR)/scap-security-guide/guides
	install -m 0644 docs/scap-security-guide.8 $(PREFIX)/$(MANDIR)/en/man8/
	install -m 0644 LICENSE $(PREFIX)/$(DOCDIR)/scap-security-guide
	install -m 0644 README.md $(PREFIX)/$(DOCDIR)/scap-security-guide
	@# install a symlink in the old content location for compatibility
	install -d $(PREFIX)/$(DATADIR)/xml/scap/ssg
	ln -sf ../../../scap/ssg $(PREFIX)/$(DATADIR)/xml/scap/ssg/content

.PHONY: rhel5 rhel6 rhel7 rhel-osp7 debian8 wrlinux jre firefox fuse6 webmin tarball srpm rpm clean all
	rm -f scap-security-guide.spec
