#!/bin/bash

INPUT_FILE="server_list.txt"
OUTPUT_FILE="command_output.txt"

if [ -z "$1" ]; then
    echo "Usage: $0 '<remote_command>'"
    exit 1
fi

REMOTE_COMMAND="$1"
> "$OUTPUT_FILE"

for server in $(cat "$INPUT_FILE"); do
    echo "[+] Running on $server..."
    OUTPUT=$(ssh "$server" "$REMOTE_COMMAND" 2>&1)
    echo "$server $OUTPUT" >> "$OUTPUT_FILE"
done

echo "[✓] Done. Results saved to $OUTPUT_FILE"
