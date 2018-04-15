#!/bin/bash
echo "[Setup ArchLinux]"

host_name="anikiforov_nb"
user_name="anikiforov"
pass_common="1"
pacman_pkg="grub efibootmgr dnsutils xorg-server xorg-xinit xorg-server-utils mesa python2 git mc zsh openssh wget dialog wpa_supplicant dwm xf86-video-intel xf86-video-vesa xf86-video-fbdev xorg-fonts-cyrillic xorg-fonts-100dpi ttf-ubuntu-font-family slim"


echo "[Set locale and fonts]"

echo LANG=ru_RU.UTF-8 > /etc/locale.conf
#echo LANG=en_US.UTF-8 > /etc/locale.conf
sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
loadkeys ru
setfont cyr-sun16
echo -e "KEYMAP=ru\nFONT=cyr-sun16\nFONT_MAP=\n" > /etc/vconsole.conf

echo "[Set hostname]"
echo $host_name > /etc/hostname

echo "[Set clock]"
ln -svf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc --utc

echo "[Install package]"
pacman -Syu
pacman -S $pacman_pkg --noconfirm

echo "[Install pacman]"

echo "[Add user]"
useradd -m -g users -G lp,optical,power,storage,video -s /bin/zsh $user_name
echo -e "$pass_common\n$pass_common" | passwd
echo -e "$pass_common\n$pass_common" | passwd $user_name
chsh -s /bin/zsh

#gdb
systemctl enable slim.service

echo "[Install GRUB]"
grub-install --recheck /dev/sda --efi-directory=/boot
sed -i 's/^GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo "[Finish Setup ArchLinux]"
#read
