# Build from source

1. On RHEL and Fedora make sure the packages `openscap-utils` and `python-lxml` and their dependencies are installed. We require version `1.0.8` or later of `openscap-utils` (available in RHEL) as well as `git`. 

 `# yum -y install git openscap-utils python-lxml`

2. Download the source code 

 `$ git clone https://github.com/OpenSCAP/scap-security-guide.git`

3. Build the source code  
  * To build all the content:  
  
    `$ cd scap-security-guide/`  
    `$ make`  

  * To build an RPM for development/testing or non-official release use:  
  
    `$ cd scap-security-guide/`  
    `$ make rpm` 

  * To build an RPM for official release use:

    `$ cd scap-security-guide/`
    `$ make SSG_VERSION_IS_GIT_SNAPSHOT=no rpm` 

  * To build content only for a specific distribution:  
  
    `$ cd scap-security-guide/`  
    `$ make rhel6`  

      Or alternatively, content can be made within the sub-group (e.g. RHEL7, RHEL6):  
  
    `$ cd scap-security-guide/RHEL/6/`  
    `$ make`  

      
  When the content has completed the build process, the built content exists in the distribution's `output` directory. For example:  
  
    `$ cd scap-security-guide/RHEL/6/output`  
  
4. Discover the following:  
 * A pretty prose guide **in rhel6-guide.html** containing practical, actionable information for administrators 
 * A concise spreadsheet representation (potentially useful as the basis for an SRTM document) in **rhel6-table-nistrefs-server.html**
 * Files that can be ingested by SCAP-compatible scanning tools, to enable automated checking:  
    * **ssg-rhel6-xccdf.xml**
    * **ssg-rhel6-oval.xml**
    * **ssg-rhel6-ds.xml**
