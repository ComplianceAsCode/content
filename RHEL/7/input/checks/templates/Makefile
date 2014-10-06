templates: services packages

SHARED_DIR=../../../../../shared/oval/templates

services:
	${SHARED_DIR}/create_services_enabled.py services_enabled.csv
	${SHARED_DIR}/create_services_disabled.py services_disabled.csv

packages:
	./create_package_installed.py packages_installed.csv
	${SHARED_DIR}/create_package_removed.py packages_removed.csv

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
