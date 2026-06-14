#!/bin/bash


# cek_hdd.sh — Memeriksa space HDD dan notifikasi


LOG_FILE="./hdd_report.log"
BATAS_PERINGATAN=80  # Notifikasi jika pemakaian > 80%

echo "===== Laporan Space HDD: $(date) =====" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Cek semua partisi
df -h | grep -v tmpfs | grep -v udev | tail -n +2 | while read -r BARIS; do
    PARTISI=$(echo "$BARIS" | awk '{print $1}')
    TOTAL=$(echo "$BARIS" | awk '{print $2}')
    TERPAKAI=$(echo "$BARIS" | awk '{print $3}')
    TERSISA=$(echo "$BARIS" | awk '{print $4}')
    PERSEN=$(echo "$BARIS" | awk '{print $5}' | tr -d '%')
    MOUNT=$(echo "$BARIS" | awk '{print $6}')

    echo "Partisi : $PARTISI" | tee -a "$LOG_FILE"
    echo "Total   : $TOTAL" | tee -a "$LOG_FILE"
    echo "Terpakai: $TERPAKAI ($PERSEN%)" | tee -a "$LOG_FILE"
    echo "Tersisa : $TERSISA" | tee -a "$LOG_FILE"

    if [ "$PERSEN" -ge "$BATAS_PERINGATAN" ] 2>/dev/null; then
        echo "PERINGATAN: Space HDD $MOUNT tinggal $(( 100 - PERSEN ))%!" | tee -a "$LOG_FILE"
    else
        echo "Status: Space HDD $MOUNT masih aman (tersisa $(( 100 - PERSEN ))%)" | tee -a "$LOG_FILE"
    fi
    echo "----------------------------------------" | tee -a "$LOG_FILE"
done

echo "" | tee -a "$LOG_FILE"
echo "Laporan selesai" | tee -a "$LOG_FILE"
