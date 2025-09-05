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
<td><p><code>ssg</code></p></td>
<td><p>Contains Python <code>ssg</code> module which is used by most of the scripts in this repository.</p></td>
</tr>
<tr class="even">
<td><p><code>utils</code></p></td>
<td><p>Miscellaneous scripts used for development but not used by the build system.</p></td>
</tr>
</tbody>
</table>

The remaining directories such as `fedora`, `rhel7`, etc. are product
directories.

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

    $ cat rhel7/product.yml
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

-   If product versions are required, use major versions only. For
    example, `rhel7`, `ubuntu16`, etc.

-   If the content to be produced does not matter on versions, **do
    not** add version numbers. For example: `fedora`, `firefox`, etc.

-   In addition, use only a maxdepth of 3 directories.

-   See the [README](https://github.com/ComplianceAsCode/content/tree/master/example/README.md) for more information about
    the changes needed.

Following these guidelines help with the usability and browsability of
using and navigating the content.

For example:

    $ tree -d rhel7
    rhel7
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
