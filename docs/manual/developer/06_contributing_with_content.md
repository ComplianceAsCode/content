
# Contributing with XCCDFs, OVALs and remediations

There are three main types of content in the project, they are rules,
defined using the XCCDF standard, checks, usually written in
[OVAL](https://oval.mitre.org/language/about/) format, and remediations,
that can be executed on ansible, bash, anaconda installer, puppet,
ignition and kubernetes. ComplianceAsCode also has its own templating
mechanism, allowing content writers to create models and use it to
generate a number of checks and remediations.

## Contributing

Contributions can be made for rules, checks, remediations or even
utilities. There are different sets of guidelines for each type, for
this reason there is a different topic for each of them.

### Rules

Rules are input described in YAML which mirrors the XCCDF format (an XML
container). Rules are translated to become members of a `Group` in an
XML file. All existing rules for Linux products can be found in the
`linux_os/guide` directory. For non-Linux products (e.g., `jre`), this
content can be found in the `<product>/guide`. The exact location
depends on the group (or category) that a rule belongs to.

For an example of rule group, see
`linux_os/guide/system/software/disk_partitioning/partition_for_tmp/rule.yml`.
The id of this rule is `partition_for_tmp`; this rule belongs to the
`disk_partitioning` group, which in turn belongs to the `software` group
(which in turn belongs to the `system` group). Because this rule is in
`linux_os/guide`, it can be shared by all Linux products.

Rules describe the desired state of the system and may contain
references if they are parts of higher-level standards. All rules should
reflect only a single configuration change for compliance purposes.

Structurally, a rule is a YAML file (which can contain Jinja macros)
that represents a dictionary.

A rule YAML file has one implied attribute:

-   `id`: The primary identifier for the rule to be referenced from
    profiles. This is inferred from the file name and links it to checks
    and fixes with the same file name.

A rule itself contains these attributes:

-   `title`: Human-readable title of the rule.

-   `rationale`: Human-readable HTML description of the reason why the
    rule exists and why it is important from the technical point of
    view. For example, rationale of the `partition_for_tmp` rule states
    that:

    The &lt;tt&gt;/tmp&lt;/tt&gt; partition is used as temporary storage
    by many programs. Placing &lt;tt&gt;/tmp&lt;/tt&gt; in its own
    partition enables the setting of more restrictive mount options,
    which can help protect programs which use it. \* `description`:
    Human-readable HTML description, which provides broader context for
    non-experts than the rationale. For example, description of the
    `partition_for_tmp` rule states that:

-   `requires`: The `id` of another rule or group that must be selected
    and enabled in a profile.

-   `conflicts`: The `id` of another rule or group that must not be
    selected and disabled in a profile.

    The &lt;tt&gt;/var/tmp&lt;/tt&gt; directory is a world-writable
    directory used for temporary file storage. Ensure it has its own
    partition or logical volume at installation time, or migrate it
    using LVM. \* `severity`: Is used for metrics and tracking. It can
    have one of the following values: `unknown`, `info`, `low`,
    `medium`, or `high`.

    <table>
    <colgroup>
    <col style="width: 50%" />
    <col style="width: 50%" />
    </colgroup>
    <thead>
    <tr class="header">
    <th>Level</th>
    <th>Description</th>
    </tr>
    </thead>
    <tbody>
    <tr class="odd">
    <td><p><code>unknown</code></p></td>
    <td><p>Severity not defined (default)</p></td>
    </tr>
    <tr class="even">
    <td><p><code>info</code></p></td>
    <td><p>Rule is informational only. Failing the rule doesn’t imply failure to conform to the security guidance of the benchmark.</p></td>
    </tr>
    <tr class="odd">
    <td><p><code>low</code></p></td>
    <td><p>Not a serious problem</p></td>
    </tr>
    <tr class="even">
    <td><p><code>medium</code></p></td>
    <td><p>Fairly serious problem</p></td>
    </tr>
    <tr class="odd">
    <td><p><code>high</code></p></td>
    <td><p>Grave or critical problem</p></td>
    </tr>
    </tbody>
    </table>

    When deciding on severity levels, it is best to follow the following
    guidelines: .Table Vulnerability Severity Category Code Definitions

    <table>
    <colgroup>
    <col style="width: 33%" />
    <col style="width: 33%" />
    <col style="width: 33%" />
    </colgroup>
    <tbody>
    <tr class="odd">
    <td><p>Severity</p></td>
    <td><p>DISA Category</p></td>
    <td><p>Category Code Guidelines</p></td>
    </tr>
    <tr class="even">
    <td><p><code>high</code></p></td>
    <td><p><code>CAT I</code></p></td>
    <td><p>Any vulnerability, the exploitation of which will directly and immediately result in loss of Confidentiality, Availability, or Integrity.</p></td>
    </tr>
    <tr class="odd">
    <td><p><code>medium</code></p></td>
    <td><p><code>CAT II</code></p></td>
    <td><p>Any vulnerability, the exploitation of which has a potential to result in loss of Confidentiality, Availability, or Integrity.</p></td>
    </tr>
    <tr class="even">
    <td><p><code>low</code></p></td>
    <td><p><code>CAT III</code></p></td>
    <td><p>Any vulnerability, the existence of which degrades measures to protect againstloss of Confidentiality, Availability, or Integrity.</p></td>
    </tr>
    </tbody>
    </table>

    The severity of the rule can be overridden by a profile with
    `refine-rule` selector. \* `platform`: Defines applicability of a
    rule. For example, if a rule is not applicable to containers, this
    should be set to `machine`, which means it will be evaluated only if
    the targeted scan environment is either bare-metal or virtual
    machine. Also, it can restrict applicability on higher software
    layers. By setting to `shadow-utils`, the rule will have its
    applicability restricted to only environments which have
    `shadow-utils` package installed. The available options can be found
    in the file &lt;product&gt;/cpe/&lt;product&gt;-cpe-dictionary.xml
    (e.g.: rhel8/cpe/rhel8-cpe-dictionary.xml). In order to support a
    new value, an OVAL check (of `inventory` class) must be created
    under `shared/checks/oval/` and referenced in the dictionary
    file. \* `ocil`: Defines asserting statements to check whether or
    not the rule is valid. \* `ocil_clause`: This attribute contains the
    statement which describes how to determine whether the statement is
    true or false. Check out `rule.yml` in
    `linux_os/guide/system/software/disk_partitioning/encrypt_partitions/`:
    this contains a `partitions do not have a type of crypto_LUKS` value
    for `ocil_clause`. This clause is prefixed with the phrase "It is
    the case that".

A rule may contain those reference-type attributes:

-   `identifiers`: This is related to products that the rule applies to;
    this is a dictionary. Currently, only the Common Configuration
    Enumeration or CCE identifier is supported. Other identifiers can be
    added as well. Contributions to add these other identifiers are
    welcomed. The table below shows a list of common identifiers and
    their current support in a rule:

    <table>
    <colgroup>
    <col style="width: 33%" />
    <col style="width: 33%" />
    <col style="width: 33%" />
    </colgroup>
    <thead>
    <tr class="header">
    <th>URI</th>
    <th>Supported</th>
    <th>Identifier Value Description</th>
    </tr>
    </thead>
    <tbody>
    <tr class="odd">
    <td><p><a href="http://cce.mitre.org">http://cce.mitre.org</a></p></td>
    <td><p>Yes</p></td>
    <td><p>Common Configuration Enumeration (CCE) – the identifier value MUST be a CCE version 5 number</p></td>
    </tr>
    <tr class="even">
    <td><p><a href="http://cpe.mitre.org">http://cpe.mitre.org</a></p></td>
    <td><p>No</p></td>
    <td><p>CPE –the identifier value MUST be a CPE version 2.0 or 2.3 name</p></td>
    </tr>
    <tr class="odd">
    <td><p><a href="http://cve.mitre.org">http://cve.mitre.org</a></p></td>
    <td><p>No</p></td>
    <td><p>CVE –the identifier value MUST be a CVE number</p></td>
    </tr>
    <tr class="even">
    <td><p><a href="http://www.cert.org">http://www.cert.org</a></p></td>
    <td><p>No</p></td>
    <td><p>CERT Coordination Center – the identifier value SHOULD be a CERT advisory identifier (e.g., “CA-2004-02”)</p></td>
    </tr>
    <tr class="odd">
    <td><p><a href="http://www.kb.cert.org">http://www.kb.cert.org</a></p></td>
    <td><p>No</p></td>
    <td><p>US-CERT vulnerability notes database – the identifier value SHOULD be a vulnerability note number (e.g., “709220”)</p></td>
    </tr>
    <tr class="even">
    <td><p><a href="http://www.us-cert.gov/cas/techalerts">http://www.us-cert.gov/cas/techalerts</a></p></td>
    <td><p>No</p></td>
    <td><p>US-CERT technical cyber security alerts –the identifier value SHOULD be a technical cyber security alert ID (e.g., “TA05-189A”)</p></td>
    </tr>
    </tbody>
    </table>

    When the rule is related to RHEL, it should have a CCE. A CEE (e.g.
    <cce@rhel7>: CCE-80328-8) is used as a global identifier that maps
    the rule to the product over the lifetime of a rule. There should
    only be one CCE mapped to a rule as a global identifier. Any other
    usage of CCE is no longer considered a best practice. CCEs are also
    product dependent which means that a different CCE must be used for
    each different product and product version. For example if
    `cce@rhel7: 80328-8` exists in a rule, that CCE cannot be used for
    another product or version (e.g. rhel9), and the CCE MUST be retired
    with the rule. Available CCEs that can be assigned to new rules are
    listed in the `shared/references/cce-rhel-avail.txt` file.

-   `references`: This is related to the compliance document line items
    that the rule applies to. These can be attributes such as `stigid`,
    `srg`, `nist`, etc., whose keys may be modified with a product
    (e.g., `stigid@rhel7`) to restrict what products a reference
    identifier applies to. Depending on the type of reference (e.g.
    catalog, rulei, etc.) will depend on how many can be added to a
    single rule. In addition, certain references in a rule such as
    `stigid` only apply to a certain product and product version; they
    cannot be used for multiple products and versions

    <table>
    <colgroup>
    <col style="width: 25%" />
    <col style="width: 25%" />
    <col style="width: 25%" />
    <col style="width: 25%" />
    </colgroup>
    <thead>
    <tr class="header">
    <th>Key</th>
    <th>Reference Type</th>
    <th>Mapping to Rule</th>
    <th>Example Format</th>
    </tr>
    </thead>
    <tbody>
    <tr class="odd">
    <td><p>cis</p></td>
    <td><p>Center for Internet Security (catalog identifier)</p></td>
    <td><p>0-to-many, 0-to-1 is preferred</p></td>
    <td><p>5.2.5</p></td>
    </tr>
    <tr class="even">
    <td><p>cjis</p></td>
    <td><p>Criminal Justice Information System (catalog identifier)</p></td>
    <td><p>0-to-1</p></td>
    <td><p>5.4.1.1</p></td>
    </tr>
    <tr class="odd">
    <td><p>cui</p></td>
    <td><p>Controlled Unclassified Information (catalog identifier)</p></td>
    <td><p>0-to-many, 0-to-1 is preferred</p></td>
    <td><p>3.1.7</p></td>
    </tr>
    <tr class="even">
    <td><p>disa</p></td>
    <td><p>DISA Control Correlation Identifiers (catalog identifier)</p></td>
    <td><p>0-to-many</p></td>
    <td><p>CCI-000018,CCI-000172,CCI-001403</p></td>
    </tr>
    <tr class="odd">
    <td><p>srg, vmmsrg, etc.</p></td>
    <td><p>DISA Security Requirements Guide (catalog identifier)</p></td>
    <td><p>0-to-many</p></td>
    <td><p>SRG-OS-000003-GPOS-00004</p></td>
    </tr>
    <tr class="even">
    <td><p>stigid@&lt;product&gt;&lt;product_version&gt;</p></td>
    <td><p>DISA STIG identifier (rule identifier)</p></td>
    <td><p>0-to-1</p></td>
    <td><p>RHEL-07-030874</p></td>
    </tr>
    <tr class="odd">
    <td><p>hipaa</p></td>
    <td><p>Health Insurance Portability and Accountability Act of 1996 (HIPAA) (catalog identifier)</p></td>
    <td><p>0-to-many</p></td>
    <td><p>164.308(a)(1)(ii)(D),164.308(a)(3)(ii)(A)</p></td>
    </tr>
    <tr class="even">
    <td><p>nist</p></td>
    <td><p>National Institute for Standards and Technology 800-53 (catalog identifier)</p></td>
    <td><p>0-to-many</p></td>
    <td><p>AC-2(4),AC-17(7),AU-1(b)</p></td>
    </tr>
    <tr class="odd">
    <td><p>nist-csf</p></td>
    <td><p>National Institute for Standards and Technology Cybersecurity Framework (catalog identifier)</p></td>
    <td><p>0-to-many</p></td>
    <td><p>DE.AE-3,DE.AE-5,DE.CM-1</p></td>
    </tr>
    <tr class="even">
    <td><p>ospp</p></td>
    <td><p>National Information Assurance Partnership (selected control identifier)</p></td>
    <td><p>0-to-many</p></td>
    <td><p>FMT_MOF_EXT.1</p></td>
    </tr>
    <tr class="odd">
    <td><p>pcidss</p></td>
    <td><p>Payment Card Industry Data Security Standard</p></td>
    <td><p>0-to-many, 0-to-1 is preferred</p></td>
    <td><p>Req-8.7.c</p></td>
    </tr>
    </tbody>
    </table>

    See
    `linux_os/guide/system/software/disk_partitioning/encrypt_partitions/rule.yml`
    for an example of reference-type attributes as there are others that
    are not referenced above.

Some of existing rule definitions contain attributes that use macros.
There are two implementations of macros:

-   [Jinja macros](http://jinja.pocoo.org/docs/2.10/), that are defined
    in `shared/macros.jinja`, and `shared/macros-highlevel.jinja`.

-   Legacy XSLT macros, which are defined in `shared/transforms/*.xslt`.

For example, the `ocil` attribute of `service_ntpd_enabled` uses the
`ocil_service_enabled` jinja macro. Due to the need of supporting
Ansible output, which also uses jinja, we had to modify control
sequences, so macro operations require one more curly brace. For
example, invocation of the partition macro looks like
`{{{ complete_ocil_entry_separate_partition(part="/tmp") }}}` - there
are three opening and closing curly braces instead of the two that are
documented in the Jinja guide.

`shared/macros.jinja` contains specific low-level macros s.a.
`systemd_ocil_service_enabled`, whereas `shared/macros-highlevel.jinja`
contains general macros s.a. `ocil_service_enabled`, that decide which
one of the specialized macros to call based on the actual product being
used.

The macros that are likely to be used in descriptions begin by
`describe_`, whereas macros likely to be used in OCIL entries begin with
`ocil_`. Sometimes, a rule requires `ocil` and `ocil_clause` to be
specified, and they depend on each other. Macros that begin with
`complete_ocil_entry_` were designed for exactly this purpose, as they
make sure that OCIL and OCIL clauses are defined and consistent. Macros
that begin with underscores are not meant to be used in descriptions.

To parametrize rules and remediations as well as Jinja macros, you can
use product-specific variables defined in `product.yml` in product root
directory. Moreover, you can define **implied properties** which are
variables inferred from them. For example, you can define a condition
that checks if the system uses `yum` or `dnf` as a package manager and
based on that populate a variable containing correct path to the
configuration file. The inferring logic is implemented in
`_get_implied_properties` in `ssg/yaml.py`. Constants and mappings used
in implied properties should be defined in `ssg/constants.py`.

Rules are unselected by default - even if the scanner reads rule
definitions, they are effectively ignored during the scan or
remediation. A rule may be selected by any number of profiles, so when
the scanner is scanning using a profile the rule is included in, the
rule is taken into account. For example, the rule identified by
`partition_for_tmp` defined in
`shared/xccdf/system/software/disk_partitioning.xml` is included in the
`RHEL7 C2S` profile in `rhel7/profiles/C2S.xml`.

Checks are connected to rules by the `oval` element and the filename in
which it is found. Remediations (i.e. fixes) are assigned to rules based
on their basename. Therefore, the rule `sshd_print_last_log` has a
`bash` fix associated as there is a `bash` script
`shared/fixes/bash/sshd_print_last_log.sh`. As there is an Ansible
playbook `shared/fixes/ansible/sshd_print_last_log.yml`, the rule has
also an Ansible fix associated.

### Rule Directories

The rule directory simplifies the structure of a rule and all of its
associated content by placing it all under a common directory. The
structure of a rule directory looks like the following example:

    linux_os/guide/system/group/rule_id/rule.yml
    linux_os/guide/system/group/rule_id/bash/ol7.sh
    linux_os/guide/system/group/rule_id/bash/shared.sh
    linux_os/guide/system/group/rule_id/oval/rhel7.xml
    linux_os/guide/system/group/rule_id/oval/shared.xml

To be considered a rule directory, it must be a directory contained in a
benchmark pointed to by some product. The directory must have a name
that is the id of the rule, and must contain a file called `rule.yml`
which is a YAML Rule description as described above. This directory can
then contain the following subdirectories:

-   `anaconda` - for Anaconda remediation content, ending in `.anaconda`

-   `ansible` - for Ansible remediation content, ending in `.yml`

-   `bash` - for Bash remediation content, ending in `.sh`

-   `oval` - for OVAL check content, ending in `.xml`

-   `puppet` - for Puppet remediation content, ending in `.pp`

-   `ignition` - for Ignition remediation content, ending in `.yml`

-   `kubernetes` - for Kubernetes remediation content, ending in `.yml`

In each of these subdirectories, a file named `shared.ext` will apply to
all products and be included in all builds, but `{{{ product }}}.ext`
will only get included in the build for `{{{ product }}}` (e.g.,
`rhel7.xml` above will only be included in the build of the `rhel7`
guide content and not in the `ol7` content). Note that `.ext` must be
substituted for the correct extension for content of that type (e.g.,
`.sh` for `bash` content). Further, all of these directories are
optional and will only be searched for content if present. Lastly, the
product naming of content will not override the contents of `platform`
or `prodtype` fields in the content itself (e.g., if `rhel7` is not
present in the `rhel7.xml` OVAL check platform specifier, it will be
included in the build artifacts but later removed because it doesn’t
match the platform).

Currently the build system supports both rule files (discussed above)
and rule directories. For example content in this format, please see
rules in `linux_os/guide`.

To interact with build directories, the `ssg.rules` and
`ssg.rule_dir_stats` modules have been created, as well as three
utilities:

-   `utils/rule_dir_json.py` - to generate a JSON tree describing the
    current content of all guides

-   `utils/rule_dir_stats.py` - for analyzing the JSON tree and finding
    information about specific rules, products, or summary statistics

-   `utils/rule_dir_diff.py` - for diffing two JSON trees (e.g., before
    and after a major change), using the same interface as
    `rule_dir_stats.py`.

For more information about these utilities, please see their help text.

To interact with `rule.yml` files and the OVALs inside a rule directory,
the following utilities are provided:

#### `utils/mod_prodtype.py`

This utility modifies the prodtype field of rules. It supports several
commands:

-   `mod_prodtype.py <rule_id> list` - list the computed and actual
    prodtype of the rule specified by `rule_id`.

-   `mod_prodtype.py <rule_id> add <product> [<product> ...]` - add
    additional products to the prodtype of the rule specified by
    `rule_id`.

-   `mod_prodtype.py <rule_id> remove <product> [<product> ...]` -
    remove products to the prodtype of the rule specified by `rule_id`.

-   `mod_prodtype.py <rule_id> replace <replacement> [<replacement> ...]` -
    do the specified replacement transformations. A replacement
    transformation is of the form `match~replace` where `match` and
    `replace` are a comma separated list of products. If all of the
    products in `match` exist in the original `prodtype` of the rule,
    they are removed and the products in `replace` are added.

This utility requires an up to date JSON tree created by
`rule_dir_json.py`.

#### `utils/mod_checks.py`

This utility modifies the `<affected>` element of an OVAL check. It
supports several commands on a given rule:

-   `mod_checks.py <rule_id> list` - list all OVALs, their computed
    products, and their actual platforms.

-   `mod_checks.py <rule_id> delete <product>` - delete the OVAL for the
    the specified product.

-   `mod_checks.py <rule_id> make_shared <product>` - moves the product
    OVAL to the shared OVAL (e.g., `rhel7.xml` to `shared.xml`).

-   `mod_checks.py <rule_id> diff <product> <product>` - Performs a diff
    between two OVALs (product can be `shared` to diff against the
    shared OVAL).

In addition, the `mod_checks.py` utility supports modifying the shared
OVAL with the following commands:

-   `mod_checks.py <rule_id> add <platform> [<platform> ...]` - adds the
    specified platforms to the shared OVAL for the rule specified by
    `rule_id`.

-   `mod_checks.py <rule_id> remove <platform> [<platform> ...]` -
    removes the specified platforms from the shared OVAL.

-   `mod_checks.py <rule_id> replace <replacement> [<replacement ...]` -
    do the specified replacement against the platforms in the shared
    OVAL. See the description of `replace` under `mod_prodtype.py` for
    more information about the format of a replacement.

This utility requires an up to date JSON tree created by
`rule_dir_json.py`.

#### `utils/mod_fixes.py`

This utility modifies the `<affected>` element of a remediation. It
supports several commands on a given rule and for the specified
remediation language:

-   `mod_fixes.py <rule_id> <lang> list` - list all fixes, their
    computed products, and their actual platforms.

-   `mod_fixes.py <rule_id> <lang> delete <product>` - delete the fix
    for the specified product.

-   `mod_fixes.py <rule_id> <lang> make_shared <product>` - moves the
    product fix to the shared fix (e.g., `rhel7.sh` to `shared.sh`).

-   `mod_fixes.py <rule_id> <lang> diff <product> <product>` - Performs
    a diff between two fixes (product can be `shared` to diff against
    the shared fix).

In addition, the `mod_fixes.py` utility supports modifying the shared
fixes with the following commands:

-   `mod_fixes.py <rule_id> <lang> add <platform> [<platform> ...]` -
    adds the specified platforms to the shared fix for the rule
    specified by `rule_id`.

-   `mod_fixes.py <rule_id> <lang> remove <platform> [<platform> ...]` -
    removes the specified platforms from the shared fix.

-   `mod_fixes.py <rule_id> <lang> replace <replacement> [<replacement ...]` -
    do the specified replacement against the platforms in the shared
    fix. See the description of `replace` under `mod_prodtype.py` for
    more information about the format of a replacement.

This utility requires an up to date JSON tree created by
`rule_dir_json.py`.

#### `utils/add_platform_rule.py`

This utility can be used to bootstrap and test Kubernetes/OpenShift
application checks. See the help output for more detailed usage examples
of each of the supported subcommands:

-   `utils/add_platform_rule.py create --rule=<rule_name> <options>` -
    creates files for a new rule.

-   `utils/add_platform_rule.py test --rule=<rule_name> <options>` -
    tests a rule against local files using an oscap container.

-   `utils/add_platform_rule.py cluster-test --rule=<rule_name> <options>`
    - tests a rule against a running OCP4 cluster using
    compliance-operator.

This utility requires the following:

-   KUBECONFIG env set to a kubeconfig file for a running OCP4 cluster.

-   `oc` and `podman` in PATH.

Tips:

-   The --yamlpath option requires a specialized format to specify the
    resource element to check. See
    <https://github.com/OpenSCAP/yaml-filter/wiki/YAML-Path-Definition>
    for documentation.

-   To use the local `test` subcommand, first create a yaml file under a
    directory structure under /tmp that mirrors the API path. For
    example, if the resource’s full path is /api/v1/foo, save the yaml
    to /tmp/api/v1/foo. Running `test` will then check the rule against
    the local file by launching an openscap-1.3.3 container using
    podman.

### Checks

Checks are used to evaluate a Rule. They are written using a custom OVAL
syntax and are stored as xml files inside the *checks/oval* directory
for the desired platform. During the building process, the system will
transform the checks in OVAL compliant checks.

In order to create a new check, you must create a file in the
appropriate directory, and name it the same as the Rule *id*. This *id*
will also be used as the OVAL *id* attribute. The content of the file
should follow the OVAL specification with these exceptions:

-   The root tag must be `<def-group>`

-   If the OVAL check has to be a certain OVAL version, you can add
    `oval_version="oval_version_number"` as an attribute to the root
    tag. Otherwise if `oval_version` does not exist in `<def-group>`, it
    is assumed that the OVAL file applies to *any* OVAL version.

-   Don’t use the tags `<definitions>` `<tests>` `<objects>` `<states>`,
    instead, put the tags `<definition>` `<*_test>` `<*_object>`
    `<*_state>` directly inside the `<def-group>` tag.

-   **TODO** Namespaces

This is an example of a check, written using the custom OVAL syntax,
that checks if the group that owns the file */etc/cron.allow* is the
root:

    <def-group oval_version="5.11">
      <definition class="compliance" id="file_groupowner_cron_allow" version="1">
        <metadata>
          <title>Verify group who owns 'cron.allow' file</title>
          <affected family="unix">
            <platform>Red Hat Enterprise Linux 7</platform>
          </affected>
          <description>The /etc/cron.allow file should be owned by the appropriate
          group.</description>
        </metadata>
        <criteria>
          <criterion test_ref="test_groupowner_etc_cron_allow" />
        </criteria>
      </definition>
      <unix:file_test check="all" check_existence="any_exist"
      comment="Testing group ownership /etc/cron.allow" id="test_groupowner_etc_cron_allow"
      version="1">
        <unix:object object_ref="object_groupowner_cron_allow_file" />
        <unix:state state_ref="state_groupowner_cron_allow_file" />
      </unix:file_test>
      <unix:file_state id="state_groupowner_cron_allow_file" version="1">
        <unix:group_id datatype="int">0</unix:group_id>
      </unix:file_state>
      <unix:file_object comment="/etc/cron.allow"
      id="object_groupowner_cron_allow_file" version="1">
        <unix:filepath>/etc/cron.allow</unix:filepath>
      </unix:file_object>

#### Macros

-   `oval_sshd_config` - check a parameter and value in the sshd
    configuration file

-   `oval_grub_config` - check a parameter and value in the grub
    configuration file

-   `oval_check_config_file` - check a parameter and value in a given
    configuration file

-   `oval_check_ini_file` - check a parameter and value in a given
    section of a given configuration file in "INI" format

Always consider reusing `oval_check_config_file` when creating new
macros, it has some logic that will save you some time (e.g.: platform
applicability).

They also include several low-level macros which are used to build the
high level macros:

-   set of low-level macros to build the OVAL checks for line in file:
```
oval_line_in_file_criterion
oval_line_in_file_test
oval_line_in_file_object
oval_line_in_file_state
```

- set of low-level macros to build the OVAL checks to test if a file exists:
```
oval_config_file_exists_criterion
oval_config_file_exists_test
oval_config_file_exists_object
```

###### Platform applicability

Whenever possible, please reuse the macros and form high-level
simplifications.

Remediations
------------

Remediations, also called fixes, are used to change the state of the
machine, so that previously non-passing rules can pass. There can be
multiple versions of the same remediation meant to be executed by
different applications, more specifically Ansible, Bash, Anaconda,
Puppet, Ignition and Kubernetes. By default all remediation languages
are built and included in the DataStream.

But each product can specify its own set of remediation to include in
the DataStream via a CMake Variable in the product’s `CMakeLists.txt`.
See example below, from OCP4 product, `ocp4/CMakeLists.txt`:

    set(PRODUCT_REMEDIATION_LANGUAGES "ignition;kubernetes")

They also have to be idempotent, meaning that they must be able to be
executed multiple times without causing the fixes to accumulate. The
Ansible’s language works in such a way that this behavior is built-in,
however, for the other versions, the remediations must have it
implemented explicitly. Remediations also carry metadata that should be
present at the beginning of the files. This meta data will be converted
in [XCCDF
tags](https://scap.nist.gov/specifications/xccdf/xccdf_element_dictionary.html#fixType)
during the building process. That is how it looks like and what it
means:

    # platform = multi_platform_all
    # reboot = false
    # strategy = restrict
    # complexity = low
    # disruption = low

<table>
<colgroup>
<col style="width: 33%" />
<col style="width: 33%" />
<col style="width: 33%" />
</colgroup>
<thead>
<tr class="header">
<th>Field</th>
<th>Description</th>
<th>Accepted values</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><p>platform</p></td>
<td><p>CPE name, CPE applicability language expression or even wildcards declaring which platforms the fix can be applied</p></td>
<td><p><a href="https://github.com/OpenSCAP/openscap/blob/maint-1.2/cpe/openscap-cpe-dict.xml">Default CPE dictionary is packaged along with openscap</a>. Custom CPE dictionaries can be used. Wildcards are multi_platform_[all, oval, fedora, debian, ubuntu, linux, rhel, openstack, opensuse, rhev, sle].</p></td>
</tr>
<tr class="even">
<td><p>reboot</p></td>
<td><p>Whether or not a reboot is necessary after the fix</p></td>
<td><p>true, false</p></td>
</tr>
<tr class="odd">
<td><p>strategy</p></td>
<td><p>The method or approach for making the described fix. Only informative for now</p></td>
<td><p>unknown, configure, disable, enable, patch, policy, restrict, update</p></td>
</tr>
<tr class="even">
<td><p>complexity</p></td>
<td><p>The estimated complexity or difficulty of applying the fix to the target. Only informative for now</p></td>
<td><p>unknown, low, medium, high</p></td>
</tr>
<tr class="odd">
<td><p>disruption</p></td>
<td><p>An estimate of the potential for disruption or operational degradation that the application of this fix will impose on the target. Only informative for now</p></td>
<td><p>unknown, low, medium, high</p></td>
</tr>
</tbody>
</table>

### Ansible

> **Important**
>
> The minimum version of Ansible must be at the latest supported
> version. See
> <https://access.redhat.com/support/policy/updates/ansible-engine> for
> information on the supported Ansible versions.

Ansible remediations are either:

-   Stored as `.yml` files in directory `ansible` in the rule directory.

-   Generated from templates.

-   Generated using jinja2 macros.

They are meant to be executed by Ansible itself when requested by
openscap, so they are written using [Ansible’s own
language](http://docs.ansible.com/ansible/latest/intro.html) with the
following exceptions:

-   The remediation content must be only the *tasks* section of what
    would be a playbook.

    -   Tasks can include blocks for grouping related tasks.

    -   The `when` clause will get augmented in certain scenarios.

-   Notifications and handlers are not supported.

-   Tags are not necessary, because they are automatically generated
    during build of content.

Here is an example of an Ansible remediation that ensures the SELinux is
enabled in grub:

    # platform = multi_platform_rhel,multi_platform_fedora
    # reboot = false
    # strategy = restrict
    # complexity = low
    # disruption = low
    - name: Ensure SELinux Not Disabled in /etc/default/grub
      replace:
        dest: /etc/default/grub
        regexp: selinux=0

The Ansible remediation will get included by our build system to the
SCAP datastream in the `fix` element of respective rule.

The build system generates an Ansible Playbook from the remediation for
all profiles. The generated Playbook is located in
`/build/<product>/playbooks/<profile_id>/<rule_id>.yml`.

For each rule in the given product we also generate an Ansible Playbook
regardless presence of the rule in any profile. The generated Playbook
is located in `/build/<product>/playbooks/all/<rule_id>.yml`. The
`/build/<product>/playbooks/all/` directory represents the virtual
`(all)` profile which consists of all rules in the product. Due to
undefined XCCDF Value selectors in this pseudo-profile, these Playbooks
use defaults of XCCDF Values when applicable.

We also build profile Playbook that contains tasks for all rules in the
profile. The Playbook is generated in
`/build/ansible/<product>-playbook-<profile_id>.yml`.

Jinja macros for Ansible content are located in
`/shared/macros-ansible.jinja`. These currently include the following
high-level macros:

-   `ansible_sshd_set` - set a parameter in the sshd configuration

-   `ansible_etc_profile_set` - ensure a command gets executed or a
    variable gets set in /etc/profile or /etc/profile.d

-   `ansible_tmux_set` - set a command in tmux configuration

-   `ansible_deregexify_banner_etc_issue` - Formats a banner regex for
    use in /etc/issue

-   `ansible_deregexify_banner_dconf_gnome` - Formats a banner regex for
    use in dconf

They also include several low-level macros:

-   `ansible_lineinfile` - ensure a line is in a given file

-   `ansible_stat` - check the status of a path on the file system

-   `ansible_find` - find all files with matched content

-   `ansible_only_lineinfile` - ensure that no lines matching the regex
    are present and add the given line

-   `ansible_set_config_file` - for configuration files; set the given
    configuration value and ensure no conflicting values

-   `ansible_set_config_file_dir` - for configuration files and files in
    configuration directories; set the given configuration value and
    ensure no conflicting values

Low level macros to make login banner regular expressions usable in
Ansible remediations

-   `ansible_deregexify_multiple_banners` - Strips multibanner regex and
    keeps only the first banner

-   `ansible_deregexify_banner_space` - Strips whitespace or newline
    regex

-   `ansible_deregexify_banner_newline` - Strips newline or newline
    escape sequence regex

-   `ansible_deregexify_banner_newline_token` - Strips newline token for
    a newline escape sequence regex

-   `ansible_deregexify_banner_backslash` - Strips backslash regex

When `msg` is absent from any of the above macros, rule title will be
substituted instead.

Whenever possible, please reuse the macros and form high-level
simplifications. This ensures consistent, high quality remediations that
we can edit in one place and reuse in many places.

### Bash

Bash remediations are stored as shell script files in *bash* directory
in rule directory. You can make use of any available command, but beware
of too specific or complex solutions, as it may lead to a narrow range
of supported platforms. There are a number of already written bash
remediations functions available in
*shared/bash_remediation_functions/* directory, it is possible one of
them is exactly what you are looking for.

Following, you can see an example of a bash remediation that sets the
maximum number of days a password may be used:

    # platform = Red Hat Enterprise Linux 7
    . /usr/share/scap-security-guide/remediation_functions
    populate var_accounts_maximum_age_login_defs

    grep -q ^PASS_MAX_DAYS /etc/login.defs && \
        sed -i "s/PASS_MAX_DAYS.*/PASS_MAX_DAYS     $var_accounts_maximum_age_login_defs/g" /etc/login.defs
    if [ $? -ne 0 ]; then
        echo "PASS_MAX_DAYS      $var_accounts_maximum_age_login_defs" >> /etc/login.defs
    fi

When writing new bash remediations content, please follow the following
guidelins:

-   Use four spaces for indentation rather than tabs.

-   You can use macros from `shared/macros-bash.jinja` in the
    remediation content. If the macro is used from a nested block, use
    the `indent` jinja2 filter assuming the 4-space indentation.
    Typically, you want to call the macro with the intended indentation,
    and as `indent` doesn’t indent the first line by default, you just
    pass the number of spaces as the only argument. See the remediation
    for rule `ensure_fedora_gpgkey_installed` for reference.

-   Prefer to use `sed` rather than `awk`.

-   Try to keep expressions simple, avoid double negations. Use
    [compound lists](http://tldp.org/LDP/abs/html/list-cons.html) with
    moderation and only [if you understand
    them](https://mywiki.wooledge.org/BashPitfalls#cmd1_.26.26_cmd2_.7C.7C_cmd3).

-   Test your script in the "strict mode" with `set -e -o pipefail`
    specified at the top of it. Make sure that the script doesn’t end
    prematurely in the strict mode.

-   Beware of constructs such as `[ $x = 1 ] && echo "$x is one"` as
    they violate the previous point. `[ $x != 1 ] || echo "$x is one"`
    is OK.

-   Use the `die` function defined in `remediation_functions` to handle
    exceptions, such as
    `[ -f "$config_file" ] || die "Couldn't find the configuration file '$config_file'"`.

-   Run `shellcheck` over your remediation script. Make sure that you
    fix all warnings that are applicable. If you are not sure, mention
    those warnings in the pull request description.

-   Use POSIX syntax in regular expressions, so prefer
    `grep '^[[:space:]]*something'` over `grep '^\s*something'`.

Jinja macros that generate Bash remediations can be found in
`shared/macros-bash.jinja`.

Available high-level Jinja macros to generate Bash remediations:

-   `bash_sshd_config_set` - Set SSH Daemon configuration option in
    `/etc/ssh/sshd_config`.

-   `bash_auditd_config_set` - Set Audit Daemon option in
    `/etc/audit/auditd.conf`.

-   `bash_coredump_config_set` - Set Coredump configuration in
    `/etc/systemd/coredump.conf`

-   `bash_package_install` - Install a package

-   `bash_package_remove` - Remove a package

-   `bash_disable_prelink` - disables prelinking

-   `bash_dconf_settings` - configure DConf settings for RHEL and Fedora
    systems

-   `bash_dconf_lock` - configure DConf locks for RHEL and Fedora
    systems

-   `bash_service_command` - enable or disable a service (either with
    systemctl or xinet.d)

-   `bash_firefox_js_setting` - configure a setting in a Mozilla Firefox
    JavaScript configuration file.

-   `bash_firefox_cfg_setting` - configure a setting in a Mozilla
    Firefox configuration file.

Available low-level Jinja macros that can be used in Bash remediations:

-   `die` - Function to terminate the remediation

-   `set_config_file` - Add an entry to a text configuration file

Low level macros to make login banner regular expressions usable in Bash
remediations

-   `bash_deregexify_multiple_banners` - Strips multibanner regex and
    keeps only the first banner

-   `bash_deregexify_banner_space` - Strips whitespace or newline regex

-   `bash_deregexify_banner_newline` - Strips newline or newline escape
    sequence regex

-   `bash_deregexify_banner_newline_token` - Strips newline token for a
    newline escape sequence regex

-   `bash_deregexify_banner_backslash` - Strips backslash regex

### Kubernetes

Jinja macros for Kubernetes content are located in
`/shared/macros-kubernetes.jinja`. These currently include the following
high-level macros:

-   `kubernetes_sshd_set` - Set SSH Daemon configuration file in
    `/etc/ssh/sshd_config`.

Available low-level Jinja macros that can be used in Kubernetes
remediations:

-   `kubernetes_machine_config_file` - Set a configuration file to a
    given path

Templating
----------

Writing OVAL checks, Bash, or any other content can be tedious work. For
certain types of rules we provide templates. If there is a template that
can be used for the new rule you only need to specify the template name
and its parameters in `rule.yml` and the content will be generated
during the build.

The templating system currently supports generating OVAL checks and
Ansible, Bash, Anaconda, Puppet, Ignition and Kubernetes remediations.
All templates can be found in
[shared/templates](https://github.com/ComplianceAsCode/content/tree/master/shared/templates) directory. The files
are named `template_<TYPE>_<NAME>`, where `<TYPE>` should be OVAL,
ANSIBLE, BASH, ANACONDA, PUPPET, IGNITION and KUBERNETES and `<NAME>` is
the template name.

### Using Templates

To use a template in `rule.yml` add `template:` key there and fill it
accordingly. The general form is the following:

    template:
        name: template_name
        vars:
            param_name: value # these parameters are individual for each template
            param_name@rhel7: value1
            param_name@rhel8: value2
        backends: # optional
            ansible: "off"
            bash: "on" # on is implicit value

The `vars:` key contains template parameters and their values which will
be substituted into the template. Each template has specific parameters.
To use different values of parameters based on product, append `@`
followed by product ID to the parameter name.

The `backends:` key is optional. By default, all languages supported by
a given template will be generated. with given name exist will be
generated. This key can be used to explicitly opt out from generating a
certain type of content for the rule.

For example, to generate templated content except Bash remediation for
rule "Package GCC is Installed" using `package_installed` template, add
the following to `rule.yml`:

    template:
        name: package_installed
        vars:
            pkgname: gcc
        backends:
            bash: "off"

> **Important**
>
> The build system does not support implicit conversion of bool strings
> when **Python 2** is used, so `bash: True` argument in the example
> above would cause a **build error**. One should always use quoted
> strings as arguments until **Python 2** is completely removed from the
> list of supported interpreters.

### Available Templates

#### accounts_password
-   Checks if PAM enforces password quality requirements. Checks the
    configuration in `/etc/pam.d/system-auth` (for RHEL 6 systems) or
    `/etc/security/pwquality.conf` (on other systems).

-   Parameters:

    -   **variable** - PAM `pam_cracklib` (on RHEL 6) or `pam_pwquality`
        (on other systems) module name, eg. `ucredit`, `ocredit`

    -   **operation** - OVAL operation, eg. `less than or equal`

-   Languages: OVAL

#### auditd_lineinfile
-   Checks configuration options of the Audit Daemon in
    `/etc/audit/auditd.conf`.

-   Parameters:

    -   **parameter** - auditd configuration item

    -   **value** - the value of configuration item specified by
        parameter

    -   **missing_parameter_pass** - effective only in OVAL checks, if
        set to `"false"` and the parameter is not present in the
        configuration file, the OVAL check will return false (default value: `"false"`).

-   Languages: Ansible, Bash, OVAL

#### audit_rules_dac_modification
-   Checks Audit Discretionary Access Control rules

-   Parameters:

    -   **attr** - value of `-S` argument in Audit rule, eg. `chmod`

-   Languages: Ansible, Bash, OVAL, Kubernetes

#### audit_rules_file_deletion_events
-   Ensure auditd Collects file deletion events

-   Parameters:

    -   **name** - value of `-S` argument in Audit rule, eg. `unlink`

-   Languages: Ansible, Bash, OVAL

#### audit_rules_login_events
-   Checks if there are Audit rules that record attempts to alter logon
    and logout events.

-   Parameters:

    -   **path** - value of `-w` in the Audit rule, eg.
        `/var/run/faillock`

-   Languages: Ansible, Bash, OVAL, Kubernetes

#### audit_rules_path_syscall
-   Check if there are Audit rules to record events that modify
    user/group information via a syscall on a specific file.

-   Parameters:

    -   **path** - path of the protected file, eg `/etc/shadow`

    -   **pos** - position of argument, eg. `a2`

    -   **syscall** - name of the system call, eg. `openat`

-   Languages: Ansible, Bash, OVAL

#### audit_rules_privileged_commands
-   Ensure Auditd collects information on the use of specified
    privileged command.

-   Parameters:

    -   **path** - the path of the privileged command - eg.
        `/usr/bin/mount`

-   Languages: Ansible, Bash, OVAL, Kubernetes

#### audit_file_contents
-   Ensure that audit `.rules` file specified by parameter `filepath`
    contains the contents specified in parameter `contents`.

-   Parameters:

    -   **filepath** - path to audit rules file, e.g.:
        `/etc/audit/rules.d/10-base-config.rules`

    -   **contents** - expected contents of the file

-   Languages: Ansible, Bash, OVAL

#### audit_rules_unsuccessful_file_modification
-   Ensure there is an Audit rule to record unsuccessful attempts to
    access files

-   Parameters:

    -   **name** - name of the unsuccessful system call, eg. `creat`

-   Languages: Ansible, Bash, OVAL

#### audit_rules_unsuccessful_file_modification_o_creat
-   Ensure there is an Audit rule to record unsuccessful attempts to
    access files when O_CREAT flag is specified.

-   Parameters:

    -   **syscall** - name of the unsuccessful system call, eg. `openat`

    -   **pos** - position of the O_CREAT argument in the syscall, as
        specified by `-F` audit rule argument, eg. `a2`

-   Languages: OVAL

#### audit_rules_unsuccessful_file_modification_o_trunc_write
-   Ensure there is an Audit rule to record unsuccessful attempts to
    access files when O_TRUNC_WRITE flag is specified.

-   Parameters:

    -   **syscall** - name of the unsuccessful system call, eg. `openat`

    -   **pos** - position of the O_TRUNC_WRITE argument in the
        syscall, as specified by `-F` audit rule argument, eg. `a2`

-   Languages: OVAL

#### audit_rules_unsuccessful_file_modification_rule_order
-   Ensure that Audit rules for unauthorized attempts to use a specific
    system call are ordered correctly.

-   Parameters:

    -   **syscall** - name of the unsuccessful system call, eg. `openat`

    -   **pos** - position of the flag parameter in the syscall, as
        specified by `-F` audit rule argument, eg. `a2`

-   Languages: OVAL

#### audit_rules_usergroup_modification
-   Check if Audit is configured to record events that modify account
    changes.

-   Parameters:

    -   **path** - path that should be part of the audit rule as a value
        of `-w` argument, eg. `/etc/group`.

-   Languages: Ansible, Bash, OVAL

#### argument_value_in_line
-   Checks that `argument=value` pair is present in (optionally) the
    line started with line_prefix (and, optionally, ending with
    line_suffix) in the file(s) defined by filepath.

-   Parameters:

    -   **filepath** - File(s) to be checked. The value would be treated
        as a regular expression pattern.

    -   **arg_name** - Argument name, eg. `audit`

    -   **arg_value** - Argument value, eg. `'1'`

    -   **line_prefix** - The prefix of the line in which
        argument-value pair should be present, optional.

    -   **line_suffix** - The suffix of the line in which
        argument-value pair should be present, optional.

-   Languages: OVAL

#### file_groupowner
-   Check group that owns the given file.

-   Parameters:

    -   **filepath** - File path to be checked. If the file path ends
        with `/` it describes a directory.

    -   **filepath_is_regex** - If set to `"true"` the OVAL will
        consider the value of **filepath** as a regular expression.

    -   **missing_file_pass** - If set to `"true"` the OVAL check will
        pass when file is absent. Default value is `"false"`.

    -   **file_regex** - Regular expression that matches file names in
        a directory specified by **filepath**. Can be set only if
        **filepath** parameter specifies a directory. Note: Applies to
        base name of files, so if a file `/foo/bar/file.txt` is
        processed, only `file.txt` is tested against **file_regex**.

    -   **filegid** - group ID (GID)

-   Languages: Ansible, Bash, OVAL

#### file_owner
-   Check user that owns the given file.

-   Parameters:

    -   **filepath** - File path to be checked. If the file path ends
        with `/` it describes a directory.

    -   **filepath_is_regex** - If set to `"true"` the OVAL will
        consider the value of **filepath** as a regular expression.

    -   **missing_file_pass** - If set to `"true"` the OVAL check will
        pass when file is absent. Default value is `"false"`.

    -   **file_regex** - Regular expression that matches file names in
        a directory specified by **filepath**. Can be set only if
        **filepath** parameter specifies a directory. Note: Applies to
        base name of files, so if a file `/foo/bar/file.txt` is
        processed, only `file.txt` is tested against **file_regex**.

    -   **fileuid** - user ID (UID)

-   Languages: Ansible, Bash, OVAL

#### file_permissions
-   Checks permissions (mode) on a given file.

-   Parameters:

    -   **filepath** - File path to be checked. If the file path ends
        with `/` it describes a directory.

    -   **filepath_is_regex** - If set to `"true"` the OVAL will
        consider the value of **filepath** as a regular expression.

    -   **missing_file_pass** - If set to `"true"` the OVAL check will
        pass when file is absent. Default value is `"false"`.

    -   **file_regex** - Regular expression that matches file names in
        a directory specified by **filepath**. Can be set only if
        **filepath** parameter specifies a directory. Note: Applies to
        base name of files, so if a file `/foo/bar/file.txt` is
        processed, only `file.txt` is tested against **file_regex**.

    -   **filemode** - File permissions in a hexadecimal format, eg.
        `'0640'`.

    -   **allow_stricter_permissions** - If set to `"true"` the OVAL
        will also consider permissions stricter than **filemode** as compliant.
        Default value is `"false"`.

-   Languages: Ansible, Bash, OVAL

#### grub2_bootloader_argument
-   Checks kernel command line arguments in GRUB 2 configuration.

-   Parameters:

    -   **arg_name** - argument name, eg. `audit`

    -   **arg_value** - argument value, eg. `'1'`

-   Languages: Ansible, Bash, OVAL

#### kernel_module_disabled
-   Checks if the given Linux kernel module is disabled.

-   Parameters:

    -   **kernmodule** - name of the Linux kernel module, eg. `cramfs`

-   Languages: Ansible, Bash, OVAL

#### lineinfile
-   Checks that the given text is present in a file.
    This template doesn't work with a concept of keys and values - it is meant
    only for simple statements.

-   Parameters:

    -   **path** - path to the file to check.

    -   **text** - the line that should be present in the file.

    -   **oval_extend_definitions** - optional, list of additional OVAL
        definitions that have to pass along the generated check.

-   Languages: Ansible, Bash, OVAL


#### mount
-   Checks that a given mount point is located on a separate partition.

-   Parameters:

    -   **mountpoint** - path to the mount point, eg. `/var/tmp`

-   Languages: Anaconda, OVAL

#### mount_option
-   Checks if a given partition is mounted with a specific option such
    as "nosuid".

-   Parameters:

    -   **mountpoint** - mount point on the filesystem eg. `/dev/shm`

    -   **mountoption** - mount option, eg. `nosuid`

    -   **filesystem** - filesystem in `/etc/fstab`, eg. `tmpfs`. Used
        only in Bash remediation.

    -   **type** - filesystem type. Used only in Bash remediation.

    -   **mount_has_to_exist** - Specifies if the **mountpoint**
        entry has to exist in `/etc/fstab` before the remediation is
        executed. If set to `yes` and the **mountpoint** entry is not
        present in `/etc/fstab` the Bash remediation terminates. If set
        to `no` the **mountpoint** entry will be created in
        `/etc/fstab`.

-   Languages: Anaconda, Ansible, Bash, OVAL

#### mount_option_remote_filesystems
-   Checks if all remote filesystems (NFS mounts in `/etc/fstab`) are
    mounted with a specific option.

-   Parameters:

    -   **mountpoint** - always set to `remote_filesystems`

    -   **mountoption** - mount option, eg. `nodev`

    -   **filesystem** - filesystem of new mount point (used when adding
        new entry in `/etc/fstab`), eg. `tmpfs`. Used only in Bash
        remediation.

    -   **mount_has_to_exist** - Used only in Bash remediation.
        Specifies if the **mountpoint** entry has to exist in
        `/etc/fstab` before the remediation is executed. If set to `yes`
        and the **mountpoint** entry is not present in `/etc/fstab` the
        Bash remediation terminates. If set to `no` the **mountpoint**
        entry will be created in `/etc/fstab`.

-   Languages: Ansible, Bash, OVAL

#### mount_option_removable_partitions
-   Checks if all removable media mounts are mounted with a specific
    option. Unlike other mount option templates, this template doesn’t
    use the mount point, but the block device. The block device path
    (eg. `/dev/cdrom`) is always set to `var_removable_partition`. This
    is an XCCDF Value, defined in
    [var_removable_partition.var](https://github.com/ComplianceAsCode/content/tree/master/linux_os/guide/system/permissions/partitions/var_removable_partition.var)

-   Parameters:

    -   **mountoption** - mount option, eg. `nodev`

-   Languages: Anaconda, Ansible, Bash, OVAL

#### package_installed
-   Checks if a given package is installed. Optionally, it can also
    check whether a specific version or newer is installed.

-   Parameters:

    -   **pkgname** - name of the RPM or DEB package, eg. `tmux`

    -   **evr** - Optional parameter. It can be used to check if the
        package is of a specific version or newer. Provide epoch,
        version, release in `epoch:version-release` format, eg.
        `0:2.17-55.0.4.el7_0.3`. Used only in OVAL checks. The OVAL
        state uses operation "greater than or equal" to compare the
        collected package version with the version in the OVAL state.

-   Languages: Anaconda, Ansible, Bash, OVAL, Puppet

#### package_removed
-   Checks if the given package is not installed.

-   Parameters:

    -   **pkgname** - name of the RPM or DEB package, eg. `tmux`

-   Languages: Anaconda, Ansible, Bash, OVAL, Puppet

#### sebool
-   Checks values of SELinux booleans.

-   Parameters:

    -   **seboolid** - name of SELinux boolean, eg.
        `cron_userdomain_transition`

    -   **sebool_bool** - the value of the SELinux Boolean. Can be
        either `"true"` or `"false"`. If this parameter is not
        specified, the rule will use XCCDF Value `var_<seboolid>`. These
        XCCDF Values are usually defined in the same directory where the
        `rule.yml` that describes the rule is located. The **seboolid**
        will be replaced by a SELinux boolean, for example:
        `selinuxuser_execheap` and in the profile you can use
        `var_selinuxuser_execheap` to turn on or off the SELinux
        boolean.

-   Languages: Ansible, Bash, OVAL

#### service_disabled
-   Checks if a service is disabled. Uses either systemd or SysV init
    based on the product configuration in `product.yml`.

-   Parameters:

    -   **servicename** - name of the service.

    -   **packagename** - name of the package that provides this
        service. This argument is optional. If **packagename** is not
        specified it means the name of the package is the same as the
        name of service.

    -   **daemonname** - name of the daemon. This argument is optional.
        If **daemonname** is not specified it means the name of the
        daemon is the same as the name of service.

-   Languages: Ansible, Bash, OVAL, Puppet, Ignition, Kubernetes

#### service_enabled
-   Checks if a system service is enabled. Uses either systemd or SysV
    init based on the product configuration in `product.yml`.

-   Parameters:

    -   **servicename** - name of the service.

    -   **packagename** - name of the package that provides this
        service. This argument is optional. If **packagename** is not
        specified it means the name of the package is the same as the
        name of service.

    -   **daemonname** - name of the daemon. This argument is optional.
        If **daemonname** is not specified it means the name of the
        daemon is the same as the name of service.

-   Languages: Ansible, Bash, OVAL, Puppet

#### shell_lineinfile
-   Checks shell variable assignments in files. Remediations will paste
    assignments with single shell quotes unless there is the dollar sign
    in the value string, in which case double quotes are administered.
    The OVAL checks for a match with either of no quotes, single quoted
    string, or double quoted string.

-   Parameters:

    -   **path** - What file to check.

    -   **parameter** - name of the shell variable, eg. `SHELL`.

    -   **value** - value of the SSH configuration option specified by
        **parameter**, eg. `"/bin/bash"`. Don’t pass extra shell
        quoting - that will be handled on the lower level.

    -   **no_quotes** - If set to `"true"`, the assigned value has to
        be without quotes during the check and remediation doesn’t quote
        assignments either.

    -   **missing_parameter_pass** - effective only in OVAL checks, if
        set to `"false"` and the parameter is not present in the
        configuration file, the OVAL check will return false (default value: `"false"`).

-   Languages: Ansible, Bash, OVAL

-   Example: A template invocation specifying that parameter `HISTSIZE`
    should be set to value `500` in `/etc/profile` will produce a check
    that passes if any of the following lines are present in
    `/etc/profile`:

    -   `HISTSIZE=500`

    -   `HISTSIZE="500"`

    -   `HISTSIZE='500'`

        The remediation would insert one of the quoted forms if the line
        was not present.

        If the `no_quotes` would be set in the template, only the first
        form would be checked for, and the unquoted assignment would be
        inserted to the file by the remediation if not present.

#### sshd_lineinfile
-   Checks SSH server configuration items in `/etc/ssh/sshd_config`.

-   Parameters:

    -   **parameter** - name of the SSH configuration option, eg.
        `KerberosAuthentication`

    -   **value** - value of the SSH configuration option specified by
        **parameter**, eg. `"no"`.

    -   **missing_parameter_pass** - effective only in OVAL checks, if
        set to `"false"` and the parameter is not present in the
        configuration file, the OVAL check will return false (default value: `"false"`).

-   Languages: Ansible, Bash, OVAL, Kubernetes

#### sysctl
-   Checks sysctl parameters. The OVAL definition checks both
    configuration and runtime settings and require both of them to be
    set to the desired value to return true.

-   Parameters:

    -   **sysctlvar** - name of the sysctl value, eg.
        `net.ipv4.conf.all.secure_redirects`.

    -   **datatype** - data type of the sysctl value, eg. `int`.

    -   **sysctlval** - value of the sysctl value, eg. `'1'`. If this
        parameter is not specified, XCCDF Value is used instead.

    -   **operation** - operation used for comparison of collected object
        with **sysctlval**. Default value: `equals`.

    -   **sysctlval_regex** - if **operation** is `pattern match`, this
        parameter is used instead of **sysctlval**.

-   Languages: Ansible, Bash, OVAL

#### timer_enabled
-   Checks if a SystemD timer unit is enabled.

-   Parameters:

    -   **timername** - name of the SystemD timer unit, without the
        `timer` suffix, eg. `dnf-automatic`.

    -   **packagename** - name of the RPM package which provides the
        SystemD timer unit. This parameter is optional, if it is not
        provided it is assumed that the name of the RPM package is the
        same as the name of the SystemD timer unit.

-   Languages: Ansible, Bash, OVAL

#### yamlfile_value
-   Check if value(s) of certain type is (are) present in a YAML (or
    JSON) file at a given path.

-   Parameters:

    -   **ocp_data** - if set to `"true"` then the filepath would be
        treated as a part of the dump of OCP configuration with the
        `ocp_data_root` prefix; optional.

    -   **filepath** - full path to the file to check

    -   **yamlpath** - OVAL’s [YAML
        Path](https://github.com/OpenSCAP/yaml-filter/wiki/YAML-Path-Definition)
        expression.

    -   **entity_check**
        ([CheckEnumeration](https://github.com/OVALProject/Language/blob/master/docs/oval-common-schema.md#CheckEnumeration)) -
        entity_check value for state’s value, optional. If omitted,
        entity_check attribute would not be set and will be treated by
        OVAL as *all*.
        Possible options are `all`, `at least one`, `none satisfy` and
        `only one`.

    -   **check_existence**
        ([ExistenceEnumeration](https://github.com/OVALProject/Language/blob/master/docs/oval-common-schema.md#ExistenceEnumeration)) -
        `check_existence` value for the `yamlfilecontent_test`,
        optional. If omitted, check_existence attribute will default to
        *only_one_exists*.
        Possible options are `all_exist`, `any_exist`,
        `at_least_one_exists`, `none_exist`, `only_one_exists`.

    -   **values** - a list of dictionaries with values to check, where:

        -   **key** - the yaml key to check, optional. Used when the
            yamlpath expression yields a map.

        -   **value** - the value to check.

        -   **type**
            ([SimpleDatatypeEnumeration](https://github.com/OVALProject/Language/blob/master/docs/oval-common-schema.md#---simpledatatypeenumeration---)) -
            datatype for state’s field (child of value), optional. If
            omitted, datatype would be treated as OVAL’s default *string*.
            Most common datatypes are `string` and `int`. For complete list
            check reference link.

        -   **operation**
            ([OperationEnumeration](https://github.com/OVALProject/Language/blob/master/docs/oval-common-schema.md#---operationenumeration---)) -
            operation value for state’s field (child of value), optional. If
            omitted, operation attribute would not be set. OVAL’s default
            operation is *equals*.
            Most common operations are `equals`, `not equal`,
            `pattern match`, `greater than or equal` and
            `less than or equal`. For complete list of operations check the
            reference link.

        -   **entity_check**
            ([CheckEnumeration](https://github.com/OVALProject/Language/blob/master/docs/oval-common-schema.md#CheckEnumeration)) -
            entity_check value for state’s field (child of value),
            optional. If omitted, entity_check attribute would not be set
            and will be treated by OVAL as *all*.
            Possible options are `all`, `at least one`, `none satisfy` and
            `only one`.

-   Languages: OVAL

### Creating Templates

The offer of currently available templates can be extended by developing a new
template.

1) Create a new subdirectory within the
[shared/templates](https://github.com/ComplianceAsCode/content/tree/master/shared/templates) directory. The name of the
new subdirectory will become the template name.

2) For each language supported by this template, create a corresponding file
within the template directory. File names should have format of `LANG.template`,
where *LANG* should be the language  identifier in lower case, e.g.
`oval.template`, `bash.template` etc.

    Use the Jinja syntax we use elsewhere in the project; refer to the earlier
    section on Jinja macros for more information.  The parameters should be named
    using uppercase letters, because the keys from `rule.yml` are converted to
    uppercase by the code that substitutes the parameters to the template.

    Notice that OVAL should be written in shorthand format.  This is an example of
    an OVAL template file called `oval.template` within the `package_installed`
    directory:

        <def-group>
        <definition class="compliance" id="package_{{{ PKGNAME }}}_installed"
        version="1">
            <metadata>
            <title>Package {{{ PKGNAME }}} Installed</title>
            <affected family="unix">
                <platform>multi_platform_all</platform>
            </affected>
            <description>The {{{ pkg_system|upper }}} package {{{ PKGNAME }}} should be installed.</description>
            </metadata>
            <criteria>
            <criterion comment="package {{{ PKGNAME }}} is installed"
            test_ref="test_package_{{{ PKGNAME }}}_installed" />
            </criteria>
        </definition>
        {{{ oval_test_package_installed(package=PKGNAME, evr=EVR, test_id="test_package_"+PKGNAME+"_installed") }}}
        </def-group>

    And here is the Ansible template file called `ansible.template` within the
    `package_installed` directory:

        # platform = multi_platform_all
        # reboot = false
        # strategy = enable
        # complexity = low
        # disruption = low
        - name: Ensure {{{ PKGNAME }}} is installed
        package:
            name: "{{{ PKGNAME }}}"
            state: present

3) Create a file called `template.yml` within the template directory. This file
stores template metadata. Currently, it stores list of supported languages. Note
that each language listed in this file must have associated implementation
file with the *.template* extension, see above. 

    An example can look like this:

    supported_languages:
    - ansible
    - bash
    - ignition
    - kubernetes
    - oval
    - puppet


4) If needed, implement a preprocessing function which will process the
parameters before passing them to the Jinja engine.  For example, this function can
provide default values, escape characters, check if parameters are correct, or
perform any other processing of the parameters specific for the template.

    The function should be called _preprocess_ and should be located in the file
    `template.py` within the template directory.

    The function must have 2 parameters:

    - `data` - dictionary which contains the contents of `vars:` dictionary from `rule.yml`
    - `lang` - string, describes language, can be one of: `"anaconda"`, `"ansible"`, `"bash"`, `"oval"`, `"puppet"`, `"ignition"`, `"kubernetes"`

    The function is executed for every supported language, so it can process the data differently for each language.

    The function must always return the (modified) `data` dictionary.

    The following example shows the file `template.py` for the template
    `mount_option`. The code takes the `data` argument which is a dictionary with
    template parameters from `rule.yml` and based on `lang` it modifies the template
    parameters and returns the modified dictionary.

        import re

        def preprocess(data, lang):
            if lang == "oval":
                data["pointid"] = re.sub(r"[-\./]", "_", data["mountpoint"]).lstrip("_")
            else:
                data["mountoption"] = re.sub(" ", ",", data["mountoption"])
            return data

### Filters

You can use Jinja macros and Jinja filters in the template code.
ComplianceAsCode support all built-in Jinja
[filters](https://jinja.palletsprojects.com/en/2.11.x/templates/#builtin-filters).

There are also some custom filters useful for content authoring defined
in the project:

escape_id
-   Replaces all non-word (regex **\\W**) characters with underscore.
    Useful for sanitizing ID strings as it is compatible with OVAL IDs
    `oval:[A-Za-z0-9_\-\.]+:ste:[1-9][0-9]*`.

escape_regex
-   Escapes characters in the string for it to be usable as a part of
    some regular expression, behaves similar to the Python 3’s
    [**re.escape**](https://docs.python.org/3/library/re.html#re.escape).

## Applicability of content

All profiles and rules included in a products' DataStream are applicable
by default. For example, all profiles and rules included in a `rhel8` DS
will apply and evaluate in a RHEL 8 host.

But a content’s applicability can be fine tuned to a specific
environment in the product. The SCAP standard specifies two mechanisms
to define applicability: - [CPE](https://nvd.nist.gov/products/cpe):
Allows a specific hardware or platform to be identified. -
[Applicability Language](https://csrc.nist.gov/projects/security-content-automation-protocol/specifications/cpe/applicability-language):
Allows the construction of logical expressions involving CPEs.

At the moment, only the CPE mechanism is supported.

### Applicability by CPE

The CPEs defined by the project are declared in
`shared/applicability/cpes.yml`.

Syntax is as follows (using examples of existing CPEs):

    cpes:
      - machine:                                  ## The id of the CPE
          name: "cpe:/a:machine"                  ## The CPE Name as defined by the CPE standard
          title: "Bare-metal or Virtual Machine"  ## Human readable title for the CPE
          check_id: installed_env_is_a_machine    ## ID of OVAL implementing the applicability check
      - gdm:
          name: "cpe:/a:gdm"
          title: "Package gdm is installed"
          check_id: installed_env_has_gdm_package

The first entry above defines a CPE whose `id` is `machine`, this CPE
is used for rules not applicable to containers.
A rule or profile with `platform: machine` will be evaluated only if the
targeted scan environment is either bare-metal or virtual machine.

The second entry defines a CPE for GDM.
By setting the `platform` to `gdm`, the rule will have its applicability
restricted to only environments which have `gdm` package installed.

The OVAL checks for the CPE need to be of `inventory` class, and must be
under `shared/checks/oval/`.

#### Setting a product’s default CPE

The product’s default applicability is set in its `product.yml` file,
under the `cpes` key. For example:

    cpes:
      - example:
          name: "cpe:/o:example"
          title: "Example"
          check_id: installed_OS_is_part_of_Unix_family

Multiple CPEs can be set as default platforms for a product.

#### Setting the product’s CPE source directory

The key `cpes_root` in `product.yml` file specifies the directory to
source the CPEs from.
By default, all products source their CPEs from `shared/applicability/`.
Any file with extension `.yml` will be sourced for CPE definitions.

Note: Only CPEs that are referenced by a rule or profile will be included
in the product’s CPE Dictionary.
If no content requires the CPE, it is deemed unnecessary and won’t be
included in the dictionary.

## Tests (ctest)

ComplianceAsCode uses ctest to orchestrate testing upstream. To run the
test suite go to the build folder and execute `ctest`:

    cd build/
    ctest -j 4

Check out the various `ctest` options to perform specific testing, you
can rerun just one test or skip all tests that match a regex. (See -R,
-E and other options in the ctest man page)

Tests are added using the add_test cmake call. Each test should finish
with a 0 exit-code in case everything went well and a non-zero if
something failed. Output (both stdout and stderr) are collected by ctest
and stored in logs or displayed. Make sure you never hard-code a path to
any tool when doing testing (or anything really) in the cmake code.
Always use configuration to find all the paths and then use the
respective variable.

See some of the existing testing code in `cmake/SSGCommon.cmake`.

## Tests (OCP4)

### Unit tests

TBD

### End-to-end tests


The ComplianceAsCode/content repo runs some end-to-end tests for the
ocp4 content. These tests run over the OpenShift infrastructure, spawn
an ephemeral cluster and run tests targetted at a specific profile.

The current workflow is as follows:

-   Install needed prerequisites (e.g. the compliance-operator and other
    resources it might need)

-   Run a scan using the specific profile (for the specific product)

-   Run manual remediations

-   Run automated remediations

-   Wait for remediations to converge

-   Run second scan

The test will pass if: \* There are no errors in the scan runs \* We
have less rule failures after the remediations have been applied \* The
cluster status is not inconsistent

Rules may have extra verifications on them. For instance, one is able to
verify if: \* The rule’s expected result is gotten on a clean run. \*
The rule’s result changes after a remediation has been applied.

If an automated remediation is not possible, one is also able to created
a "manual" remediation that will be run as a bash script. The end-to-end
tests have a **15 minute** timeout for the manual remediation scripts to
be executed.

#### Writing e2e tests for specific rules

In order to test that a rule is yielding expected results in the e2e
tests, one must create a file called `e2e.yml` in a `tests/ocp4/`
directory which will exist in the rule’s directory itself.

The format may look as follows:

    ---
    default_result: [PASS|FAIL|SKIP]
    result_after_remediation: [PASS|FAIL|SKIP]

Where:

-   `default_result` will look at the result when the first scan is run.

-   `result_after_remediation` will look at the result when the second
    scan is run. The second scan takes place after remediations are
    applied.

Note that this format applies if the result of a rule will be the same accross
roles in the cluster.

It is also possible to differentiate results between roles. For such a thing,
the format would look as follows:

Let’s look at an example:

    ---
    default_result:
      worker: [PASS|FAIL|SKIP]
      master: [PASS|FAIL|SKIP]
    result_after_remediation:
      worker: [PASS|FAIL|SKIP]
      master: [PASS|FAIL|SKIP]

Where "worker" and "master" are node roles.

For the `controller_use_service_account` rule, which exists in the
`applications/openshift/controller/` directory, the directory tree will
contain the rule definition and the test file:

    .
    ├── rule.yml
    └── tests
        └── ocp4
            └── e2e.yml

In this case, we just want to verify that the default value returns a
passing result. So `e2e.yml` has the following content:

    ---
    default_result: PASS

Let’s look at another example:

For the `api_server_encryption_provider_config` we want to apply a
remediation which cannot be applied via the `compliance-operator`. So
we’ll need a manual remediation for this.

The directory structure looks as follows:

    .
    ├── rule.yml
    └── tests
        └── ocp4
            ├── e2e-remediation.sh
            └── e2e.yml

Where our test contains information for both the first default result
and the expected result after the remediation has been applied:

    ---
    default_result: FAIL
    result_after_remediation: PASS

The remediation expects the name of the remediation script to be
`e2e-remediation.sh`. The script should:

-   Apply the remediation.

-   Verify that the status has converged.

In the aforementioned case, the remediation script is as follows:

    #!/bin/bash
    oc patch apiservers cluster -p '{"spec":{"encryption":{"type":"aescbc"}}}' --type=merge
    while true; do
        status=$(oc get openshiftapiserver -o=jsonpath='{range .items[0].status.conditions[?(@.type=="Encrypted")]}{.reason}')
        echo "Current Encryption Status:"
        oc get openshiftapiserver -o=jsonpath='{range .items[0].status.conditions[?(@.type=="Encrypted")]}{.reason}{"\n"}{.message}{"\n"}'
        if [ "$status" == "EncryptionCompleted" ]; then
            exit 0
        fi
        sleep 5
    done

Here, we apply the remediation (through the `patch` command) and probe
the cluster for status. Once the cluster converges, we exit the script
with `0`, which is a successful status.

The e2e test run will time out at **15 minuntes** if a script doesn’t
converge.

Note that the scripts will be run in parallel, but the test run will
wait for all of them to be done.

#### Running the e2e tests on a local cluster

Note that it’s possible to run the e2e tests on a cluster of your
choice.

To do so, ensure that you have a `KUBECONFIG` with appropriate
credentials that points to the cluster where you’ll run the tests.

From the root of the `ComplianceAsCode/content` repository, run:

    $ make -f tests/ocp4e2e/Makefile e2e PROFILE=<profile> PRODUCT=<product>

Where profile is the name of the profile you want to test, and product
is a product relevant to `OCP4`, such as `ocp4` or `rhcos4`.

For instance, to run the tests for the `cis` benchmark for `ocp4` do:

    $ make -f tests/ocp4e2e/Makefile e2e PROFILE=cis PRODUCT=ocp4

For more information on the available options, do:

    $ make -f tests/ocp4e2e/Makefile help

It is important to note that the tests will do changes to your cluster
and there currently isn’t an option to clean them up. So take that into
account before running these tests.

## Contribution to infrastructure code

The ComplianceAsCode build and templating system is mostly written in
Python.

### Python

-   The common pattern is to dynamically add `ssg` to the
    import path. There are many useful modules with several functions
    and predefined constants. See scripts at `./build-scripts`
    as an example of this practice.

-   Follow the [PEP8
    standard](https://www.python.org/dev/peps/pep-0008/).

-   Try to keep most of your lines length under 80 characters. Although
    the 99 character limit is within [PEP8
    requirements](https://www.python.org/dev/peps/pep-0008/#maximum-line-length),
    there is no reason for most lines to be that long.
