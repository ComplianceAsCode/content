
# IMPORTANT NOTE: This spec file is solely dedicated to make changes to the
# Fedora's scap-security-guide package. If you want to apply changes against
# the main RHEL-6 scap-security-guide RPM content, use scap-security-guide.spec
# file one level up - in the main scap-security-guide directory (instead of
# this one).

%global	fedorassgversion	4.rc16

Name:		scap-security-guide
Version:	0.1.%{fedorassgversion}
Release:	1%{?dist}
Summary:	Security guidance and baselines in SCAP formats
Group:		Applications/System
License:	Public Domain
URL:		https://fedorahosted.org/scap-security-guide/
Source0:	http://fedorapeople.org/~jlieskov/%{name}-%{version}.tar.gz
BuildArch:	noarch
BuildRequires:	libxslt, expat, python, openscap-utils >= 0.9.1, python-lxml
Requires:	xml-common, openscap-utils >= 0.9.1
Obsoletes:	openscap-content < 0:0.9.13

%description
The scap-security-guide project provides a guide for configuration of the
system from the final system's security point of view. The guidance is specified
in the Security Content Automation Protocol (SCAP) format and constitutes
a catalog of practical hardening advice, linked to government requirements
where applicable. The project bridges the gap between generalized policy
requirements and specific implementation guidelines. The Fedora system
administrator can use the oscap CLI tool from openscap-utils package, or the
scap-workbench GUI tool from scap-workbench package to verify that the system
conforms to provided guideline. Refer to scap-security-guide(8) manual page for
further information.

%package	compat
Summary:	Extra package to ensure compatibility with firstaidkit-plugin-openscap
License:	Public Domain
BuildArch:	noarch
Requires:	xml-common, openscap-utils >= 0.9.1
Provides:	openscap-content, firstaidkit-plugin-openscap

%description	compat
This package corrects Provides requirements needed to maintain
backward-compatibility with openscap-content and firstaidkit-plugin-openscap
packages.

%prep
%setup -q -n %{name}-%{version}

%build
cd Fedora && make dist

%install
mkdir -p %{buildroot}%{_datadir}/xml/scap/ssg/fedora
mkdir -p %{buildroot}%{_mandir}/en/man8/

# Add in core content (SCAP XCCDF and OVAL content)
cp -a Fedora/dist/content/* %{buildroot}%{_datadir}/xml/scap/ssg/fedora

# Add in manpage
cp -a Fedora/input/auxiliary/scap-security-guide.8 %{buildroot}%{_mandir}/en/man8/scap-security-guide.8

%files
%{_datadir}/xml/scap
%lang(en) %{_mandir}/en/man8/scap-security-guide.8.*
%doc Fedora/LICENSE Fedora/output/ssg-fedora-guide.html

%files compat

%changelog
* Fri Dec 20 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.4.rc16-1
- Fix remediation for sshd set keepalive (ClientAliveCountMax) and move
  it to /shared
- Add shared remediations for sshd disable empty passwords and
  sshd set idle timeout

* Thu Dec 19 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.4.rc15-1
- Shared remediation for sshd disable root login
- Add empty -compat subpackage to ensure backward-compatibility with
  openscap-content and firstaidkit-plugin-openscap packages (RH BZ#1040335)

* Mon Dec 16 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.4.rc14-1
- OVAL check for sshd disable root login
- Fix typo in OVAL check for sshd disable empty passwords

* Fri Dec 13 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.4.rc13-1
- OVAL check for sshd disable empty passwords
- Unselect no shelllogin for systemaccounts rule from being run by default

* Mon Dec 09 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.4.rc12-1
- Rename XCCDF rules
- Revert Set up Fedora release name and CPE based on build system properties

* Fri Dec 06 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.4.rc11-1
- Shared OVAL check for Verify that Shared Library Files Have Root Ownership
- Shared OVAL check for Verify that System Executables Have Restrictive Permissions
- Shared OVAL check for Verify that System Executables Have Root Ownership

* Thu Dec 05 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.4.rc10-1
- Shared OVAL check for Verify that Shared Library Files Have Restrictive
  Permissions

* Mon Dec 02 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.4.rc9-1
- Fix remediation for Disable Prelinking rule

* Fri Nov 29 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.4.rc8-1
- OVAL check and remediation for sshd's ClientAliveCountMax rule
- OVAL check for sshd's ClientAliveInterval rule

* Thu Nov 28 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.4.rc7-1
- Include descriptions for permissions section, and rules for checking
  permissions and ownership of shared library files and system executables
- Disable selected rules by default
- Add remediation for Disable Prelinking rule

* Tue Nov 26 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.4.rc6-1
- Adjust service-enable-macro, service-disable-macro XSLT transforms
  definition to evaluate to proper systemd syntax
- Fix service_ntpd_enabled OVAL check make validate to pass again
- Include patch from Šimon Lukašík to obsolete openscap-content
  package (RH BZ#1028706)

* Mon Nov 25 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.4.rc5-1
- Add OVAL check to test if there's is remote NTP server configured for
  time data
- Add system settings section for the guide (to track system wide
  hardening configurations)
- Include disable prelink rule and OVAL check for it

* Mon Nov 25 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.4.rc4-1
- Initial OVAL check if ntpd service is enabled. Add package_installed
  OVAL templating directory structure and functionality.

* Fri Nov 22 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.4.rc3-1
- Include services section, and XCCDF description for selected ntpd's
  sshd's service rules

* Tue Nov 19 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.4.rc2-1
- Include remediations for login.defs' based password minimum, maximum and
  warning age rules

* Mon Nov 18 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.4.rc1-1
- Include directory structure to support remediations
- Add SCAP "replace or append pattern value in text file based on variable"
  remediation script generator
- Add remediation for "Set Password Minimum Length in login.defs" rule

* Mon Nov 18 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.3-1
- Update versioning scheme - move fedorassgrelease to be part of
  upstream version. Rename it to fedorassgversion to avoid name collision
  with Fedora package release.

* Tue Oct 22 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1-3
- Add .gitignore for Fedora output directory
- Set up Fedora release name and CPE based on build system properties
- Use correct file paths in scap-security-guide(8) manual page 
  (RH BZ#1018905, c#10)
- Apply further changes motivated by scap-security-guide Fedora RPM review
  request (RH BZ#1018905, c#8):
  * update package description,
  * make content files to be owned by the scap-security-guide package,
  * remove Fedora release number from generated content files,
  * move HTML form of the guide under the doc directory (together
    with that drop fedora/content subdir and place the content
    directly under fedora/ subdir).
- Fixes for scap-security-guide Fedora RPM review request (RH BZ#1018905):
  * drop Fedora release from package provided files' final path (c#5),
  * drop BuildRoot, selected Requires:, clean section, drop chcon for
    manual page, don't gzip man page (c#4),
  * change package's description (c#4),
  * include PD license text (#c4).

* Mon Oct 14 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1-2
- Provide manual page for scap-security-guide
- Remove percent sign from spec's changelog to silence rpmlint warning
- Convert RHEL6 'Restrict Root Logins' section's rules to Fedora
- Convert RHEL6 'Set Password Expiration Parameter' rules to Fedora
- Introduce 'Account and Access Control' section
- Convert RHEL6 'Verify Proper Storage and Existence of Password Hashes' section's
  rules to Fedora
- Set proper name of the build directory in the spec's setup macro.
- Replace hard-coded paths with macros. Preserve attributes when copying files.

* Tue Sep 17 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1-1
- Initial Fedora SSG RPM.
