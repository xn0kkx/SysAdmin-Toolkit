#!/bin/bash

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="/tmp/system_diagnostics_$TIMESTAMP"
ARCHIVE_PATH="/tmp/system_diagnostics.tar.gz"

mkdir -p "$OUTPUT_DIR"

echo "[+] Collecting journal from previous boot..."
journalctl --boot -1 --no-pager > "$OUTPUT_DIR/journal_previous_boot.log"

echo "[+] Collecting kernel messages from previous boot..."
journalctl -k --boot -1 --no-pager > "$OUTPUT_DIR/kernel_previous_boot.log"

echo "[+] Searching for critical kernel errors..."
journalctl -k --no-pager | grep -iE 'panic|fatal|watchdog|nmi|segfault|error' > "$OUTPUT_DIR/kernel_critical_errors.log"

echo "[+] Searching for possible unexpected reboot messages..."
journalctl -b -1 | grep -iE 'reboot|power|shutdown|crash|watchdog' > "$OUTPUT_DIR/unexpected_reboot.log"

echo "[+] Checking for filesystem errors (fsck)..."
journalctl --no-pager | grep -iE 'fsck|file system check' > "$OUTPUT_DIR/filesystem_check.log"

echo "[+] Listing IOMMU groups..."
find /sys/kernel/iommu_groups/ -type l > "$OUTPUT_DIR/iommu_groups.txt"

echo "[+] Checking for ACS override usage..."
grep acs_override /proc/cmdline > "$OUTPUT_DIR/acs_override_status.txt"

echo "[+] Checking IPMI logs (if available)..."
if command -v ipmitool >/dev/null 2>&1; then
    ipmitool sel list > "$OUTPUT_DIR/ipmi_sel_list.txt" 2>&1
    ipmitool sel elist > "$OUTPUT_DIR/ipmi_sel_elist.txt" 2>&1
    ipmitool chassis status > "$OUTPUT_DIR/ipmi_chassis_status.txt" 2>&1
else
    echo "ipmitool is not installed or not available" > "$OUTPUT_DIR/ipmi_unavailable.txt"
fi

echo "[+] Compressing collected diagnostics to archive..."
tar -czf "$ARCHIVE_PATH" -C "$OUTPUT_DIR" .

echo "[✓] Diagnostic collection complete."
echo "Archive created at: $ARCHIVE_PATH"
