
# IMPORTANT NOTE: This spec file is solely dedicated to make changes to the
# Fedora's scap-security-guide package. If you want to apply changes against
# the main RHEL-6 scap-security-guide RPM content, use scap-security-guide.spec
# file one level up - in the main scap-security-guide directory (instead of
# this one).

%global	fedorassgrelease	2

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
mkdir -p $RPM_BUILD_ROOT%{_mandir}/en/man8/

# Add in core content (SCAP, guide)
cp -a Fedora/dist/* $RPM_BUILD_ROOT%{_datadir}/xml/scap/ssg/fedora/19

# Add in manpage
gzip -c Fedora/input/auxiliary/scap-security-guide.8 > $RPM_BUILD_ROOT%{_mandir}/en/man8/scap-security-guide.8.gz
chcon -u system_u $RPM_BUILD_ROOT%{_mandir}/en/man8/scap-security-guide.8.gz

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%{_datadir}/xml/scap/ssg/fedora/19/*
%lang(en) %{_mandir}/en/man8/scap-security-guide.8.gz

%changelog
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
