SHARED_DIR:=../../../../../../shared/oval/templates
OUTPUT:=$(shell mkdir -p output)

all:
	# First create 'package_pkgname_installed' OVAL-5.11 checks
	${SHARED_DIR}/create_package_installed.py packages_installed.csv
	# Then create 'service_daemon_enabled' OVAL-5.11 checks using the
	# former ones
	${SHARED_DIR}/create_services_enabled.py services_enabled.csv
	${SHARED_DIR}/create_services_disabled.py services_disabled.csv

copy:
	cp output/*.xml ..

clean:
	rm -rf output/*.xml
	rm -rf output/*.sh
	rm -rf output
