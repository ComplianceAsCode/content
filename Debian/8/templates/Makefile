SHARED_DIR:=../../../shared/templates
export PYTHONPATH=../../../shared
OUTPUT:=output
OUTPUT_BASH:=output/bash
OUTPUT_OVAL:=output/oval
CSV_DIR:=csv
OVAL_5.11_CSV_DIR=csv/oval_5.11

templates: templates_oval

templates_oval: csv/*csv
	mkdir -p $(OUTPUT_OVAL)
	${SHARED_DIR}/create_package_removed.py   oval $(CSV_DIR)/packages_removed.csv
	${SHARED_DIR}/create_package_installed.py oval $(CSV_DIR)/packages_installed.csv
	${SHARED_DIR}/create_permission.py        oval $(CSV_DIR)/file_dir_permissions.csv
	${SHARED_DIR}/create_services_disabled.py oval $(CSV_DIR)/services_disabled.csv
	${SHARED_DIR}/create_sysctl_checks.py          $(CSV_DIR)/sysctl_values.csv

oval_5.11: export TEMPLATE_DIR=oval_5.11_templates
oval_5.11:
	mkdir -p $(OUTPUT_OVAL)
	# First create 'package_pkgname_installed' OVAL-5.11 checks
	${SHARED_DIR}/create_package_installed.py oval $(OVAL_5.11_CSV_DIR)/packages_installed.csv
	# Then create 'service_daemon_enabled' OVAL-5.11 checks using the
	# former ones
	${SHARED_DIR}/create_services_enabled.py  $(OVAL_5.11_CSV_DIR)/services_enabled.csv
	${SHARED_DIR}/create_services_disabled.py oval $(OVAL_5.11_CSV_DIR)/services_disabled.csv

bash:
	mkdir -p $(OUTPUT_BASH)

.PHONY = templates_oval

clean:
	rm -rf $(OUTPUT)

