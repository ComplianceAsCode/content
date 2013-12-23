
%global		redhatssgrelease	16

Name:		scap-security-guide
Version:	0.1
Release:	%{redhatssgrelease}%{?dist}
Summary:	Security guidance and baselines in SCAP formats
Vendor:		scap-security-guide

Group:		System Environment/Base
License:	Public Domain
URL:		https://fedorahosted.org/scap-security-guide/

Source0:	http://repos.ssgproject.org/sources/%{name}-%{version}-%{redhatssgrelease}.tar.gz

BuildArch:	noarch

BuildRequires:	libxslt, expat, python, openscap-utils >= 0.9.1, python-lxml
Requires:	xml-common, openscap-utils >= 0.9.1

%description
The scap-security-guide project provides a guide for configuration of the
system from the final system's security point of view. The guidance is
specified in the Security Content Automation Protocol (SCAP) format and
constitutes a catalog of practical hardening advice, linked to government
requirements where applicable. The project bridges the gap between generalized
policy requirements and specific implementation guidelines. The Red Hat
Enterprise Linux 6 system administrator can use the oscap command-line tool
from the openscap-utils package to verify that the system conforms to provided
guideline. Refer to scap-security-guide(8) manual page for further information.

%prep
%setup -q -n %{name}-%{version}-%{redhatssgrelease}

%build
(cd RHEL/6 && make dist)
(cd RHEL/7 && make dist)

%install
mkdir -p %{buildroot}%{_datadir}/xml/scap/ssg/content
mkdir -p %{buildroot}%{_mandir}/en/man8/

