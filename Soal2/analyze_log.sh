#!/bin/bash

# analyze_log.sh — Analisis Log Aktivitas Server Harian


BERKAS_LOG="./user_activity.log"
BERKAS_LAPORAN="./daily_report.txt"
BERKAS_PERINGATAN="./alert.log"
TANGGAL_HARI_INI=$(date '+%Y-%m-%d')
BATAS_GAGAL=10

if [ ! -f "$BERKAS_LOG" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Berkas $BERKAS_LOG tidak ditemukan." >> "$BERKAS_PERINGATAN"
    exit 1
fi

if [ ! -s "$BERKAS_LOG" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Berkas $BERKAS_LOG kosong." >> "$BERKAS_PERINGATAN"
    exit 1
fi

LOG_HARI_INI=$(grep "^$TANGGAL_HARI_INI" "$BERKAS_LOG")

if [ -z "$LOG_HARI_INI" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: Tidak ditemukan log untuk tanggal $TANGGAL_HARI_INI." >> "$BERKAS_PERINGATAN"
    exit 0
fi

TOTAL_GAGAL=$(echo "$LOG_HARI_INI" | grep "ACTION=login" | grep "STATUS=FAILED" | wc -l)
TOTAL_UPLOAD=$(echo "$LOG_HARI_INI" | grep "ACTION=upload" | grep "STATUS=SUCCESS" | wc -l)

PENGGUNA_TERATAS=$(echo "$LOG_HARI_INI" | \
    grep -oP 'USER=\K\w+' | \
    sort | uniq -c | sort -rn | \
    head -3 | \
    awk '{print NR". "$2" - "$1" aktivitas"}')

cat > "$BERKAS_LAPORAN" << LAPORAN
======================================
DAILY ACTIVITY REPORT
Tanggal: $TANGGAL_HARI_INI
======================================
Total login gagal  : $TOTAL_GAGAL
Total upload sukses: $TOTAL_UPLOAD

Top 3 user paling aktif:
$(echo "$PENGGUNA_TERATAS" | awk '{print "  "$0}')
======================================
LAPORAN

echo "Laporan harian berhasil disimpan ke $BERKAS_LAPORAN"

if [ "$TOTAL_GAGAL" -gt "$BATAS_GAGAL" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ALERT: Terjadi $TOTAL_GAGAL kali login gagal hari ini!" >> "$BERKAS_PERINGATAN"
    echo "Peringatan telah dikirim ke $BERKAS_PERINGATAN"
fi
