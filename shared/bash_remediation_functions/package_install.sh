# Function to install packages on RHEL, Fedora, Debian, and possibly other systems.
#
# Example Call(s):
#
#     package_install aide
#
function package_install {

# Load function arguments into local variables
local package="$1"

# Check sanity of the input
if [ $# -ne "1" ]
then
  echo "Usage: package_install 'package_name'"
  echo "Aborting."
  exit 1
fi

if which dnf ; then
  if ! rpm -q --quiet "$package"; then
    dnf install -y "$package"
  fi
elif which yum ; then
  if ! rpm -q --quiet "$package"; then
    yum install -y "$package"
  fi
elif which apt-get ; then
  apt-get install -y "$package"
else
  echo "Failed to detect available packaging system, tried dnf, yum and apt-get!"
  echo "Aborting."
  exit 1
fi

}
