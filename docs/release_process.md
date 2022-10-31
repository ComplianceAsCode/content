How to Perform An Upstream Release (GitHub)
===========================================

# Stabilization Phase

Before each release we initiate a stabilization period which is typically two weeks long.
A stabilization branch is branched from master and more extensive testing is done on the content.
The goal is to have space and time to find and fix issues before the release.
Everyone is welcome to test the stabilization branch and propose fixes.

This process reduces the risk of bringing a sudden breaking change into the release,
and ultimately allows the release process to happen while development continues on master branch.

## Preparing the stabilization

### Updating Contributors List

- Update the contributors list by accessing the root folder of Content repository, in the
**stabilization** branch, and executing the following command:
    ```
    PYTHONPATH=. utils/generate_contributors.py`
    ```
    - De-duplicate names if necessary.
    - Make a commit send the a PR.
    - Reference: https://github.com/ComplianceAsCode/content/pull/9601

### Creating the Stabilization Branch

- Create a new branch called **stabilization-vX.Y.Z** where **X.Y.Z** is the version of upstream
release to be created.
    - For example, if the last released version was **0.1.64**, the branch should be named as
    `stabilization-v0.1.65`

### Creating the New Milestone

- Create a new Milestone called **X.Y.Z**, where **X.Y.Z** is the version of future upstream release.
    - For example, if you have just created the `stabilization-v0.1.65` branch in order to start
    the stabilization phase for **0.1.65**, the new Milestone should be `0.1.66`.

### Updating Open PRs and Issues

- All **Pull Requests** and **Issues** which are open at the moment the stabilization branch is
created can only be part of a future release, through another stabilization branch that will likely
be created in about 2 months. Therefore, if they have a Milestone defined, they must be updated to
the new Milestone.
    - For example, when the `stabilization-v0.1.65` is created, all open Pull Requests and Issues
    with the Milestone `0.1.65` should be updated to the Milestone `0.1.66`.
<!-- -->
- All Issues which are open at the moment the stabilization branch was created can only be part of
a future release, through another stabilization branch that will likely be created in about 2
months. Therefore, like Pull Requests, if they have a Milestone defined, the
Milestone must be updated to refer the next release.
<!-- -->
- Close the **Milestone** related to the current stabilization phase.
    - For example, if the Milestone `0.1.66` was just created, the Milestone `0.1.65` should be closed.
    - This makes the Milestone less visible and reduces the chance of PRs and Issues being
    accidentally added to it.
    _NOTE: It is still possible to add items to the closed Milestone. Just select it in the `closed` tab._

### Bumping the Version

- Open a PR to bump the version of `CMakeLists.txt` on the **master** branch.
    - For example, when the `stabilization-v0.1.65` is created, the line `set(SSG_PATCH_VERSION 65)`
    must be updated to `set(SSG_PATCH_VERSION 66)` in the `CMakeLists.txt` file
    - Reference: https://github.com/ComplianceAsCode/content/pull/9600

### Announcing the Start of Stabilization Period

- Announce the start of stabilization period on the following communication channels:
    - Gitter
        - https://gitter.im/Compliance-As-Code-The/content
    - SCAP Security Guide Mail List
        - scap-security-guide@lists.fedorahosted.org
    - Github Discussion
        - https://github.com/ComplianceAsCode/content/discussions/new?category=announcements
    - Here is an example message that could be used as reference:
    ```
    Subject: stabilization of v0.1.65

    Hello all,

    The release of Content version 0.1.65 is scheduled for December 2nd.
    As part of the release process, a stabilization branch was created.
    Issues and PRs that were not solved were moved to the 0.1.66 milestone.

    Any bug fixes you would like to include in release 0.1.65 should be proposed
    for the *stabilization-v0.1.65* and *master* branches as a measure to avoid
    potential conflicts between these branches.

    The next version, 0.1.66, is scheduled to be released on February 3rd,
    with the stabilization phase starting on January 23th, 2022.

    Regards,
    ```

## During the stabilization

### Bug Fixes
- Run whatever extra tests you have and report bugs as Upstream issues using the
[General Issue](https://github.com/ComplianceAsCode/content/issues/new?assignees=&labels=&template=general_issue.md) template.
- Propose bug fixes by targeting PRs to the **stabilization** branch. e.g. `stabilization-v0.1.65`
  - Once the PR is **merged** in the **stabilization** branch, make a PR with the same fix to the **master** branch.

  _NOTE: There are different ways how to port commits from one branch to another._
  _Below are listed a few approaches how to do it._

  - Cherry pick individually each of the fixing commits from one branch to another:
    For example:
    ```
    git checkout master
    git pull upstream master
    git checkout -b my_fix_in_master
    git cherry-pick abcd1234
    ...
    # Push my_fix_in_master and create the PR
    ```

  - To quickly move multiple commits from one branch to another:
    ```
    # Assuming that my_fix is the branch containing the fix for the **stabilization** branch
    git fetch upstream master:master
    git checkout my_fix
    base_my_fix=$(git merge-base master my_fix)
    git rebase --onto master $base_my_fix HEAD
    git checkout -b my_fix_in_master
    # Push my_fix_in_master and create the PR
    ```

  - Alternatively, you can create a fix branch that can be used to create both PRs.
    The branch needs to be created from the merge base of **master** and **stabilization**.
    This approach only works if the relevant files did not diverge in a way that causes conflicts.
    Example commands:
    ```
    stab_base=$(git merge-base master stabilization-v0.1.65)
    git checkout -b my_fix $stab_base
    # Do the fix, commit, push and create two PRs through the Github Web Interface.
    # One PR should targeting **master** and the other targeting the **stabilization** branch.
    ```

_Historic note_:
In the past, to ensure that all fixes pushed to the stabilization branch were also included in the
master branch, every Friday during the stabilization phase, a PR was created to merge the
stabilization changes into the master branch. However, this approach was prone to conflicts that
could be complex to be solved after one week of asynchronous contributions on master branch.
Therefore, since the `0.1.63` release, a simpler and more reliable process has been adopted where
the authors themselves ensure that the fixes are merged into each branch at almost the same time.
This reduces the risk of conflicts and also makes it easier for authors to resolve them as the
changes are still "fresh".

### Tests

There is a GitHub Action hooked up with **stabilization** branch that will run a set of tests on
every push.
Make sure that all these tests are passing before moving on with the release process.

# Release

## Checklist

- Double check the version in `CMakeLists.txt` is correct.
    - The version should correspond to an unreleased version number.
- Make sure the relevant labels are defined in the `.github/workflows/release-changelog.json`
configuration file.

## Triggering the Release Process

Everything necessary for the release is built by the release GitHub Action,
which is triggered when a tag **v\*.\*.\*** is pushed to the repository. This tag
should point to the **stabilization** branch that is ready to be released.

This action will also create a release draft with release notes automatically
generated. The way in which the action will categorize and break down changes is
controlled by the `.github/workflows/release-changelog.json` configuration file.

The general rule is that the PR Titles will compose the body of the changelog.

### Tagging

- Create and push a **vX.Y.Z** tag to the GitHub repo.
```
git tag vX.Y.Z stabilization-vX.Y.Z
git push --tags
```
- Wait for the release action to finish.
- Check the release draft and update the release notes if necessary.

- Publish the release.

_NOTE: In case there is a need to run the job again, delete the release
draft and run the GitHb Action again._

# Clean Up

- Update the **stable** branch to point to the new release:
```
git checkout stable
git merge stabilization-vX.Y.Z
```
- Make sure any conflicts are solved.

- Delete the **stabilization** branch.

# Announce It!

- Announce the new release on the following communication channels:
    - Gitter
        - https://gitter.im/Compliance-As-Code-The/content
    - SCAP Security Guide and OpenSCAP Mail Lists
        - scap-security-guide@lists.fedorahosted.org
        - open-scap-list@redhat.com
    - Github Discussion
        - https://github.com/ComplianceAsCode/content/discussions/new?category=announcements
    - Twitter
        - https://twitter.com/openscap
    - Here is an example message that could be used as reference:
    ```
    Subject: ComplianceAsCode/content v0.1.65

    Hello all,

    ComplianceAsCode/Content v0.1.65 is out.

    Some of the highlights of this release are:
        * Introduce ol9 stig profile (#9207)
        * Introduce Ol9 anssi profiles (#9243)
        * Update RHEL8 STIG to V1R7 (#9276)
        * Introduce e8 profile for OL9 (#9284)
        * Update RHEL7 STIG to V3R8 (#9317)

    Welcome to the new contributor:
        * contributor1
        * contributor2

    For full release notes, please have a look at:
    https://github.com/ComplianceAsCode/content/releases/tag/v0.1.65

    Zip archive with pre-built content:
    https://github.com/ComplianceAsCode/content/releases/download/v0.1.65/scap-security-guide-0.1.65.zip
    SHA-512 hash: e6f8f9440562799120ae7425d68c9bd9975557b05c64e7c6851fdf60946876c3fe26e7353f48f096ca4a5c14164e857cd36fdaeb7c2f44b371fafddff33d7dfd

    Source tarball:
    https://github.com/ComplianceAsCode/content/releases/download/v0.1.65/scap-security-guide-0.1.65.tar.bz2
    SHA-512 hash: fc295bafdac8a3fafbcd1bff50b7043a11de23e1a363883a7fac11d3734e9d381dad2e180cc14c259e34fa4eea8b0c27720a8df455d509be3c97913f51294850

    Thank you to everyone who contributed!

    Regards,
    ```

# Downstream Build (Fedora)

## Fedora Builds

To submit Fedora updates, check:
- [Package Maintenance Guide](https://fedoraproject.org/wiki/Package_maintenance_guide)

- [Package Update How To](https://fedoraproject.org/wiki/Package_update_HOWTO)
