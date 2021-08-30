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

## Modifying rule directory content files

All utilities discussed below require information about the existing rules
for fast operation. We've provided the `utils/rule_dir_json.py` script to
build this information in a format understood by these scripts.

To execute it:

    $ ./utils/rule_dir_json.py

Optionally, provide a path to a CaC root and destination YAML file:

    $ ./utils/rule_dir_json.py --root /path/to/ComplianceAsCode/content \
                               --output /tmp/rule_dirs.json

### `utils/fix_rules.py` -- automatically fix-up rules

`utils/fix_rules.py` includes various sub-commands for automatically fixing
common problems in rules.

These sub-commands are:

 - `empty_identifiers`: removes any `identifiers` which are empty.
 - `invalid_identifiers`: removes any invalid CCE `identifiers` (due to
   incorrect format).
 - `int_identifiers`: turns any identifiers which are an integer into a
   string.
 - `empty_references`: removes any `references` which are empty.
 - `int_references`: turns any references which are an integer into a string.
 - `duplicate_subkeys`: finds (but doesn't fix!) any rules with duplicated
   `identifiers` or `references`.
 - `sort_subkeys`: sorts all subkeys under `identifiers` and `references`.
 - `sort_prodtypes`: "sorts the products in prodtype"

To execute:

    $ ./utils/fix_rules.py [--assume-yes] [--dry-run] <command>

For example:

    $ ./utils/fix_rules.py -y sort_subkeys

Note that it is generally good practice to commit all changes prior to running
one of these commands and then commit the results separately.

### `utils/autoprodtyper.py` -- automatically add product to `prodtype`

When building a profile for a new product version (such as forking
`ubuntu1804` into `ubuntu2004`), it is helpful to be able to build a
profile (adding in all rules that are necessary) and then attempt a
build.

However, usually lots of rules will lack the new product in its `prodtype`
field.

This is where `utils/autoprodtyper.py` comes in: point it at a product and
a profile and it will automatically modify the prodtype, adding this product.

To execute:

    $ ./utils/autoprodtyper.py <product> <profile>

For example:

    $ ./utils/autoprodtyper.py ubuntu2004 cis_level1_server

Note that it is generally good practice to commit all changes prior to running
one of these commands and then commit the results separately.

### `utils/refchecker.py` -- automatically check `rule.yml` for references

This utility checks all `rule.yml` referenced from a given profile for the
specified reference.  Unlike `build-scripts/profile_tool.py`, which operates
on the built XCCDF information, `utils/refchecker.py` operates on the contents
of the `rule.yml` files.

To execute:

    $ ./utils/refchecker.py <product> <profile> <reference>

For example:

    $ ./utils/refchecker.py ubuntu2004 cis_level1_server cis

This utility has some knowledge of which references are product-specific
(checking for `cis@ubuntu2004` in the above example) and which are
product-independent.

Note that this utility does not modify the rule directories at all.

### `utils/mod_prodtype.py` -- programmatically modify prodtype in `rule.yml`

`utils/mod_prodtype.py` is a command-based utility for modifying `rule.yml`
files. It supports the following sub-commands:

 - `add`: add the given product(s) to the specified rule's prodtype.
 - `list`: list computed and actual products in the specified rule's prodtype.
 - `replace`: perform a pattern-match replacement on the specified rule's
   prodtype.
 - `remove`: remove the given product(s) from the specified rule's prodtype.

To execute:

    $ ./utils/mod_prodtype.py <rule_id> <command> [...other arguments...]

For an example of `add`:

    $ ./utils/mod_prodtype.py accounts_passwords_pam_tally2 add ubuntu2004

For an example of `list`:

    $ ./utils/mod_prodtype.py accounts_passwords_pam_tally2 list

For an example of `replace`:

    $ ./utils/mod_prodtype.py accounts_passwords_pam_tally2 replace ubuntu2004~ubuntu1604,ubuntu1804,ubuntu2004

For an example of `remove`:

    $ ./utils/mod_prodtype.py accounts_passwords_pam_tally2 remove ubuntu1604 ubuntu1804 ubuntu2004

### `utils/mod_checks.py` and `utils/mod_fixes.py` -- programmatically modify check and fix applicability

These two utilities have identical usage. Both modifies the platform/product
applicability of various files (either OVAL or hardening content), similar to
`utils/mod_prodtype.py` above. They supports the following sub-commands:

 - `add`: add the given platform(s) to the specified rule's OVAL check.
   **Note**: Only applies to shared content.
 - `list`: list the given OVAL(s) and the products that apply to them; empty
   if product-independent.
 - `remove`: remove the given platform(s) from the specified rule's OVAL check.
   **Note**: Only applies to shared content.
 - `replace`: perform a pattern-match replacement on the specified rule's
   platform applicability. **Note**: Only applies to shared content.
 - `diff`: perform a textual diff between content for the specified products.
 - `delete`: remove an OVAL for the specified product.
 - `make_shared`: move a product-specific OVAL into a shared OVAL.

To execute:

    $ ./utils/mod_checks.py <rule_id> <command> [...other arguments...]
    $ ./utils/mod_fixes.py <rule_id> <type> <command> [...other arguments...]

For an example of `add`:

    $ ./utils/mod_checks.py clean_components_post_updating add multi_platform_sle
    $ ./utils/mod_fixes.py clean_components_post_updating bash add multi_platform_sle

For an example of `list`:

    $ ./utils/mod_checks.py clean_components_post_updating list
    $ ./utils/mod_fixes.py clean_components_post_updating ansible list

For an example of `remove`:

    $ ./utils/mod_checks.py file_permissions_local_var_log_messages remove multi_platform_sle
    $ ./utils/mod_fixes.py file_permissions_local_var_log_messages bash remove multi_platform_sle

For an example of `replace`:

    $ ./utils/mod_checks.py file_permissions_local_var_log_messages replace multi_platform_sle~multi_platform_sle,multi_platform_ubuntu
    $ ./utils/mod_fixes.py file_permissions_local_var_log_messages bash replace multi_platform_sle~multi_platform_sle,multi_platform_ubuntu

For an example of `diff`:

    $ ./utils/mod_checks.py clean_components_post_updating diff sle12 sle15
    $ ./utils/mod_fixes.py clean_components_post_updating bash diff sle12 sle15

For an example of `delete`:

    $ ./utils/mod_checks.py clean_components_post_updating delete sle12
    $ ./utils/mod_fixes.py clean_components_post_updating bash delete sle12

For an example of `make_shared`:

    $ ./utils/mod_checks.py clean_components_post_updating make_shared sle12
    $ ./utils/mod_fixes.py clean_components_post_updating bash make_shared sle12

### `utils/rule_dir_diff.py` and `utils/rule_dir_stats.py` -- comparison of rule directories

`utils/rule_dir_stats.py` is a utility for extracting various statistics out
of the `rule_dir.json` file. `utils/rule_dir_diff.py` is its counterpart,
operating on two separate JSON blobs, presumably at different points in time
or from different content trees. They support the following arguments which
affect output:

 - `--products`: limit results to only the specified product(s)
 - `--strict`: enforce product applicability strictly on the `rule.yml`
   level, discarding results from rules which lack specified product in the
   `rule.yml` file.
 - `--missing`: List rules which are missing OVALs or fixes.
 - `--two-plus`: List rules which have two or more OVALs or fixes.
 - `--prodtypes`: List rules which have different prodtypes/platform
   applicability between `rule.yml` and its OVALs/fixes.
 - `--product-names`: List rules which have product-specific names (e.g.,
   a `sle15.xml` with `multi_platform_sle` applicability.
 - `--introspect`: Dump raw objects for explicitly queried rules.
 - `--unassociated`: Search for rules without any product association (e.g.,
   missing or empty prodtype).
 - `--ovals-only`: Only output information about OVALs.
 - `--fixes-only`: Only output information about fixes.
 - `--summary-only`: Only output summary information.

Options specific to `utils/rule_dir_stats.py`:

 - `--left`: old JSON artifact; displayed on the left of diffs.
 - `--right`: new JSON artifact; displayed on the right of diffs.

To execute:

    $ ./utils/rule_dir_stats.py [...any options...]
    $ ./utils/rule_dir_diff.py [...any options...]
