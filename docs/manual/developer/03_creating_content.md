# Creating Content

## Directory Structure/Layout

### Top Level Structure/Layout

Under the top level directory, there are directories and/or files for
different products, shared content, documentation, READMEs, Licenses,
build files/configuration, etc.

#### Important Top Level Directory Descriptions

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>Directory</p></td>
<td><p>Description</p></td>
</tr>
<tr class="even">
<td><p><code>linux_os</code></p></td>
<td><p>Contains security content for Linux operating systems. Contains rules, OVAL checks, Ansible tasks, Bash remediations, etc.</p></td>
</tr>
<tr class="odd">
<td><p><code>applications</code></p></td>
<td><p>Contains security content for applications such as OpenShift or OpenStack. Contains rules, OVAL checks, Ansible tasks, Bash remediations, etc.</p></td>
</tr>
<tr class="even">
<td><p><code>shared</code></p></td>
<td><p>Contains templates which can generate, Jinja macros, Bash remediation functions.</p></td>
</tr>
<tr class="odd">
<td><p><code>tests</code></p></td>
<td><p>Contains the test suite for content validation and testing, contains also unit tests.</p></td>
</tr>
<tr class="even">
<td><p><code>build</code></p></td>
<td><p>Can be used to build the content using CMake.</p></td>
</tr>
<tr class="odd">
<td><p><code>build-scripts</code></p></td>
<td><p>Scripts used by the build system.</p></td>
</tr>
<tr class="even">
<td><p><code>cmake</code></p></td>
<td><p>Contains the CMake build configuration files.</p></td>
</tr>
<tr class="odd">
<td><p><code>Dockerfiles</code></p></td>
<td><p>Contains Dockerfiles to build content test suite container backends.</p></td>
</tr>
<tr class="even">
<td><p><code>docs</code></p></td>
<td><p>Contains the User Guide and Developer Guide, manual page template, etc.</p></td>
</tr>
<tr class="odd">
<td><p><code>products</code></p></td>
<td><p>Contains per-product directories (such as <code>rhel8</code>) of product-specific information and profiles.</p></td>
</tr>
<tr class="even">
<td><p><code>ssg</code></p></td>
<td><p>Contains Python <code>ssg</code> module which is used by most of the scripts in this repository.</p></td>
</tr>
<tr class="odd">
<td><p><code>utils</code></p></td>
<td><p>Miscellaneous scripts used for development but not used by the build system.</p></td>
</tr>
</tbody>
</table>

Note that product directories used to be top-level directories; these have now been reorganized under `products/`.

#### Important Top Level File Descriptions

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>File</p></td>
<td><p>Description</p></td>
</tr>
<tr class="even">
<td><p><code>CMakeLists.txt</code></p></td>
<td><p>Top-level CMake build configuration file</p></td>
</tr>
<tr class="odd">
<td><p><code>Contributors.md</code></p></td>
<td><p><strong>DO NOT MANUALLY EDIT</strong> script-generated file</p></td>
</tr>
<tr class="even">
<td><p><code>Contributors.xml</code></p></td>
<td><p><strong>DO NOT MANUALLY EDIT</strong> script-generated file</p></td>
</tr>
<tr class="odd">
<td><p><code>DISCLAIMER</code></p></td>
<td><p>Disclaimer for usage of content</p></td>
</tr>
<tr class="even">
<td><p><code>Dockerfile</code></p></td>
<td><p>CentOS7 Docker build file</p></td>
</tr>
<tr class="odd">
<td><p><code>LICENSE</code></p></td>
<td><p>Content license</p></td>
</tr>
<tr class="even">
<td><p><code>README.md</code></p></td>
<td><p>Project README file</p></td>
</tr>
</tbody>
</table>

### Benchmark Structure/Layout

