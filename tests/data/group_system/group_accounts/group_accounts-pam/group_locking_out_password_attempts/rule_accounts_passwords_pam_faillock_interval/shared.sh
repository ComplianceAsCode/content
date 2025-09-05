#!/bin/bash

function insert_preauth {
	local pam_file="$1"
	local fail_interval="$2"
	sed -i --follow-symlinks "/^auth.*sufficient.*pam_unix.so.*/i auth        required      pam_faillock.so preauth silent fail_interval=$fail_interval" "$pam_file"
}

function insert_authfail {
	local pam_file="$1"
	local fail_interval="$2"
	sed -i --follow-symlinks "/^auth.*sufficient.*pam_unix.so.*/a auth        [default=die] pam_faillock.so authfail fail_interval=$fail_interval" "$pam_file"
}

function insert_account {
	local pam_file="$1"
	sed -E -i --follow-symlinks "/^\s*account\s*required\s*pam_unix.so/i account     required      pam_faillock.so" "$pam_file"
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
		fi
		if [ $authfail_set -eq 1 ] ; then
			insert_authfail $file $interval
		fi
		if [ $account_set -eq 1 ] ; then
			insert_account $file
		fi
	done
}

function set_default_configuration {
	cp password-auth /etc/pam.d/
	cp system-auth /etc/pam.d/
}
