#!/bin/bash
DISK=/dev/nvme0n1
export DISK

echo "Start install ArchLinux"
echo "[Remove old LVM]"
vgremove vg0
pvremove ${DISK}p2
cryptsetup close cryptlvm

echo "[Partition disk]"
parted -s ${DISK} mklabel gpt
parted -s -a optimal ${DISK} mkpart primary 0% 512MB
parted -s -a optimal ${DISK} mkpart primary 512MB 100%

echo "[Encrypt disk]"
cryptsetup luksFormat ${DISK}p2
cryptsetup open ${DISK}p2 cryptlvm

echo "[Setup LVM]"
pvcreate /dev/mapper/cryptlvm
vgcreate vg0 /dev/mapper/cryptlvm
lvcreate -L 48G vg0 -n root
lvcreate -L 8G vg0 -n swap
lvcreate -l 100%FREE vg0 -n home

echo "[Make FS]"
mkfs.fat -F32 ${DISK}p1
mkfs.ext4 -F /dev/vg0/root
mkfs.ext4 -F /dev/vg0/home

echo "[Make swap]"
mkswap /dev/vg0/swap
swapon

echo "[Mount FS]"
mount /dev/vg0/root /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount ${DISK}p1 /mnt/boot
mount /dev/vg0/home /mnt/home

echo "[Set locale]"
loadkeys ru
setfont cyr-sun16
echo -e "en_US.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
export LANG=en_US.UTF-8

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
[ -f chroot_inst.sh ] || exit 1
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
