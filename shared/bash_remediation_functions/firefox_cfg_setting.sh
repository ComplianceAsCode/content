# Function to replace configuration setting(s) in the Firefox preferences configuration (.cfg) file or add the
# preference if it does not exist.
#
# Expects three arguments:
#
# config_file:          Configuration file that will be modified
# key:                  Configuration option to change
# value:                Value of the configuration option to change
#
#
# Example Call(s):
#
#     Without string or variable:
#     firefox_cfg_setting "stig.cfg" "extensions.update.enabled" "false"
#
#     With string:
#     firefox_cfg_setting "stig.cfg" "security.default_personal_cert" "\"Ask Every Time\""
#
#     With a string variable:
#     firefox_cfg_setting "stig.cfg" "browser.startup.homepage\" "\"${var_default_home_page}\""
#
function firefox_cfg_setting {
  local firefox_cfg=$1
  local key=$2
  local value=$3
  local firefox_dirs="/usr/lib/firefox /usr/lib64/firefox /usr/local/lib/firefox /usr/local/lib64/firefox"

  # Check sanity of input
  if [ $# -lt "3" ]
  then
        echo "Usage: firefox_cfg_setting 'config_cfg_file' 'key_to_search' 'new_value'"
        echo
        echo "Aborting."
        exit 1
  fi

  # Check the possible Firefox install directories
  for firefox_dir in ${firefox_dirs}; do
    # If the Firefox directory exists, then Firefox is installed
    if [ -d "${firefox_dir}" ]; then
      # Make sure the Firefox .cfg file exists and has the appropriate permissions
      if ! [ -f "${firefox_dir}/${firefox_cfg}" ] ; then
        touch "${firefox_dir}/${firefox_cfg}"
        chmod 644 "${firefox_dir}/${firefox_cfg}"
      fi

      # If the key exists, change it. Otherwise, add it to the config_file.
      if `grep -q "^lockPref(\"${key}\", " "${firefox_dir}/${firefox_cfg}"` ; then
        sed -i "s/lockPref(\"${key}\".*/lockPref(\"${key}\", ${value});/g" "${firefox_dir}/${firefox_cfg}"
      else
        echo "lockPref(\"${key}\", ${value});" >> "${firefox_dir}/${firefox_cfg}"
      fi
    fi
  done
}
