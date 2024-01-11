# ComplianceAsCode Style Guide

## Labels

* Use labels efficiently
    * For example, use only the minimal necessary labels
* Labels must have a clear and objective description
* New labels should be created in lowercase
* New labels should be agnostic to PRs and Issues
* Labels related to the same group/category should share the same colors, like in these examples:
    * Assessment languages related labels, like "OVAL" and "OCIL", share the color <span style="color:#0e8a16">#0e8a16</span>
    * Attention required labels, like "BLOCKER" and "productization-issue", share the color <span style="color:#e11d21">#e11d21</span>
    * Benchmarks related labels, like "CIS" and "STIG", share the color <span style="color:#08d2d8">#08d2d8</span>
    * Components related labels, like "Test Suite" and "Documentation", share the color <span style="color:#84b6eb">#84b6eb</span>
    * Improvements related labels, like "New Product" or "New Rule", share the color <span style="color:#c2e0c6">#c2e0c6</span>
    * "EyeCatcher" related labels, like a "Highlight" or "bugfix", share the color <span style="color:#fbca04">#fbca04</span>
    * Product related labels, like "RHEL" and "Ubuntu", share the color <span style="color:#4141f4">#4141f4</span>
    * Remediation related labels, like "Ansible" and "Bash", share the color <span style="color:#9bf442">#9bf442</span>
