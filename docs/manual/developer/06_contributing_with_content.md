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

Following lines are rather reference material. If you are completely new and
would like to try more guided approach, we recommend you to go through materials
prepared for our Content creation workshop. They can be found
[here](https://gitlab.com/2020-summit-labs/rhel-custom-security-content/-/tree/master/fedora-setup).
They guide you step by step through the process of creating new rules, profiles,
checks and remediations.

### Rules

Rules are input described in YAML which mirrors the XCCDF format (an XML
container). Rules are translated to become members of a `Group` in an
XML file. All existing rules for Linux products can be found in the
`linux_os/guide` directory. For non-Linux products (e.g., `firefox`), this
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
    which can help protect programs which use it.

-   `description`:
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
    using LVM.

-   `severity`: Is used for metrics and tracking. It can
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
    <td><p>Rule is informational only. Failing the rule doesn't imply failure to conform to the security guidance of the benchmark.</p></td>
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
    guidelines:

    <table>
    <caption>Table Vulnerability Severity Category Code Definitions</caption>
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
    `refine-rule` selector.

-   `platform` or `platforms`: Defines applicability of a
    rule. It is specified either as a single platform or as a list of platforms.
    For example, if a rule is not
    applicable to containers, the list should contain the item `machine`, which
    means it will be evaluated only if the targeted scan environment is either
    bare-metal or virtual
    machine. Also, it can restrict applicability on higher software
    layers. By setting to `package[audit]`, the rule will have its
    applicability restricted to only environments which have
    `audit` package installed.

    The available options can be found
    in the file &lt;product&gt;/cpe/&lt;product&gt;-cpe-dictionary.xml
    (e.g.: rhel8/cpe/rhel8-cpe-dictionary.xml). In order to support a
    new value, an OVAL check (of `inventory` class) must be created
    under `shared/checks/oval/` and referenced in the dictionary file.

    It is possible to specify multiple platforms in the list. In that case, they are implicitly connected with "OR" operator.

    > ⚠ **Deprecated!** List of platforms feature is being phased out, use boolean expressions.

    Platforms from groups are inherited by rules for the whole group hierarchy. They are implicitly joined with rule's platforms using "AND" operator.

    The `platform` can also be a [Boolean expression](https://booleanpy.readthedocs.io/en/latest/concepts.html),
    describing applicability of the rule as a combination of multiple platforms.

    The build system recognizes `!` or `not` as "NOT" operator, `&` or `and` as "AND" operator, and `|` or `or` as "OR" operator.
    And it also allows to group and alter operator precedence with brackets: `(` and `)`.

    For example, the expression `grub2 & !(shadow-utils | ssh)` will denote that rule is applicable for systems with *GRUB2 bootloader*,
    but only if there is no *shadow-utils* or *ssh* package installed.

    Some platforms can also define applicability based on the version of the entity they check.
    Please note that this feature is not yet consistently implemented.
    Read the following before using it.
    If the version specification is used, it is correctly rendered into appropriate OVAL check which is later used when deciding on applicability of a rule.
    However, conditionals used to limit applicability of Bash and Ansible remediations are currently not generated correctly in this case; the version specification is not taken into account.
    Therefore, the build will be interrupted in case you try to use a platform with version specification which influences Bash or Ansible remediation.

    Version specifiers notation loosely follows [PEP440](https://peps.python.org/pep-0440/#version-specifiers),
    most notably not supporting *wildcard*, *epoch* and *non-numeric* suffixes.

    For example, a rule with platform `package[ntp]>=1.9.0,<2.0` would be applicable for systems with *ntp* package installed,
    but only if its *version* is greater or equal 1.9.0 *and* less than 2.0.

    See also: [Applicability of content](#applicability-of-content).

-   `ocil`: Defines asserting
    statements to check whether or not the rule is valid.

-   `ocil_clause`: This
    attribute contains the
    statement which describes how to determine whether the statement is
    true or false. Check out `rule.yml` in
    `linux_os/guide/system/software/disk_partitioning/encrypt_partitions/`:
    this contains a `partitions do not have a type of crypto_LUKS` value
    for `ocil_clause`. This clause is prefixed with the phrase `Is it
    the case that <ocil_clause> ?`.
    If you are using the SRG Export the clause will be used in the sentence `If <ocil_clause>, then this is a finding.`

- `check`: Describes how to manually check the rule.
   This should be based on the OVAL.

- `fixtext`: This describes how to fix the rule if the system is not compliant.
    For most Linux systems this should be based on the bash fix.

A rule may contain those reference-type attributes:

-   `identifiers`: This is related to products that the rule applies to.
    This attribute is a dictionary. Currently, only the Common Configuration
    Enumeration or CCE identifier are supported. Other identifiers can be
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
    catalog, ruleid, etc.) will depend on how many can be added to a
    single rule. In addition, certain references in a rule such as
    `stigid` or `cis` only apply to a certain product and product version; they
    cannot be used for multiple products and versions.

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
    <td><p>cis@&lt;product&gt;&lt;product_version&gt;</p></td>
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
    in `*.jinja` files in `shared/macros` directory.

-   Legacy XSLT macros, which are defined in `shared/transforms/*.xslt`.

For example, the `ocil` attribute of `service_ntpd_enabled` uses the
`ocil_service_enabled` jinja macro. Due to the need of supporting
Ansible output, which also uses jinja, we had to modify control
sequences, so macro operations require one more curly brace. For
example, invocation of the partition macro looks like
`{{{ complete_ocil_entry_separate_partition(part="/tmp") }}}` - there
are three opening and closing curly braces instead of the two that are
documented in the Jinja guide.

The macros that are likely to be used in descriptions begin by
`describe_`, whereas macros likely to be used in OCIL entries begin with
`ocil_`. Sometimes, a rule requires `ocil` and `ocil_clause` to be
specified, and they depend on each other. Macros that begin with
`complete_ocil_entry_` were designed for exactly this purpose, as they
make sure that OCIL and OCIL clauses are defined and consistent. Macros
that begin with underscores are not meant to be used in descriptions.

You can also check documentation for all macros in the `Jinja Macros Reference`
section accessible from the table of contents.

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

#### Rule Deprecation
As the project and products evolve, it is natural for some rules to become obsolete, split, or even replaced by others that take a different approach.
When situations like this happen, it's important to make it clear that a rule is obsolete so users can evaluate and use the alternative as quickly as possible.

This is done by including a deprecation warning message in the warning section of the rule and setting the `highlight` label for the PR.
The purpose of the 'highlight' label is to ensure that this PR is highlighted in the release notes and is therefore more visible and transparent to the public.

Regarding the warning message, to make it easier for developers and to maintain the standard, the `warning_rule_deprecated_by(rule, release='')` macro was created.

As a reference, here is an example where this macro is used:
[account_passwords_pam_faillock_dir](https://github.com/ComplianceAsCode/content/blob/9e0c6ac6eec596b0662d5672e4d3081523afdc9d/linux_os/guide/system/accounts/accounts-pam/locking_out_password_attempts/account_passwords_pam_faillock_dir/rule.yml#L40-L41)

And this is the respective PR where the `highlight` label is set:
[https://github.com/ComplianceAsCode/content/pull/9462](https://github.com/ComplianceAsCode/content/pull/9462)

##### Agreements
* We avoid hard problems by not removing anything from data stream whenever we want to rename, split or deprecate a rule.
* Obsolete rules should have "deprecated_by" warnings for the transitional period.
* We keep the "obsolete" rule in the data stream for some time, usually while the applicable products are still active.
    * If an obsolete rule is removed in a tailoring file, the tailoring file likely have to be updated to also remove the new rule.
    * The administrators should assess each situation in their tailoring files.
* It is imperative that we document those changes in release notes.
* Changes like in the PR [Rename account_passwords_pam_faillock_audit #9462](https://github.com/ComplianceAsCode/content/pull/9462) are worth doing because it improves consistency in the project.

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

-   `sce` - for Script Check Engine content, with any file extension

- `blueprint` - for OSBuild blueprint content, ending in `.toml`

In each of these subdirectories, a file named `shared.ext` will apply to
all products and be included in all builds, but `{{{ product }}}.ext`
will only get included in the build for `{{{ product }}}` (e.g.,
`rhel7.xml` above will only be included in the build of the `rhel7`
guide content and not in the `ol7` content). Additionally, we support
the use of unversioned products here (e.g., `rhel` applies to `rhel7`,
`rhel8`, and `rhel9`). Note that `.ext` must be substituted for the
correct extension for content of that type (e.g., `.sh` for `bash`
content). Further, all of these directories are optional and will only
be searched for content if present. Lastly, the product naming of
content will not override the contents of `platform` or `prodtype`
fields in the content itself (e.g., if `rhel7` is not present in the
`rhel7.xml` OVAL check platform specifier, it will be included in the
build artifacts but later removed because it doesn't match the platform).
This means that any shared (or templated) checks won't be searched if
a product-specific file is present but has the wrong applicability;
this includes shared checks being preferred above templated checks.

Currently the build system supports both rule files (discussed above)
and rule directories. For example content in this format, please see
rules in `linux_os/guide`.

To interact with build directories, the `ssg.rules` and
`ssg.rule_dir_stats` modules have been created, as well as three
utilities:

-   `utils/rule_dir_json.py` - to generate a JSON tree describing the
    current content of all guides

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
    example, if the resource's full path is /api/v1/foo, save the yaml
    to /tmp/api/v1/foo. Running `test` will then check the rule against
    the local file by launching an openscap-1.3.3 container using
    podman.

### Checks

Checks are used to evaluate a Rule. There are two types of check content
supported by ComplianceAsCode: OVAL and SCE. Note that OVAL is standardized
by NIST and has better cross-scanner support than SCE does. However, because
SCE can use any language on the target system (Bash, Python, ...) it is much
more flexible and general-purpose than OVAL. This project generally encourages
OVAL unless it lacks support for certain features.

#### OVAL Check Content

They are written using a custom OVAL syntax and are transformed by the system
during the building process into OVAL compliant checks.

The OVAL checks are stored as XML files and the build system can source
them from:

- the `oval` directory of a rule
- the shared pool of checks `shared/checks/oval`
- a template

In order to create a new check you must create a file in the
appropriate directory. The *id* attribute of the check needs to match the *id*
of its rule.
The content of the file should follow the OVAL specification with these
exceptions:

-   The root tag must be `<def-group>`

-   If the OVAL check has to be a certain OVAL version, you can add
    `oval_version="oval_version_number"` as an attribute to the root
    tag. Otherwise if `oval_version` does not exist in `<def-group>`, it
    is assumed that the OVAL file applies to *any* OVAL version.

-   Don't use the tags `<definitions>` `<tests>` `<objects>` `<states>`,
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

Before you start creating an OVAL check, please consult our [list of JINJA
macros](../../jinja_macros/10-oval.rst)
specific for OVAL. It might save time for you as an author as well as for
reviewers.

##### Limitations and pitfalls

This section aims to list known OVAL limitations and situations that OVAL can't
handle well or at all.

###### Checking that all objects exist based on a variable

A test with *check_existence="all_exist"* attribute will not ensure that all
objects defined based on a variable exist.

This happens because in the test context *all_exist* defaults to
*at_least_one_exists*.
Reference: OVAL [ExistenceEnumeration](https://github.com/OVALProject/Language/blob/master/docs/oval-common-schema.md#---existenceenumeration---)

This means that an object defined based on a variable with multiple values will
result in *pass* if just one of the expected objects exist.
Example, lets say there is a variable containing multiple paths, and you'd like
to check that all of them are present in the file system. The following snippet
would work if *all_exist* didn't default to *at_least_one_exists*.

```xml
  <unix:file_test id="" check="all" check_existence="all_exist" comment="This test fails to ensure that all paths from variable exist" version="1">
    <unix:object object_ref="collect_objects_based_on_variable" />
  </unix:file_test>

  <unix:file_object id="collect_objects_based_on_variable" version="1">
    <unix:path datatype="string" var_ref="variable_containing_a_list_of_paths" var_check="at least one"/>
  </unix:file_object>
```

A workaround is to add a second test to count the number of objects
collected and compare the sum against the number of values in the variable.
This works well, except when none of the files exist, which leads to a
result of *unknown*. Counting the number of collected items of an
object definition that doesn't exist is *unknown* (not 0, for example).

###### Platform applicability

Whenever possible, please reuse the macros and form high-level
simplifications.

### SCE Check Content

[SCE](http://www.open-scap.org/features/other-standards/sce/) is a mechanism
for running arbitrary scripts while delivering them via the same data stream
as OVAL content. These checks (being written in a general-purpose programming
language) can be more flexible than OVAL checks but at the downside of not
being compliant with the relevant NIST standards (and thus losing
interoperability with other scanners). This project prefers Bash SCE content.

Within a rule directory, SCE content is stored under the `sce/` subfolder;
it doesn't have a single extension (taking the preferred extension of the
language the check is written in, `.sh` for Bash content).

To build SCE content, specify the `-DSSG_SCE_ENABLED=ON` option to CMake;
note that we default to not building SCE content.

We support the same comment-based mechanism for controlling script parameters
as the test suite and rest of the content system. The following parameters
are unique to SCE:

 - `check-import`: can be `stdout` or `stderr` and corresponds to the XCCDF's
   `<check-import />` element's `import-name` attribute.
 - `check-export`: a comma-separated list of `variable_name=xccdf_variable`
    pairs to export via XCCDF `<check-export />` elements.
    oscap will generate 3 env_variables before calling the SCE script:
    ```bash
    XCCDF_VALUE_<variable_name>=<value>
    XCCDF_TYPE_<variable_name>=<type>
    XCCDF_OPERATOR_<variable_name>=<operator>
    ```
    The `<value>`, `<type>` and `<operator>` come from the corresponding xccdf variable.
 - `complex-check`: an XCCDF operator (`AND` or `OR`) to be passed as the
   `operator` attribute on the XCCDF element's `<complex-check />` element.
   Note that this gets provisioned into the `<Rule />` element to handle
   whether both the OVAL and SCE checks must pass (AND) or whether only one
   is necessary (OR). If a rule only has one or the other check language,
   it is not necessary. Additionally, OCIL checks, if any is present in the
   `rule.yml`, are added as a top-level OR-operator `<complex-check />` with
   the results of this `<complex-check />`.

For an example of SCE content, consider the check:

```bash
$ cat ./linux_os/guide/system/accounts/accounts-session/accounts_users_own_home_directories/sce/ubuntu2004.sh
#!/bin/bash
#
# Contributed by Canonical.
#
# Disable job control and run the last command of a pipeline in the current shell environment
# Require Bash 4.2 and later
#
# platform = multi_platform_ubuntu
# check-import = stdout

set +m
shopt -s lastpipe

result=$XCCDF_RESULT_PASS

cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/usr/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }'| while read user dir; do
	if [ ! -d "$dir" ]; then
		echo "The home directory ($dir) of user $user does not exist."
		result=$XCCDF_RESULT_FAIL
		break
	else
		owner=$(stat -L -c "%U" "$dir")
		if [ "$owner" != "$user" ]; then
			echo "The home directory ($dir) of user $user is owned by $owner."
			result=$XCCDF_RESULT_FAIL
			break
		fi
	fi
done
exit $result
```

Since this rule lacks an OVAL, this rule does not need a `complex-check`
attribute. Additionally, this rule doesn't use any XCCDF variables and
thus doesn't need a `check-export` element.

Remediations
------------

Remediations, also called fixes, are used to change the state of the
machine, so that previously non-passing rules can pass. There can be
multiple versions of the same remediation meant to be executed by
different applications, more specifically Ansible, Bash, Anaconda,
Puppet, Ignition and Kubernetes. By default all remediation languages
are built and included in the DataStream.

But each product can specify its own set of remediation to include in
the DataStream via a CMake Variable in the product's `CMakeLists.txt`.
See example below, from OCP4 product, `ocp4/CMakeLists.txt`:

    set(PRODUCT_REMEDIATION_LANGUAGES "ignition;kubernetes")

They also have to be idempotent, meaning that they must be able to be
executed multiple times without causing the fixes to accumulate. The
Ansible's language works in such a way that this behavior is built-in,
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
openscap, so they are written using [Ansible's own
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
`/shared/macros/ansible.jinja`. You can see their reference
[here](../../jinja_macros/10-ansible.rst).

Whenever possible, please reuse the macros and form high-level
simplifications. This ensures consistent, high quality remediations that
we can edit in one place and reuse in many places.

### Bash

Bash remediations are stored as shell script files in the *bash* directory
in a rule's directory. You can make use of any available command, but beware
of too specific or complex solutions, as it may lead to a narrow range
of supported platforms.

Following, you can see an example of a bash remediation that sets the
maximum number of days a password may be used:

    # platform = Red Hat Enterprise Linux 7
    {{{ bash_instantiate_variables("var_accounts_maximum_age_login_defs) }}}

    grep -q ^PASS_MAX_DAYS /etc/login.defs && \
        sed -i "s/PASS_MAX_DAYS.*/PASS_MAX_DAYS     $var_accounts_maximum_age_login_defs/g" /etc/login.defs
    if [ $? -ne 0 ]; then
        echo "PASS_MAX_DAYS      $var_accounts_maximum_age_login_defs" >> /etc/login.defs
    fi

When writing new bash remediations content, please follow the following
guidelines:

-   Use four spaces for indentation rather than tabs.

-   You can use macros from `shared/macros/bash.jinja` in the
    remediation content. If the macro is used from a nested block, use
    the `indent` jinja2 filter assuming the 4-space indentation.
    Typically, you want to call the macro with the intended indentation,
    and as `indent` doesn't indent the first line by default, you just
    pass the number of spaces as the only argument. See the remediation
    for rule `ensure_fedora_gpgkey_installed` for reference.

-   Prefer to use `sed` rather than `awk`.

-   Try to keep expressions simple, avoid double negations. Use
    [compound lists](http://tldp.org/LDP/abs/html/list-cons.html) with
    moderation and only [if you understand
    them](https://mywiki.wooledge.org/BashPitfalls#cmd1_.26.26_cmd2_.7C.7C_cmd3).

-   Test your script in the "strict mode" with `set -e -o pipefail`
    specified at the top of it. Make sure that the script doesn't end
    prematurely in the strict mode.

-   Beware of constructs such as `[ $x = 1 ] && echo "$x is one"` as
    they violate the previous point. `[ $x != 1 ] || echo "$x is one"`
    is OK.

-   Use the `die` macro defined in `shared/macros/bash.jinja` to handle
    exceptions and terminate the remediation, such as
    `{{{ die("An error was encountered during the remediation of rule.") }}}`.

-   Run `shellcheck` over your remediation script. Make sure that you
    fix all warnings that are applicable. If you are not sure, mention
    those warnings in the pull request description.

-   Use POSIX syntax in regular expressions, so prefer
    `grep '^[[:space:]]*something'` over `grep '^\s*something'`.

Jinja macros that generate Bash remediations can be found in
`shared/macros/bash.jinja`. You can see their reference
[here](../../jinja_macros/10-bash.rst).

### Kubernetes

Jinja macros for Kubernetes content are located in
`/shared/macros/kubernetes.jinja`. You can see their reference
[here](../../jinja_macros/10-kubernetes.rst)

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

you can see reference of all available templates [here](../../templates/template_reference.md#available-templates).

## Applicability of content

All profiles and rules included in a products' DataStream are applicable
by default. For example, all profiles and rules included in a `rhel8` DS
will apply and evaluate in a RHEL 8 host.

But a content's applicability can be fine-tuned to a specific
environment in the product. The SCAP standard specifies two mechanisms
to define applicability: *CPE* and *Applicability Language*.

### Applicability by [CPE](https://nvd.nist.gov/products/cpe)

Allows a specific hardware or platform to be identified.

The CPEs defined by the project are declared in
`shared/applicability/*.yml`, one CPE per file.

The id of the CPE is inferred from the file name.

Syntax is as follows (using examples of existing CPEs):

       machine.yml:                               ## The id of the CPE is 'machine'
          name: "cpe:/a:machine"                  ## The CPE Name as defined by the CPE standard
          title: "Bare-metal or Virtual Machine"  ## Human readable title for the CPE
          check_id: installed_env_is_a_machine    ## ID of OVAL implementing the applicability check

       package.yml:
          name: "cpe:/a:{arg}"
          title: "Package {pkgname} is installed"
          check_id: cond_package_{arg}
          bash_conditional: {{{ bash_pkg_conditional("{pkgname}") }}}         ## The conditional expression for Bash remediations
          ansible_conditional: {{{ ansible_pkg_conditional("{pkgname}") }}}   ## The conditional expression for Ansible remediations
          template:                                                           ## Instead of static OVAL checks a CPE can use templates
             name: cond_package                                               ## Name of the template with OVAL applicability check
          args:                                                               ## CPEs can be parametrized: 'package[*]'.
             ntp:                                                             ## This is the map of substitution values for 'package[ntp]'
                pkgname: ntp                                                  ## "Package {pkgname} is installed" -> "Package ntp is installed"
                title: NTP daemon and utilities

The first file above defines a CPE whose `id` is `machine`, this CPE
is used for rules not applicable to containers.
A rule or profile with `platform: machine` will be evaluated only if the
targeted scan environment is either bare-metal or virtual machine.

The second file defines a parametrized CPE. This allows us to define multiple
similar CPEs that differ in their argument. In our example, we define
the `package` CPE. Within the `args` key we configure a set of its possible
arguments and their values. In our example, there is a single possible value: `ntp`.

By setting the `platform` to `package[ntp]`, the rule will have its applicability
restricted to only environments which have `ntp` package installed.

The OVAL checks for the CPE need to be of `inventory` class, and must be
under `shared/checks/oval/` or have a template under `shared/templates/`.

#### Setting a product's default CPE

The product's default applicability is set in its `product.yml` file,
under the `cpes` key. For example:

    cpes:
      - example:
          name: "cpe:/o:example"
          title: "Example"
          check_id: installed_OS_is_part_of_Unix_family

Multiple CPEs can be set as default platforms for a product.

#### Setting the product's CPE source directory

The key `cpes_root` in `product.yml` file specifies the directory to
source the CPEs from.
By default, all products source their CPEs from `shared/applicability/`.
Any file with extension `.yml` will be sourced for CPE definitions.

Note: Only CPEs that are referenced by a rule or profile will be included
in the product's CPE Dictionary.
If no content requires the CPE, it is deemed unnecessary and won't be
included in the dictionary.

### Applicability by CPE AL ([Applicability Language](https://csrc.nist.gov/projects/security-content-automation-protocol/specifications/cpe/applicability-language))

Allows the construction of logical expressions involving CPEs.

CPEs can be combined to form an applicability statement.
The `platform` property of a rule (or a group) can contain a [Boolean expression](https://booleanpy.readthedocs.io/en/latest/concepts.html),
that describes the relationship of a set of individual CPEs (symbols), which would later be converted
by the build system into the CPE AL definition in the XCCDF document.

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

Running unit tests is very useful way to verify the content being
written without requiring a full-blown OpenShift cluster.

The unit testing approach for content requires a container
where the scanning will be executed. This container will
be a small replication of the environment where the content
is intended to run.

To build the container, from the project's root
directory, execute the following command:

    podman build --build-arg CLIENT_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)" -t ssg_test_suite -f test_suite-fedora Dockerfiles

Unit tests reside in each rule's `tests/` directory. Tests are
simply bash scripts that set up the required environment
and set expectations on what the scan is supposed to output.

The naming convention is as follows:

    <test name>.<expected result>.sh

e.g. when testing if encryption is disabled in a specific cloud
provider, and that this should fail a compliance scan, you'd have
a file named as follows:

    encryption_disabled.fail.sh

Note that this file has to be executable. So don't forget to
change the mode appropriately.

Test files shall always begin with the following lines:

    #!/bin/bash
    # remediation = none

Bash is used to evaluate the scripts. And we don't expect remediations
executed by OpenSCAP itself (this is done elsewhere), so we set
`remediation = none`.

OpenShift content (as well as other Kubernetes content) is usually meant
to run through the Compliance Operator. The aforementioned component will
read the API paths specified as `warnings` and persist them on a temporary
volume. The Compliance Operator is also the one that handles remediating
rules, this is why we turned remediations off in our scripts as mentioned
earlier.

For unit tests, we'll do something similar when setting up the
testing container in our test scripts: We'll create a directory for
the API resource object and persist it there.

Note that the content uses the path `/kubernetes-api-resources` by
default as a base for any API path for Kubernetes. So, be mindful of
always using that.

An example looks as follows:

    kube_apipath="/kubernetes-api-resources"
    machinev1beta1="/apis/machine.openshift.io/v1beta1"
    machineset_apipath="$machinev1beta1/machinesets?limit=500"

    # Create kubernetes resource directory path
    mkdir -p "$kube_apipath/$machinev1beta1"

    # Persist kubernetes resource
    cat <<EOF > "$kube_apipath/$machineset_apipath"
    {
        "apiVersion": "v1",
        ...
    EOF

When the scanner tests the content for this rule, it'll read the Kubernetes
resource (both YAML or JSON are fine for this) and evaluate it accordingly.

Note that some rules require a specific CPE to be set. e.g. there
are some rules that are meant to run on a specific cloud platform.

You'll see them from the `platforms` key of the rule:

    platforms:
    - ocp4-on-azure

For rules like these, you'll also need to persist the appropriate CPE information (normally another Kubernetes object).

The information needed varies on each CPE. These are defined
in [`/shared/checks/oval`](https://github.com/ComplianceAsCode/content/tree/master/shared/checks/oval).

For the `ocp4-on-azure` example, the CPE requires that the
`infrastructures/cluster` resource specifies the platform
as `Azure`. That would look as follows:

    kube_apipath="/kubernetes-api-resources"

    # Create infra file for CPE to pass
    mkdir -p "$kube_apipath/apis/config.openshift.io/v1/infrastructures/"
    cat <<EOF > "$kube_apipath/apis/config.openshift.io/v1/infrastructures/cluster"
    {
        "apiVersion": "config.openshift.io/v1",
        "kind": "Infrastructure",
        "metadata": {
            "name": "cluster"
        },
        "spec": {
            "platformSpec": {
                "type": "Azure"
            }
        },
        "status": {
            "platform": "Azure",
            "platformStatus": {
                "azure": {
                    "cloudName": "AzurePublicCloud"
                },
                "type": "Azure"
            }
        }
    }
    EOF

For rules that use jq filters, they are using a unique file path
instead of the one you see above, therefore we also need to install
the jq package, run the jq test, and save the filtered jq result
into that unique file path.

The format for the file path for a jq filter rule is:

`"$kube_apipath$rule_apipath#$(echo -n "$rule_apipath$jq_filter" | sha256sum | awk '{print $1}')"`

Noted it is important to know that the `$rule_apipath` does not
have `/` at the end, or it will cause a different hash with `/`
at the end, and jq result will be saved into a location that is
different from where the rule is checking, hence will fail the test.


We have a test file for rule 'routes_rate_limit' as an example that uses jq filter:


    #!/bin/bash
    # remediation = none

    yum install -y jq

    kube_apipath="/kubernetes-api-resources"
    mkdir -p "$kube_apipath/apis/route.openshift.io/v1"
    routes_apipath="/apis/route.openshift.io/v1/routes?limit=500"

    cat <<EOF > "$kube_apipath$routes_apipath"
    {
      ...
    }
    EOF

    jq_filter='[.items[] | select(.metadata.namespace | startswith("kube-") or startswith("openshift-") | not) | select(.metadata.annotations["haproxy.router.openshift.io/rate-limit-connections"] == "true" | not) | .metadata.name]'

    filteredpath="$kube_apipath$routes_apipath#$(echo -n "$routes_apipath$jq_filter" | sha256sum | awk '{print $1}')"

    jq "$jq_filter" "$kube_apipath$routes_apipath" > "$filteredpath"



Before running the unit tests, the content needs to be built to
ensure that the latest changes are taken into account:

    ./build_product ocp4

Remember this needs to be done every time before running the unit tests.

Now, with all of this set, we'll run the unit test!

    tests/test_rule_in_container.sh \
        --dontclean --logdir logs_bash \
        --remediate-using bash \
        --name ssg_test_suite \
        --datastream build/ssg-ocp4-ds.xml \
        <rule name>

This command will run the unit tests on dedicated containers.
The logs will be located in the `logs_bash` directory.

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

The test will pass if:
- There are no errors in the scan runs
- We have less rule failures after the remediations have been applied
- The cluster status is not inconsistent

Rules may have extra verifications on them. For instance, one is able to
verify if:
- The rule's expected result is gotten on a clean run.
- The rule's result changes after a remediation has been applied.

If an automated remediation is not possible, one is also able to created
a "manual" remediation that will be run as a bash script. The end-to-end
tests have a **15 minute** timeout for the manual remediation scripts to
be executed.

#### Writing e2e tests for specific rules

In order to test that a rule is yielding expected results in the e2e
tests, one must create a file called `e2e.yml` in a `tests/ocp4/`
directory which will exist in the rule's directory itself.

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

Let's look at an example:

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

Let's look at another example:

For the `api_server_encryption_provider_config` we want to apply a
remediation which cannot be applied via the `compliance-operator`. So
we'll need a manual remediation for this.

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

The e2e test run will time out at **15 minuntes** if a script doesn't
converge.

Note that the scripts will be run in parallel, but the test run will
wait for all of them to be done.

#### Running the e2e tests on a local cluster

The end-to-end tests for OpenShift are maintained in separate
[repository](https://github.com/ComplianceAsCode/ocp4e2e):

    $ git clone https://github.com/ComplianceAsCode/ocp4e2e; cd ocp4e2e

Note that it's possible to run the e2e tests on a cluster of your choice.

To do so, ensure that you have a `KUBECONFIG` with appropriate
credentials that points to the cluster where you'll run the tests.

Run:

    $ make e2e PROFILE=<profile> PRODUCT=<product>

Where profile is the name of the profile you want to test, and product
is a product relevant to `OCP4`, such as `ocp4` or `rhcos4`.

For instance, to run the tests for the `cis` benchmark for `ocp4` do:

    $ make e2e PROFILE=cis PRODUCT=ocp4

For more information on the available options, do:

    $ make help

It is important to note that the tests will do changes to your cluster
and there currently isn't an option to clean them up. So take that into
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
