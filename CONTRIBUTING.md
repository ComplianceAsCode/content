ComplianceAsCode Contribution Guidelines
===

We're so glad you're thinking about contributing to ComplianceAsCode! If you're unsure about
anything, just ask -- or submit the issue or pull request to start the conversation! The worst that
could happen is you'll politely be asked to change something.

We want to ensure a welcoming environment for all members of the ComplianceAsCode community.
Reading the projects CONTRIBUTING policy (you are here), its
[LICENSE](https://github.com/ComplianceAsCode/content/blob/master/LICENSE), and its
[README](https://github.com/ComplianceAsCode/content/blob/master/README.md), will help you get
calibrated.

This project is a public-private partnership with the United States Government as part of its
[open source initiatives](https://code.nsa.gov/). The project has welcomed contributions from
across the United States Government, private industry, and countries worldwide. Currently, there
are four project maintainers who are accountable to ensure a welcoming community and our code of
conduct is followed. Should you ever need, please feel free to reach out directly!

- @shawndwells (Shawn Wells // CrowdStrike // shawn.wells@crowdstrike.com)
- @redhatrises  (Gabe Alford // CrowdStrike // gabriel.alford@crowdstrike.com)
- @jeffblank (Jeff Blank // U.S. Department of Defense // jeffrey.d.blank@ugov.gov)
- @carlosmmatos (Carlos Matos // Red Hat // cmatos@redhat.com)

These maintainers are ultimately held responsible for ensuring that the commits and contributions
meet the standards, expectations, and if applicable, laws of the public-private partnership.

Issues
---
When creating an issue, please be detailed as possible without writing an essay! This makes the
issue actionable. Ideally, issues with small tasks should be created to help others understand what
needs to be accomplished.

Pull Requests
---

Two-party review is needed for merging pull requests. This second set of eyes helps review the code
for functionality and style, and helps create a shared understanding of why certain things are
merged (or not!). Therefore, pull requests should not be merged by the author, with one exception:
typo fixes and small changes to textual data (only if it would not shift the meaning of the text).
If one of reviewers raises material objections to the pull request, those objections should be
addressed before the merge.

Ideally, pull request feedback should be addressed within 30 days. This helps us move the project
forward and helps prevent the need for major rebasing of pull requests. If you are unable to work
through the feedback within the 30 days, please let us know in the pull request to avoid it being
closed for no response. Even if your pull request is closed, worst case you'll need to re-open it
upon your return (no code will be lost!).

Pull requests may be closed by a reviewer or maintainer for some of the following reasons:
 - The change would render the build system, a profile, or a tool broken.
 - The change is out-of-scope for the project.
 - The change does not meet the expectations of the public-private partnership.
 - There is no way to improve the pull request.
Please provide some justification and an explanation as part of the feedback.

As in any project, pull requests should pass continuous integration tests before merging. There are
times when the continuous integration tests may error or fail. In this case, a reviewer can merge
the pull requests if they deem the failure unrelated to the pull request itself. Additionally,
there are certain types of pull requests (like changing `README.md`) that the continuous
integration tests do not evaluate that a reviewer might merge regardless of continuous integration
test status. In any case, generally most reviewers wait until everything passes before merging.

If possible, please create a set of small self-contained pull requests rather than a single
massive pull request. If a pull request consists of a sequence of well-defined steps, the best
approach is to keep the *one step = one commit* approach.

Avoid merge commits in pull requests - use *git rebase* to get rid of them. This helps us keep git
tree clean and helps to make it easy to understand historical changes done in past commits.

Contributing Content
---

If you are considering contributing content to the project, thank you for your willingness to do so.
There are some guidelines and rules to consider when you are contributing content:

1. There should only be 1 configuration change per XCCDF rule. This is to not only help us meet U.S. Government expectations, but it makes our content easier to use and tweak for the end users.
1. Create variables when a configuration change can be multiple different values. For example if a rule says to "create a 16 character password", create a variable that by default is set to 16 and add other possible password lengths. This is not just to make the content more usable, but not everyone's computing environments require a 16 character password.
1. It is always better to fix an issue in external upstream open source projects before contributing, fixing, or breaking content here. For example if the `gdm` rpm reports changed permissions when the `rpm_verify_permissions` rule runs, the fix needs to be provided in the `gdm` rpm not by changing or disabling the content. Another example of this is adding a configuration option like to `pam_faillock` and `pam_pwquality` to make it easy for centralized accounts to ignore local settings which may be governed by the centralized account management tool. Once the patches are merged in the upstream project, you should then open a new pull request in this project with the changes. Following this approach not only ensures that it is easier for others to securely configure their systems, but it makes other upstream projects better and easier to use.
1. Ask before you disable or remove content because you feel that they are not security relevant. They might actaully be security relevant in ways that you might not realize. This way we all learn something.
1. Products or content that have been previously retired should stay retired unless there is a heavy commitment to support that content.
1. While this is an open source project, contributing content from projects (e.g. Webmin) that have been taken over by a hacker is a no-go. Not only can you or the project not guarantee that that project is truly cleaned up, but doing so diminishes the trust and provenance of this project.
1. Both DISA and NSA have said CentOS does not meet the expectations of U.S. Government security requirements. Therefore, there are no government profiles for CentOS, and they are not supported by this project whether through developement or contributions. This clearly angers some, but good cyber practices and compliance are practiced and expected by this project.
1. Changes related to one product or profile shouldn’t change behavior for other products or profiles unless the nature of the change affects multiple products or profiles.
1. If you are able and have time, prevent duplication of code. Use Jinja macros and [check (remediation) templates](/docs/manual/developer_guide.adoc#732-list-of-available-templates).
1. When developing Python scripts, follow the indentation style. For Python code, follow [PEP8](https://www.python.org/dev/peps/pep-0008/).

And as always, you can view the docs at [https://complianceascode.readthedocs.io/](https://complianceascode.readthedocs.io/),
or if you do not have internet access, the docs can be viewed at [Developer Guide](/docs/manual/developer_guide.adoc).

Enjoy!
