export SHARED_DIR=../../shared/templates/
export PYTHONPATH=../../shared
OUTPUT:=output
OUTPUT_BASH:=$(OUTPUT)/bash
CSV_DIR:=csv

templates: bash

bash:
	mkdir -p $(OUTPUT_BASH)
	${SHARED_DIR}/create_package_installed.py        bash $(CSV_DIR)/packages_installed.csv
	${SHARED_DIR}/create_services_enabled.py         bash $(CSV_DIR)/services_enabled.csv

clean:
	rm -rf $(OUTPUT)
