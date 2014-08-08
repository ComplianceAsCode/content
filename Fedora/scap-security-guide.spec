
# IMPORTANT NOTE: This spec file is solely dedicated to make changes to the
# Fedora's scap-security-guide package. If you want to apply changes against
# the main RHEL-6 scap-security-guide RPM content, use scap-security-guide.spec
# file one level up - in the main scap-security-guide directory (instead of
# this one).

# Used for Fedora scap-security-guide RPM package versioning
%global	fedorassgversion	5

# Used to specify RHEL scap-security-guide tarball source
# (needs to match latest EPEL-6 scap-security-guide RPM release)
%global	rhelssgversion		0.1.18

Name:		scap-security-guide
Version:	0.1.%{fedorassgversion}
Release:	2%{?dist}
Summary:	Security guidance and baselines in SCAP formats
Group:		Applications/System
License:	Public Domain
URL:		https://fedorahosted.org/scap-security-guide/
Source0:	http://fedorapeople.org/~jlieskov/%{name}-%{version}.tar.gz
Source1:	http://repos.ssgproject.org/sources/%{name}-%{rhelssgversion}.tar.gz
BuildArch:	noarch
BuildRequires:	libxslt, expat, python, openscap-utils >= 0.9.1, python-lxml
Requires:	xml-common, openscap-utils >= 0.9.1
Obsoletes:	openscap-content < 0:0.9.13
Provides:	openscap-content

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

%prep
%setup -q -D -n %{name}-%{version} -a1

%build
# Build Fedora distribution content
(cd Fedora && make dist)
# Change CWD to point to RHEL content. Build RHEL content
pushd %{name}-%{rhelssgversion}
(cd RHEL/6 && make dist)
(cd RHEL/7 && make dist)
# Restore CWD to old value
popd

%install
# Create required directory structure
mkdir -p %{buildroot}%{_datadir}/xml/scap/ssg/fedora
mkdir -p %{buildroot}%{_datadir}/xml/scap/ssg/rhel{6,7}
mkdir -p %{buildroot}%{_mandir}/en/man8/

# Add in core Fedora content (SCAP XCCDF and OVAL)
cp -a Fedora/dist/content/* %{buildroot}%{_datadir}/xml/scap/ssg/fedora
# Add in Fedora manpage
cp -a Fedora/input/auxiliary/scap-security-guide.8 %{buildroot}%{_mandir}/en/man8/scap-security-guide.8

# Change CWD to point to RHEL content. Copy
# datastreams to appropriate buildroot places
pushd %{name}-%{rhelssgversion}
# Add in datastream form of RHEL-6 benchmark
cp -a RHEL/6/dist/content/ssg-rhel6-ds.xml %{buildroot}%{_datadir}/xml/scap/ssg/rhel6
# Add in datastream form of RHEL-7 benchmark
cp -a RHEL/7/dist/content/ssg-rhel7-ds.xml %{buildroot}%{_datadir}/xml/scap/ssg/rhel7
# Restore CWD to old value
popd

%files
%{_datadir}/xml/scap
%lang(en) %{_mandir}/en/man8/scap-security-guide.8.*
%doc Fedora/LICENSE Fedora/output/ssg-fedora-guide.html


%changelog
* Sun Jun 22 2014 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.5-2
- Upgrade internal RHEL content to 0.1.18 version

* Thu Feb 27 2014 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.5-1
- Fix fedora-srpm and fedora-rpm Make targets to work again
- Include RHEL-6 and RHEL-7 datastream files to support remote RHEL system scans
- EOL for Fedora 18 support
- Include Fedora datastream file for remote Fedora system scans

* Mon Jan 06 2014 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.4-2
- Drop -compat package, provide openscap-content directly (RH BZ#1040335#c14)

* Fri Dec 20 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1.4-1
- Fix remediation for sshd set keepalive (ClientAliveCountMax) and move
  it to /shared
- Add shared remediations for sshd disable empty passwords and
  sshd set idle timeout
- Shared remediation for sshd disable root login
- Add empty -compat subpackage to ensure backward-compatibility with
  openscap-content and firstaidkit-plugin-openscap packages (RH BZ#1040335)
- OVAL check for sshd disable root login
- Fix typo in OVAL check for sshd disable empty passwords
- OVAL check for sshd disable empty passwords
- Unselect no shelllogin for systemaccounts rule from being run by default
- Rename XCCDF rules
- Revert Set up Fedora release name and CPE based on build system properties
- Shared OVAL check for Verify that Shared Library Files Have Root Ownership
- Shared OVAL check for Verify that System Executables Have Restrictive Permissions
- Shared OVAL check for Verify that System Executables Have Root Ownership
- Shared OVAL check for Verify that Shared Library Files Have Restrictive
  Permissions
- Fix remediation for Disable Prelinking rule
- OVAL check and remediation for sshd's ClientAliveCountMax rule
- OVAL check for sshd's ClientAliveInterval rule
- Include descriptions for permissions section, and rules for checking
  permissions and ownership of shared library files and system executables
- Disable selected rules by default
- Add remediation for Disable Prelinking rule
- Adjust service-enable-macro, service-disable-macro XSLT transforms
  definition to evaluate to proper systemd syntax
- Fix service_ntpd_enabled OVAL check make validate to pass again
- Include patch from Šimon Lukašík to obsolete openscap-content
  package (RH BZ#1028706)
- Add OVAL check to test if there's is remote NTP server configured for
  time data
- Add system settings section for the guide (to track system wide
  hardening configurations)
- Include disable prelink rule and OVAL check for it
- Initial OVAL check if ntpd service is enabled. Add package_installed
  OVAL templating directory structure and functionality.
- Include services section, and XCCDF description for selected ntpd's
  sshd's service rules
- Include remediations for login.defs' based password minimum, maximum and
  warning age rules
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
