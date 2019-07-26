#!/bin/bash

. release-utils.sh
echo == Create Release ==

check_github_credentials
move_on_to_next_milestone
download_release_assets
