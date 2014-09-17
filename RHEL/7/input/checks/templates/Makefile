templates: services

SHARED_DIR=../../../../../shared/oval/templates

services:
	${SHARED_DIR}/create_services_disabled.py services_disabled.csv

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
