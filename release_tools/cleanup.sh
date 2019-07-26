#!/bin/bash

. release-utils.sh
echo == Bump and cleanup ==

cleanup_release
bump_release
