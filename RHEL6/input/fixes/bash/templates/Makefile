templates: sysctls

sysctls:
	./create_sysctl_bash.py ../../../checks/templates/sysctl_values.csv
	
compare:
	diff output/ ../ | grep -v "Only in ../"

copy:
	cp output/*.sh ../

clean:
	rm -f output/*.sh
