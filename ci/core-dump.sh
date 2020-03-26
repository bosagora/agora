#!/bin/bash

set -veo pipefail

for file in /cores/*; do
    echo "Core file: $file"
    sudo lldb -c $file -o "bt all" -o "script import os; os._exit(1)"

    # DUB_EXEC=$(echo "$file" | sed 's/\/cores\///' | sed -E 's/\.[0-9]+$//' | tr '!' '/')
    # gdb -c "$file" "$DUB_EXEC" -ex 'set print pretty on' -ex "thread apply all bt" -ex "set pagination 0" -ex 'info files' -ex 'p $_siginfo._sifields._sigfault.si_addr' -ex 'info locals' -ex 'info frame' -ex 'info args' -ex 'p *sym' -batch
done
