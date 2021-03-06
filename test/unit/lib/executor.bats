#!/usr/bin/env bats

load ../../helper/test_helper

setup() {
    super_setup ".."
    source "${PDC_FOLDER}/sh/lib/executor.sh"
}

teardown() {
    super_teardown
}

# pdcdef_executor_shell -------------------------------------------------------
@test "pdcdef_executor_shell: must run command" {
    RESULT=$(pdcdef_executor_shell 'echo 123')

    [ "$RESULT" == '123' ]
}

# pdcdef_executor_sh ----------------------------------------------------------
@test "pdcdef_executor_sh: must execute sh file" {
    TEMP_FILE="${RESOURCES}/execute/sh.sh"
    touch "$TEMP_FILE"

    RESULT=$(pdcdef_executor_sh "$TEMP_FILE")

    [ "$RESULT" == '456' ]
}

# pdcdef_executor_bash ----------------------------------------------------------
@test "pdcdef_executor_bash: must execute bash file" {
    TEMP_FILE="${RESOURCES}/execute/bash.sh"
    touch "$TEMP_FILE"

    RESULT=$(pdcdef_executor_bash "$TEMP_FILE")

    [ "$RESULT" == '789' ]
}

# pdcdef_executor_plugin ------------------------------------------------------
@test "pdcdef_executor_plugin: test values to execute" {
    # variables
    plugin="plugin"
    plugin_file="${TEMP}/plugin_result"
    plugin_command="(\"touch $plugin_file\")"

    # mocks
    pdcyml_path_plugins="${TEMP}"
    expected_plugin_path="${pdcyml_path_plugins}/pdc-${plugin}-plugin/plugin.yml"

    pdcdef_yaml_loadsettings() {
        [ "$1" = "$expected_plugin_path" ] &&
        [ "$2" = 'pdcyml_plugin_execute' ] &&
        settings="pdcyml_ok="$plugin_command"" &&
        echo "${settings[@]}" ;
    }

    # run
    pdcdef_executor_plugin "$plugin"

    # asserts
    [ -f "$plugin_file" ]
}

@test "pdcdef_executor_plugin: must execute many" {
    # variables
    plugin="plugin"

    # mocks
    pdcyml_path_plugins="${RESOURCES}/execute"
    expected_plugin_path="${pdcyml_path_plugins}/pdc-${plugin}-plugin/plugin.yml"

    source "${PDC_FOLDER}/sh/lib/yaml.sh"

    # run
    pdcdef_executor_plugin "$plugin"

    # asserts
    [ -f "${TEMP}/cmd1" ]
    [ -f "${TEMP}/cmd2" ]
    [ -f "${TEMP}/cmd3" ]
}
