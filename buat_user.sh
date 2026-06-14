#!/bin/bash

# =========================================================
# buat_user.sh — Script membuat user baru secara otomatis
# Password otomatis dibuat: namauser@123
# =========================================================

BERKAS_USER="./daftar_user.txt"
LOG_FILE="./user_creation.log"

# Cek apakah script dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
    echo "Script harus dijalankan sebagai root! Gunakan sudo."
    exit 1
fi

# Cek apakah file daftar user ada
if [ ! -f "$BERKAS_USER" ]; then
    echo "File $BERKAS_USER tidak ditemukan!"
    exit 1
fi

echo "===== Proses pembuatan user dimulai: $(date) =====" >> "$LOG_FILE"

# Baca file dan buat user satu per satu
while IFS= read -r NAMA_USER; do
    # Lewati baris kosong
    [ -z "$NAMA_USER" ] && continue

    # Cek apakah user sudah ada
    if id "$NAMA_USER" &>/dev/null; then
        echo "[SKIP] User $NAMA_USER sudah ada." | tee -a "$LOG_FILE"
        continue
    fi

    # Buat password otomatis: namauser@123
    PASSWORD="${NAMA_USER}@123"

    # Buat user baru
    useradd -m -s /bin/bash "$NAMA_USER"

    # Set password
    echo "$NAMA_USER:$PASSWORD" | chpasswd

    echo "[OK] User $NAMA_USER berhasil dibuat. Password: $PASSWORD" | tee -a "$LOG_FILE"

done < "$BERKAS_USER"

echo "===== Proses selesai: $(date) =====" >> "$LOG_FILE"
echo ""
echo "Daftar user yang ada di sistem:"
cat /etc/passwd | grep -E "reza|sinta|taufik|ulfah|vino"
