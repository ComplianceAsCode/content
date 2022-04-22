# ComplianceAsCode Style Guide

## Pull Requests
* Should follow [the template](https://github.com/ComplianceAsCode/content/blob/master/.github/pull_request_template.md)
* Shall remove the sample text from the template pull request
* Shall not have merge commits, they should have to be taken out by [rebasing](https://docs.github.com/en/get-started/using-git/about-git-rebase)
* Should target `master`, unless pulling an already merged pull request to a stabilization branch

### Before Merging
* Must have the milestone set correctly
* Must have the correct labels
* Should be assigned to the reviewers

### Merging
* Should use the [merge commit method](https://docs.github.com/en/github/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/about-pull-request-merges)
* Should use the GitHub Web UI to document and ensure code reviews are done correctly

## All files
* Shall use UNIX style line endings
* Shall have one newline at the end of the file
* Shall not have trailing whitespace, unless syntactically necessary
* File names must:
    * Be in lower case
    * Have words separated by an underscore
    * Have a total path length less than 250 characters
* Shall not use "smart quotes" or curved quotes
* Maximum line length should be 99 characters

## Jinja
* Shall use 4-space indentation
* Shall have a docstring comment describe what the macro does
* Shall have a docstring comment describing all parameters and their types
  * Types shall be Python class names. (E.g. `str`, `bool`, `dict`, etc)
  * Shall be last section of the docstring
  * Shall have one blank after list before the close of the docstring block
* Shall have two blank lines between macros

## Python
* All Python files should follow [PEP 8](https://www.python.org/dev/peps/pep-0008/)
    * We use [PEP 8 Speaks](https://pep8speaks.com/) and it leaves a comment on PR if you have PEP8 issues in the Python file(s) you touched
    * We do make one change from PEP 8, our maximum line length is 99 characters
* Methods should be defined before they are called
* The files in the build system shall be Python 2.7 and Python 3 compatible
* Utilities may only support Python 3
* Shall use the `.py` for the file extension
* Shall use 4-space indentation
* New Python 3 methods and scripts should have type hints

## YAML
* All new YAML files shall use 4-space indentation
    * Existing YAML files may use 2-space indentation
* Must be able to be parsed with PyYAML
* Shall use the `.yml` vs `.yaml` for the file extension
* Shall have one blank line between sections

### HTML Like Fields
The sections below marked with an `(HTML Like)` means that a limited number of HTML elements are supported in these sections.
The lists of elements below are **not** fully inclusive.
Any elements that are not strictly for formatting shall not be used.

We support the following elements:
* `b` - Boldface
* `br` - Line break
* `code` - Inline code blocks
* `i` - Italics
* `pre` - Code block
* `tt` - Inline code blocks

The following elements are not allowed:
* `script`
* `video`
* `audio`

### Rule
This section describes the styleguide around the `rule.yml` files.
* All the above [YAML](manual/developer/04_style_guide:yaml) rules apply.
* A rule should only address one configuration item change.
* A variable should be when a configuration change can be multiple different values.
* When writing rule and a template is available, the template should be used over custom content

#### Rule Sections
Rules sections must be in the following order, if they are present.
* `documentation_complete`
* `prodtype`
    * Comma separated list
    * No spaces between items
    * Items must be in alphabetical order
* `title`
    * Must be one line
    * Must be in [Title case](https://en.wikipedia.org/wiki/Title_case)
    * Must be short and descriptive
    * Must align the directory name the `rule.yml` is in
* `description` (HTML Like)
* `rationale` (HTML Like)
* `severity`
* `identifiers`
    * Keys must be in alphabetical order
* `references`
    * Keys must be in alphabetical order
* `platforms`
* `ocil_clause`
* `ocil` (HTML Like)
* `fix` (HTML Like)
* `warnings`
    * All subsections are HTML-Like
    * If defined must have at least one of the following sub-sections:
        * `general`
        * `dependency`
        * `performance`
        * `management`
        * `functionality`
* `conflicts`
    * Must be a valid rule id
* `requires`
    * Must be a valid rule id
* `template`

### Group
This section describes the styleguide around the `group.yml` files.
* All the above [YAML](manual/developer/04_style_guide:yaml) rules apply
* A group should only contain rules that effect the same software or service

#### Group Sections
Group sections must be in the following order, if present.
* `documentation_complete`
* `title`
    * Must be in [Title case](https://en.wikipedia.org/wiki/Title_case)
* `platforms`
* `description` (HTML-Like)

### Benchmark
This section describes the styleguide around the `benchmark.yml` files.
All the above [YAML](manual/developer/04_style_guide:yaml) rules apply.

#### Benchmark Sections
Benchmark sections must be in the following order, if they are present.
* `documentation_complete`
* `status`
* `title`
    * Must be in [Title case](https://en.wikipedia.org/wiki/Title_case)
* `description` (HTML-Like)
* `notice` (HTML-Like)
* `front-matter` (HTML-Like)
* `rear-matter` (HTML-Like)
* `version`

### Controls
These rules apply to the files in `controls/`
All the above [YAML](manual/developer/04_style_guide:yaml) rules apply.

#### Control Sections
Control sections must be in the following order, if they are present.
* `policy`
* `title`
    * Must be in [Title case](https://en.wikipedia.org/wiki/Title_case)
* `id`
    * Must be short
    * Must be lowercase
    * If product specific should be in the format `standard_product`. For example CIS on RHEL8 would be `cis_rhel8`
    * Should match the filename of the control
    * Words shall be separated by an underscore
* `version`
    * Should be the same as the standard
* `source`
    * URL to the standard
* `controls`
    * `id`
    * `levels`
        * Should be in lowercase
        * Must have words separated by an underscore
        * Shall follow the standard
    * `title`
        * Shall be one line
    * `status`
    * `notes`
        * Must be a block
    * `rules`
        * Must be a list of valid rule id

### Profile

#### Profile Sections
Control sections must be in the following order, all sections are required unless otherwise noted.
* `documentation_complete`
* `id`
* `metadata`
  * `reference`
  * `version`
  * `SMEs`
* `title`
  * Shall be short and descriptive 
* `description` (HTML-Like)
* `extends` (Optional)
  * Must be valid id of another profile id
* `selections`
  * Must be valid rule ids

## Remediation

### Header
All remediations should have the following header with the appropriate values.
The header should start on the first line.
```bash
# platform = multi_platform_all
# reboot = false
# strategy = enable
# complexity = low
# disruption = low
```

#### `platform`
Unless there is a good reason this should be `multi_platform_all`. 
But if the rule only applies to a specific operating system or family of operating then should be used. 
The values can be product names or values from `MULTI_PLATFORM_LIST` or `MULTI_PLATFORM_LIST` in [ssg/constants.py](https://github.com/ComplianceAsCode/content/blob/master/ssg/constants.py).

#### `reboot`
Must be true or false.
Shall be true if the system needs to be rebooted in order for the changes to take effect.

#### `strategy`
Should be one of the following values:
* configure
* disable
* enable
* patch
* restrict
* unknown

#### `complexity`
Value must be low, medium, or high.

#### `disruption`
Value must be low, medium, or high.

### Ansible
* Shall follow all the rules in the [YAML](manual/developer/04_style_guide:yaml) section
* Should prefer using Ansible modules over just calling system commands
* Shall be written to pass [`ansible-lint`](https://github.com/ansible-community/ansible-lint)

### Bash
* Should use Jinja macros instead of shared functions
* Must use 4-space indentation
* Shall put `do` or `then` on the same line as `for` or `if` respectively, e.g. `for file in *; do`

### Kubernetes
* Shall follow all the rules in the [YAML](manual/developer/04_style_guide:yaml) section

## XML
* Shall use the `.xml` for the file extension
* Must be able to be parsed by Python's XML parser
* Shall use 4-space indentation

### OVAL
* The `id` attribute of `<definition>` should be `{{{ rule_id }}}`
* The elements should be in the following order:
    * `def-group`
        * `definition`
            * `metadata`
                * Should be defined by the`oval_metadata` macro
            * `criteria`
        * Like OVAL `test`, `object`, and `state` should have the same name after their respective prefix.
        * Like OVAL `test`, `object`, and `state` should group together, if there are many tests the order below should be repeated for each group.
            * `test`
            * `object`
            * `state`
* If an element has an optional a `comment` it should be added

#### Test Elements
* `id` should start with `test_`

#### Object Elements
* `id` should start with `obj_`

#### State Elements
* `id` should start with `state_`

## Tests
* Shall always do something, even if testing default behavior
* Shall test one change
* Shall use the `.sh` for the file extension
* Shall use the `#!/bin/bash` shebang at the first line
* Shall have a single empty line after the shebang line or after the last [header parameter](https://complianceascode.readthedocs.io/en/latest/tests/README.html#scenarios-format), like in the following valid examples:
```bash
#!/bin/bash

<code here>
```
or
```bash
#!/bin/bash
# packages = audit

<code here>
```

* Must follow all the rules in the [Bash](manual/developer/04_style_guide:bash) section

## Markup Languages
* Shall have [one sentence per line](https://asciidoctor.org/docs/asciidoc-recommended-practices/#one-sentence-per-line)

### Headings
* Must have one blank line above headings
* Must be in [Title case](https://en.wikipedia.org/wiki/Title_case)

### Markdown
* Shall use the `.md` for the file extension

### ASCIIDoc
* Shall use the `.adoc` for the file extension
* Shall not be used for new documentation

### reStructuredText
* Shall use the `.rst` for the file extension
* Must only be used when necessary
