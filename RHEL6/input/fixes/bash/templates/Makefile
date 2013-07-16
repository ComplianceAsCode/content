templates: sysctls services

sysctls:
	./create_sysctl_bash.py ../../../checks/templates/sysctl_values.csv

services:
	./create_services_disabled.py ../../../checks/templates/services_disabled.csv
	./create_services_enabled.py ../../../checks/templates/services_disabled.csv
	
compare:
	diff output/ ../ | grep -v "Only in ../"

copy:
	cp output/*.sh ../

clean:
	rm -f output/*.sh
