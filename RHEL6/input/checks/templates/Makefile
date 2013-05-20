templates: services packages kernel_modules permissions sysctls

services:
	./create_services_disabled.py services_disabled.csv
	./create_services_enabled.py services_enabled.csv

packages:
	./create_package_installed.py packages_installed.csv
	./create_package_removed.py packages_removed.csv

kernel_modules:
	./create_kernel_modules_disabled.py kernel_modules_disabled.csv

permissions:
	./create_permission_checks.py file_dir_permissions.csv

sysctls:
	./create_sysctl_checks.py sysctl_values.csv
	
compare:
	diff output/ ../ | grep -v "Only in ../"

copy:
	cp output/*.xml ../
	cp output/*.sh ../../fixes/bash/

find-untemplated: templates
	./find_untemplated.py

clean:
	rm -f output/*.xml
	rm -f output/*.sh
