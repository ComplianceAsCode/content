templates: bash ansible

export SHARED_DIR=../../../shared/templates/
export PYTHONPATH=../../../shared
CSV_DIR=csv
OUTPUT:=output
OUTPUT_BASH=$(OUTPUT)/bash
OUTPUT_ANSIBLE=$(OUTPUT)/ansible

bash:
	mkdir -p $(OUTPUT_BASH)
	$(SHARED_DIR)/create_BASH_sysctl.py                  $(CSV_DIR)/sysctl_values.csv
	$(SHARED_DIR)/create_services_disabled.py       bash $(CSV_DIR)/services_disabled.csv
	$(SHARED_DIR)/create_services_enabled.py        bash $(CSV_DIR)/services_enabled.csv
	$(SHARED_DIR)/create_package_installed.py       bash $(CSV_DIR)/packages_installed.csv
	$(SHARED_DIR)/create_package_removed.py         bash $(CSV_DIR)/packages_removed.csv
	$(SHARED_DIR)/create_kernel_modules_disabled.py bash $(CSV_DIR)/kernel_modules_disabled.csv
	$(SHARED_DIR)/create_BASH_permission.py              $(CSV_DIR)/file_dir_permissions.csv

ansible:
	mkdir -p $(OUTPUT_ANSIBLE)
	$(SHARED_DIR)/create_kernel_modules_disabled.py   ansible $(CSV_DIR)/kernel_modules_disabled.csv
	$(SHARED_DIR)/create_package_installed.py         ansible $(CSV_DIR)/packages_installed.csv
	$(SHARED_DIR)/create_package_removed.py           ansible $(CSV_DIR)/packages_removed.csv
	$(SHARED_DIR)/create_services_disabled.py         ansible $(CSV_DIR)/services_disabled.csv
	$(SHARED_DIR)/create_services_enabled.py          ansible $(CSV_DIR)/services_enabled.csv
clean:
	rm -rf $(OUTPUT)
