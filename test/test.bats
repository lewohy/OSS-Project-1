setup_file() {
    SCRIPT_NAME="proj1_12226322_leewoohyun.sh"
    TEAM_FILE="./res/teams.csv"
    PLAYER_FILE="./res/players.csv"
    MATCH_FILE="./res/matches.csv"

    DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
    PATH="$DIR/../src:$PATH"

    current=$(date "+%Y-%m-%d %H_%M_%S")
    OUTPUT_DIR="$DIR/../outputs/$current"

    create_log_dir

    export SCRIPT_NAME
    export TEAM_FILE
    export PLAYER_FILE
    export MATCH_FILE
    export DIR
    export PATH
    export OUTPUT_DIR
}

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    bats_require_minimum_version 1.5.0

    INPUT_PATH="./input/${BATS_TEST_DESCRIPTION}.txt"
    EXPECTED_PATH="./expect/${BATS_TEST_DESCRIPTION}.txt"
}

create_log_dir() {
    mkdir -p "${OUTPUT_DIR}"
}

print_output() {
    echo "$output" > "$OUTPUT_DIR/${BATS_TEST_DESCRIPTION}.log"

}

assert_with_expected_output() {
    declare -a expected
    
    while read -r line; do
        expected+=("$line")
    done < "${EXPECTED_PATH}"
    
    for i in "${!expected[@]}"; do
        assert_output --partial "${expected[$i]}"
    done
}

@test "test params with 0 param" {
    run -1 bash -c "echo '7' | ${SCRIPT_NAME}"
    print_output
    assert_output --partial "Usage: ./${SCRIPT_NAME} file1 file2 file3"
}

@test "test params with 1 param" {
    run -1 bash -c "echo '7' | ${SCRIPT_NAME} ${TEAM_FILE}"
    print_output
    assert_output --partial "Usage: ./${SCRIPT_NAME} file1 file2 file3"
}

@test "test params with 2 param" {
    run -1 bash -c "echo '7' | ${SCRIPT_NAME} ./src/teams.csv ./src/players.csv"
    print_output
    assert_output --partial "Usage: ./${SCRIPT_NAME} file1 file2 file3"
}

@test "test params with 3 param" {
    run -0 bash -c "echo '7' | ${SCRIPT_NAME} ./src/teams.csv ./src/players.csv ./src/matches.csv"
    print_output
    refute_output --partial "Usage: ./${SCRIPT_NAME} file1 file2 file3"
}

@test "test menu 1" {
    run -0 bash -c "cat '${INPUT_PATH}' | ${SCRIPT_NAME} ${TEAM_FILE} ${PLAYER_FILE} ${MATCH_FILE} >&1"
    print_output
    assert_with_expected_output
}

@test "test menu 2" {
    run -0 bash -c "cat '${INPUT_PATH}' | ${SCRIPT_NAME} ${TEAM_FILE} ${PLAYER_FILE} ${MATCH_FILE} >&1"
    print_output
    assert_with_expected_output
}

@test "test menu 3" {
    run -0 bash -c "cat '${INPUT_PATH}' | ${SCRIPT_NAME} ${TEAM_FILE} ${PLAYER_FILE} ${MATCH_FILE} >&1"
    print_output
    assert_with_expected_output
}

@test "test menu 4" {
    run -0 bash -c "cat '${INPUT_PATH}' | ${SCRIPT_NAME} ${TEAM_FILE} ${PLAYER_FILE} ${MATCH_FILE} >&1"
    print_output
    assert_with_expected_output
}

@test "test menu 5" {
    run -0 bash -c "cat '${INPUT_PATH}' | ${SCRIPT_NAME} ${TEAM_FILE} ${PLAYER_FILE} ${MATCH_FILE} >&1"
    print_output
    assert_with_expected_output
    
}

@test "test menu 6" {
    run -0 bash -c "cat '${INPUT_PATH}' | ${SCRIPT_NAME} ${TEAM_FILE} ${PLAYER_FILE} ${MATCH_FILE} >&1"
    print_output
    assert_with_expected_output
}

@test "test menu 7" {
    run -0 bash -c "cat '${INPUT_PATH}' | ${SCRIPT_NAME} ${TEAM_FILE} ${PLAYER_FILE} ${MATCH_FILE} >&1"
    print_output
    assert_with_expected_output
}
