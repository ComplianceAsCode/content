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

- Update the contributors list before creating the new **stabilization-vX.Y.Z** branch. So, make
sure there is enough time to review and merge the PR before starting the **stabilization** phase.
- Update the contributors list by accessing the root folder of `content` repository and executing
the following command:
    ```
    PYTHONPATH=. utils/generate_contributors.py
    ```
    - De-duplicate names if necessary.
    - Make a commit send a PR to the `master` branch.
    - Reference: https://github.com/ComplianceAsCode/content/pull/9843

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
> **_NOTE:_** It is still possible to add items to the closed Milestone. Just select it in the
`closed` tab.

### Bumping the Version

- Open a PR to bump the version of `CMakeLists.txt` on the **master** branch.
    - For example, when the `stabilization-v0.1.65` is created, the line `set(SSG_PATCH_VERSION 65)`
    must be updated to `set(SSG_PATCH_VERSION 66)` in the `CMakeLists.txt` file
    - Reference: https://github.com/ComplianceAsCode/content/pull/9857

### Announcing the Start of Stabilization Period

- Announce the start of stabilization period on the following communication channels:
    - Gitter
        - https://gitter.im/Compliance-As-Code-The/content
    - SCAP Security Guide Mail List
        - scap-security-guide@lists.fedorahosted.org
    - Github Discussion
        - https://github.com/ComplianceAsCode/content/discussions/new?category=announcements
        - Reference: https://github.com/ComplianceAsCode/content/discussions/9859
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
- Propose bug fixes by targeting PRs to the **stabilization-vX.Y.Z** branch.
e.g.: `stabilization-v0.1.65`
  - For easier identification, it is a good practice to prefix PRs for the
  **stabilization-vX.Y.Z** branch by `Stabilization: `.
      - Reference: https://github.com/ComplianceAsCode/content/pull/9877
  - Once the PR is **merged** in the **stabilization-vX.Y.Z** branch, make a PR with the same fix
  to the **master** branch.

> **_NOTE:_** There are different ways how to port commits from one branch to another.
Below are listed a few approaches how to do it.

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
    The branch needs to be created from the merge base of **master** and
    **stabilization-vX.Y.Z** branches.
    This approach only works if the relevant files did not diverge in a way that causes conflicts.
    Example commands:
    ```
    stab_base=$(git merge-base master stabilization-v0.1.65)
    git checkout -b my_fix $stab_base
    # Do the fix, commit, push and create two PRs through the Github Web Interface.
    # One PR should targeting **master** and the other targeting the **stabilization** branch.
    ```

> **_NOTE:_** In the past, to ensure that all fixes pushed to the stabilization branch were also
included in the master branch, every Friday during the stabilization phase, a PR was created to
merge the stabilization changes into the master branch. However, this approach was prone to
conflicts that could be complex to be solved after one week of asynchronous contributions on
master branch. Therefore, since the `0.1.63` release, a simpler and more reliable process has been
adopted where the authors themselves ensure that the fixes are merged into each branch at almost
the same time. This reduces the risk of conflicts and also makes it easier for authors to resolve
them as the changes are still "fresh".

### Tests

There is a GitHub Action hooked up with **stabilization-vX.Y.Z** branch that will run a set of
tests on every push.
Make sure that all these tests are passing before moving on with the release process.

# Release

## Checklist

- Double check the version in `CMakeLists.txt` is correct.
    - https://github.com/ComplianceAsCode/content/blob/036e790b9160ebe253e8069732f53363edbb2452/CMakeLists.txt#L35
    - The version should correspond to an unreleased version number.
- Make sure the relevant labels are defined in the `.github/workflows/release-changelog.json`
configuration file.
    - https://github.com/ComplianceAsCode/content/blob/master/.github/workflows/release-changelog.json

## Triggering the Release Process

Everything necessary for the release is built by the release GitHub Action, which is triggered
when a tag **v\*.\*.\*** is pushed to the repository. This tag should point to the
**stabilization-vX.Y.Z** branch that is ready to be released.

