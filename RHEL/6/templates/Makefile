templates: bash

export SHARED_DIR=../../../shared/templates/
export PYTHONPATH=../../../shared
CSV_DIR=csv
OUTPUT:=output
OUTPUT_BASH=$(OUTPUT)/bash

bash:
	mkdir -p $(OUTPUT_BASH)
	$(SHARED_DIR)/create_BASH_sysctl.py                  $(CSV_DIR)/sysctl_values.csv
	#$(SHARED_DIR)/create_BASH_services_disabled.py       $(CSV_DIR)/services_disabled.csv
	#$(SHARED_DIR)/create_BASH_services_enabled.py        $(CSV_DIR)/services_enabled.csv
	#$(SHARED_DIR)/create_BASH_package_installed.py       $(CSV_DIR)/packages_installed.csv
	#$(SHARED_DIR)/create_BASH_package_removed.py         $(CSV_DIR)/packages_removed.csv
	#$(SHARED_DIR)/create_BASH_kernel_modules_disabled.py $(CSV_DIR)/kernel_modules_disabled.csv

clean:
	rm -rf $(OUTPUT)
