templates: services

SHARED_DIR=../../../../../shared/oval/templates

services:
	${SHARED_DIR}/create_services_enabled.py services_enabled.csv

compare:
	diff output/ ../ | grep -v "Only in ../"

copy:
	cp output/*.xml ../

clean:
	rm -f output/*.xml
	rm -f output/*.sh
