templates: packages

packages:
	./create_package_installed.py packages_installed.csv

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
