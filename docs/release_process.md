How to Perform An Upstream Release (GitHub)
===========================================

Stabilization Phase
-------------------

Before each release we initiate a stabilization period which is typically two weeks long.
A stabilization branch is branched from master and more extensive testing is done on the content.
The goal is to have space and time to find and fix issues before the release.
Everyone is welcome to test the stabilization branch and propose fixes.

This process reduces the risk of bringing a sudden breaking change into the release,
and ultimately allows the release process to happen while development continues on master branch.

To start the stabilization:

- Create a new branch called **stabilization-vX.Y.Z**, e.g.: stabilization-v0.1.61

- Create a new milestone for the next version

- Update the milestone of open pull requests to the new one, if they have any

- Update the milestone of open issues to the new one, if they have any

- Close the milestone for the current release.
  This makes the milestone less visible and reduces the chance of PRs and Issues being added to it
  accidentally.
  It is still possible to add items to the closed Milestone, just select it in the `closed` tab.

- Bump the version of `CMakeLists.txt` on the **master** branch.

- Announce the start of stabilization period on the mailing list

During the stabilization:

- Run whatever extra tests you have and propose bug fixes to the **stabilization** branch
    - https://github.com/ComplianceAsCode/content/pulls?q=is%3Apr+head%3Astabilization+is%3Aopen

- Once the PR is merged in the **stabilization** branch, cherry-pick it to the **master** branch
    - This way it is prevented any possible conflicts which were encountered in the past when\
    porting fixes from the stabilization branch to the master branch.
    - This process was adopted since release 0.1.

Tests during Stabilization Phase
-----------

There is a GitHub Action hooked up with **stabilization** branch that will run a set of tests on every push.\
Make sure that all these tests are passing before moving on with the release process.

Before the Release
------------------

-   Make sure the version in `CMakeLists.txt` is correct, i.e.: the
    version corresponds to an unreleased version number.

-   Run `PYTHONPATH=. utils/generate_contributors.py` to update the
    contributors list. De-duplicate names if necessary.\
    Make a commit and PR it.
    * Make sure you don’t have any uncommitted changes, otherwise they may be lost during the release.
    * Make sure you have the `master` and `stabilization` branch checked out and up to date.

Release
-------

Everything necessary for the release is built by the release GitHub Action,
which is triggered when a tag **v\*.\*.\*** is pushed to the repository. This tag
should point to the **stabilization** branch that is ready to be released.

This action will also create a release draft with release notes automatically
generated. The way in which the action will categorize and break down changes is
controlled by the `.github/workflows/release-changelog.json` configuration file.

The general rule is that the PR Titles will compose the body of the changelog.


- Create and push a **vX.Y.Z** tag to the GitHub repo. Wait for the release action
to finish.\
  `git tag vX.Y.Z stabilization-vX.Y.Z`\
  `git push --tags`

- Check the release draft and update the release notes if necessary.

- Publish the release.

In case there is a need to run the job again, delete the release
draft and run the GitHb Action again.


Clean Up
-------------------------

- Update the **stable** branch to point to the new release:\
 `git checkout stable`\
 `git merge stabilization-vX.Y.Z`

- Delete the **stabilization** branch.

Announce It!
------------

-   Announce on
    [scap-security-guide](https://lists.fedorahosted.org/admin/lists/scap-security-guide.lists.fedorahosted.org/)
    and
    [open-scap](https://www.redhat.com/mailman/listinfo/open-scap-list)
    mailing lists.

-   Announce on twitter via [@OpenSCAP](https://twitter.com/openscap)


How to Perform A Downstream Build (Fedora)
================================================

Fedora Builds
-------------

-   Submit Fedora updates, check:

-   the [Package Maintenance
    Guide](https://fedoraproject.org/wiki/Package_maintenance_guide)

-   and [Package Update How
    To](https://fedoraproject.org/wiki/Package_update_HOWTO)
