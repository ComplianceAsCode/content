#!/bin/bash

function remove_hosts_files() {
	find /root -xdev -type f -name ".rhosts" -exec rm -f {} \;
	find /home -maxdepth 2 -xdev -type f -name ".rhosts" -exec rm -f {} \;
	rm -f /etc/hosts.equiv
}
