#!/bin/sh
###########################################################
############### 功能:系统安装,系统拯救 ####################
############### 作者:xichao@sina.cn    ####################
############### 时间:2018-05-23        ####################
###########################################################

hard_detect(){
	echo -e "\e[1;32mThe installer will detect your hard disks before starting the partitioner. \e[m"

	lsblk | awk '{print $1"\t"$4"\t"$6}'

	read -p "Install the system on which hard disk, it should be sda or sdb : " LOCAL_DISK
	if [ ! -b /dev/${LOCAL_DISK} ]
	then
		echo -e "\e[1;31mPlease enter the correct local disk name ! \e[m"
		continue
	fi
	read -p "Where to read the installed system files,it should be sr0 or sdbx : " REMOVABLE_DISK
	if [ ! -b /dev/${REMOVABLE_DISK} ]
	then
		echo -e "\e[1;31mPlease enter the correct removable disk name ! \e[m"
		continue
	fi
}

############### 清空磁盘分区           ####################
wipe_partition(){
	dd if=/dev/zero of=/dev/$1 bs=512 count=1
}
###########################################################
############### 创建磁盘分区           ####################
create_partition(){
	sfdisk /dev/$1 < /etc/init.d/disk.script
}
###########################################################
############### 格式化磁盘分区         ####################
formatting_partition(){
	for partition in $(sfdisk -l | grep $1[1-9] | awk '{print $1}')
	do
		echo -e "\e[1;32mFormatting $partition start ...\e[m"
		if [ $partition == "/dev/${1}1" ]
		then 
			mkfs.vfat -n boot $partition
		else
			mkfs.xfs -f $partition
		fi
		echo -e "\e[1;32mFormatting $partition stop ... \e[m"
	done
}
###########################################################
############### 准备分区               ####################
partition_to_prepare(){
	wipe_partition $1
	create_partition $1
	formatting_partition $1
}
###########################################################

################ 安装前准备            ####################
pre_install(){
	mkdir -p /media/mp{1,2,3}
	mount -v /dev/${1}1 /media/mp1
	mount -v /dev/${1}2 /media/mp2
	mount -v /dev/${2}  /media/mp3
}
###########################################################
################ 安装 extlinux         ####################
install_bootloader(){
	cp -av /install/efi-part/* /media/mp1/
}
############################################################
################# 安装操作系统         #####################
install_os(){
	cp -av /media/mp3/OS/bzImage /media/mp1/
	xzcat /media/mp3/OS/rootfs.cpio.xz | cpio -dim -D /media/mp2
	sync
}
############################################################

################# 安装后工作           #####################
post_install(){
	umount -v /media/mp*
}
############################################################

################# 主菜单               #####################
while :
do
	echo "##########################################"
	echo "    1. Install new system "
	echo "    2. Upgrade system  "
	echo "    3. Access rescue system "
	echo "    4. Reboot "
	echo "    5. Poweroff "
	echo "##########################################"

	echo ""
	read -p "Please enter your choice (1~5) " input

	case $input in
		1) echo "Install system ... "
			hard_detect
			partition_to_prepare ${LOCAL_DISK}
			pre_install ${LOCAL_DISK} ${REMOVABLE_DISK}
			install_bootloader ${LOCAL_DISK}
			install_os
			post_install
			;;
		2) echo "Unfinished, please wait! "
			hard_detect
			pre_install ${LOCAL_DISK} ${REMOVABLE_DISK}
			install_os 
			post_install
			;;
		3) echo "Access rescue system ... "
			break
			;;
		4) echo "System will reboot now !"
			reboot
			break
			;;
		5) echo "System will poweroff now !"
			poweroff
			break
			;;
		*) echo -e "\e[1;31mEnter an integer in 1 ~ 5 ! \e[m"
			;;
	esac
done
############################################################
