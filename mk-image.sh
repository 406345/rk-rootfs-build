#!/bin/bash -e

if [ "$RELEASE" == "stretch" ]; then
	RELEASE='stretch'
elif [ "$RELEASE" == "buster" ]; then
	RELEASE='buster'
else
    echo -e "\033[36m please input the os type,stretch or buster...... \033[0m"
fi

if [ "$ARCH" == "armhf" ]; then
	ARCH='armhf'
elif [ "$ARCH" == "arm64" ]; then
	ARCH='arm64'
else
    echo -e "\033[36m please input the os type,armhf or arm64...... \033[0m"
fi

if [ ! $TARGET ]; then
	TARGET='base'
fi
echo arch=${ARCH},release=${RELEASE},target=${TARGET} 
TARGET_ROOTFS_DIR=./ubuntu-build-service/$RELEASE-$TARGET-$ARCH/binary
MOUNTPOINT=./rootfs
ROOTFSIMAGE=linaro-rootfs.img
 
echo -e "Making rootfs!"

if [ -e ${ROOTFSIMAGE} ]; then
	rm ${ROOTFSIMAGE}
fi
if [ -e ${MOUNTPOINT} ]; then
	rm -r ${MOUNTPOINT}
fi

# Create directories
mkdir ${MOUNTPOINT}
dd if=/dev/zero of=${ROOTFSIMAGE} bs=1M count=0 seek=4000

finish() {
	sudo umount ${MOUNTPOINT} || true
	echo -e "\e[31m MAKE ROOTFS FAILED.\e[0m"
	exit -1
}

echo Format rootfs to ext4
mkfs.ext4 ${ROOTFSIMAGE}

echo Mount rootfs to ${MOUNTPOINT}
sudo mount  ${ROOTFSIMAGE} ${MOUNTPOINT}
trap finish ERR

echo Copy rootfs to ${MOUNTPOINT}
sudo cp -rfp ${TARGET_ROOTFS_DIR}/*  ${MOUNTPOINT}

echo Umount rootfs
sudo umount ${MOUNTPOINT}

echo Rootfs Image: ${ROOTFSIMAGE}

e2fsck -p -f ${ROOTFSIMAGE}
resize2fs -M ${ROOTFSIMAGE}
