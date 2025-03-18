#!/bin/sh

# Warna teks
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# Pastikan script dijalankan sebagai root
if [ $(id -u) -ne 0 ]; then
    su -c "sh $0"
    exit 0
fi

TMP_DIR="/data/data/com.termux/files/usr/tmp"
mkdir -p $TMP_DIR

list_aplikasi() {
    echo -e "${CYAN}Pilih kategori aplikasi yang ingin ditampilkan:${RESET}"
    echo -e "${YELLOW}1)${RESET} Semua aplikasi"
    echo -e "${YELLOW}2)${RESET} App sistem"
    echo -e "${YELLOW}3)${RESET} App pengguna"
    echo -e "${YELLOW}4)${RESET} App vendor"
    echo -e "${YELLOW}5)${RESET} App operator"
    echo -e "${YELLOW}6)${RESET} App istimewa (privileged)"
    echo -e "${YELLOW}7)${RESET} App yang diperbarui"
    echo -e "${YELLOW}8)${RESET} App produsen ponsel"
    echo -e "${YELLOW}9)${RESET} Keluar"
    echo -n "Pilihan: "
    read tipe

    case "$tipe" in
        1) pm list packages | cut -d':' -f2 > "$TMP_DIR/apps.txt" ;;
        2) pm list packages -s | cut -d':' -f2 > "$TMP_DIR/apps.txt" ;;
        3) pm list packages -3 | cut -d':' -f2 > "$TMP_DIR/apps.txt" ;;
        4) if [ -d /vendor/app/ ]; then ls /vendor/app/ > "$TMP_DIR/apps.txt"; else echo "Tidak ada aplikasi vendor." > "$TMP_DIR/apps.txt"; fi ;;
        5) if [ -d /carrier/app/ ]; then ls /carrier/app/ > "$TMP_DIR/apps.txt"; else echo "Tidak ada aplikasi operator." > "$TMP_DIR/apps.txt"; fi ;;
        6) if [ -d /system/priv-app/ ]; then ls /system/priv-app/ > "$TMP_DIR/apps.txt"; else echo "Tidak ada aplikasi istimewa." > "$TMP_DIR/apps.txt"; fi ;;
        7) pm list packages -u | cut -d':' -f2 > "$TMP_DIR/apps.txt" ;;
        8) if [ -d /system/app/ ] || [ -d /system/priv-app/ ]; then
               echo -e "${RED}Aplikasi sistem dari produsen:${RESET}" > "$TMP_DIR/apps.txt"
               ls /system/app/ >> "$TMP_DIR/apps.txt"
               ls /system/priv-app/ >> "$TMP_DIR/apps.txt"
           else
               echo "Tidak ada aplikasi produsen yang terdeteksi." > "$TMP_DIR/apps.txt"
           fi ;;
        9) echo -e "${GREEN}Keluar...${RESET}"; exit 0 ;;
        *) echo -e "${RED}Pilihan tidak valid.${RESET}"; return ;;
    esac

    echo -e "${GREEN}Daftar aplikasi:${RESET}"
    awk '{print "\033[0;33m" NR "\033[0m) \033[0;35m" $0 "\033[0m"}' "$TMP_DIR/apps.txt"
}

hapus_aplikasi() {
    while true; do
        list_aplikasi
        echo -n "Masukkan nomor aplikasi yang ingin dihapus (atau ketik '0' untuk kembali ke menu utama): "
        read nomor
        if [ "$nomor" = "0" ]; then
            return
        fi
        package=$(sed -n "${nomor}p" "$TMP_DIR/apps.txt")

        if [ -z "$package" ]; then
            echo -e "${RED}Pilihan tidak valid.${RESET}"
            continue
        fi

        echo -n "Anda yakin ingin menghapus $package? (y/n): "
        read konfirmasi
        if [ "$konfirmasi" = "y" ]; then
            su -c "pm uninstall --user 0 $package"
            echo -e "${GREEN}Aplikasi $package telah dihapus untuk user 0.${RESET}"
        else
            echo -e "${CYAN}Penghapusan dibatalkan.${RESET}"
        fi
    done
}

while true; do
    hapus_aplikasi
done

