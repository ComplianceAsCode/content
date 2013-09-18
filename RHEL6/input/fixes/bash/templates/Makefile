templates: sysctls services kernel_modules

sysctls:
	./create_sysctl_bash.py ../../../checks/templates/sysctl_values.csv

services:
	./create_services_disabled.py ../../../checks/templates/services_disabled.csv
	./create_services_enabled.py ../../../checks/templates/services_enabled.csv
	
compare:
	diff output/ ../ | grep -v "Only in ../"

kernel_modules:
	./create_kernel_module_disabled.py ../../../checks/templates/kernel_modules_disabled.csv

copy:
	cp output/*.sh ../

clean:
	rm -f output/*.sh
