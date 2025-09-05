#!/bin/bash

# This script sets the PYTHONPATH environment variable for the user, without
# overriding their existing path. This allows them to directly execute scripts
# in utils/ or build-scripts/ without having to install the ssg/ module in a
# traditional python location (either system-wide or user-wide).
#
# This script can either be executed as:
#     $ source ../relative/or/absolute/path/to/.pyenv.sh
# In which case, the user can then proceed to use any script as they wish.
# Otherwise, it can be executed as:
#     $ PYTHONPATH=`.../path/to/.pyenv.sh` .../path/to/utils/some_script.py
# In which case, the changes to $PYTHONPATH will not persist past this command.


# By acquiring both the path to the current source, and the current working
# directory, joining the two gives us an absolute path which we can add to
# PYTHONPATH, allowing the user to change directories without having to
# constantly re-source the script.
script_dir="$(dirname "${BASH_SOURCE[@]}")"
current_dir="$(pwd)"
pathdir="$(python -c "import os.path; print(os.path.abspath(os.path.join('$current_dir', '$script_dir')))")"
newpath="$pathdir"

# If the path is already set, append to it.
if [ "x$PYTHONPATH" != "x" ]; then
    newpath="$newpath:$PYTHONPATH"
fi

echo "$newpath"
export PYTHONPATH="$newpath"
