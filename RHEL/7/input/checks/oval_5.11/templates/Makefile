templates: services

SHARED_DIR=../../../../../../shared/oval/templates

OUTPUT:=$(shell mkdir -p output)

services:
	${SHARED_DIR}/create_services_enabled.py services_enabled.csv
	${SHARED_DIR}/create_services_disabled.py services_disabled.csv

compare:
	diff output/ ../ | grep -v "Only in ../"

copy:
	cp output/*.xml ../
	cp output/*.sh ../../fixes/bash/

find-untemplated: templates
	${SHARED_DIR}/find_untemplated.py

clean:
	rm -f output/*.xml
	rm -f output/*.sh
	rm -rf output/
