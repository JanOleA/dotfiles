#!/bin/sh
# Run the first of the given programs that exists and is executable.
# Used to start helpers whose path differs between distros, e.g.:
#   run-first.sh /usr/lib/pam_kwallet_init /usr/lib/x86_64-linux-gnu/libexec/pam_kwallet_init

for p in "$@"; do
    if [ -x "$p" ]; then
        exec "$p"
    fi
done

echo "run-first.sh: none of these found: $*" >&2
exit 1
