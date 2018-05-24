#!/bin/sh
TARGET_DIR=${PWD}/output/target
BINARIES_DIR=${PWD}/output/images
mkdir -p ${TARGET_DIR}/install/
cd ${BINARIES_DIR} && {
rsync -a --delete ${BINARIES_DIR}/efi-part  ${TARGET_DIR}/install/
cd -
}
