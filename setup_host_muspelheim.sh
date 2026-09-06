#!/bin/bash
set -e

# setup_host_muspelheim.sh
# Prepares the Muspelheim host directories for the Comics stack.
# Usage: ./setup_host_muspelheim.sh via SSH on the target node (Muspelheim)

echo "Setting up Comics directories on Muspelheim..."

# Komga config/data — local system disk (NOT mergerfs; the app database).
KOMGA_CONFIG_DIR="/opt/comics/komga"
if [ ! -d "${KOMGA_CONFIG_DIR}" ]; then
    echo "Creating ${KOMGA_CONFIG_DIR}..."
    sudo mkdir -p "${KOMGA_CONFIG_DIR}"
    sudo chown -R 1000:1000 "${KOMGA_CONFIG_DIR}"
fi

# Suwayomi config/extensions/database — local system disk.
SUWAYOMI_DATA_DIR="/opt/comics/suwayomi"
if [ ! -d "${SUWAYOMI_DATA_DIR}" ]; then
    echo "Creating ${SUWAYOMI_DATA_DIR}..."
    sudo mkdir -p "${SUWAYOMI_DATA_DIR}"
    sudo chown -R 1000:1000 "${SUWAYOMI_DATA_DIR}"
fi

# Shared manga library — mergerfs pool. Suwayomi downloads CBZ files here and
# Komga reads the same directory as its library.
LIBRARY_DIR="/mnt/storage/comics/library"
if [ ! -d "${LIBRARY_DIR}" ]; then
    echo "Creating ${LIBRARY_DIR}..."
    sudo mkdir -p "${LIBRARY_DIR}"
    sudo chown -R 1000:1000 "${LIBRARY_DIR}"
fi

echo "Done. Muspelheim is ready for Comics deployment."
