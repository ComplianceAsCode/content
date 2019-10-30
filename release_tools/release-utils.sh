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
