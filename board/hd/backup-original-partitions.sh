#!/bin/sh
TARGET_DIR=${PWD}/output/target
cd ${TARGET_DIR} && {
rsync -a --delete ${TARGET_DIR}/etc  ${TARGET_DIR}/root/.backups/
rsync -a --delete ${TARGET_DIR}/var ${TARGET_DIR}/root/.backups/
rsync -a --delete ${TARGET_DIR}/var/log ${TARGET_DIR}/root/.backups/var/
cd -
}
