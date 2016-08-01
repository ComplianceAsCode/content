#!/bin/bash

# SCAP "replace or append pattern value in text file based on variable"
# remediation script generator
#
# Required arguments:
# -p pattern to search content of text file for
# -f text file to be searched
# -v use variable as new value for the pattern
# -o name of resulting remediation script output file
#
# Optional arguments:
# -s request pattern match from the start of the line
#
# Example use:
#
# ./create_replace_or_append_pattern_value_in_text_file.sh \
# -p PASS_MIN_LEN \ 
# -f /etc/login.defs \
# -v var_accounts_password_minlen_login_defs
# -o ../output/accounts_password_minlen_login_defs.sh

# meaning:
# a remediation script to replace 'PASS_MIN_LEN' string
# in '/etc/login.defs' file with value of
# '$var_accounts_password_minlen_login_defs' variable
# would be created based on template and stored into
# 'accounts_password_minlen_login_defs.sh' output file
# Since no -s argument was provided the text file would
# be searched for any occurrence of 'PASS_MIN_LEN' row
# -----------------------------------------------------

# Define script routines below
# ----------------------------

#1 Usage function definition

function usage {
  echo -e "Usage:\n\t$0 [-s] -p pattern -f file -v variable -o output_script\n"
  echo -e "-p pattern to search file for\t\t\t-f text file to be searched"
  echo -e "-v name of the variable to be considered\t[-s] match the start of the line or not"
  echo -e "   to hold new value for pattern\t\t-o name of the resulting remediation script"
}

#2 Remediation script generator function definition
# Expects pattern as first argument, file as second argument,
# and variable name as third argument

function generate_replace_or_append_remediation_script {

  # Save the provided args to local variables
  local pattern=$1 file=$2 variable=$3 remediation=$4

  pattern_prefix=''

  if [ $MATCH_START_OF_LINE ]
  then
    pattern_prefix='^'
  fi

  # Generate the remediation script
  cat > $REMEDIATION << EOF
. /usr/share/scap-security-guide/remediation_functions
populate $variable

grep -q $pattern_prefix$pattern $file && \\
sed -i "s/$pattern.*/$pattern\t\$$variable/g" $file
if ! [ \$? -eq 0 ]
then
  echo -e "$pattern\t\$$variable" >> $file
fi
EOF

}


##### Main body of the generator script #####

# Initialize variables
PATTERN=false FILE= false VARIABLE=false 
MATCH_START_OF_LINE=false REMEDIATION=false

# Specify valid options and action for each of them
while getopts "p:f:v:so:" opt
do
  case $opt in
    p ) PATTERN=$OPTARG  ;;
    f ) FILE=$OPTARG     ;;
    v ) VARIABLE=$OPTARG ;;
    s ) MATCH_START_OF_LINE=true ;;
    o ) REMEDIATION=$OPTARG ;;
    * ) usage; exit
  esac
done

# Provided input wasn't correct. Just display usage message
if [ -z $PATTERN ] || [ -z $FILE ] || [ -z $VARIABLE ] || [ -z $REMEDIATION ]
then
  usage
# Command line was correct, generate the remediation script
else
  generate_replace_or_append_remediation_script $PATTERN $FILE $VARIABLE $REMEDIATION
fi
