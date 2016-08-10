SHARED_DIR:=../../../shared/templates
export PYTHONPATH=../../../shared
OUTPUT:=$(shell mkdir -p output)
CSV_DIR:=csv

all:
	${SHARED_DIR}/create_package_removed.py        $(CSV_DIR)/packages_removed.csv
	${SHARED_DIR}/create_package_installed.py      $(CSV_DIR)/packages_installed.csv
	${SHARED_DIR}/create_permission_checks.py      $(CSV_DIR)/file_dir_permissions.csv
	${SHARED_DIR}/create_services_disabled.py      $(CSV_DIR)/services_disabled.csv
	${SHARED_DIR}/create_sysctl_checks.py          $(CSV_DIR)/sysctl_values.csv

clean:
	rm -rf output
