#!/bin/bash


# backup_otomatis.sh — Backup otomatis disk ke /backup


SUMBER="/mnt/disk_baru"
TUJUAN="/backup"
NAMA_BACKUP="backup_$(date '+%Y%m%d_%H%M%S').tar.gz"
LOG_FILE="$TUJUAN/backup.log"

# Cek apakah direktori sumber ada
if [ ! -d "$SUMBER" ]; then
    echo "[$(date)] ERROR: Direktori $SUMBER tidak ditemukan." >> "$LOG_FILE"
    exit 1
fi

# Buat direktori backup kalau belum ada
mkdir -p "$TUJUAN"

# Proses backup
echo "[$(date)] Memulai backup $SUMBER ke $TUJUAN/$NAMA_BACKUP ..." >> "$LOG_FILE"

tar -czf "$TUJUAN/$NAMA_BACKUP" "$SUMBER"

if [ $? -eq 0 ]; then
    UKURAN=$(du -sh "$TUJUAN/$NAMA_BACKUP" | cut -f1)
    echo "[$(date)] Backup berhasil: $NAMA_BACKUP (Ukuran: $UKURAN)" >> "$LOG_FILE"
else
    echo "[$(date)] ERROR: Backup gagal!" >> "$LOG_FILE"
    exit 1
fi

# Tampilkan isi direktori backup
echo "[$(date)] Isi direktori backup:" >> "$LOG_FILE"
ls -lh "$TUJUAN"/*.tar.gz >> "$LOG_FILE"
