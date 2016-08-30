export SHARED_DIR := ./
export PYTHONPATH := ./

PREFIX_DIR =       .

OUTPUT =           $(PREFIX_DIR)/output
OUTPUT_BASH =      $(OUTPUT)/bash
OUTPUT_ANSIBLE =   $(OUTPUT)/ansible
OUTPUT_OVAL =      $(OUTPUT)/oval
OUTPUT_OVAL_5_11 = $(OUTPUT)/oval_5.11
CSV_DIR =          $(SHARED_DIR)/csv

templates: bash ansible

bash:
	mkdir -p $(OUTPUT_BASH)
	#$(SHARED_DIR)/create_BASH_sysctl.py                  ${CSV_DIR}/sysctl_values.csv
	#$(SHARED_DIR)/create_BASH_sysctl.py                  ${CSV_DIR}/sysctl_ipv6_values.csv
	#$(SHARED_DIR)/create_BASH_services_disabled.py       ${CSV_DIR}/services_disabled.csv
	#$(SHARED_DIR)/create_BASH_services_enabled.py        ${CSV_DIR}/services_enabled.csv
	$(SHARED_DIR)/create_kernel_modules_disabled.py bash ${CSV_DIR}/kernel_modules_disabled.csv
	$(SHARED_DIR)/create_package_installed.py       bash ${CSV_DIR}/package_installed.csv
	$(SHARED_DIR)/create_package_removed.py         bash ${CSV_DIR}/package_removed.csv

ansible:
	mkdir -p $(OUTPUT_ANSIBLE)
	$(SHARED_DIR)/create_package_installed.py               ansible ${CSV_DIR}/package_installed.csv
	$(SHARED_DIR)/create_package_removed.py                 ansible ${CSV_DIR}/package_removed.csv

clean:
	rm -rf $(TARGET_DIR)/output
