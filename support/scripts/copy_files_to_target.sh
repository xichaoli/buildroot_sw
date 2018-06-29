#!/bin/sh
SRC=${PWD}/output/staging/usr
DST=${PWD}/output/target/usr
BIN_TOOLS="ldd locale localedef tzselect"
SBIN_TOOLS="ldconfig "

for b in ${BIN_TOOLS}
do
	install -m 0755 ${SRC}/bin/$b ${DST}/bin/
done

for s in ${SBIN_TOOLS}
do
	install -m 0755 ${SRC}/sbin/$s ${DST}/sbin/
done

