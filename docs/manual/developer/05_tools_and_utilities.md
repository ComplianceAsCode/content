# Tools and Utilities

To run the Python utilities (those ending in `.py`), you will need to
have the PYTHONPATH environment variable set. This can be accomplished
one of two ways: by prefixing all commands with a local variable
(`PYTHONPATH=/path/to/scap-security-guide`), or by exporting
`PYTHONPATH` in your shell environment. We provide a script for making
this easier: `.pyenv.sh`. To set `PYTHONPATH` correctly for the current
shell, simply call `source .pyenv.sh`. For more information on how to
use this script, please see the comments at the top of the file.

## Testing OVAL Content

Located in `utils` directory, the `testoval.py` script allows easy
testing of oval definitions. It wraps the definition and makes up an
oval file ready for scanning, very useful for testing new OVAL content
or modifying existing ones.

Example usage:

    $ PYTHONPATH=`./.pyenv.sh` ./utils/testoval.py install_hid.xml

Create or add an alias to the script so that you don’t have to type out
the full path everytime that you would like to use the `testoval.py`
script.

    $ alias testoval='/home/_username_/scap-security-guide/utils/testoval.py'

An alternative is adding the directory where `testoval.py` resides to
your PATH.

    $ export PATH=$PATH:/home/_username_/scap-security-guide/utils/

## Profile Statistics and Utilities

The `profile_tool.py` tool displays XCCDF profile statistics. It can
show number of rules in the profile, how many of these rules have an
OVAL check implemented, how many have a remediation available, shows
rule IDs which are missing them and other useful information.

To use the script, first build the content, then pass the built XCCDF
(not DataStream) to the script.

For example, to check which rules in RHEL8 OSPP profile are missing
remediations, run this command:

    $ ./build_product rhel8
    $ ./build-scripts/profile_tool.py stats --missing-fixes --profile ospp --benchmark build/ssg-rhel8-xccdf.xml

Note: There is an automated job which provides latest statistics from
all products and all profiles, you can view it here:
[Statistics](https://jenkins.complianceascode.io/job/scap-security-guide-stats/)

The tool also can subtract rules between YAML profiles.

For example, to subtract selected rules from a given profile based on
rules selected by another profile, run this command:

    $ ./build-scripts/profile_tool.py sub --profile1 rhel7/profiles/ospp.profile --profile2 rhel7/profiles/pci-dss.profile

This will result in a new YAML profile containing exclusive rules to the
profile pointed by the `--profile1` option.

## Generating login banner regular expressions

Rules like `banner_etc_issue` and `dconf_gnome_login_banner_text` will
check for configuration of login banners and remediate them. Both rules
source the banner text from the same variable `login_banner_text`, and
the banner texts need to be in the form of a regular expression. There
are a few utilities you can use to transform your text into the
appropriate regular expression:

When adding a new banner directly to the `login_banner_text`, use the
custom Jinja filter `banner_regexify`.
If customizing content via SCAP Workbench, or directly writing your
tailoring XML, use `utils/regexify_banner.py` to generate the
appropriate regular expression.
