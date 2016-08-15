templates: packages kernel_modules permissions umasks sysctls

SHARED_DIR=../../../../../shared/templates
export PYTHONPATH=../../../../../shared
SHARED_TEMPLATES=../../../../../shared/templates

OUTPUT:=$(shell mkdir -p output)

packages:
	${SHARED_DIR}/create_package_installed.py packages_installed.csv
	${SHARED_DIR}/create_package_removed.py packages_removed.csv

kernel_modules:
	${SHARED_DIR}/create_kernel_modules_disabled.py kernel_modules_disabled.csv

permissions:
	${SHARED_DIR}/create_permission_checks.py file_dir_permissions.csv

umasks:
	${SHARED_TEMPLATES}/create_umask_checks.py ${SHARED_TEMPLATES}/file_umask_checks.csv

sysctls:
	${SHARED_DIR}/create_sysctl_checks.py sysctl_values.csv
	${SHARED_DIR}/create_sysctl_ipv6_checks.py sysctl_ipv6_values.csv

sebools:
	${SHARED_TEMPLATES}/create_sebool_oval.py ${SHARED_TEMPLATES}/selinux_booleans.csv

compare:
	diff output/ ../ | grep -v "Only in ../"

copy:
	cp output/*.xml ../
	cp output/*.sh ../../remediations/bash/

find-untemplated: templates
	${SHARED_DIR}/find_untemplated.py

clean:
	rm -f output/*.xml
	rm -f output/*.sh
	rm -rf output/
