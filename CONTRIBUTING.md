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
- @redhatrises  (Gabe Alford // Red Hat // galford@redhat.com)
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

Changes related to one product or profile shouldn’t change behavior for other products or profiles.

Prevent duplication of code. Use Jinja macros and [check (remediation) templates](/docs/manual/developer_guide.adoc#732-list-of-available-templates). Follow the indentation style. For Python code, follow [PEP8](https://www.python.org/dev/peps/pep-0008/). [Developer Guide](/docs/manual/developer_guide.adoc) is your friend.

Enjoy!