# Add in core content (SCAP)
cp -a RHEL/6/dist/content/* %{buildroot}%{_datadir}/xml/scap/ssg/content/
cp -a RHEL/7/dist/content/* %{buildroot}%{_datadir}/xml/scap/ssg/content/
cp -a JBossEAP5/eap5-* %{buildroot}%{_datadir}/xml/scap/ssg/content/

# Add in manpage
cp -a RHEL/6/input/auxiliary/scap-security-guide.8 %{buildroot}%{_mandir}/en/man8/scap-security-guide.8

%files
%{_datadir}/xml/scap
%lang(en) %{_mandir}/en/man8/scap-security-guide.8.gz
%doc RHEL/6/LICENSE RHEL/6/output/rhel6-guide.html RHEL/6/output/table-rhel6-cces.html RHEL/6/output/table-rhel6-nistrefs-common.html RHEL/6/output/table-rhel6-nistrefs.html RHEL/6/output/table-rhel6-srgmap-flat.html RHEL/6/output/table-rhel6-srgmap-flat.xhtml RHEL/6/output/table-rhel6-srgmap.html RHEL/6/output/table-rhel6-stig.html JBossEAP5/docs/JBossEAP5_Guide.html

%changelog
* Mon Dec 23 2013 Shawn Wells <shawn@redhat.com> 0.1-16.rc1
+ Added RHEL7 content to SSG rpm
+ Added to RHEL7 content pool:
- OVAL for partition_for_tmp
- OVAL for partition_for_var
- OVAL for partition_for_var_log
- OVAL for partition_for_var_log_audit
- OVAL for selinux_state
- OVAL for selinux_policytype
- OVAL for ensure_redhat_gpgkey_installed
- OVAL for ensure_gpgcheck_never_disabled
- OVAL for package_aide_installed
- OVAL for accounts_password_reuse_limit
- OVAL for no_shelllogin_for_systemaccounts
- OVAL for no_empty_passwords
- OVAL for no_hashes_outside_shadow
- OVAL for accounts_no_uid_except_zero
- OVAL for accounts_password_minlen_login_defs
- OVAL for accounts_minimum_age_login_defs
- OVAL for accounts_password_warn_age_login_defs
- OVAL for accounts_password_pam_cracklib_retry

* Fri Nov 01 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1-15
- Version bump

* Sat Oct 26 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1-15.rc5
- Point the spec's source to proper remote tarball location
- Modify the main Makefile to use remote tarball when building RHEL/6's SRPM

* Sat Oct 26 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1-15.rc4
- Don't include the table html files two times
- Remove makewhatis

* Fri Oct 25 2013 Shawn Wells <shawn@redhat.com> 0.1-15.rc3
- [bugfix] Updated rsyslog_remote_loghost to scan /etc/rsyslog.conf and /etc/rsyslog.d/*
- Numberous XCCDF->OVAL naming schema updates
- All rules now have CCE

* Fri Oct 25 2013 Shawn Wells <shawn@redhat.com> 0.1-15.rc2
- Updated file permissions of JBossEAP5/eap5-cpe-dictionary.xml (chmod -x) to resolve rpmlint errors
- RHEL/6 HTML table naming bugfixes (table-rhel6-*, not table-*-rhel6)

* Fri Oct 25 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1-15.rc1
- Apply spec file changes required by review request (RH BZ#1018905)

* Thu Oct 24 2013 Shawn Wells <shawn@redhat.com> 0.1-14
- Formal RPM release
- Inclusion of rht-ccp profile
- OVAL unit testing patches
- Bash remediation patches
- Bugfixes

* Mon Oct 07 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1-14.rc1
- Change RPM versioning scheme to include release into tarball

* Sat Sep 28 2013 Shawn Wells <shawn@redhat.com> 0.1-13
- Updated RPM spec file to fix rpmlint warnings

* Wed Jun 26 2013 Shawn Wells <shawn@redhat.com> 0.1-12
- Updated RPM version to 0.1-12

* Fri Apr 26 2013 Shawn Wells <shawn@redhat.com> 0.1-11
- Significant amount of OVAL bugfixes
- Incorporation of Draft RHEL/6 STIG feedback

* Sat Feb 16 2013 Shawn Wells <shawn@redhat.com> 0.1-10
- SSG now includes JBoss EAP5 content!
- `man scap-security-guide`
- OVAL bug fixes
- NIST 800-53 mappings update

* Wed Nov 28 2012 Shawn Wells <shawn@redhat.com> 0.1-9
- Updated BuildRequires to reflect python-lxml (thank you, Ray S.!)
- Reverting to noarch RPM

* Tue Nov 27 2012 Shawn Wells <shawn@redhat.com> 0.1-8
- Significant copy editing to XCCDF rules per community
  feedback on the DISA RHEL/6 STIG Initial Draft

* Thu Nov 1 2012 Shawn Wells <shawn@redhat.com> 0.1-7
- Corrected XCCDF content errors
- OpenSCAP now supports CPE dictionaries, important to
  utilize --cpe-dict when scanning machines with OpenSCAP,
  e.g.:
  $ oscap xccdf eval --profile stig-server \
   --cpe-dict ssg-rhel6-cpe-dictionary.xml ssg-rhel6-xccdf.xml

* Mon Oct 22 2012 Shawn Wells <shawn@redhat.com> 0.1-6
- Corrected RPM versioning, we're on 0.1 release 6 (not version 1 release 6)
- Updated RPM includes feedback received from DoD Consensus meetings

* Fri Oct 5  2012 Jeffrey Blank <blank@eclipse.ncsc.mil> 1.0-5
- Adjusted installation directory to /usr/share/xml/scap.

* Tue Aug 28  2012 Spencer Shimko <sshimko@tresys.com> 1.0-4
- Fix BuildRequires and Requires.

* Tue Jul 3 2012 Jeffrey Blank <blank@eclipse.ncsc.mil> 1.0-3
- Modified install section, made description more concise.

* Thu Apr 19 2012 Spencer Shimko <sshimko@tresys.com> 1.0-2
- Minor updates to pass some variables in from build system.

* Mon Apr 02 2012 Shawn Wells <shawn@redhat.com> 1.0-1
- First attempt at SSG RPM. May ${deity} help us...
