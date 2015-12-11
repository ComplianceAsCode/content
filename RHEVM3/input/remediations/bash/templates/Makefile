templates: sysctls services kernel_modules

SHARED_DIR=../../../../../shared/remediations/bash/templates

OUTPUT:=$(shell mkdir -p output)

sysctls:
	$(SHARED_DIR)/create_sysctl_bash.py ../../../oval/templates/sysctl_values.csv

services:
	$(SHARED_DIR)/create_services_disabled.py ../../../oval/templates/services_disabled.csv
	$(SHARED_DIR)/create_services_enabled.py ../../../oval/templates/services_enabled.csv

compare:
	diff output/ ../ | grep -v "Only in ../"

kernel_modules:
	$(SHARED_DIR)/create_kernel_module_disabled.py ../../../oval/templates/kernel_modules_disabled.csv

copy:
	cp output/*.sh ../

clean:
	rm -f output/*.sh
	rm -rf output/
