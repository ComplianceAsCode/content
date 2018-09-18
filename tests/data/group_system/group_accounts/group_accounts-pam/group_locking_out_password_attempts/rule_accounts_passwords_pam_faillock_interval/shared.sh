#!/bin/bash

set -x

function insert_preauth {
	local pam_file="$1"
	local fail_interval="$2"
	if ! grep -qE "^\s*auth\s+required\s+pam_faillock\.so\s+preauth.*fail_interval=([0-9]*).*$" "$pam_file" ; then
		sed -i --follow-symlinks "/^auth.*sufficient.*pam_unix.so.*/i auth        required      pam_faillock.so preauth silent fail_interval=$fail_interval" "$pam_file"
	fi
}

function remove_preauth {
	local pam_file="$1"
	if grep -qE "^\s*auth\s+required\s+pam_faillock\.so\s+preauth.*fail_interval=([0-9]*).*$" "$pam_file" ; then
		sed -E -i --follow-symlinks "/^\s*auth\s+required\s+pam_faillock\.so\s+preauth.*fail_interval=([0-9]*).*$/d" "$pam_file"
	fi
}

function insert_authfail {
	local pam_file="$1"
	local fail_interval="$2"
	if ! grep -qE "^\s*auth\s+((sufficient)|(\[default=die\]))\s+pam_faillock\.so\s+authfail.*fail_interval=([0-9]*).*$" "$pam_file" ; then
		sed -i --follow-symlinks "/^auth.*sufficient.*pam_unix.so.*/a auth        [default=die] pam_faillock.so authfail fail_interval=$fail_interval" "$pam_file"
	fi
}

function remove_authfail {
	local pam_file="$1"
	if grep -qE "^\s*auth\s+((sufficient)|(\[default=die\]))\s+pam_faillock\.so\s+authfail.*fail_interval=([0-9]*).*$" "$pam_file" ; then
		sed -E -i --follow-symlinks "/^\s*auth\s+((sufficient)|(\[default=die\]))\s+pam_faillock\.so\s+authfail.*fail_interval=([0-9]*).*$/d" "$pam_file"
	fi
}

function insert_account {
	local pam_file="$1"
	if ! grep -qE "^\s*account\s+required\s+pam_faillock\.so.*$" "$pam_file" ; then
		sed -E -i --follow-symlinks "/^\s*account\s*required\s*pam_unix.so/i account     required      pam_faillock.so" "$pam_file"
	fi
}

function remove_account {
	local pam_file="$1"
	if grep -qE "^\s*account\s+required\s+pam_faillock\.so.*$" "$pam_file" ; then
		sed -E -i --follow-symlinks "/^\s*account\s*required\s*pam_faillock.so/d" "$pam_file"
	fi
}

function insert_or_remove_settings {
	local preauth_set="$1"
	local authfail_set="$2"
	local account_set="$3"
	local interval="$4"
	shift 4
	if [ $# -le 0 ] ; then
		echo "No files"
		exit
	fi
	for file in "$@" ; do
		if [ $preauth_set -eq 1 ] ; then
			insert_preauth $file $interval
		else
			remove_preauth $file
		fi
		if [ $authfail_set -eq 1 ] ; then
			insert_authfail $file $interval
		else
			remove_authfail $file
		fi
		if [ $account_set -eq 1 ] ; then
			insert_account $file
		else
			remove_account $file
		fi
	done
}
