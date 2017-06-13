# Function to replace configuration setting(s) in the Firefox preferences JavaScript file or add the
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
#     firefox_js_setting "stig_settings.js" "general.config.obscure_value" "0"
#
#     With string:
#     firefox_js_setting "stig_settings.js" "general.config.filename" "\"stig.cfg\""
#
#     With a string variable:
#     firefox_js_setting "stig_settings.js" "general.config.filename" "\"$var_config_file_name\""
#
function firefox_js_setting {
  local firefox_js=$1
  local key=$2
  local value=$3
  local firefox_dirs="/usr/lib/firefox /usr/lib64/firefox /usr/local/lib/firefox /usr/local/lib64/firefox"
  local firefox_pref="/defaults/pref"
  local firefox_preferences="/defaults/preferences"

  # Check sanity of input
  if [ $# -lt "3" ]
  then
        echo "Usage: firefox_js_setting 'config_javascript_file' 'key_to_search' 'new_value'"
        echo
        echo "Aborting."
        exit 1
  fi

  # Check the possible Firefox install directories
  for firefox_dir in ${firefox_dirs}; do
    # If the Firefox directory exists, then Firefox is installed
    if [ -d "${firefox_dir}" ]; then
      # Different versions of Firefox have different preferences directories, check for them and set the right one
      if [ -d "${firefox_dir}/${firefox_pref}" ] ; then
        local firefox_pref_dir="${firefox_dir}/${firefox_pref}"
      elif [ -d "${firefox_dir}/${firefox_preferences}" ] ; then
        local firefox_pref_dir="${firefox_dir}/${firefox_preferences}"
      else
        mkdir -m 755 -p "${firefox_dir}/${firefox_preferences}"
        local firefox_pref_dir="${firefox_dir}/${firefox_preferences}"
      fi

      # Make sure the Firefox .js file exists and has the appropriate permissions
      if ! [ -f "${firefox_pref_dir}/${firefox_js}" ] ; then
        touch "${firefox_pref_dir}/${firefox_js}"
        chmod 644 "${firefox_pref_dir}/${firefox_js}"
      fi

      # If the key exists, change it. Otherwise, add it to the config_file.
      if `grep -q "^pref(\"${key}\", " "${firefox_pref_dir}/${firefox_js}"` ; then
        sed -i "s/pref(\"${key}\".*/pref(\"${key}\", ${value});/g" "${firefox_pref_dir}/${firefox_js}"
      else
        echo "pref(\"${key}\", ${value});" >> "${firefox_pref_dir}/${firefox_js}"
      fi
    fi
  done

}