Benchmarks are directories that contain `benchmark.yml` file. We have
multiple benchmarks in our project:

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>Name</p></td>
<td><p>Location</p></td>
</tr>
<tr class="even">
<td><p>Linux OS</p></td>
<td><p><code>/linux_os/guide</code></p></td>
</tr>
<tr class="odd">
<td><p>Applications</p></td>
<td><p><code>/applications</code> (Notice no <code>guide</code> subdirectory there!)</p></td>
</tr>
<tr class="even">
<td><p>Java Runtime Environment</p></td>
<td><p><code>/jre/guide</code></p></td>
</tr>
<tr class="odd">
<td><p>Fuse 6</p></td>
<td><p><code>/fuse6/guide</code></p></td>
</tr>
<tr class="even">
<td><p>Firefox</p></td>
<td><p><code>/firefox/guide</code></p></td>
</tr>
<tr class="odd">
<td><p>Chromium</p></td>
<td><p><code>/chromium/guide</code></p></td>
</tr>
</tbody>
</table>

The **Linux OS** benchmark describes Linux Operating System in general.
This benchmark is used by multiple ComplianceAsCode products, eg.
`rhel7`, `fedora`, `ubuntu1604`, `sle15` etc. The benchmark is located
in `/linux_os/guide`.

The products specify which benchmark they use as a source of content in
their `product.yml` file using `benchmark_root` key. For example,
`rhel7` product specifies that it uses the Linux OS benchmark.

    $ cat products/rhel7/product.yml
    product: rhel7
    full_name: Red Hat Enterprise Linux 7
    type: platform

    benchmark_root: "../linux_os/guide"

    .....

Rules from multiple locations can be used for a single Benchmark. There
is an optional key `additional_content_directories` for a list of paths
to some arbitrary Groups of Rules to be included in the benchmark. Note
that the additional directories cannot contain a benchmark file
(`benchmark.yml`), otherwise it fails to build the content. Of all the
rules collected only the following would become a part of the benchmark:

-   rules that have the `prodtype` specified in correspondence with the
    benchmark;

-   rules that have no `prodtype` metadata.

<!-- -->

    .....

    benchmark_root: "../applications"
    additional_content_directories:
        - "../linux_os/guide/services"
        - "../linux_os/guide/system"

    .....

The Benchmarks are organized into directory structure. The directories
represent either groups or rules. The group directories contain
`group.yml` and rule directories `rule.yml`. The name of the group
directory is the group ID, without the prefix. Similarly, the name of
the rule directory if the rule ID, without the prefix.

For example, the Linux OS Benchmark is structured in this way:

    .
    ├── benchmark.yml
    ├── intro
    │   ├── general-principles
    │   ├── group.yml
    │   └── how-to-use
    ├── services
    │   ├── apt
    │   ├── avahi
    │   ├── cron_and_at
    │   ├── deprecated
    │   ├── dhcp
    │   ├── dns
    │   ├── ftp
    │   ├── group.yml
    │   ├── http
    │   ├── imap
    │   ├── ldap
    │   ├── mail
    │   ├── nfs_and_rpc
    │   .......
    │   .......
    └── system
        ├── accounts
        ├── auditing
        ├── bootloader-grub2
        ├── bootloader-grub-legacy
        ├── entropy
        ├── group.yml
        ├── logging
    ......

### Product Structure/Layout

When creating a new product, use the guidelines below for the directory
layout:

-   **Do not** use capital letters

-   If product versions are required, use major or LTS versions only. For
    example, `rhel7`, `ubuntu2004`, etc.

-   If the content does not depend on specific versions,
    **do not** add version numbers. For example: `fedora`, `firefox`, etc.

