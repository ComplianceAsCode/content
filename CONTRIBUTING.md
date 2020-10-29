ComplianceAsCode Contribution Guidelines
===

We're so glad you're thinking about contributing to ComplianceAsCode! If you're unsure about anything, just ask -- or submit the issue or pull request to start the conversation! The worst that could happen is you'll politely be asked to change something.

We want to ensure a welcoming environment for all members of the ComplianceAsCode community. Reading the projects CONTRIBUTING policy (you are here), its [LICENSE](https://github.com/ComplianceAsCode/content/blob/master/LICENSE), and its [README](https://github.com/ComplianceAsCode/content/blob/master/README.md), will help you get calibrated.

This project is a public-private partnership with the United States Government as part of its [open source initiatives](https://code.nsa.gov/). The project has welcomed contributions from across the United States Government, private industry, and countries worldwide. Currently, there are four project maintainers who are accountable to ensure a welcoming community and our code of conduct is followed. Should you ever need, please feel free to reach out directly!

- @shawndwells (Shawn Wells // CrowdStrike // shawn.wells@crowdstrike.com)
- @redhatrises  (Gabe Alford // Red Hat // galford@redhat.com)
- @jeffblank (Jeff Blank // U.S. Department of Defense // jeffrey.d.blank@ugov.gov)
- @carlosmmatos (Carlos Matos // Red Hat // cmatos@redhat.com)

Issues and Pull Requests
---

Two-party review is needed for merging pull requests. This second set of eyes helps review the code for functionality and style, and helps create a shared understanding of why certain things are merged (or not!). Therefore, pull requests can’t be merged by the author, with one exception: typo fixes and small changes to textual data (only if it would not shift the meaning of the text). If one of reviewers raises material objections to the pull request, those objections should be addressed before the merge.

- Ideally pull request feedback would be addressed within 30 days. This helps us move the project forward and helps prevent the need for major rebasing of pull requests. Everyone goes on vacation or has reasons this won't always be possible. If that's the case, please let us know in the pull request to avoid it being closed for no response. Even if your pull request is closed, worst case you'll need to re-open it upon your return (no code will be lost!). If a pull request is inactive for no apparent reason for a prolonged period of time, a "30 days until we close it" warning would be placed as a comment to emphasis its stalled state.

Pull requests may be closed immediately only if the change would render the build system, a profile, or a tool broken, and, at the same time, there is no way to improve the PR. Justification and an extensive explanation (or a link to a previous case of such a change) should always be provided as a part of the feedback.

Pull requests should pass continuous integration tests. If the CI run ends with an error, the merge can only be approved by an independent reviewer who has the knowledge of the CI. A waiver justification message is required to be a part of the PR.

Both issues and pull requests should contain a description that clarifies the matter to a degree that a regular contributor can understand it. They should describe problems (and possible solutions) for the whole community to acknowledge and act upon.

It is always better to create a set of small self-contained pull requests rather than a single massive PR, if possible. And if a pull request consists of a sequence of well-defined steps, it is advisable to keep the *one step = one commit* approach.

Avoid merge commits in pull requests - use *git rebase* to get rid of them.

Contributing Content
---

Changes related to one product or profile shouldn’t change behavior for other products or profiles.

Prevent duplication of code. Use Jinja macros and [check (remediation) templates](/docs/manual/developer_guide.adoc#732-list-of-available-templates). Follow the indentation style. For Python code, follow [PEP8](https://www.python.org/dev/peps/pep-0008/). [Developer Guide](/docs/manual/developer_guide.adoc) is your friend.

Enjoy!
