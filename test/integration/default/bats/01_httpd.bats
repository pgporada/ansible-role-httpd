#!/usr/bin/env bats

@test "Ensure wget is installed" {
    run rpm -q wget
    [ "$status" -eq 0 ]
}

@test "Ensure a command has specific output"
    set -o pipefail
    run bash -c "grep 127.0.0.1 /etc/hosts | grep -o localhost"
    set +o pipefail
    [ "$status" -eq 0 ]
    [[ "$output" =~ "localhost" ]]
}

@test "Ensure a complex command returns successfully" {
    set -o pipefail
    run bash -c "ps aux | grep root | grep -v kworker"
    set +o pipefail
    [ "$status" -eq 0 ]
}
