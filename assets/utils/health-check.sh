#!/bin/bash

DURATION=$(</dev/stdin)
if (($DURATION <= 10000 )); then
    exit 60
else
    curl --silent squeaknode.embassy:12994 &>/dev/null
    RES=$?
    if test "$RES" != 0; then
        echo "The Squeaknode UI is unreachable" >&2
        exit 1
    fi
fi
