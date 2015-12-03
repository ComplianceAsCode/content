SHARED_DIR:=../../../../../shared/oval/templates
OUTPUT:=$(shell mkdir -p output)

all:
	${SHARED_DIR}/create_package_removed.py packages_removed.csv

copy:
	cp output/*.sh ../../remediations/bash/

clean:
	rm -rf output/*.xml
	rm -rf output/*.sh
	rm -rf output