This action will also create a release draft with release notes automatically generated.
The way in which the action will categorize and break down changes is controlled by the
`.github/workflows/release-changelog.json` configuration file.

The general rule is that the PR Titles will compose the body of the changelog.

### Tagging

- Create and push a **vX.Y.Z** tag to the GitHub repo.
```
git tag vX.Y.Z stabilization-vX.Y.Z
git push --tags
```
- Wait for the release action to finish. You can follow the Workflow runs in this link:
    - https://github.com/ComplianceAsCode/content/actions/workflows/release.yaml
- Check the release draft and update the release notes if necessary.
    - https://github.com/ComplianceAsCode/content/releases

- Publish the release.

> **_NOTE:_** In case there is a need to run the job again, delete the release draft and run the
GitHb Action again.

# Clean Up

- Update the **stable** branch to point to the new release:
```
git checkout stable
git merge stabilization-vX.Y.Z
```
- Make sure any conflicts are solved.
- Push the changes:
```
git push
```

- Delete the **stabilization-vX.Y.Z** branch.
```
git push upstream --delete stabilization-vX.Y.Z
```

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

# Downstream Build

It is good for the community when the packages are also updated and released with the latest
stable release. In this section there is information about how to update the packages in specific
distros.
## Fedora

To update a Fedora package it is ultimately necessary to be approved as a Fedora Packager.
There are some ways to get this approval and more details are found here:
- [Joining the Package Maintainers](https://docs.fedoraproject.org/en-US/package-maintainers/Joining_the_Package_Maintainers/)

However, if you are not yet a Fedora Packager, it is still possible to propose updates.
In this case, a current maintainer will review it and guide the contributions to a good shape.

### Preparation
The first step to prepare an update is to be conscious about the [Fedora Package Guidelines](https://docs.fedoraproject.org/en-US/packaging-guidelines/).

> **_NOTE:_** Even if you are an experienced Fedora packager, it is recommended to review the
the Guidelines since some changes might be important for the package.

#### Install the required tools
```bash
sudo dnf install fedora-packager fedora-review
```
- Ensure your system user is included in the `mock` group. This is useful when testing the package
changes.
```bash
sudo usermod -a -G mock <username>
```

#### Get familiar with the tools
Most of the needed commands are well documented in the [Package Maintenance Guide](https://docs.fedoraproject.org/en-US/package-maintainers/Package_Maintenance_Guide).
- Please, check this guide if you are not an experienced Fedora Packager.
- If you are an experienced Fedora Packager, it is also recommended to quickly take a look in case
something new was included.

#### Get a token for authenticated commands
Make sure you have a valid kerberos token.
It will be necessary to upload the new source files later and the commands require authentication:
```bash
fkinit -u <your_fas_id>
```
> **_NOTE:_**  You need OTP configured in your Fedora account.

### Package Upadate
This section covers the usual updates in the `scap-security-guide.spec` file.

#### Fork the repository
You can skip this step if you already did it in the past. Otherwise:
- Create a fork from https://src.fedoraproject.org/rpms/scap-security-guide
    - It can be done via Web UI or using the following command:
```bash
fedpkg clone scap-security-guide
cd scap-security-guide
fedpkg fork
```
- If you forked it via Web UI, clone your fork using `fedpkg`. e.g.:
```
fedpkg clone --anonymous forks/<your fedora id>/rpms/scap-security-guide
cd scap-security-guide
```
More information about using `fedpkg` anonymously is found in [Fedora Package Tools](https://docs.fedoraproject.org/en-US/package-maintainers/Package_Maintenance_Guide/#using_fedpkg_anonymously).

It is preferred to update the `scap-security-guide.spec` file via PR instead of [committing directly](https://docs.fedoraproject.org/en-US/package-maintainers/Package_Maintenance_Guide/#typical_fedpkg_session),
even if you are the a maintainer of the `scap-security-guide` package.
This ensures that at least two maintainers are involved in the process and makes it much less
prone to human errors.

#### Update the spec file
Usually the changes are straightforward in the `scap-security-guide.spec` file.
It will be necessary to update the `Version:` line with the new version. e.g.:
```
Version:	0.1.65
```
This should be the only line to be changed in most cases. But your should review the file
completely and propose improvements if any opportunity is found. Updates regarding [Package Maintenance Guide](https://docs.fedoraproject.org/en-US/package-maintainers/Package_Maintenance_Guide)
or new features for `spec` files might be welcome.

Once the Version is updated and the `scap-security-guide.spec` file is reviewed, it is necessary
to append the `%changelog` section. For reference, this was included when the package was rebased
to `0.1.65`:
```
%changelog
* Tue Dec 06 2022 Marcus Burghardt <maburgha@redhat.com> - 0.1.65-1
- Update to latest upstream SCAP-Security-Guide-0.1.65 release:
  https://github.com/ComplianceAsCode/content/releases/tag/v0.1.65
```
These changes should be enough for most cases. Save the file and proceed to the next steps.

> **_HINT:_** You can use `rpmdev-bumpspec` command to automatically update the version and create
an initial `%changelog` entry. e.g.: `rpmdev-bumpspec -n 0.1.65 scap-security-guide.spec`

#### Update the source
When the `Version:` line is updated in the `scap-security-guide.spec` file, the `Source0` line is
also impacted.
- Ensure the sources are downloaded locally:
```bash
fedpkg sources
```
- Check the new sources and ensure they are correct.
- To ensure the `scratch build` doesn't fail due to an "Invalid Source", ensure the new sources
are uploaded to the [lookaside_cache](https://docs.fedoraproject.org/en-US/package-maintainers/Package_Maintenance_Guide/#_upload_new_source_files_to_the_lookaside_cache):
```bash
fedpkg new-sources
```
- This command will change the `source` and `.gitignore` files. Please, check the changes.

### Package Tests
- Check if the changes work as expected:
```bash
fedpkg mockbuild
fedpkg diff
fedpkg lint
```
> **_NOTE:_** Alternatively one can test the package build in Koji with `fekpkg scratch-build --srpm`.

- Check and fix whatever is necessary before proceeding to the next step.
- If you confirm everything is fine, create a new branch to use in the Pull Request:
```
git checkout -b release-0.1.65_rawhide
git status
git add -u
git commit
git push -u origin release-0.1.65_rawhide
```
- Continue the steps via src.fedoraproject.org web UI. Here is an example of a resulting PR:
    - https://src.fedoraproject.org/rpms/scap-security-guide/pull-request/16
- Follow the CI tests and fix whatever is necessary.
- Repeat this process for all other relevant branches, usually branches not in End-Of-Life (EOL).
    - You can use the `fedpkg switch-branch` command to change the branches. e.g.:
```bash
fedpkg switch-branch <f35,f36,f37>
```

### Create the new Builds
Once the PRs are merged, it is time to create the new builds.
- This example would create the build for `rawhide`:
```bash
fedpkg switch-branch rawhide
fedpkg build
```
- Follow the builds status in the following links:
    - [Builds Status](https://koji.fedoraproject.org/koji/packageinfo?packageID=17182)

### Submit Fedora updates
After the build is done an update must be submitted to Bodhi.
Updates for `rawhide` builds are submitted automatically,
but updates for any branched version needs to be submitted manually.
One can do so via command line:
```bash
fedpkg update
```
Or via web interface on [Bodhi](https://bodhi.fedoraproject.org).

The new updates enter in `testing` state and are moved to stable after 7 day, or sooner
if it receives 3 positive "karmas".
After moving to `stable` state the update is signed and awaits to be pushed to
the repositories by the Release Engineering Team.

- Check the package update status in the following links:
    - [Updates Status](https://bodhi.fedoraproject.org/updates/?packages=scap-security-guide)
    - [Package Overview](https://src.fedoraproject.org/rpms/scap-security-guide)

### More information
- [Package Update Guide](https://docs.fedoraproject.org/en-US/package-maintainers/Package_Update_Guide/)
