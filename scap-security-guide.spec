Name:           scap-security-guide
Version:        %{version}
Release:        %{release}
Summary:        The scap-security-guide project provides security guidance and baselines in SCAP formats for Red Hat Enterprise Linux.

Group:          Testing
License:        Public domain and GPL
URL:            https://fedorahosted.org/scap-security-guide/

Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

BuildArch:	%{arch}

BuildRequires:  coreutils, libxslt, expat, python, openscap-utils
Requires:       filesystem

%description
The scap-security-guide project provides security configuration guidance in
formats of the Security Content Automation Protocol (SCAP).  It provides a
catalog of practical hardening advice and links it to government requirements
where applicable. The project bridges the gap between generalized policy
requirements and specific implementation guidance.
%prep
%setup -q 


%build
cd RHEL6 && make dist


%install
rm -rf $RPM_BUILD_ROOT
#make install DESTDIR=$RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr/share/xml/scap/ssg/

cp -r RHEL6/dist/* $RPM_BUILD_ROOT/usr/share/xml/scap/ssg/


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(0644,root,root,0755)
%attr(0755,root,root) /usr/share/xml/scap/ssg


%changelog
* Fri Oct 5  2012 Jeffrey Blank <blank@eclipse.ncsc.mil> 1.0-5
- Adjusted installation directory to /usr/share/xml/scap.

* Tue Aug 28  2012 Spencer Shimko <sshimko@tresys.com> 1.0-4
- Fix BuildRequires and Requires.

* Wed Jul 3 2012 Jeffrey Blank <blank@eclipse.ncsc.mil> 1.0-3
- Modified install section, made description more concise.

* Thu Apr 19 2012 Spencer Shimko <sshimko@tresys.com> 1.0-2
- Minor updates to pass some variables in from build system.

* Mon Apr 02 2012 Shawn Wells <shawn@redhat.com> 1.0-1
- First attempt at SSG RPM. May ${diety} help us...
