#!/bin/bash

# etl_solution.sh — Pipeline ETL Data Transaksi E-Commerce

BERKAS_INPUT="./transactions.txt"
BERKAS_OUTPUT="./processed_transactions.log"
BERKAS_LOG="./log/etl.log"
BERKAS_ERROR="./log/etl_error.log"
BERKAS_KUNCI="/tmp/etl_pipeline.lock"
BATAS_NOMINAL=100000

catat_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO]  $1" | tee -a "$BERKAS_LOG"
}

catat_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" | tee -a "$BERKAS_ERROR"
}

bersihkan() {
    rm -f "$BERKAS_KUNCI"
    catat_info "File kunci dihapus. Proses ETL selesai."
}
trap bersihkan EXIT

if [ -f "$BERKAS_KUNCI" ]; then
    PID_LAMA=$(cat "$BERKAS_KUNCI")
    if kill -0 "$PID_LAMA" 2>/dev/null; then
        catat_info "Proses ETL sudah berjalan (PID: $PID_LAMA). Eksekusi dilewati."
        exit 0
    else
        catat_info "File kunci lama ditemukan (PID: $PID_LAMA tidak aktif). Melanjutkan."
        rm -f "$BERKAS_KUNCI"
    fi
fi

echo $$ > "$BERKAS_KUNCI"
catat_info "===== Proses ETL dimulai (PID: $$) ====="

if [ ! -f "$BERKAS_INPUT" ]; then
    catat_error "Berkas $BERKAS_INPUT tidak ditemukan. Proses dibatalkan."
    exit 1
fi

if [ ! -s "$BERKAS_INPUT" ]; then
    catat_info "Berkas $BERKAS_INPUT kosong. Tidak ada data untuk diproses."
    exit 0
fi

catat_info "Berkas input ditemukan: $(wc -l < "$BERKAS_INPUT") baris data."
catat_info "Memulai proses transformasi data..."

BERKAS_SEMENTARA=$(mktemp /tmp/etl_sementara_XXXX.tmp)

awk -F',' -v batas="$BATAS_NOMINAL" '
NR > 1 {
    nominal = $3 + 0
    if (nominal > batas) {
        print toupper($0)
    }
}
' "$BERKAS_INPUT" > "$BERKAS_SEMENTARA" 2>> "$BERKAS_ERROR"

STATUS_TRANSFORM=$?
JUMLAH_DATA=$(wc -l < "$BERKAS_SEMENTARA")

if [ $STATUS_TRANSFORM -ne 0 ]; then
    catat_error "Transformasi gagal. Periksa $BERKAS_ERROR untuk detail."
    rm -f "$BERKAS_SEMENTARA"
    exit 1
fi

catat_info "Transformasi selesai: $JUMLAH_DATA data lolos filter nominal."

if [ "$JUMLAH_DATA" -gt 0 ]; then
    echo "# === Batch diproses: $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$BERKAS_OUTPUT"
    cat "$BERKAS_SEMENTARA" >> "$BERKAS_OUTPUT"
    catat_info "Data berhasil dimuat: $JUMLAH_DATA rekord tersimpan di $BERKAS_OUTPUT."
else
    catat_info "Tidak ada data yang memenuhi batas nominal."
fi

rm -f "$BERKAS_SEMENTARA"
