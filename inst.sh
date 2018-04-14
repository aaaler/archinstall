#!/bin/bash

echo "Start install ArchLinux"

echo "[Make FS]"
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p3
mkfs.ext4 /dev/nvme0n1p4
#dbg sleep
read


echo "[Make swap]"
mkswap /dev/nvme0n1p2
swapon
#dbg sleep
read

echo "[Mount FS]"
mount /dev/nvme0n1p3 /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount /dev/nvme0n1p1 /mnt/boot
mount /dev/nvme0n1p4 /mnt/home
#dbg sleep
read

echo "[Set locale]"
loadkeys ru
setfont cyr-sun16
echo -e "en_US.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
export LANG=ru_RU.UTF-8
#dbg sleep
read

echo "[Set time]"
timedatectl set-timezone Europe/Moscow
timedatectl set-ntp true
sleep 3
timedatectl status
sleep 3
#dbg sleep
read

echo "[Set pacman mirror]"
sed -i '1s/^/Server = http:\/\/mirror.yandex.ru\/archlinux\/$repo\/os\/$arch\n/' /etc/pacman.d/mirrorlist
#dbg sleep
read

echo "[Base install]"
pacman -Syy
echo -e "\n\n" | pacstrap -i /mnt base base-devel
#dbg sleep
read

echo "[Generated fatab]"
genfstab -U -p /mnt >> /mnt/etc/fstab
#dbg sleep
read

echo "[Umount all]"
umount -R /mnt
