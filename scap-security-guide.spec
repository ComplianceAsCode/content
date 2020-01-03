Name:		scap-security-guide
Version:	0.1.47
Release:	2%{?dist}
Summary:	Security guidance and baselines in SCAP formats
License:	BSD-3-Clause
URL:		https://github.com/ComplianceAsCode/content/
Source0:	https://github.com/ComplianceAsCode/content/releases/download/v%{version}/scap-security-guide-%{version}.tar.bz2
BuildArch:	noarch

Patch0:		scap-security-guide-0.1.48-xml_parsing.patch

BuildRequires:	libxslt, expat, python3, openscap-scanner >= 1.2.5, cmake >= 3.8, python3-jinja2, python3-PyYAML
Requires:	xml-common, openscap-scanner >= 1.2.5
Obsoletes:	openscap-content < 0:0.9.13
Provides:	openscap-content

%description
The scap-security-guide project provides a guide for configuration of the
system from the final system's security point of view. The guidance is specified
in the Security Content Automation Protocol (SCAP) format and constitutes
a catalog of practical hardening advice, linked to government requirements
where applicable. The project bridges the gap between generalized policy
requirements and specific implementation guidelines. The Fedora system
administrator can use the oscap CLI tool from openscap-scanner package, or the
scap-workbench GUI tool from scap-workbench package to verify that the system
conforms to provided guideline. Refer to scap-security-guide(8) manual page for
further information.

%package	doc
Summary:	HTML formatted security guides generated from XCCDF benchmarks
Requires:	%{name} = %{version}-%{release}

%description	doc
The %{name}-doc package contains HTML formatted documents containing
hardening guidances that have been generated from XCCDF benchmarks
present in %{name} package.

%prep
%setup -q
%patch0 -p1
mkdir build

%build
cd build
%cmake ../
%make_build

%install
cd build
%make_install

%files
%{_datadir}/xml/scap/ssg/content
%{_datadir}/%{name}/kickstart
%{_datadir}/%{name}/ansible
%{_datadir}/%{name}/bash
%lang(en) %{_mandir}/man8/scap-security-guide.8.*
%doc %{_docdir}/%{name}/LICENSE
%doc %{_docdir}/%{name}/README.md
%doc %{_docdir}/%{name}/Contributors.md

%files doc
%doc %{_docdir}/%{name}/guides/*.html
%doc %{_docdir}/%{name}/tables/*.html

%changelog
