How to Perform An Upstream Release (GitHub)
===========================================

Stabilization Phase
-------------------

It is a good practice to have a stabilization phase before the upstream release
is performed. During this period, the new stabilization branch is created. Only
bugfixes which are discovered during this stabilization period are cherry-picked
from the master branch into the stabilization branch. This reduces the risk of
bringing a sudden breaking change into the release.

The stabilization phase is typically two weeks long. To start the stabilization:

- Create a new branch called **stabilization**, if there is a leftover branch
  from the previous release the new one should replace it, we do not version
  stabilization and stable branches

- Create a new milestone for the next version

- Set milestone of opened pull requests to the new milestone

- Announce start of stabilization period through mailing list

During the stabilization:

- PRs containing bug fixes should be labeled with the **bugfix-stabilization** label
  so that they can be easily identified

- If a bug is fixed, cherry-pick the PR from the master branch into the
  stabilization branch

- Change the milestone for the cherry-picked PR to the milestone of upcoming
  release

- Label the PR with **backported-into-stabilization**


Before the Release
------------------

-   Make sure that the `build` directory is empty

-   Make sure the version in `CMakeLists.txt` is correct, i.e.: the
    version corresponds to an unreleased version number.

-   Run `PYTHONPATH=. utils/generate_contributors.py` to update the
    contributors list.

    Make a commit and PR it. \* Make sure you don’t have any uncommited
    changes, otherwise they may be lost during the release. \* Make sure
    you have the `master` and `stabilization` branch checked
    out and up to date.


Check Phase
-----------

There is a GitHub Action hooked up with **stabilization** branch which
would run a set of extensive tests on every push. Make sure that all these tests
are passing before moving on to the release process.


Build and Release Phase
-----------------------

Everything necessary for the release is built by the release GitHub Action,
which is triggered when a tag **v*.*.*** is pushed to the repository. This tag
should point to the **stabilization** branch that is ready to be released.

This action will also create a release draft with release notes automatically
generated. The way in which the action will categorize and break down changes is
controlled by the `.github/workflows/release-changelog.json` configuration file.

General rule is that Title Case PR labels would form the base of the changelog.


Release
-------

Create and push **vX.X.XX** tag to the GitHub repo. Wait for the release action
to finish. Check the release draft and update the release notes if necessary.
Publish the release.

In case there would be a need to start over don't forget to delete the release
draft before trying to push the tag again.


Clean Up and Bump Version
-------------------------

-   Run `python3 release_content.py move_milestone`

    It will create the next milestone (if it doesn’t exist yet), move
    any open issues and PRs from current milestone to the next milestone,
    and close current release’s milestone.

-   Run `python3 release_content.py prep_next_release`

    It will cleanup the release process, meaning that local copy of the
    artifacts will be deleted, tracking of Jenkins builds are dropped.
    It will also create a `bump_version_{version}` branch and a "Bump
    version" commit for your convenience. **Make a PR out of the branch**.

- delete the **stable** branch and rename the **stabilization** branch to **stable**


Announce It!
------------

-   Announce on
    [scap-security-guide](https://lists.fedorahosted.org/admin/lists/scap-security-guide.lists.fedorahosted.org/)
    and
    [open-scap](https://www.redhat.com/mailman/listinfo/open-scap-list)
    mailing lists.

-   Announce on twitter via [@OpenSCAP](https://twitter.com/openscap)


How to Perform A Downstream Build (Fedora, COPR)
================================================

Fedora Builds
-------------

-   Submit Fedora updates, check:

-   the [Package Maintenance
    Guide](https://fedoraproject.org/wiki/Package_maintenance_guide)

-   and [Package Update How
    To](https://fedoraproject.org/wiki/Package_update_HOWTO)


COPR Builds
-----------

-   Move to the directory where you did the latest Fedora build.

-   Copy `copr_epel8.patch` and `copr_epel7.patch` from the directory where this
    readme is placed into the directory where the spec file is.

-   For epel8, apply the patch with `patch -p1 < copr_epel8.patch` and
    rename the patched file appropriately.

-   Upload the new spec file into publicly visible folder in your
    `fedorapeople.org` space.

-   Patch and upload spec file for epel7 in similar way as shown above.

-   Use your Fedora account and login into [COPR
    repo](https://copr.fedorainfracloud.org/coprs/openscapmaint/openscap-latest/).

-   Verify that you have build permissions through settings →
    permissions.

-   If you don’t have build permissions, you can ask for them directly
    from the interface. Wait for one of administrators to confirm.

-   Make new builds. Use URLs to spec files which you previously
    uploaded to your folder at fedorapeople.org. Use respective spec
    files for respective epels.
