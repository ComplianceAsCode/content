SHARED_DIR:=../../../../../shared/oval/templates
OUTPUT:=$(shell mkdir -p output)

all:
	${SHARED_DIR}/create_package_removed.py packages_removed.csv
	${SHARED_DIR}/create_package_installed.py packages_installed.csv
	${SHARED_DIR}/create_permission_checks.py file_dir_permissions.csv
	${SHARED_DIR}/create_services_disabled.py services_disabled.csv

copy:
	cp output/*.sh ../../remediations/bash/
	cp output/*.xml ..

clean:
	rm -rf output/*.xml
	rm -rf output/*.sh
	rm -rf output
