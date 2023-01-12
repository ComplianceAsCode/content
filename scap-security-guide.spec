# SSG build system and tests count with build directory name `build`.
# For more details see:
# https://fedoraproject.org/wiki/Changes/CMake_to_do_out-of-source_builds
%global _vpath_builddir build
%global _default_patch_fuzz 2

Name:		scap-security-guide
# Version placeholder. Copr build version is determined by utils/version.sh. See .packit.yaml config
Version:	0.0.1
Release:	0%{?dist}
Summary:	Security guidance and baselines in SCAP formats
License:	BSD-3-Clause
URL:		https://github.com/ComplianceAsCode/content/
Source0:	https://github.com/ComplianceAsCode/content/releases/download/v%{version}/scap-security-guide-%{version}.tar.bz2
BuildArch:	noarch

%if 0%{?centos} == 7
BuildRequires:  libxslt, expat, openscap-scanner >= 1.2.5, cmake >= 2.8, python, python-jinja2, PyYAML, python-setuptools
%else
BuildRequires:  libxslt, expat, openscap-scanner >= 1.2.5, cmake >= 2.8, /usr/bin/python3, python%{python3_pkgversion}, python%{python3_pkgversion}-jinja2, python%{python3_pkgversion}-PyYAML, python%{python3_pkgversion}-setuptools
%endif
Requires:	xml-common, openscap-scanner >= 1.2.5

%description
The scap-security-guide project provides a guide for configuration of the
system from the final system's security point of view. The guidance is specified
in the Security Content Automation Protocol (SCAP) format and constitutes
a catalog of practical hardening advice, linked to government requirements
where applicable. The project bridges the gap between generalized policy
requirements and specific implementation guidelines. The system
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
%autosetup -p1

%define cmake_defines_common -DSSG_SEPARATE_SCAP_FILES_ENABLED=OFF -DSSG_BASH_SCRIPTS_ENABLED=OFF -DSSG_BUILD_SCAP_12_DS=OFF -DSSG_BUILD_DISA_DELTA_FILES=OFF
%define cmake_defines_specific %{nil}
%define centos_8_specific %{nil}

%if 0%{?centos}
%define cmake_defines_specific -DSSG_PRODUCT_DEFAULT:BOOLEAN=FALSE -DSSG_PRODUCT_RHEL%{centos}:BOOLEAN=TRUE -DSSG_SCIENTIFIC_LINUX_DERIVATIVES_ENABLED:BOOL=OFF -DSSG_CENTOS_DERIVATIVES_ENABLED:BOOL=ON
%endif
%if 0%{?fedora}
%define cmake_defines_specific -DSSG_PRODUCT_DEFAULT:BOOLEAN=FALSE -DSSG_PRODUCT_FEDORA:BOOLEAN=TRUE
%endif

mkdir -p build
%build
%if 0%{?centos} == 7 || 0%{?centos} == 8
cd build
%cmake %{cmake_defines_common} %{cmake_defines_specific} ../
%else
%cmake %{cmake_defines_common} %{cmake_defines_specific}
%endif

%if 0%{?centos} == 7
make %{?_smp_mflags}
%else
%cmake_build
%endif

%install
%if 0%{?centos} == 7 || 0%{?centos} == 8
cd build
%endif
%if 0%{?centos} == 7
%make_install
%else
%cmake_install
%endif
rm %{buildroot}/%{_docdir}/%{name}/README.md
rm %{buildroot}/%{_docdir}/%{name}/Contributors.md

%files
%{_datadir}/xml/scap/ssg/content
# No kickstarts for Fedora
%if 0%{?centos}
%{_datadir}/%{name}/kickstart
%endif
%{_datadir}/%{name}/ansible/*.yml
%lang(en) %{_mandir}/man8/scap-security-guide.8.*
%doc %{_docdir}/%{name}/LICENSE

%files doc
%doc %{_docdir}/%{name}/guides/*.html
# No tables for Fedora
%if 0%{?centos}
%doc %{_docdir}/%{name}/tables/*.html
%endif
