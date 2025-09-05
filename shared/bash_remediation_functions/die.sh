# Print a message to stderr and exit the shell
# $1: The message to print.
# $2: The error code (optional, default is 1)
function die {
	local _message="$1" _rc="${2:-1}"
	printf '%s\n' "$_message" >&2
	exit "$_rc"
}
