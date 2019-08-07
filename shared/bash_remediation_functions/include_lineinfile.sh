# Functions which minic Ansible's lineinfile module.

function include_lineinfile() {
    :
}

# Internal helper function to remove a line, if it is present.
function lineinfile_absent() {
    local path="$1"
    local regex="$2"
    local insensitive="${3:-true}"

    if [ "$insensitive" == "true" ]; then
        LC_ALL=C sed -i "/$regex/Id" "$path"
    else
        LC_ALL=C sed -i "/$regex/d" "$path"
    fi
}

# Internal helper function to add a line at the desire location.
function lineinfile_present() {
    local path="$1"
    local regex="$2"
    local line="$3"
    local insert_after="$6"
    local insert_before="$7"
    local insensitive="${8:-true}"

    local grep_args=("-q" "-m" "1")
    if [ "$insensitive" == "true" ]; then
        grep_args+=("-i")
    fi

    if [ -z "$regex" ] || ! LC_ALL=C grep "${grep_args[@]}" "$regex" "$path"; then
        if [ -z "$insert_after" ] && [ -z "$insert_before" ] || [ "$insert_after" == "EOF" ]; then
            # Insert at the end of the file
            cp "$path" "$path.bak"
            printf '%s\n' "$line" >> "$path"
        elif [ "$insert_before" == "BOF" ]; then
             # Insert at the beginning of the file
             cp "$path" "$path.bak"
             printf '%s\n' "$line" > "$path"
             cat "$path.bak" >> "$path"
         elif [ -n "$insert_after" ]; then
             # Insert after the line matching the regex $insert_after.
             cp "$path" "$path.bak"
             local line_number="$(LC_ALL=C grep -n "$insert_after" "$path.bak" | LC_ALL=C sed 's/:.*//g')"
             if [ -z "$line_number" ]; then
                 # We used insert_after, but there was no match: insert at
                 # the end of the file.
                 printf '%s\n' "$line" >> "$path"
             else
                 head -n "$(( line_number ))" "$path.bak" > "$path"
                 printf '%s\n' "$line" >> "$path"
                 tail -n "+$(( line_number + 1 ))" "$path.bak" >> "$path"
             fi

             # Clean up after ourselves.
             rm "$path.bak"
         elif [ -n "$insert_before" ]; then
             # Insert before the line matching the regex $insert_before.
              cp "$path" "$path.bak"
             local line_number="$(LC_ALL=C grep -n "$insert_before" "$path.bak" | LC_ALL=C sed 's/:.*//g')"
             if [ -z "$line_number" ]; then
                 # We used insert_after, but there was no match: insert at
                 # the end of the file.
                 printf '%s\n' "$line" >> "$path"
             else
                 head -n "$(( line_number - 1 ))" "$path.bak" > "$path"
                 printf '%s\n' "$line" >> "$path"
                 tail -n "+$(( line_number ))" "$path.bak" >> "$path"
             fi

             # Clean up after ourselves.
             rm "$path.bak"
         fi
     fi
}

function lineinfile() {
    local path="$1"
    local regex="$2"
    local line="$3"
    local create="${4:-false}"
    local state="${5:-present}"
    local insert_after="$6"
    local insert_before="$7"
    local insensitive="${8:-true}"

    if [ "$state" == "absent" ] ; then
        if [ -e "$path" ] ; then
            lineinfile_absent "$path" "$regex" "$insensitive"
        fi
    elif [ "$state" == "present" ]; then
        if [ ! -e "$path" ] ; then
            if [ "$create" == "true" ] ; then
                touch "$path"
            else
                {{{ die("Path '$path' wasn't found on this system and option 'create' is set to '$create'. Refusing to continue.") }}}
            fi
        fi
        lineinfile_present "$path" "$regex" "$line" "$insert_after" "$insert_before" "$insensitive"
    fi
}

function only_lineinfile() {
    local path="$1"
    local line_regex="$2"
    local new_line="$3"
    local create="$4"
    local insert_after="$5"
    local insert_before="$6"
    local insensitive="$7"

    lineinfile "$path" "$line_regex" '' 'false' 'absent' '' '' "$insensitive"
    lineinfile "$path" '' "$new_line" "$create" 'present' "$insert_after" "$insert_before" "$insensitive"
}

function set_config_file() {
    # Note that this differs significantly from the Ansible version in ordering
    # of parameters.
    local path="$1"
    local parameter="$2"
    local value="$3"
    local create="$4"
    local insert_after="$5"
    local insert_before="$6"
    local insensitive="$7"
    local separator="${8:- }"
    local separator_regex="${9:-\s\+}"
    local prefix_regex="${10:-^\s*}"

    only_lineinfile "$path" "$prefix_regex$parameter$separator_regex" "$parameter$separator$value" "$create" "$insert_after" "$insert_before" "$insensitive"
}

function sshd_config_set() {
    local parameter="$1"
    local value="$2"

    set_config_file "/etc/ssh/sshd_config" "$parameter" "$value" "true" '' '^Match' 'true'
}

function auditd_config_set() {
    local parameter="$1"
    local value="$2"

    set_config_file "/etc/audit/auditd.conf" "$parameter" "$value" "true" "" "" "true" " = " "\s*=\s*"
}

function coredump_config_set() {
    local parameter="$1"
    local value="$2"

    set_config_file "/etc/systemd/coredump.conf" "$parameter" "$value" "false" "" "" "true" "=" "\s*=\s*"
}
