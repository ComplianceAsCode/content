SHARED_DIR:=../../../shared/templates
export PYTHONPATH=../../../shared
OUTPUT:=$(shell mkdir -p output)
CSV_DIR:=csv
OVAL_5.11_CSV_DIR=csv/oval_5.11

templates:
	${SHARED_DIR}/create_package_removed.py        $(CSV_DIR)/packages_removed.csv
	${SHARED_DIR}/create_package_installed.py      $(CSV_DIR)/packages_installed.csv
	${SHARED_DIR}/create_permission_checks.py      $(CSV_DIR)/file_dir_permissions.csv
	${SHARED_DIR}/create_services_disabled.py      $(CSV_DIR)/services_disabled.csv
	${SHARED_DIR}/create_sysctl_checks.py          $(CSV_DIR)/sysctl_values.csv

oval_5.11: export TEMPLATE_DIR=oval_5.11_templates
oval_5.11:
	# First create 'package_pkgname_installed' OVAL-5.11 checks
	${SHARED_DIR}/create_package_installed.py $(OVAL_5.11_CSV_DIR)/packages_installed.csv
	# Then create 'service_daemon_enabled' OVAL-5.11 checks using the
	# former ones
	${SHARED_DIR}/create_services_enabled.py  $(OVAL_5.11_CSV_DIR)/services_enabled.csv
	${SHARED_DIR}/create_services_disabled.py $(OVAL_5.11_CSV_DIR)/services_disabled.csv



clean:
	rm -rf output
