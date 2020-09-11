ComplianceAsCode Contribution Guidelines
===

We aim to create a welcoming environment for all contributors regardless of their age, gender, experience, nationality, or employer. However, to foster smooth collaboration we are asking contributors to adhere to the following rules.

Issues and Pull Requests
---

Pull requests can’t be merged by the author, a review from another person is needed. If anybody raises material objections to the pull request, those objections should be addressed before the PR merge.

If a pull request has received feedback from reviewers, and the original author hasn’t touched it for more than 14 days, the PR may be closed (it is still possible to re-open it if the author catches up later).

Pull requests may be closed immediately only if the change would render the build system, a profile, or a tool broken, and, at the same time, there is no way to improve the PR. Justification and an extensive explanation (or a link to a previous case of such a change) should always be provided as a part of the feedback.

Pull requests should pass continuous integration tests. If the CI run ends with an error, the merge can only be approved by an independent reviewer who has the knowledge of the CI. A waiver justification message is required to be a part of the PR.

Both issues and pull requests should contain a description that clarifies the matter to a degree that a regular contributor can understand it. Issues and PRs are not a personal TODO list, they are problems and solutions descriptions for the whole community to acknowledge and act upon.

It is always better to create a set of small self-contained pull requests rather than a single massive PR, if possible. And if a pull request consists of a sequence of well-defined steps, it is advisable to keep the *one step = one commit* approach.

Avoid merge commits in pull requests - use *git rebase* to get rid of them.

Contributing Content
---

Changes related to one distribution or profile shouldn’t change behavior for other distributions or profiles.

Prevent duplication of code. Use Jinja macros and [check (remediation) templates](/docs/manual/developer_guide.adoc#732-list-of-available-templates). Follow the indentation style. For Python code, follow PEP8. [Developer Guide](/docs/manual/developer_guide.adoc) is your friend.

Enjoy!
