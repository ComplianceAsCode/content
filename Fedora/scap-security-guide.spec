
# IMPORTANT NOTE: This spec file is solely dedicated to make changes to the
# Fedora's scap-security-guide package. If you want to apply changes against
# the main RHEL-6 scap-security-guide RPM content, use scap-security-guide.spec
# file one level up - in the main scap-security-guide directory (instead of
# this one).

%global	fedorassgrelease	2.rc5

Name:		scap-security-guide
Version:	0.1
Release:	%{fedorassgrelease}%{?dist}
Summary:	Security guidance and baselines in SCAP formats
Group:		Applications/System
License:	Public Domain
URL:		https://fedorahosted.org/scap-security-guide/
Source0:	http://fedorapeople.org/~jlieskov/%{name}-%{version}-%{fedorassgrelease}.tar.gz
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:	noarch
BuildRequires:	coreutils, libxslt, expat, python, openscap-utils >= 0.9.1, python-lxml
Requires:	filesystem, openscap-utils >= 0.9.1

%description
The scap-security-guide project provides security configuration guidance in
formats of the Security Content Automation Protocol (SCAP).  It provides a
catalog of practical hardening advice and links it to government requirements
where applicable. The project bridges the gap between generalized policy
requirements and specific implementation guidance.
%prep
%setup -q -n %{name}-%{version}-%{fedorassgrelease}


%build
cd Fedora && make dist


%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT%{_datadir}/xml/scap/ssg/fedora/19

# Add in core content (SCAP, guide)
cp -a Fedora/dist/* $RPM_BUILD_ROOT%{_datadir}/xml/scap/ssg/fedora/19

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%{_datadir}/xml/scap/ssg/fedora/19/*

%changelog
* Mon Oct 12 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1-2.rc5
- Remove percent sign from spec's changelog to silence rpmlint warning

* Fri Oct 11 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1-2.rc4
- Convert RHEL6 'Restrict Root Logins' section's rules to Fedora

* Thu Oct 10 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1-2.rc3
- Convert four RHEL6 'Set Password Expiration Parameter' rules to Fedora

* Thu Oct 10 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1-2.rc2
- Introduce 'Account and Access Control' section
- Convert following "Verify Proper Storage and Existence of Password Hashes" section
  rules to Fedora:
  * Prevent Log In to Accounts With Empty Password
  * Verify All Account Password Hashes are Shadowed
  * All GIDs referenced in /etc/passwd must be defined in /etc/group
  * Verify No netrc Files Exist

* Wed Oct 02 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1-2.rc1
- Set proper name of the build directory in the spec's setup macro.
- Replace hard-wired paths with macros. Preserve attributes when copying files.

* Tue Sep 17 2013 Jan iankko Lieskovsky <jlieskov@redhat.com> 0.1-1
- Initial Fedora SSG RPM.
