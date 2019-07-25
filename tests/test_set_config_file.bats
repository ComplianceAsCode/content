# Source set_config_file function
. $BATS_TEST_DIRNAME/../shared/bash_remediation_functions/include_lineinfile.sh


@test "Basic value remediation" {
    tmp_file="$(mktemp)"
    printf "%s\n" "Compression yes" > "$tmp_file"
    expected_output="Compression no\n"

    set_config_file "$tmp_file" "Compression" "no"

    run diff "$tmp_file" <(printf "$expected_output")
    [ "$status" -eq 0 ]

    rm "$tmp_file"
}

@test "No remediation happened" {
    tmp_file="$(mktemp)"
    printf "%s\n" "Compression no" > "$tmp_file"
    expected_output="Compression no\n"

    set_config_file "$tmp_file" "Compression" "no"

    run diff "$tmp_file" <(printf "$expected_output")
    [ "$status" -eq 0 ]

    rm "$tmp_file"
}

@test "Multiline file remediation" {
    tmp_file="$(mktemp)"
    printf "%s\n" "Protocol 2" "Compression yes" "Port 22" > "$tmp_file"
    expected_output="Protocol 2\nPort 22\nCompression no\n"

    set_config_file "$tmp_file" "Compression" "no"

    run diff "$tmp_file" <(printf "$expected_output")
    [ "$status" -eq 0 ]

    rm "$tmp_file"
}

@test "No remediation on commented line" {
    tmp_file="$(mktemp)"
    printf "%s\n" "Protocol 2" "# Compression yes" "Port 22" > "$tmp_file"
    expected_output="Protocol 2\n# Compression yes\nPort 22\nCompression no\n"

    set_config_file "$tmp_file" "Compression" "no"

    run diff "$tmp_file" <(printf "$expected_output")
    [ "$status" -eq 0 ]

    rm "$tmp_file"
}

@test "Create if missing" {
    tmp_file="$(mktemp)"
    printf "%s\n" "Protocol 2" "Port 22" > "$tmp_file"
    expected_output="Protocol 2\nPort 22\nCompression no\n"

    set_config_file "$tmp_file" "Compression" "no"

    run diff "$tmp_file" <(printf "$expected_output")
    [ "$status" -eq 0 ]

    rm "$tmp_file"
}

@test "Create file if doesn't exist" {
    tmp_file="$(mktemp)"
    rm "$tmp_file"
    expected_output="Compression no\n"

    set_config_file "$tmp_file" "Compression" "no" "true"

    run diff "$tmp_file" <(printf "$expected_output")
    [ "$status" -eq 0 ]

    rm "$tmp_file"
}

@test "Do not create if missing" {
    tmp_file="$(mktemp)"
    rm "$tmp_file"

    run set_config_file "$tmp_file" "Compression" "no" "false"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Path '$tmp_file' wasn't found" ]]
}


@test "Case insensitive remediation" {
    tmp_file="$(mktemp)"
    printf "%s\n" "Protocol 2" "COMPRESSION YES" "Port 22" > "$tmp_file"
    expected_output="Protocol 2\nPort 22\nCompression no\n"

    set_config_file "$tmp_file" "Compression" "no"

    run diff "$tmp_file" <(printf "$expected_output")
    [ "$status" -eq 0 ]

    rm "$tmp_file"
}

@test "Case sensitive remediation" {
    tmp_file="$(mktemp)"
    printf "%s\n" "Protocol 2" "COMPRESSION YES" "Port 22" > "$tmp_file"
    expected_output="Protocol 2\nCOMPRESSION YES\nPort 22\nCompression no\n"

    set_config_file "$tmp_file" "Compression" "no" "" "" "" "false"

    run diff "$tmp_file" <(printf "$expected_output")
    [ "$status" -eq 0 ]

    rm "$tmp_file"
}
