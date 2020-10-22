# Updating Reference and Overlay Content

## Reference Content

### STIG Reference Content

## STIG Overlay Content

`stig_overlay.xml` maps an official product/version STIG release with a
SSG product/version STIG release.

**`stig_overlay.xml` should never be manually created or updated. It
should always be generated using `create-stig-overlay.py`.**

### Creating stig_overlay.xml

To create `stig_overlay.xml`, there are two things that are required: an
official non-draft STIG release from DISA containing a XCCDF file (e.g.
`U_Red_Hat_Enterprise_Linux_7_STIG_V1R1_Manual-xccdf.xml` and an XCCDF
file built by the project (e.g. `ssg-rhel7-xccdf.xml`)

Example using `create-stig-overlay.py`:

    $ PYTHONPATH=`./.pyenv.sh` utils/create-stig-overlay.py --disa-xccdf=disa-stig-rhel7-v1r12-xccdf-manual.xml --ssg-xccdf=ssg-rhel7-xccdf.xml -o rhel7/overlays/stig_overlay.xml

### Updating stig_overlay.xml

To update `stig_overlay.xml`, use the `create-stig-overlay.py` script as
mentioned above. Then, submit a pull request to replace the
`stig_overlay.xml` file that is needing to be updated. Please note that
as a part of this update rules that have been removed from the official
STIG will be removed here as well.
