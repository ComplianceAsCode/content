SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTENT_REPO_ROOT="$(cd "$SCRIPT_DIR" && cd .. && pwd)"
BUILDDIR="$CONTENT_REPO_ROOT/build"

CMAKE_FILE="$CONTENT_REPO_ROOT/CMakeLists.txt"
MAJOR_VERSION=$(awk '/SSG_MAJOR_VERSION /{print substr($2, 1, length($2)-1)}' $CMAKE_FILE)
MINOR_VERSION=$(awk '/SSG_MINOR_VERSION /{print substr($2, 1, length($2)-1)}' $CMAKE_FILE)
PATCH_VERSION=$(awk '/SSG_PATCH_VERSION /{print substr($2, 1, length($2)-1)}' $CMAKE_FILE)

version=$MAJOR_VERSION.$MINOR_VERSION.$PATCH_VERSION
let PATCH_VERSION++
next_version=$MAJOR_VERSION.$MINOR_VERSION.$PATCH_VERSION

die()
{
    echo "$1"
    exit 1
}

check_for_clean_repo()
{
    echo Checking whether the repository is clean...
    # check that there is nothing to report by 'status' except untracked files.
    git status --porcelain=v2 | grep -q --invert-match '^?' && die "The repository is not clean, stash your changes to proceed."
}

check_release_is_ok()
{
    # check that release $version doesn't exist yet
    python3 content_gh.py $OWNER $REPO $GITHUB_TOKEN $version check || die
}

check_jenkins_jobs()
{
    echo Checking Jenkins Jobs
    python3 jenkins_ci.py --jenkins-user $JENKINS_USER --jenkins-token $JENKINS_TOKEN check

}

check_rhel_stig_ids()
{
    echo Checking missing STIG IDS...
    echo Building RHEL6 and RHEL7 content
    ncpu=$(nproc) # This won't return number of physical core, but it shouldn't be problem
    (cd "$BUILDDIR" && cmake .. && make -j $(ncpu) rhel7 rhel6) &> rhel_build.log || die "Error building RHEL7 content, check rhel_build.log file for errors"
    (PYTHONPATH=.. python3 ../build-scripts/profile_tool.py stats -b ../build/ssg-rhel6-xccdf.xml --missing-stig-ids --profile stig) > rhel6-stig-ids.log
    echo :: Check rhel6-stig-ids.log for rules missing STIG IDs
    (PYTHONPATH=.. python3 ../build-scripts/profile_tool.py stats -b ../build/ssg-rhel7-xccdf.xml --missing-stig-ids --profile stig) > rhel7-stig-ids.log
    echo :: Check rhel7-stig-ids.log for rules missing STIG IDs

}

make_dist()
{
    if [ -e artifacts/scap-security-guide-$version.tar.bz2 ]; then
        echo Tarball already exists
    else
        echo Generating source code tarball
        ncpu=$(nproc) # This won't return number of physical core, but it shouldn't be problem
        (cd "$BUILDDIR" && cmake .. && make -j $ncpu package_source) &> package_source.log || die "Error making package_source. Check package_source.log for errors"
        mkdir artifacts/
        mv $BUILDDIR/scap-security-guide-$version.tar.bz2 artifacts/
    fi
}

build_jenkins_jobs()
{
    if python3 jenkins_ci.py --jenkins-user $JENKINS_USER --jenkins-token $JENKINS_TOKEN build; then
        echo :: You can continue to next step of the release
    else
        echo Still building, wait for it to finish
    fi
}

build_release()
{
    make_dist
    build_jenkins_jobs
}

generate_release_notes()
{
    python3 content_gh.py $OWNER $REPO $GITHUB_TOKEN $version rn
}

move_on_to_next_milestone()
{
    python3 content_gh.py $OWNER $REPO $GITHUB_TOKEN $version move_milestone $next_version || die
}

download_release_assets()
{
    python3 jenkins_ci.py --jenkins-user $JENKINS_USER --jenkins-token $JENKINS_TOKEN --version $version download || die
}

create_new_release()
{
    echo Creating release for version $version
    commit=$(git show --format=%H HEAD)
    python3 content_gh.py $OWNER $REPO $GITHUB_TOKEN $version release $commit || die
    echo :: Review Release $version in GitHub and publish it
}

bump_release_in_cmake()
{
    local _version_triplet=($(echo "$next_version" | tr "." "\n"))
    local _version_names=(SSG_MAJOR_VERSION SSG_MINOR_VERSION SSG_PATCH_VERSION)
    for i in 0 1 2
    do
        sed -i "s/set(\s*${_version_names[$i]}\s\+[0-9]\+\s*)/set(${_version_names[$i]} ${_version_triplet[$i]})/" $CMAKE_FILE
    done
}

bump_release()
{
    bump_release_in_cmake
    git diff
    git add "$CMAKE_FILE"
    echo :: Run "'git commit -m \"Version bump after release\" -m \"Next release will be $next_version\"'"
    echo :: Make a PR to bump the version
}

cleanup_release()
{
    python3 jenkins_ci.py clean
}
