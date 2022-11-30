# ReadTheDocs.org Integration

The [ComplianceAsCode developer documentation](manual/developer) is integrated into the ReadTheDocs.org documentation hosting platform: https://complianceascode.readthedocs.io

A webhook exists to build the Markdown files into a complete set of documentation.

You can check all the webhooks in this page as well (if you have the rights to do so): https://github.com/ComplianceAsCode/content/settings/hooks

Synchronization status:

- The main branch always build whenever a new push occurs.
- Any new release will trigger a new build and a documentation tag will be created for that specific release.


## How the Integration Works:

[conf.py](conf.py): Contains the python configuration for the Sphinx build. Add new modules and control options for the build to this file.

[index.rst](index.rst): Main page. It's an entry point for all other documentation included. If you add a new documentation page, you need to change this file.

[requirements.txt](requirements.txt): Contains all the required python modules to build the documentation, to build the Sphinx documentation locally check: [manual/developer/02_building_complianceascode.html#building](https://complianceascode.readthedocs.io/en/latest/manual/developer/02_building_complianceascode.html#building).
  - You will need to install the requirements "pip install -r docs/requirements.txt" and run "make docs" or "ninja docs" depending on your setup.

[.readthedocs.yml](../.readthedocs.yml): Contains the configuration options for ReadTheDocs.org. For example, place to pull the `requirements.txt` that will be used by ReadTheDocs.org to install required modules during the building of the documentation.

## How to Change ReadTheDocs.org Project Settings

You need to have maintainer permissions to the project in order to change the settings.
Create an account on ReadTheDocs.org and ask the maintainers of this project to grant the permissions.