-   See the [README](https://github.com/ComplianceAsCode/content/tree/master/example/README.md) for more information about
    the changes needed.

Following these guidelines help with the usability and browsability of
using and navigating the content.

For example:

    $ tree -d products/rhel7
    products/rhel7
    ├── kickstart
    ├── overlays
    ├── profiles
    └── transforms

    7 directories

#### Product Level Directory Descriptions

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>Directory</p></td>
<td><p>Description</p></td>
</tr>
<tr class="even">
<td><p><code>kickstart</code></p></td>
<td><p><code>Optional</code> Contains product kickstart or build files to be used in testing, development, or production (not recommended) of compliance content.</p></td>
</tr>
<tr class="odd">
<td><p><code>overlays</code></p></td>
<td><p><code>Required</code> Contains overlay files for specific standards organizations such as NIST, DISA STIG, PCI-DSS, etc.</p></td>
</tr>
<tr class="even">
<td><p><code>profiles</code></p></td>
<td><p><code>Required</code> Contains profiles that are created and tailored to meet government or commercial compliance standards.</p></td>
</tr>
<tr class="odd">
<td><p><code>transforms</code></p></td>
<td><p><code>Required</code> Contains XSLT files and scripts that are used to transform the content into the expected compliance document such as XCCDF, OVAL, Datastream, etc.</p></td>
</tr>
</tbody>
</table>

> **Important**
>
> For any of the `Required` directories that may not yet add
> content, add a `.gitkeep` file for any empty directories.

## Profiles

Profiles define the set of rules and variables aligned to a compliance
standard.

Structurally, a profile is a YAML file that represents a dictionary. A
profile YAML file has one implied attribute:

-   `id`: The primary identifier for the profile, to be referenced
    during evaluations. This is inferred from the file name.

A profile YAML file can, optionally, include metadata about the
implemented policy and experts in the field, called Subject Matter
Experts (SMEs). The SMEs usually are people familiar with the policy
requirements or how it is applied.

-   `metadata`: Dictionary for profile metadata.

-   `reference`: URL pointing to page or organization that publishes the
    policy.

-   `version`: Version of the policy implemented by the profile.

-   `SMEs`: List of people experienced with the profile, or how they are
    applied. The preferred method is the GitHub handle, but email is
    also accepted.

A profile should define these attributes:

-   `title`: Human-readable title of the profile.

-   `description`: Human-readable HTML description, which provides
    broader context for non-experts than the rationale.

-   `extends`: The `id` of a profile to be extended. A profile can make
    incremental changes based on another profile, via `extends`
    attribute. The extendee can then, via the `selections` attribute,
    select/unselect rules and change XCCDF Value selectors.

-   `selections`: List composed of items of these types:

-   `` id`s of rules to be included in the profile, e.g. `accounts_tmout ``,
    or

-   `` id`s of rules to be excluded from the profile prefixed by an exclamation mark, e.g. `!accounts_tmout ``,
    or

-   changes to XCCDF Value selectors, e.g. `var_accounts_tmout=10_min`,
    or

-   rule refinements, e.g. `accounts_tmout.severity=high`.


## Controls

The controls add another layer on top of profiles. Controls files store the
metadata for security controls and, more importantly, concentrate the mapping
from requirement to rule at a single place.

We will explain the format using the expected workflow and we will show examples
of the format.

### Storing controls data

When we develop a new SCAP profile, we usually base it off an external standard.
Standard documents define a policy that consists of controls (or requirements).
For example, the `rhel8/profiles/cis.profile` profile was based off of the CIS
Benchmark for RHEL 8, published as a PDF document by the CIS organization. This
document is organized by sections, with each "rule" being a specific piece of
guidance. For instance, CIS for RHEL 8 1.1.1.1 "Ensure mounting of cramfs
filesystems is disabled" would map to our `kernel_module_cramfs_disabled` rule.
Other benchmarks like NIST 800-53 controls, ANSSI requirements, and STIG have
different organization, specific to their benchmark document.

To add the policy to our project repository, we will create a YAML file that
represents this policy. There is a special directory, called `controls`, in the
repository root to store these files. These files serve as a database of
controls (requirements). They are independent from profiles and products. We can
extract the relevant data from the standard document and save them in a YAML
file. Presently, control files are created manually. In the future, automatic
conversions from XML or OpenControl formats into the YAML control file format
could be used.

For example, a YAML control file would look like this:

```
$ cat controls/abcd.yml

id: abcd
title: ABCD Benchmark for securing Linux systems
version: 1.2.3
source: https://www.abcd.com/linux.pdf
controls:
  - id: R1
    title: User session timeout
    description: |-
      Remote user sessions must be closed after a certain
      period of inactivity.
  - id: R2
    title: Minimization of configuration
    description: |-
      The features configured at the level of launched services
      should be limited to the strict minimum.
  - id: R3
    title: Enabling SELinux targeted Policy
    description: |-
      It is recommended to enable SELinux in enforcing mode
      and to use the targeted policy.
```

In the real world, controls (requirements) can be nested. For example, PCI-DSS
has a tree-like structure, within requirement 2.3, we can find 2.3.a, 2.3.b,
etc. Therefore, each item in `controls` list can contain a `controls` list.

Once we have the initial file, we can read through the policy requirements and
assess each requirement. For each control, we will have to identify whether it
can be automated by SCAP. If so, we should look if we already have existing
XCCDF rules in our project.

In the example below we identified that:

* R1 can be automatically scanned by SCAP and we already have 3 existing rules
in our repository. However, we want one of them to be selected only on RHEL 9,
but the rule is applicable to all platforms.
* R2 is up to manual checking, but we have systemd_target_multi_user which is
related to this control.
* R3 can be automatically scanned by SCAP but unfortunately we don’t have any
rules implemented yet.

For each control we will add the `status` key, which describes the current
implementation status of the control. For instance, if the control requirement
can be automated by SCAP and scanning, the status will be `automated`.
The `status` key is just for informational purposes and does not have any
impact on the processing.

The  `status` key deprecates the `automated` key -
`automated: yes` translates to `status: automated`, and so on.
The `status` key is preferred as it it is capable to reflect the control state more accurately.

When XCCDF rules exist, we will assign them to the controls. We will distinguish
between XCCDF rules which directly implement the given controls (represented by
`rules` YAML key) and rules that are only related or relevant to the control
(represented by `related_rules` YAML key).

The `rules` and `related_rules` keys consist of a list of rule IDs and variable
selections.

If a rule needs to be chosen only in some of products despite its `prodtype` we
can use Jinja macros inside the controls file to choose products.

After we finish our analysis, we will insert our findings to the controls file,
the file will look like this:

```
$ cat controls/abcd.yml
 
id: abcd
title: ABCD Benchmark for securing Linux systems
version: 1.2.3
source: https://www.abcd.com/linux.pdf
controls:
  - id: R1
    title: User session timeout
    description: |-
      Remote user sessions must be closed after a certain
      period of inactivity.
    status: automated
    rules:
    - sshd_set_idle_timeout
    - accounts_tmout
    - var_accounts_tmout=10_min
{{% if product == "rhel9" %}}
    - cockpit_session_timeout
{{% endif %}}
  - id: R2
    title: Minimization of configuration
    description: |-
      The features configured at the level of launched services
      should be limited to the strict minimum.
    status: supported
    note: |-
      This is individual depending on the system workload
      therefore needs to be audited manually.
    related_rules:
       - systemd_target_multi_user
  - id: R3
    title: Enabling SELinux targeted Policy
    description: |-
      It is recommended to enable SELinux in enforcing mode
      and to use the targeted policy.
    status: automated
```

Notice that each section identifier is a reference in the standard's benchmark.
Each of the values under the `rules` key maps onto a rule identifier in the
project. In the future, we could automatically assign references to rules via
this control file.

### Defining levels

Some real world policies, e.g.,  ANSSI, have a concept of levels.
Level can be defined as a group of controls which logically form a single unit.

Control files can work with the concept of levels.
You can define explicit inheritance between levels e.g., the "high" level inherits all controls from "low" level adding some more controls on the top of it.

For example, let's say that ABCD benchmark would define 2 levels: low and high.
The low level would contain R1 and R2. The high level would contain everything
from the low level and R3, ie. the high level would contain R1, R2 and R3.

First, add the `levels` key to the YAML file.
This key will contain list of dictionaries - one per level.
Each level must have its `id` defined.
You can specify that the level should inherit all controls of a different level.
It can be done by adding a key called `inherits_from` to the level definition.
This key contains a list of level IDs.
Then add `levels` key to every control ID to specify a list of levels the control belongs to.
Note that if a control does not have any level specified, it is assigned to the default level, which is the first in the list of levels.

If a level is selected, all controls which are assigned to this level (see example below) are included in the resulting profile.
If a level with `inherits_from` key specified is selected, all controls from inherited levels are included together with controls assigned to the inheriting level.

```
$ cat controls/abcd.yml

id: abcd
title: ABCD Benchmark for securing Linux systems
version: 1.2.3
source: https://www.abcd.com/linux.pdf
levels:
  - id: low
  - id: high
    inherits_from:
    - low
controls:
  - id: R1
    levels:
    - low
    title: User session timeout
    description: |-
      Remote user sessions must be closed after a certain
      period of inactivity.
  - id: R2
    levels:
    - low
    title: Minimization of configuration
    description: |-
      The features configured at the level of launched services
      should be limited to the strict minimum.
  - id: R3
    levels:
    - high
    title: Enabling SELinux targeted Policy
    description: |-
      It is recommended to enable SELinux in enforcing mode
      and to use the targeted policy.
```

### Reporting status

In some cases, it's useful to know the status of a certain control for a
specific product. In order to better portray this, it's possible to set
such information on each control using the `status` key.

The `status` key may hold the following values:

* `pending`: The control is not yet evaluated for the product.

* `not applicable`: The control is not applicable to this product.

* `inherently met`: The control is inherently met by the product.

* `documentation`: The control is addressed by product documentation.

* `planned`: The control is not yet implemented, but is planned.

* `partial`: While work has been done to address this control, there is still
             work needed to fully address it.

* `supported`: The control is addressed by the product (but is missing content
                automation).

* `automated`: The control is addressed by the product and can be automatically
               checked for.

Note that if the `status` key is missing from a control definition, the default
status will be `pending`.

When there is work on-going to address a specific control, it may be portrayed
via the `tickets` key. The aforementioned key shall contain a list of URLs that
may help the reader track what work needs to be done to address a specific
control.

```
$ cat controls/abcd.yml

id: abcd
title: ABCD Benchmark for securing Linux systems
version: 1.2.3
source: https://www.abcd.com/linux.pdf
levels:
  - id: low
  - id: high
    inherits_from:
    - low
controls:
  - id: R1
    levels:
    - low
    title: User session timeout
    description: |-
      Remote user sessions must be closed after a certain
      period of inactivity.
    status: partial
    tickets:
    - https://my-ticket-tracker.com/issue/1
    - https://my-ticket-tracker.com/issue/2
```


### Controls file format

This is a complete schema of the YAML file format.

```
id: policy ID (required key)
title: short title (required key)
source: a link to the original policy, eg. a URL of a PDF document
levels: a list of levels, the first one is default.
  - id: level ID (required key)
    inherits_from: a list of IDs of levels inheriting from

controls: a list of controls (required key)
  - id: control ID (required key)
    title: control title
    description: description of the control in a few sentences
    automated: Can be one of: ["yes", "no", "partially"]. Default value: "yes".
    levels: The list of policy levels that the control belongs to.
    notes: a short paragraph of text
    rules: a list of rule IDs that cover this control
    related_rules: a list of related rules
    note: a short paragraph of text
    controls: a nested list of controls
    status: a keyword that reflects the current status of the implementation of this control
    tickets: a list of URLs reflecting the work that still needs to be done to address this control
```

Full example of a controls file:

```
id: abcd
title: ABCD Benchmark for securing Linux systems
source: https://www.abcd.com/linux.pdf
levels:
  - id: low
  - id: high
    inherits_from:
    - low
controls:
  - id: R1
    levels:
    - low
    title: User session timeout
    description: >-
      Remote user sessions must be closed after a certain
      period of inactivity.
    status: automated
    rules:
    - sshd_set_idle_timeout
    - accounts_tmout
    - var_accounts_tmout=10_min
    - configure_crypto_policy
    notes: >-
      Certain period of inactivity is vague.
  - id: R2
    title: Minimization of configuration
    description: >-
      The features configured at the level of launched services
      should be limited to the strict minimum.
    status: supported
    note: >-
      This is individual depending on the system workload
      therefore needs to be audited manually.
    related_rules:
       - systemd_target_multi_user
  - id: R3
    title: Enabling SELinux targeted Policy
    description: >-
      It is recommended to enable SELinux in enforcing mode
      and to use the targeted policy.
    status: automated
    rules:
      - selinux_state
  - id: R4
    title: Configure authentication
    description: >-
      Ensure authentication methods are functional to prevent
      unauthorized access to the system.
    controls:
      - id: R4.a
        title: Disable administrator accounts
        status: automated
        levels:
        - low
        rules:
          -  accounts_passwords_pam_faillock_deny_root
      - id: R4.b
        title: Enforce password quality standards
        status: automated
        levels:
        - high
        rules:
          - accounts_password_pam_minlen
          - accounts_password_pam_ocredit
          - var_password_pam_ocredit=1
```

### Using controls in profiles

Later, we can use the policy requirements in profile YAML. Let’s say that we
will define a “Desktop” profile built from the controls.

To use controls, we add them under `selection` keys in the profile. The entry
has the form `policy_id:control_id[:level_id]`, where `level_id` is optional.

```
$ cat rhel8/profiles/abcd-desktop.profile
 
documentation_complete: true
title: ABCD Desktop for Red Hat Enterprise Linux 8
description: |-
  This profile contains configuration checks that align to
  the ABCD benchmark.
selections:
  - abcd:R1
  - abcd:R2
  - abcd:R3
  - security_patches_uptodate
```

Notice we can mix the controls selections with normal rule selections.

In a similar way, we could define another profile that selects only some of the
requirements.

In the example we have selected all controls from `controls/abcd.yml` by listing
them explicitly. It is possible to shorten it using the `“all”` value which
means that all controls will be selected. Let’s show how it will be easier:

```
$ cat rhel8/profiles/abcd-high.profile
 
documentation_complete: true
title: ABCD High for Red Hat Enterprise Linux 8
description: |-
  This profile contains configuration checks that align to
  the ABCD benchmark.
selections:
  - abcd:all
  - security_patches_uptodate
```

It is possible to use levels if the levels are defined in the controls file. For
example, `abcd:all:low` selects all rules for the ABCD low level or
`abcd:all:high` selects all rules from the ABCD high level.

Finally, when we build the content, we will automatically get a SCAP profile
which contains XCCDF rules and variables from all controls selected in profile
YAML.

The build system adds all XCCDF rules listed under `rules` key in the control to
the built profile. The rules listed under `related_rules` key are not added.
Therefore, the `related_rules` don't affect the generated source data stream.
Also, the selections from `selection` key in profile file are included.

In our example, the generated profile will contain rules
`sshd_set_idle_timeout`, `accounts_tmout`, `var_accounts_tmout=10_min` and
`security_patches_uptodate`. The profile will not contain
`systemd_target_multi_user` even if control `R2` is selected because that is
listed under `related_rules`.

The profile will be compiled to a canonical form during the build. The compiled
profiles are located in the `/build/${PRODUCT_ID}/profiles/` directory.

Example of a compiled profile:

```
$ cat build/rhel8/profiles/abcd-desktop.profile

documentation_complete: true
title: ABCD Desktop for Red Hat Enterprise Linux 8
description: |-
  This profile contains configuration checks that align to
  the ABCD benchmark.
selections:
  - sshd_set_idle_timeout
  - accounts_tmout
  - var_accounts_tmout=10_min
  - security_patches_uptodate
```

This profile is similar in content to one we could've created manually, but
instead is automatically generated during build from a semantic data source. It
seamlessly integrates with the build system to include the generated profile in
the resulting SCAP source data stream.

### Presentation of data

Apart to the build system, the controls files can be also processed by
different utilities.

The `render-policy.py` utility creates a HTML file where the controls are
resolved in the context of a given product. The file contains links to rule
definitions in the upstream repository. The generated file can be distributed to
subject matter experts for a review.

```
$ utils/render-policy.py --output doc.html rhel8 controls/abcd.yml
```

For more details about the `render_policy.py` tool, run `utils/render-policy.py --help`.

The `controleval.py` utility creates statistics that show the current progress
in implementing a certain level from the controls file. These are derived from
the different status options that were documented earlier in this
documentation.

```
$ utils/controleval.py stats -i cis_rhel7 -l l2_server
```

For more details about the `controleval.py` too, run `utils/controleval.py --help`.
