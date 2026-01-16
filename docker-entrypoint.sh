#!/bin/sh
set -e

# Fix permissions on SSH agent socket if it exists
if [ -n "$SSH_AUTH_SOCK" ] && [ -e "$SSH_AUTH_SOCK" ]; then
    chown linuxbrew:linuxbrew "$SSH_AUTH_SOCK"
    chmod 600 "$SSH_AUTH_SOCK"
fi

# Drop to linuxbrew user and execute the command
exec gosu linuxbrew "$@"
