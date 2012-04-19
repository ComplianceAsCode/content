Name:           scap-security-guide
Version:        %{version}
Release:        %{release}
Summary:        The scap-security-guide project, or SSG for short, aims to deliver security guidance, baselines, and associated validation mechanisms for Red Hat Enterprise Linux.

Group:          Testing
License:        GPL
URL:            https://fedorahosted.org/scap-security-guide/

Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

BuildArch:	%{arch}

BuildRequires:  /bin/rm, /bin/mkdir, /bin/cp
Requires:       /bin/bash, /bin/date, /usr/bin/oscap

%description
Today the SSG project provides guidance against U.S. Government requirements, 
including those of the U.S. Department of Defense and U.S. Intelligence Community.
Many U.S. Government policies, such as NIST 800-53 provide prose stating that
System Administrators must audit "privileged user actions," but do not define
what such actions are. The SSG bridges the gap between generalized U.S.
Government Policy and specific implementation guidance.

To lean more about the SCAP Security Guide project, please
visit https://fedorahosted.org/mailman/listinfo/scap-security-guide. Here
you will be able to find documentation, support, and information on getting
involved in the SCAP Security Guide community.

%prep
%setup -q 


%build
#configure
#`make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
#make install DESTDIR=$RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr/local/%{name}/content
mkdir -p $RPM_BUILD_ROOT/usr/local/%{name}/guide
mkdir -p $RPM_BUILD_ROOT/usr/local/%{name}/policytables
mkdir -p $RPM_BUILD_ROOT/usr/local/%{name}/STIG-draft
mkdir -p $RPM_BUILD_ROOT/usr/local/%{name}/USGCB-submission

cp -r * $RPM_BUILD_ROOT/usr/local/%{name}/


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc

%attr(0750,root,root)/usr/local/scap-security-guide/

%changelog
* Thu Apr 19 2012 Spencer Shimko <sshimko@tresys.com> 1.0-2
- Minor updates to pass some variables in from build system.

* Mon Apr 02 2012 Shawn Wells <shawn@redhat.com> 1.0-1
- First attempt at SSG RPM. May ${diety} help us...
