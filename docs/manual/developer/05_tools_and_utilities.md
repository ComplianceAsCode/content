# Tools and Utilities

To run the Python utilities (those ending in `.py`), you will need to
have the `PYTHONPATH` environment variable set. This can be accomplished
one of two ways: by prefixing all commands with a local variable
(`PYTHONPATH=/path/to/scap-security-guide`), or by exporting
`PYTHONPATH` in your shell environment. We provide a script for making
this easier: `.pyenv.sh`. To set `PYTHONPATH` correctly for the current
shell, simply call `source .pyenv.sh`. For more information on how to
use this script, please see the comments at the top of the file.

## Profile Statistics and Utilities

The `profile_tool.py` tool displays XCCDF profile statistics. It can
show number of rules in the profile, how many of these rules have an
OVAL check implemented, how many have a remediation available, shows
rule IDs which are missing them and other useful information.

To use the script, first build the content, then pass the built XCCDF
(not data stream) to the script.

For example, to check which rules in RHEL8 OSPP profile are missing
remediations, run this command:

```bash
    $ ./build_product rhel8
    $ ./build-scripts/profile_tool.py stats --missing-fixes --profile ospp --benchmark build/ssg-rhel8-xccdf.xml
```

Note: There is an automated job which provides latest statistics from
all products and all profiles, you can view it here:
[Statistics](https://complianceascode.github.io/content-pages/statistics/index.html)

The tool also can subtract rules between YAML profiles.

For example, to subtract selected rules from a given profile based on
rules selected by another profile, run this command:

```bash
    $ ./build-scripts/profile_tool.py sub --profile1 rhel7/profiles/ospp.profile --profile2 rhel7/profiles/pci-dss.profile
````

This will result in a new YAML profile containing exclusive rules to the
profile pointed by the `--profile1` option.

## Generating Controls from DISA's XCCDF Files

If you want a control file for product from DISA's XCCDF files you can run the following command:
It supports the following arguments:

```text
options:
  -h, --help            show this help message and exit
  -r ROOT, --root ROOT  Path to SSG root directory (defaults to the root of the repository)
  -o OUTPUT, --output OUTPUT
                        File to write yaml output to (defaults to build/stig_control.yml)
  -p PRODUCT, --product PRODUCT
                        What product to get STIGs for
  -m MANUAL, --manual MANUAL
                        Path to XML XCCDF manual file to use as the source of the STIGs
  -j JSON, --json JSON  Path to the rules_dir.json (defaults to build/rule_dirs.json)
  -c BUILD_CONFIG_YAML, --build-config-yaml BUILD_CONFIG_YAML
                        YAML file with information about the build configuration.
  -ref REFERENCE, --reference REFERENCE
                        Reference system to check for, defaults to stigid
  -s, --split           Splits the each ID into its own file.
```

Example

```bash
    $ ./utils/build_stig_control.py -p rhel8 -m shared/references/disa-stig-rhel8-v1r5-xccdf-manual.xml
```

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

```bash
    $ ./utils/rule_dir_json.py
```

Optionally, provide a path to a CaC root and destination YAML file:

```bash
    $ ./utils/rule_dir_json.py --root /path/to/ComplianceAsCode/content \
                               --output /tmp/rule_dirs.json
```

### `utils/fix_rules.py` &ndash; automatically fix-up rules

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
- `sort_prodtypes`: sorts the products in prodtype.
- `add-cce`: automatically assign CCE identifiers to rules.

To execute:

```bash
    $ ./utils/fix_rules.py [--assume-yes] [--dry-run] <command>
```

For example:

```bash
    $ ./utils/fix_rules.py -y sort_subkeys
```

Note that it is generally good practice to commit all changes prior to running
one of these commands and then commit the results separately.

#### How to automatically assign CCEs with the `add-cce` sub-command

First, you need to make sure that that the `rule_dirs.json` exists, run the following command to create it:

```bash
    $ ./utils/rule_dir_json.py
```

Then based on the available pool you want to assign the CCEs, you can run something like:

```bash
    $ python utils/fix_rules.py --product products/rhel9/product.yml add-cce --cce-pool redhat audit_rules_privileged_commands_newuidmap
```

Note: Multiple rules can have the CCE at the same time by just adding space separated rule IDs.
Note: The rule should have the product assigned to the `prodtype` attribute or the `prodtype` should be empty.

Example for `sle15` product:

```bash
    $ python utils/fix_rules.py --product products/sle15/product.yml add-cce --cce-pool sle15 audit_rules_privileged_commands_newuidmap audit_rules_privileged_commands_newuidmap
```


### `utils/autoprodtyper.py` &ndash; automatically add product to `prodtype`

When building a profile for a new product version (such as forking
`ubuntu1804` into `ubuntu2004`), it is helpful to be able to build a
profile (adding in all rules that are necessary) and then attempt a
build.

However, usually lots of rules will lack the new product in its `prodtype`
field.

This is where `utils/autoprodtyper.py` comes in: point it at a product and
a profile and it will automatically modify the prodtype, adding this product.

To execute:

```bash
    $ ./utils/autoprodtyper.py <product> <profile>
```

For example:

```bash
    $ ./utils/autoprodtyper.py ubuntu2004 cis_level1_server
```

Note that it is generally good practice to commit all changes prior to running
one of these commands and then commit the results separately.

### `utils/refchecker.py` &ndash; automatically check `rule.yml` for references

This utility checks all `rule.yml` referenced from a given profile for the
specified reference.  Unlike `build-scripts/profile_tool.py`, which operates
on the built XCCDF information, `utils/refchecker.py` operates on the contents
of the `rule.yml` files.

To execute:

```bash
    $ ./utils/refchecker.py <product> <profile> <reference>
```

For example:

```bash
    $ ./utils/refchecker.py ubuntu2004 cis_level1_server cis
```

This utility has some knowledge of which references are product-specific
(checking for `cis@ubuntu2004` in the above example) and which are
product-independent.

Note that this utility does not modify the rule directories at all.

### `utils/mod_prodtype.py` &ndash; programmatically modify prodtype in `rule.yml`

`utils/mod_prodtype.py` is a command-based utility for modifying `rule.yml`
files. It supports the following sub-commands:

- `add`: add the given product(s) to the specified rule's prodtype.
- `list`: list computed and actual products in the specified rule's prodtype.
- `replace`: perform a pattern-match replacement on the specified rule's
  prodtype.
- `remove`: remove the given product(s) from the specified rule's prodtype.

To execute:

```bash
    $ ./utils/mod_prodtype.py <rule_id> <command> [...other arguments...]
```

For an example of `add`:

```bash
    $ ./utils/mod_prodtype.py accounts_passwords_pam_tally2 add ubuntu2004
```

For an example of `list`:

```bash
    $ ./utils/mod_prodtype.py accounts_passwords_pam_tally2 list
```

For an example of `replace`:

```bash
    $ ./utils/mod_prodtype.py accounts_passwords_pam_tally2 replace ubuntu2004~ubuntu1604,ubuntu1804,ubuntu2004
```

For an example of `remove`:

```bash
    $ ./utils/mod_prodtype.py accounts_passwords_pam_tally2 remove ubuntu1604 ubuntu1804 ubuntu2004
````

### `utils/mod_checks.py` and `utils/mod_fixes.py` &ndash; programmatically modify check and fix applicability

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

```bash
    $ ./utils/mod_checks.py <rule_id> <command> [...other arguments...]
    $ ./utils/mod_fixes.py <rule_id> <type> <command> [...other arguments...]
````

For an example of `add`:

```bash
    $ ./utils/mod_checks.py clean_components_post_updating add multi_platform_sle
    $ ./utils/mod_fixes.py clean_components_post_updating bash add multi_platform_sle
```

For an example of `list`:

```bash
    $ ./utils/mod_checks.py clean_components_post_updating list
    $ ./utils/mod_fixes.py clean_components_post_updating ansible list
```

For an example of `remove`:

```bash
    $ ./utils/mod_checks.py file_permissions_local_var_log_messages remove multi_platform_sle
    $ ./utils/mod_fixes.py file_permissions_local_var_log_messages bash remove multi_platform_sle
```

For an example of `replace`:

```bash
    $ ./utils/mod_checks.py file_permissions_local_var_log_messages replace multi_platform_sle~multi_platform_sle,multi_platform_ubuntu
    $ ./utils/mod_fixes.py file_permissions_local_var_log_messages bash replace multi_platform_sle~multi_platform_sle,multi_platform_ubuntu
```

For an example of `diff`:

```bash
    $ ./utils/mod_checks.py clean_components_post_updating diff sle12 sle15
    $ ./utils/mod_fixes.py clean_components_post_updating bash diff sle12 sle15
```

For an example of `delete`:

```bash
    $ ./utils/mod_checks.py clean_components_post_updating delete sle12
    $ ./utils/mod_fixes.py clean_components_post_updating bash delete sle12
```

For an example of `make_shared`:

```bash
    $ ./utils/mod_checks.py clean_components_post_updating make_shared sle12
    $ ./utils/mod_fixes.py clean_components_post_updating bash make_shared sle12
```

### `utils/create_scap_delta_tailoring.py` &ndash; Create tailoring files for rules not covered by other content

The goal of this tool is to create a tailoring file that enable rules that are not covered by other SCAP content and disables rules that are covered by the given content.
It supports the following arguments:

- `-r`, `--root` - Path to SSG root directory
- `-p`, `--product` - What product to produce the tailoring file for (required)
- `-m`, `--manual` - Path to the XCCDF XML file of the SCAP content (required)
- `-j`, `--json` - Path to the `rules_dir.json` file.
    - Defaults to `build/stig_control.json`
- `-c`, `--build-config-yaml` - YAML file with information about the build configuration.
    - Defaults to `build/build_config.yml`
- `-b`, `--profile` - What profile to use.
    - Defaults to stig
- `-ref`, `--reference` - What reference system to check for.
    - Defaults to `stigid`
    - `-o`, `--output` - Defaults `build/PRODUCT_PROFILE_tailoring.xml`, where `PRODUCT` and `PROFILE` are respective parameters given to the script.
    - `--profile-id` - The id of the created profile. Defaults to PROFILE_delta
    - `--tailoring-id` - The id of the created tailoring file. Defaults to xccdf_content-disa-delta_tailoring_default

To execute:

```bash
    $ ./utils/create_scap_delta_tailoring.py -p rhel8 -b stig -m shared/references/disa-stig-rhel8-v1r4-xccdf-scap.xml
```

### `utils/compare_ds.py` &ndash; Compare two data streams (can also compare XCCDFs)

This script compares two data streams or two benchmarks and generates a diff output.
It can show what changed in rules, for example in description, references and remediation scripts.
Changes in checks (OVAL and OCIL) are shown too, but the OVAL diff is limited to the `criteria`
and `criterion` order and their IDs.

When comparing contents from DISA, either the Automated content or Manual benchmark, use the
`--disa-content` option, this options maps the rules in the old content to the rule in the new content.
The rule mapping is necessary because the IDs in DISA's content's rules change IDs whenever
they are updated.

By default, the script prints the diff to the standard output, which can generate a single huge
diff for the whole data stream or benchmark.
The option `--rule-diffs` can be used to generate a diff file per rule. In this mode the diff files
are created in a directory: `./compare_ds-diffs`. To change the output dir use `--output-dir` option.

Compare current DISA's manual benchmark, and generate per file diffs:

```bash
    $ utils/compare_ds.py --disa-content --rule-diffs ./disa-stig-rhel8-v1r6-xccdf-manual.xml shared/references/disa-stig-rhel8-v1r7-xccdf-manual.xml
```

Compare two data streams:

```bash
    $ utils/compare_ds.py /tmp/ssg-rhel8-ds.xml build/ssg-rhel8-ds.xml > content.diff
```

#### HTML Diffs

The diffs generated by `utils/compare_ds.py` can be transformed to HTML diffs with `diff2html` utility.

Install `diff2html`:

```bash
    # Fedora
    $ sudo dnf install npm
    $ sudo npm install -g diff2html-cli
```

Generate the HTML diffs:

```bash
    $ mkdir -p html
    $ for f in $(ls compare_ds-diffs/); do diff2html -i file -t $f -F "html/$f.html" "compare_ds-diffs/$f"; done
```

### `utils/compare_results.py` &ndash; Compare to two ARF result files

The goal of this script is to compare the result of two ARF files.
It will show what rules are missing, different, and the same between the two files.
The script can take results from content created by this repo and by [DISA](https://public.cyber.mil/stigs/scap/).
If the result files come from the same source the script will use XCCDF ids as basis for the comparison.
Otherwise, the script will use STIG ids to compare.

If one STIG ID has more than one result (this is the case for a few STIG IDs in this repo) the results will be merged.
Given a set of status the script will select the status from the group that is the highest value on the list below.

1. Error
2. Fail
3. Not applicable
4. Not selected
5. Not checked
6. Informational
7. Pass

Examples:

- `[pass, pass]` will result in `pass`
- `[pass, fail]` will result in `fail`
- `[pass, error, fail]` will result in `error`

To execute:

```bash
    $ ./utils/compare_results.py ssg_results.xml disa_results.xml
```

### `utils/import_srg_spreadsheet.py` &ndash; Import changes made to an SRG Spreadsheet into the project

This script will import changes from a SRG export spreadsheet.
This script is designed to be run then each file reviewed carefully before being committed.

It supports the following arguments:

- `-b`, `--current` &mdash; Path to the current XLSX export (required)
- `-c`, `--changed` &mdash; Path to the XLSX that was changed, defaults to RHEL 9
- `-e`, `--end-row` &mdash; What row to stop scanning, defaults to 600.
- `-j`, `--json` &mdash; Path to the `rules_dir.json` file.
- `-n`, `--changed-name` &mdash; The name of the current in the changed file (required)
- `-p`, `--product` &mdash; What product to produce the tailoring file for (required)
- `-r`, `--root` &mdash; Path to SSG root directory

To execute:

```bash
    $ ./utils/import_srg_spreadsheet.py --changed 20220811_submission.xlsx --current build/cac_stig_output.xlsx -p rhel9
```

## Profiling the Build System

The goal of `utils/build_profiler.sh` and `utils/build_profiler_report.py` is to help developers measure and compare build times of a single product or a group of products and determine what impact their changes had on the speed of the buildsystem.
Both of these tools shouldn't be invoked alone but rather through the build_product script by using the -p|--profiling switch.

The intended usage is:

```bash
    $ ./build_product <products> -p|--profiling
```

### `utils/build_profiler.sh` &ndash; Handle directory structure for profiling files and invokes other script

The goal of this tool is to create the directory structure necessary for the profiling system and create a new numbered logfile, as well as invoking the `utils/build_profiler_report.py` and subsequently generating an interactive HTML file using webtreenode.

It is invoked by the `build_product` script. When invoked for the first time, it creates the `.build_profiling` directory and then a directory inside it named `product_string`, which is passed from the build_product script.
This is done so that each product combination being built has its own directory for log files, because different combinations may affect each other and have different build times.

The script then moves the ninja log from the build folder to the product_string folder and numbers it.
The baseline script is number 0 and if missing, the script will call the `utils/build_profiler_report.py` script with the `--baseline` switch.

It then invokes the `utils/build_profiler_report.py` script with a logfile name, as well as the optional baseline switch.
After that, it checks if the .webtreenode file was generated and then uses the webtreenode command to generate an interactive HTML report.

It supports exactly one argument:

- `"product_string"` - Contains all the product names that were built joined by underscores

To execute:

```bash
    $ ./build_profiler.sh <product_string>
```

### `utils/build_profiler_report.py` &ndash; Parse a ninja file and display report to user

The goal of this tool is to generate a report about differences in build times, both a text version in the terminal and a webtreenode version that is later converted into an interactive HTML report.

The script parses the data from `"logfile"` as the current logfile and the data from `0.ninja_log` as the baseline logfile (if the `--baseline` switch is used, the baseline log is not loaded).
It then generates a `.webtreemap` file and prints the report:

- `Target` - The target/outputfile that was built
- `%`      - The percentage of the total build time that the target took
- `D`      - The difference of the `%` percentage between baseline and current logfile (dimensionless value, not a percentage)
              - This is the most important metric, as it signifies the ratio of this target to the other targets, therefore it shouldn't be affected too much by the speed of the hardware
- `T`      - The time that the target took to get built in an `h:m:s` format
- `TD`     - The time difference between baseline and current logfile in an `h:m:s` format
- `%TD`     - The percentage difference of build times between current and baseline logfile

It supports up to two arguments:

- `"logfile"`  - [mandatory] Name of the numbered ninja logfile, e.g. `0.ninja_log`
- `--baseline` - [optional] If the switch is used, the values are not compared with a baseline log

To execute:

```bash
    $ ./build_profiler_report.py <logfile> [--baseline]
```

## Other Scripts

### `utils/srg_diff.py` &ndash; Compare Two SRG Spreadsheets

This script will output an HTML page that compares two SRG exports.
This script should help with reviewing changes created by `utils/import_srg_spreadsheet.py` script.
This script assumes that the STIG ID columns are compatible.
This script needs the project built for the given product and `utils/rule_dir_json.py` ran.

The report has the following sections:

- Missing in base/target: These sections list rules are not in the other spreadsheet
- Rows Missing STIG ID in base/target: These section list the requirement and SRG IDs of rows that do not have an STIG ID defined in the STIG ID and have a status of "Applicable - Configurable".
- Delta: If a rule is not the same an HTML diff will appear; base content is on the left.

Example:

```bash
    $ ./utils/srg_diff.py --target submission.xlsx --base build/cac_stig_output.xlsx --output build/diff.html -p rhel9
    Wrote output to build/diff.html.
```

### `utils/shorthand_to_oval.py` &ndash; Convert shorthand OVAL to a full OVAL

This script converts (resolved) shorthand OVAL files to a valid OVAL file.

It can be useful for example when creating minimal bug reproducers.
If you know that a problem is located in OVAL for a specific rule, you can use it to convert a resolved shorthand OVAL files from the `build/product/checks/oval` directory to a standalone valid OVAL file that you can then pass to `oscap`.

Example:

```bash
$ ./build_product rhel9
$ utils/shorthand_to_oval.py build/rhel9/checks/oval/accounts_tmout.xml oval.xml
$ oscap oval eval oval.xml
```

### `utils/controlrefcheck.py` &ndash; Ensure Control Files and Rules Are Consistent

This script helps ensure that control files and rules files are in sync.
The script takes in what product, control, and reference you are looking for.
The script loops over every rule in each control; the script then checks if the control's id is in the rule's reference that passed to the script.
If a control's ID does not match or rule does not exist in the project the script will exit with a non-zero status.
If the reference you are looking for is `cis` the script will not attempt to match anything that does not match a CIS section number.

To execute:
```bash
$ ./utils/controlrefcheck.py rhel9 cis_rhel9 cis
```

### `utils/check_eof.py` - Ensure Files Follow EOF Style

This script checks files of specific extensions (see `EXTENSIONS` in the script for the full list) to ensure that the files end with new line as required by the [style guide](https://complianceascode.readthedocs.io/en/latest/manual/developer/04_style_guide.html).
This script can be used to fix files that don't have a newline at the end if the `--fix` flag is passed to the script.
By default, the script just outputs a list of files are non-compliant.

 To execute:
 ```bash
 $ ./utils/check_eof.py ssg linux_os utils tests products shared docs apple_os applications build-scripts cmake Dockerfiles
 ```

### `utils/generate_profile.py` &ndash; Generating CIS Control Files

This script accepts a CIS benchmark spreadsheet (XLSX) and outputs a profile,
section, or rule. This is primarily useful for contributors maintaining
content. The script doesn't make assumptions about rules that implement
controls, should still be done by someone knowledge about the platform and
benchmark. The goal of the script is to reduce the amount of text contributors
have to copy and paste from benchmarks, making it easier to automate parts of
the benchmark maintenance process.

You can download CIS XLSX spreadsheets from CIS directly if you have access to
[CIS workbench](https://workbench.cisecurity.org/).

You can use the script to list all controls in a benchmark:

```bash
$ python utils/generate_profile.py -i benchmark.xlsx list
1.1.1
1.1.2
1.1.3
1.1.4
1.1.5
1.1.6
1.1.7
1.1.8
1.1.9
1.1.10
...
```

To generate a rule for a specific control:

```
$ python utils/generate_profile.py -i benchmark.xlsx generate --product-type ocp -c 1.1.2
documentation_complete: false
prodtype: ocp
title: |-
  Ensure that the API server pod specification file ownership is set to root:root
description: 'Ensure that the API server pod specification file ownership is set to
  `root:root`.

  No remediation required; file permissions are managed by the operator.'
rationale: |-
  The API server pod specification file controls various parameters that set the behavior of the API server. You should set its file ownership to maintain the integrity of the file. The file should be owned by `root:root`.
severity: PLACEHOLDER
references: PLACEHOLDER
ocil: "OpenShift 4 deploys two API servers: the OpenShift API server and the Kube\
  \ API server. \n\nThe OpenShift API server is managed as a deployment. The pod specification\
  \ yaml for openshift-apiserver is stored in etcd. \n\nThe Kube API Server is managed\
  \ as a static pod. The pod specification file for the kube-apiserver is created\
  \ on the control plane nodes at /etc/kubernetes/manifests/kube-apiserver-pod.yaml.\
  \ The kube-apiserver is mounted via hostpath to the kube-apiserver pods via /etc/kubernetes/static-pod-resources/kube-apiserver-pod.yaml\
  \ with ownership `root:root`.\n\nTo verify pod specification file ownership for\
  \ the kube-apiserver, run the following command.\n\n```\n#echo \u201Ccheck kube-apiserver\
  \ pod specification file ownership\u201D\n\nfor i in $( oc get pods -n openshift-kube-apiserver\
  \ -l app=openshift-kube-apiserver -o name )\ndo\n oc exec -n openshift-kube-apiserver\
  \ $i -- \\\n stat -c %U:%G /etc/kubernetes/static-pod-resources/kube-apiserver-pod.yaml\n\
  done\n```\nVerify that the ownership is set to `root:root`."
ocil_clause: PLACEHOLDER
warnings: PLACEHOLDER
template: PLACEHOLDER
```

To generate an entire section:

```
$ python utils/generate_profile.py -i benchmark.xlsx generate --product-type ocp -s 1
```

The `PLACEHOLDER` values must be filled in later, ideally when the rules are
provided for each control.


### `utils/compare_versions.py` &ndash; Compare ComplianceAsCode versions

Show differences between two ComplianceAsCode versions.
Lists added or removed rules, profiles, changes in profile composition and changes in remediations and platforms.
For comparison, you can use git tags or ComplianceAsCode JSON manifest files directly.

To compare 2 ComplianceAsCode JSON manifests, provide the manifest files.

```
python3 utils/compare_versions.py compare_manifests ~/manifests/old.json ~/manifests/new.json
```

To compare 2 upstream versions, you need to specify the version git tags and a product ID.

```
$ python3 utils/compare_versions.py compare_tags v0.1.67 v0.1.68 rhel9
```

It will internally clone the upstream project, checkout these tags, generate ComplianceAsCode JSON manifests, compare them and print the output.


### `utils/oscal/build_cd_from_policy.py` &ndash; Build a Component Definition from a Policy

This script builds an OSCAL Component Definition (cd) (version `1.0.4`) for an existing OSCAL profile from a policy. The script uses the
[compliance-trestle](https://ibm.github.io/compliance-trestle/) library to build the component definition. The component definition can be used with the `compliance-trestle` CLI after generation.

Some assumption made by this script:

- The script maps control file statuses to valid OSCAL [statuses](https://pages.nist.gov/OSCAL-Reference/models/v1.1.1/system-security-plan/json-reference/#/system-security-plan/control-implementation/implemented-requirements/by-components/implementation-status) as follows:

  * `pending` - `alternative`

  * `not applicable`: `not-applicable`

  * `inherently met`: `implemented`

  * `documentation`: `implemented`

  * `planned`: `planned`

  * `partial`: `partial`

  * `supported`: `implemented`

  * `automated`: `implemented`

  * `manual`: `alternative`

  * `does not meet`: `alternative`

- The script uses the "Section *letter*:" convention in the control notes to create statements under the implemented requirements.
- The script maps parameter to rules uses the `xccdf_variable` field under `template.vars`
- To determine what responses will mapped to the controls in the OSCAL profile the control id and label property from the resolved catalog is searched.

It supports the following arguments:
  - `-o`, `--output` &mdash; Path to write the cd to
  - `-r`, `--root` &mdash; Root of the SSG project. Defaults to /content.
  - `-v`, `--vendor-dir` &mdash; Path to the vendor directory with third party OSCAL artifacts
  - `-p`, `--profile` &mdash; Main profile href, or name of the profile model in the trestle workspace
  - `-pr`, `--product` &mdash; Product to build cd with
  - `-c`, `--control` &mdash; Control to use as the source for control responses. To optionally filter by level, use the format <control_id>:<level>.
  - `-j`, `--json` &mdash; Path to the rules_dir.json. Defaults to /content/build/rule_dirs.json.
  - `-b`, `--build-config-yaml` &mdash; YAML file with information about the build configuration
  - `-t`, `--component-definition-type` &mdash; Type of component definition to create. Defaults to service. Options are service or validation.

An example of how to execute the script:

```bash
$ ./build_product ocp4
$ ./utils/rule_dir_json.py
$ ./utils/oscal/build_cd_from_policy.py -o build/ocp4.json -p fedramp_rev4_high -pr ocp4 -c nist_ocp4:high
```
