#!/bin/sh

export DISPLAY=${X_DISPLAY}
xauth add "$X_DISPLAY" "$X_AUTHC_PROTO" "$X_AUTHC_COOKIE"

MAXMEM=4G

/opt/ghidra/support/launch.sh fg Ghidra "${MAXMEM}" "" ghidra.GhidraRun "$@"
