#!/bin/bash

WORKDIR="/tmp"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_PREFIX="vfio_diagnostics"
ARCHIVE_NAME="${OUTPUT_PREFIX}_${TIMESTAMP}.tar.gz"

cd "$WORKDIR" || exit 1

echo "[+] Collecting previous boot journal..."
journalctl --boot -1 --no-pager > ${OUTPUT_PREFIX}_previous_boot.log

echo "[+] Collecting previous boot kernel messages..."
journalctl -k --boot -1 --no-pager > ${OUTPUT_PREFIX}_previous_kernel.log

echo "[+] Collecting logs from the last 24 hours..."
journalctl --since "1 day ago" --no-pager > ${OUTPUT_PREFIX}_last_24h.log

echo "[+] Capturing VFIO/IOMMU/dmesg messages..."
dmesg | grep -Ei 'vfio|iommu|pci-stub' > ${OUTPUT_PREFIX}_vfio_dmesg.log
journalctl --grep="vfio" --no-pager >> ${OUTPUT_PREFIX}_vfio_dmesg.log

echo "[+] Capturing GPU/DRM driver messages..."
dmesg | grep -iE 'gpu|nvrm|nouveau|amdgpu|drm' > ${OUTPUT_PREFIX}_gpu_dmesg.log
journalctl -k | grep -iE 'gpu|nvrm|nouveau|amdgpu|drm' >> ${OUTPUT_PREFIX}_gpu_dmesg.log

echo "[+] Collecting kernel errors (panic, watchdog, etc.)..."
grep -iE 'panic|fatal|error|segfault|watchdog' /var/log/kern.log > ${OUTPUT_PREFIX}_kernel_errors.log 2>/dev/null || echo "[!] Warning: /var/log/kern.log not found"

echo "[+] Compressing all log files..."
tar -czvf "$ARCHIVE_NAME" ${OUTPUT_PREFIX}_*.log

echo "[✓] Diagnostic archive generated at: $WORKDIR/$ARCHIVE_NAME"
