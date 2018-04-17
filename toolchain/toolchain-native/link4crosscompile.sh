#!/bin/sh

for p in addr2line ar as cpp c++ cc gcc g++ gcov gprof \
	ld objcopy objdump ranlib readelf size strings strip
do
	sudo ln -vs /usr/bin/$p /usr/bin/sw_64-linux-gnu-$p
	sleep 1
done