* It is possible to have custom labels for ad-hoc tasks. These must be properly managed and removed when no longer necessary.
* Be careful changing label names or removing labels. Some labels are used by bots and automated processes, like the [release changelog generation](https://github.com/ComplianceAsCode/content/blob/master/.github/workflows/release-changelog.json).

## Pull Requests

* Should follow [the template](https://github.com/ComplianceAsCode/content/blob/master/.github/pull_request_template.md)
* Shall remove the sample text from the template pull request
* Shall not have merge commits; they should have been taken out by [rebasing](https://docs.github.com/en/get-started/using-git/about-git-rebase)
* Should target `master` unless pulling an already merged pull request to a stabilization branch
* Shall have a useful title so that it can be used in the changelog

### Before Merging

* Must have the milestone set correctly
* Must have the correct labels
* Should be assigned to the reviewers

### PR Gating

All gating tests should be passing prior to merging the PR in question.
An exception to this are cases when a test fails either because there is an infrastructure issue or because the test detects false positives.
For example, a PR moves things around without making them worse, but the gating detects this as introduction of bad code.
Alternatively, a PR can contribute code that is not tested, and tests are planned to come in later PRs.
Such failing tests should be addressed in a reviewer's comment to waive them.

Noteworthy additions to these principles:

* CodeClimate: Failures should be taken seriously, especially when they can be fixed easily &mdash; that includes issues related to the complexity of code.
  If code that looks reasonably complex is labelled as too complex, relaxation of the corresponding setting in CodeClimate can be proposed and discussed.
* Openshift CI: As of 2022, those tests frequently fail because of infrastructure issues.
  Their failing results don't have to be waived if the PR is clearly unrelated to those tests.

### Merging

* Should use the [merge commit method](https://docs.github.com/en/github/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/about-pull-request-merges)
* Should use the GitHub Web UI to document and ensure code reviews are done correctly

### Commit Messages

These guidelines are based on the [*How to write a commit message*](https://cbea.ms/git-commit/) post by cbeams.

* Limit the subject line (first line) to 50 characters
    * This is not a hard limit
    * Keeping subject lines at this length ensures that they
      are readable, and forces the author to think for a moment about the most concise way
      to explain what’s going on
    * If you’re having a hard time summarizing, you might be committing too many changes at once
* Separate subject from body with a blank line
    * Not every commit requires both a subject and a body.
      Sometimes a single line is fine, especially when the change
      is so simple that no further context is necessary
* Capitalize the subject line
* Do not end the subject line with a `.` (period)
    * Trailing punctuation is unnecessary in subject lines
* Use the imperative mood in the subject line
    * Verbs like "fix", "update", "refactor", "remove" instead of "fixed", "updated", "refactors", and "removes"
    * This convention matches up with commit messages generated
      by commands like `git merge` and `git revert`
* Wrap the body at 72 characters
* Use the body to explain what and why instead of how
    * In most cases, you can leave out details about **how** a change has been made
      (other contributors can use `git show` or just look at the code for that)
    * Focus on making clear the reasons **why** you made the change — the way things worked before the change
      (and what was wrong with that), the way they work now, and why it was decided to solve it the way it was solved

This is an example of an ideal commit message:

```
Summarize changes in around 50 characters or less

More detailed explanatory text, if necessary. Wrap it to about 72
characters or so. In some contexts, the first line is treated as the
subject of the commit and the rest of the text as the body. The
blank line separating the summary from the body is critical (unless
you omit the body entirely); various tools like `log`, `shortlog`
and `rebase` can get confused if you run the two together.

Explain the problem that this commit is solving. Focus on why you
are making this change as opposed to how (the code explains that).
Are there side effects or other unintuitive consequences of this
change? Here's the place to explain them.

Further paragraphs come after blank lines.

 - Bullet points are okay, too
 - Typically a hyphen or asterisk is used for the bullet, preceded
   by a single space

Put references to issues at the bottom, like this:

Resolves: #123
See also: #456, #789
```

## General Coding Style

Prioritize the human-readability of code to its machine efficiency.
In practice, this implies:

* Keep functions and methods small, just a few lines, so it is possible to understand what they do with minimal effort.
  Prioritize the code readability over line count or code performance.
* Don't mix low-level and high-level code in one function.
  Extract functionality to separate functions or convert functions into classes with multiple methods to avoid this.
* If a function contains a try/except block, there should be no other logic present apart from exception handling.
* Name variables and functions properly; don't hesitate to use longer identifiers.
  Use explanatory variables to help the code to express itself &mdash;
  assign a result of the operation into a variable that describes its meaning even if you intend to use it only once.
* Write comments if and only if there is no chance for the code to explain itself.

When working with existing code that doesn't satisfy these recommendations, simply leave the code in a better shape than the shape in which it was before,
and keep these guidelines in mind when writing new code.

## Project-level Coding Style

* Include tests for your contribution.
* Don't take part in making files longer -- files longer than 400 lines should be an exception.
  Add your new code into a new file, and possibly move existing code to it in the same or in a follow-up PR.
* Don't copy-paste code, use, e.g., Jinja macros to reduce duplication.
  Exception to this rule is code that is identical another piece of code only by coincidence, and there is a substantial probability that the code can diverge.
* Don't put authorship information into the code, Git tracks authorship for you.
  Don't copy-paste license text into source files &mdash; use [SPDX IDs](https://spdx.dev/ids/) for that purpose.
* Don't commit one-off scripts to the project.
  On occasions when one would like to get a feedback on the approach or debug the script,
  that makes automated changes to the project in a PR, it is strongly recommended to add a removal commit before merging the PR.

## Text-level Coding Style

### All Files

* Shall use UNIX style line endings
* Shall have one newline at the end of the file
* Shall not have trailing whitespace unless syntactically necessary
* File names must:
    * Be in lower case
    * Have words separated by an underscore
    * Have a total path length less than 250 characters
* Shall not use "smart quotes" or curved quotes
* Maximum line length should be 99 characters

### Jinja

* Shall use 4-space indentation
* Shall have a docstring comment describe what the macro does
* Shall have a docstring comment describing all parameters and their types
    * Types shall be Python built-in types with | operator. (E.g. `str`,
      `bool`, `dict`, `None | int`, `list[str]`, etc), with exceptions:
        * `char`: `str` with length exactly 1
    * Shall be the last section of the docstring
    * Shall start at the beginning of the line
    * Shall have one blank after a list before the close of the docstring block
* Shall have two blank lines between macros

### Python

* All Python files should follow [PEP 8](https://www.python.org/dev/peps/pep-0008/)
    * We use [Code Climate](https://codeclimate.com/quality) to help automate the checking for PEP 8 issues.
    * We do make one change from PEP 8; our maximum line length is 99 characters
* Methods should be defined before they are called
* The files in the build system shall be Python 2.7 and Python 3 compatible
* Utilities may only support Python 3
* Shall use the `.py` for the file extension
* Shall use 4-space indentation
* New Python 3 methods and scripts should have type hints

### YAML

* All new YAML files shall use 4-space indentation
    * Existing YAML files may use 2-space indentation
* Must be able to be parsed with PyYAML
* Shall use the `.yml` vs `.yaml` for the file extension
* Shall have one blank line between sections

#### HTML Like Fields

The sections below that are marked with `(HTML Like)` means that a limited number of HTML elements are supported in these sections.
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

* `audio`
* `form`
* `script`
* `video`

## Schemas

### Rule

This section describes the style guide around the `rule.yml` files.

* All the above [YAML](#yaml) rules apply.
* A rule should only address one configuration item change.
* A variable should be when a configuration change can be multiple different values.
* When writing a rule and a template is available, the template should be used over custom content

#### Rule Sections

Rules sections must be in the following order, if they are present.

* `documentation_complete`
* `prodtype`
    * Comma separated list
    * No spaces between items
    * Items must be in alphabetical order
    * Required on all new rules
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
* `fixtext` (HTML Like)
* `checktext` (HTML Like)
* `srg_requirement`
* `warnings`
    * All subsections are HTML-Like
    * If defined must have at least one of the following sub-sections:
        * `general`
        * `functionality`
        * `performance`
        * `hardware`
        * `legal`
        * `regulatory`
        * `management`
        * `audit`
        * `dependency`
* `conflicts`
    * Must be a valid rule id
* `requires`
    * Must be a valid rule id
* `template`

### Group

This section describes the style guide around the `group.yml` files.

* All the above [YAML](#yaml) rules apply
* A group should only contain rules that effect the same software or service

#### Group Sections

Group sections must be in the following order, if present.

* `documentation_complete`
* `title`
    * Must be in [Title case](https://en.wikipedia.org/wiki/Title_case)
* `platforms`
* `description` (HTML-Like)

### Benchmark

This section describes the style guide around the `benchmark.yml` files.
All the above [YAML](#yaml) rules apply.

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

These rules apply to the files in `controls/`.
All the above [YAML](#yaml) rules apply.

#### Control Sections

Control sections must be in the following order, if they are present.

* `policy`
* `title`
    * Must be in [Title case](https://en.wikipedia.org/wiki/Title_case)
* `id`
    * Must be short
    * Must be lowercase
    * If product-specific should be in the format `standard_product`. For example, CIS on RHEL8 would be `cis_rhel8`
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
        * Must be a list of valid rule ids
    * `related_rules`
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

The `platform` key should first list specific products, then list the `multi_platform`.
Products and `multi_platform` shall be placed in alphabetical order.
For example, Oracle Linux 9, Red Hat Enterprise Linux 9, multi_platform_fedora.

#### `reboot`

Must be true or false.
Shall be true if the system needs to be rebooted in order for the changes to take effect.

#### `strategy`

Shall be one of the following values:

* configure
* combination
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

* Shall follow all the rules in the [YAML](#yaml) section
* Shall use fully-qualified collection names [(FQCN)](https://ansible-lint.readthedocs.io/rules/fqcn/). e.g. use `ansible.builtin.lineinfile:` instead of only `lineinfile:`
* Shall use specific Ansible modules whenever possible instead of just calling system commands with `command`, `shell` or `raw` modules
    * When no specific Ansible module is available, `command` module shall be used instead of `shell` or `raw` modules when the `command` module is sufficient.
* Shall define short and objective task names that reflect the end state of a machine
* Task names must be in [Title case](https://en.wikipedia.org/wiki/Title_case)
* Task names shall be prefixed by `{{{ rule_title }}}`, e.g. `- name: "{{{ rule_title }}} - Ensure Correct Banner"`
* Shall use [Native YAML Syntax](https://www.ansible.com/blog/ansible-best-practices-essentials) instead of `key=value` pairs shorthand. e.g.:

Use:
```yaml
- name: "{{{ rule_title }}} - Ensure httpd Service is Started"
  ansible.builtin.service:
    name: httpd
    state: started
    enabled: yes
```
Instead of:
```yaml
- name: "{{{ rule_title }}} - Ensure httpd Service is Started"
  ansible.builtin.service: name=httpd state=started enabled=yes
```
* Shall be written to pass [ansible-lint](https://github.com/ansible-community/ansible-lint)
* Shall use `true` for booleans values instead `True`, `yes` or `1`
* Shall use `false` for booleans values instead `False`, `no` or `0`
* Consider to use explicit parameters when reasonable in order to improve readability
    * While the default values for some modules are more intuitive, others are less used and hard to remember. In these cases, the reader will need to consult the current documentation to check the default values in order to better understand the task.

### Bash

* Should use Jinja macros instead of shared functions
* Must use 4-space indentation
* Shall put `do` or `then` on the same line as `for` or `if` respectively, e.g. `for file in *; do`

### GitHub Actions
* Shall follow all the rules in the [YAML](#yaml) section, expect the following:
  * Existing files may use the `.yaml` prefix
* Job names should be in [Title case](https://en.wikipedia.org/wiki/Title_case)
* Shall use explicit version numbers for actions
  * Updates are handled on a weekly basis by [Dependabot](https://github.com/ComplianceAsCode/content/network/updates)

### Kubernetes

* Shall follow all the rules in the [YAML](#yaml) section

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
                * Should be defined by the `oval_metadata' macro
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

* Must follow all the rules in the [Bash](#bash) section

## CMake

* Shall use 4-space indentation
* Shall use lower case for commands
* Shall use commands, including `if` etc., without extra spaces before or after `(` and `)` (Eg. `command(<args>)`
* `endif`, `endforeach`, and similar commands shall not have any arguments
* Shall keep flowing `)` at same indentation as starting clause
* Shall use no more than 2 empty lines (e.g. 1 empty to mark part and 2 empty to mark sections)
* Shall be written to pass [CMakeLint](https://pypi.org/project/cmakelint/)

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
