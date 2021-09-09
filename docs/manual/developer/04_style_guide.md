# Compliance as Code Content Style Guide

## Pull Requests
* Should follow the template
* Shall remove the sample text from the template
* Shall not have merge commits

### Before Merging 
* Must have released associated
* Must have the correct labels
* Should be assigned to the reviewers

### Merging
* Should use the merge commit method

## All files
* Shall use UNIX style line endings
* Shall have one blank line at the end of the file
* When not syntactically necessary, there shall not be trailing whitespace
* File names must:
  * Be in lower case
  * Have words separated by an underscore
  * Total path length less than 250 characters 

## Python
* All Python files should follow [PEP 8](https://www.python.org/dev/peps/pep-0008/)
  * We use [PEP 8 Speaks](https://pep8speaks.com/) and it leaves a comment on PR if you have PEP8 issues in the Python file you touched.
  * We do make one change from PEP 8, our maximum line length is 99 characters
* Methods should be defined before they called
* The files in the build system shall be Python 2.7 and Python 3 compatible
* Utilities may only be compatible Python 3
* Shall use the `.py` for the file extension

## YAML
* All YAML files shall use 4 spaces inplace of tabs.
* Maximum line length is 99 characters
* Must be able to be parsed with PyYAML
* Shall use the `.yml` vs `.yaml` for the file extension
* Shall have one blank line between sections

### HTML Like Fields
In the sections below marked with an `(HTML Like)` means that a limited number of HTML elements are supported in these fields.

We support the following elements:
* `tt` - inline code blocks
* `b` - bold face
* `i` - italics 
* `pre` - code block
* `br` - line break

### Rule
This section describes the styleguide around the `rule.yml` files. 
All the above [YAML](manual/developer/04_style_guide:yaml) rules apply.
A rule should only address one configuration item change.

#### Sections
Rules sections should be in the following order, if present.
* `documentation_complete`
* `prodtype`
  * Comma separated list
  * No spaces between items
  * Items must be in alphabetical order
* `title`
  * Must be One Line 
  * Must be in [Title case](https://en.wikipedia.org/wiki/Title_case)
  * Must be short and descriptive
  * Must roughly match the path the `rule.yml` is in
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
  * * Must be a valid rule id
* `template`

### Group
This section describes the styleguide around the `group.yml` files. 
All the above [YAML](manual/developer/04_style_guide:yaml) rules apply.
A group should only contain rules that effect the same software or service.

#### Sections
Group sections should be in the following order, if present.
* `documentation_complete`
* `title`
  * Must be in [Title case](https://en.wikipedia.org/wiki/Title_case)
* `description` (HTML-Like)

### Benchmark
This section describes the styleguide around the `benchmark.yml` files. 
All the above [YAML](manual/developer/04_style_guide:yaml) rules apply.

#### Sections
Benchmark sections should be in the following order, if present.
* `documentation_complete`
* `status`
* `title`
  * Must be in [Title case](https://en.wikipedia.org/wiki/Title_case)
* `description` (HTML-Like)
* `notice` (HTML-Like)
* `front-matter` (HTML-Like)
* `rear-matter` (HTML-Like)
* `version`

## Remediation
All remediations should have the following header with the correct 
```bash
# platform = multi_platform_all
# reboot = false
# strategy = enable
# complexity = low
# disruption = low
```

### Bash
* Should use marcos instead shared functions
* 
### Ansible
* Shall follow all the rules in the [YAML](manual/developer/04_style_guide:yaml) section
* Should prefer using Ansible modules over just calling system commands


## XML
* Shall use the `.xml` for the file extension
* Must be able to be parsed by Python's XML parser

### OVAL
* The `id` attribute of `<definition>` should be `{{{ rule_id }}}`
* The elements should be in the following order:
  * `def-group`
    * `definition`
      * `metadata`
        * Should be defined by the`oval_metadata` marco
      * `criteria`
    * * Like OVAL `test`, `object`, and `state` should have the same name after there respective prefix.
    * Like OVAL `test`, `object`, and `state` should group together, if there are many tests the order below should be repeated for each group.
      * `test`
      * `object`
      * `state`

### Test elements
* `id` should start with `test_`

### Object elements
* `id` should start with `obj_`

### State elements
* `id` should start with `state_`

## Tests
* Should always do something, even if testing default behavior
* Should test one change

## Markdown
* One sentence per line

### Headings
* Must have one blank file above headings
* Must be in [Title case](https://en.wikipedia.org/wiki/Title_case)