How to perform a semi-automatic release
=======================================

The scripts in this folder automate some processes of the release.

Dependencies
------------

-   System with `python3.6` or greater

-   Make sure the following python packages are installed:

    -   [PyGithub](https://pygithub.readthedocs.io/en/latest/index.html)

    -   [Python
        Jenkins](https://python-jenkins.readthedocs.io/en/latest/index.html)

    -   [GitPython](https://gitpython.readthedocs.io/en/stable/index.html)

On fedora:
`dnf install python3-pygithub python3-jenkins python3-GitPython`

Authentication Tokens
---------------------

The scripts interact with Jenkins and GitHub, so you’ll need to setup
authentication tokens for these services.

-   A GitHub token - get one on <https://github.com/settings/tokens>,
    `repo` scope is enough.

-   Your Jenkins user - your User ID is probably the same as your GitHub
    handle, to be sure, check your **profile page** in Jenkins.

-   A Jenkins token - generate a token on **Configure page** in Jenkins

-   Create `.env.yml` file in `release_tools` directory, to hold your
    tokens:

        github_token: '<your github token here>'
        jenkins_user: '<you jenkins user ID>'
        jenkins_token: '<you jenkins token here>'

Your Jenkins user needs to have a special permission to perform the
build successfully. This permission is not granted automatically to all
users. If you want to perform build and you don’t have this permission,
please contact one of [trusted
developers](https://github.com/orgs/ComplianceAsCode/teams/trusted-developers).

> **Note**
>
> You can also use your own fork of the project to test and debug the
> release tools, define in `.env` file the owner and name of the repo to
> use.
>
>     owner: "--owner <owner of repo>" # your github user name
>     repo: "--repo <name of repo>"    # your clone's repo name

Before the release
------------------

-   Make sure that the `build` directory is empty

-   Make sure the version in `CMakeLists.txt` is correct, i.e.: the
    version corresponds to an unreleased version number.

-   Run `PYTHONPATH=. utils/generate_contributors.py` to update the
    contributors list.

    Make a commit and PR it. \* Make sure you don’t have any uncommited
    changes, otherwise they may be lost during the release. \* Make sure
    you have the `master` and `stabilization-v{version}` branch checked
    out and up to date.

Check Phase
-----------

Let’s do some pre-flight checks:

-   Run `python3 release_content.py check`.

The script will verify the status of a few Jenkins jobs:

-   [Build](https://jenkins.complianceascode.io/job/scap-security-guide/)

-   [linkcheck](https://jenkins.complianceascode.io/job/scap-security-guide-linkchecker/)

-   [lint-check](https://jenkins.complianceascode.io/job/scap-security-guide-lint-checker/)

-   [SCAPVal
    1.2](https://jenkins.complianceascode.io/job/scap-security-guide-scapval-scap-1.2/)

-   [SCAPVal
    1.3](https://jenkins.complianceascode.io/job/scap-security-guide-scapval-scap-1.3/)

-   [Nightly
    zip](https://jenkins.complianceascode.io/job/scap-security-guide-nightly-zip/)

-   [Nightly OVAl 5.10
    zip](https://jenkins.complianceascode.io/job/scap-security-guide-nightly-oval510-zip/)

Although these jobs probably have run against `master`, they are a good
indicator of problems in the project.

The script also builds RHEL7 content to check for missing STIG IDs in
STIG profiles.
**Review the status** of missing STIG IDs `rhel7-stig-ids.log` files,
fix if necessary.
If everything seems fine, continue to build phase.

Build Phase
-----------

Everything necessary for the release is built in Jenkins:

-   Run `python3 release_content.py build`.

    It will trigger build of the zipfile, docs and tarball in Jenkins.
    You can run `python3 release_content.py build` again to check status
    of the jobs.
    NOTE: As of July-20th 2019, it takes about 44 minutes for all the
    builds finish.

While Jenkins performs the builds you can generate and review the
release notes:

-   Run `python3 release_content.py release_notes`

Format of the release notes are as follows:
At the top Highlighted PRs will be listed, followed by list of product’s
profiles that changed since last release.
Followed by a list of *relevant* changes, genereated from the Pull
Requests mereged in this release.
Not all PRs have an entry to avoid over cluttering. To determine the
*relevant* PRs a few heuristics are applied:

-   If a Profile file (`.profile`) was changed, it will be listed under
    Profiles section;

-   But if a Rule file (`rule.yml`) was changed, it will be listed under
    Rules section instead;

-   If neither a Profile nor Rule file was changed, but there were
    changes to any test, it will be listed under Tests section;

A file named `release-notes.txt` will contain the notes, **review the
file** and make changes if necessary.

Release
-------

After Jenkins builds have finished, release notes were generated and
reviewed. We move on to creating the release entry in GitHub:

-   Run `python3 release_content.py release`

    It will create the next milestone (if it doens’t exist yet), move
    any open issues and PRs from current
    milestone to next milesone, and close current release’s milestone.
    The assets from Jenkins builds and the release notes will be used to
    create the git release.
    **Review the Git Release** and publish it.

Clean up and bump version
-------------------------

-   Run `python3 release_content.py prep_next_release`

    It will cleanup the release process, meaning that local copy of the
    artifacts will be deleted, tracking of Jenkins builds are dropped.
    It will also create a `bump_version_{version}` branch and a "Bump
    version" commit for your convenience.
    **Make a PR out of the branch**.

Announce it
-----------

-   Announce on
    [scap-security-guide](https://lists.fedorahosted.org/admin/lists/scap-security-guide.lists.fedorahosted.org/)
    and
    [open-scap](https://www.redhat.com/mailman/listinfo/open-scap-list)
    mailing lists.

-   Announce on twitter via [@OpenSCAP](https://twitter.com/openscap)

Fedora builds
-------------

-   Submit Fedora updates, check:

-   the [Package Maintenance
    Guide](https://fedoraproject.org/wiki/Package_maintenance_guide)

-   and [Package Update How
    To](https://fedoraproject.org/wiki/Package_update_HOWTO)

Copr builds
-----------

-   Move to the directory where you did the latest Fedora build.

-   Copy `copr_epel8.patch`, `copr_epel7.patch` and `copr_epel6.patch`
    from the directory where this readme is placed into the directory
    where the spec file is.

-   For epel8, apply the patch with `patch -p1 < copr_epel8.patch` and
    rename the patched file appropriately.

-   Upload the new spec file into publicly visible folder in your
    `fedorapeople.org` space.

-   Patch and upload spec files for epel7 and epel6 in similar way as
    shown above.

-   Use your Fedora account and login into [COPR
    repo](https://copr.fedorainfracloud.org/coprs/openscapmaint/openscap-latest/).

-   Verify that you have build permissions through settings →
    permissions.

-   If you don’t have build permissions, you can ask for them directly
    from the interface. Wait for one of administrators to confirm.

-   Make new builds. Use URLs to spec files which you previously
    uploaded to your folder at fedorapeople.org. Use respective spec
    files for respective epels.
