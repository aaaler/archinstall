#!/bin/bash

echo "Start install ArchLinux"

echo "[Make FS]"
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 -F /dev/nvme0n1p3
mkfs.ext4 -F /dev/nvme0n1p4

echo "[Make swap]"
mkswap /dev/nvme0n1p2
swapon

echo "[Mount FS]"
mount /dev/nvme0n1p3 /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount /dev/nvme0n1p1 /mnt/boot
mount /dev/nvme0n1p4 /mnt/home

echo "[Set locale]"
loadkeys ru
setfont cyr-sun16
echo -e "en_US.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
export LANG=ru_RU.UTF-8

echo "[Set time]"
timedatectl set-timezone Europe/Moscow
timedatectl set-timezone Europe/Moscow
timedatectl set-ntp true
sleep 3
timedatectl status

echo "[Set pacman mirror]"
sed -i '1s/^/Server = http:\/\/mirror.yandex.ru\/archlinux\/$repo\/os\/$arch\n/' /etc/pacman.d/mirrorlist

echo "[Base install]"
pacman -Syy
echo -e "\n\n" | pacstrap -i /mnt base base-devel

echo "[Generated fatab]"
genfstab -U -p /mnt >> /mnt/etc/fstab

echo "[Install chroot script]"
wget https://raw.githubusercontent.com/nikalexey/archinstall/master/chroot_inst.sh
chmod +x chroot_inst.sh
mkdir /mnt/install
cp chroot_inst.sh /mnt/install/chroot_inst.sh
cp /etc/netctl/encr /mnt/etc/netctl

echo "[Run chroot script]"
arch-chroot /mnt /install/chroot_inst.sh

echo "[Copy install log]"
cp /tmp/install.log /mnt

echo "[Clean]"
rm -rf /mnt/install

echo "[Umount all]"
umount -R /mnt

echo "[Finish] Press Enter to reboot"
read
reboot
