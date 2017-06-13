# The populate function isn't directly used by SSG at the moment but it can be 
# used for testing purposes and will be used in SSG Testsuite in the future.

function populate {
# code to populate environment variables needed (for unit testing)
if [ -z "${!1}" ]; then
	echo "$1 is not defined. Exiting."
	exit
fi
}
