templates: services

SHARED_DIR=../../../../../../shared/templates
export PYTHONPATH=../../../../../../shared

OUTPUT:=$(shell mkdir -p output)

packages:
	${SHARED_DIR}/create_package_installed.py packages_installed.csv
	${SHARED_DIR}/create_package_removed.py packages_removed.csv

services:
	${SHARED_DIR}/create_services_enabled.py services_enabled.csv
	${SHARED_DIR}/create_services_disabled.py services_disabled.csv

sockets:
	${SHARED_DIR}/create_sockets_disabled.py sockets_disabled.csv

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
