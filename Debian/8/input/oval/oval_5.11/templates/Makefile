SHARED_DIR:=../../../../../../shared/oval/templates
OUTPUT:=$(shell mkdir -p output)

all:
	${SHARED_DIR}/create_services_enabled.py services_enabled.csv

copy:
	cp output/*.xml ..

clean:
	rm -rf output/*.xml
	rm -rf output/*.sh
	rm -rf output
