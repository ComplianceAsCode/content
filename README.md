## Welcome!
The purpose of this project is to create SCAP content, first for 
Red Hat Enterprise Linux 6.  "SCAP content" refers to documents 
in the XCCDF and OVAL formats.  These documents can be presented
in different forms and by different organizations to meet their
security automation and technical implementation needs.  

This project is an attempt to allow multiple organizations to 
efficiently develop such content by avoiding redundancy, which is 
possible by taking advantage of features of the SCAP standards. First, 
SCAP content is easily transformed programmatically. XCCDF also supports
selection of subsets of content through a "profile" and granular adjustment 
of settings through a "refine-value."  

The goal of this project to enable the creation of multiple security 
baselines from a single set of high-quality SCAP content.

The SSG homepage is https://fedorahosted.org/scap-security-guide/

#### Health Checks
* Python Code via landscape.io: [![Code Health](https://landscape.io/github/OpenSCAP/scap-security-guide/master/landscape.png)](https://landscape.io/github/OpenSCAP/scap-security-guide/master)

* Jenkins @ http://jenkins.ssg-project.org:8080/
