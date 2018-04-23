#!/bin/bash
echo "[Setup ArchLinux]"

host_name="anikiforov_nb"
user_name="anikiforov"
pass_common="1"
pacman_pkg="grub efibootmgr intel-ucode yajl expac dnsutils xorg-server xorg-xinit xorg-iceauth xorg-sessreg xorg-xcmsdb xorg-xbacklight xorg-xgamma xorg-xhost xorg-xinput xorg-xmodmap xorg-xrandr xorg-xrdb xorg-xrefresh xorg-xset xorg-xsetroot mesa python2 git mc zsh openssh wget dialog wpa_supplicant awesome xf86-video-intel xf86-video-vesa xf86-video-fbdev xorg-fonts-cyrillic xorg-fonts-100dpi ttf-ubuntu-font-family lightdm lightdm-webkit2-greeter chromium arandr mesa-demos xsel ttf-droid ttf-dejavu xterm"
pacaur_pkg="oh-my-zsh-git rxvt-unicode-patched sublime-text-dev ttf-fira-code zsh-syntax-highlighting"

echo "[Set locale and fonts]"
echo LANG=ru_RU.UTF-8 > /etc/locale.conf
#echo LANG=en_US.UTF-8 > /etc/locale.conf
sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
loadkeys ru
setfont cyr-sun16
echo -e "KEYMAP=ru\nFONT=cyr-sun16\nFONT_MAP=\n" > /etc/vconsole.conf

echo "[Settings pacman]"
sed -i 's/#[multilib]/[multilib]/g' /etc/pacman.conf
sed -i 's/#Include = /etc/pacman.d/mirrorlist/Include = /etc/pacman.d/mirrorlist/g' /etc/pacman.conf

echo "[Set hostname]"
echo $host_name > /etc/hostname

echo "[Set clock]"
ln -svf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc --utc

echo "[Install package]"
pacman -Syu
pacman -S --noconfirm --needed dkms
pacman -S --noconfirm --needed archlinux-keyring
pacman -S --noconfirm --needed $pacman_pkg

echo "[Add user]"
useradd -m -g users -G lp,optical,power,storage,video,audio,wheel -s /bin/zsh $user_name
echo -e "$pass_common\n$pass_common" | passwd
echo -e "$pass_common\n$pass_common" | passwd $user_name
chsh -s /bin/zsh
sed -i 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

echo "[Install pacaur]"
cd /tmp
git clone https://aur.archlinux.org/package-query.git
chown -R $user_name package-query
cd package-query
sudo -u $user_name makepkg
pacman -U package-query-*.pkg.tar.xz --noconfirm

sudo -u $user_name gpg --recv-keys --keyserver hkp://keyserver.ubuntu.com 1EB2638FF56C0C53
cd /tmp
git clone https://aur.archlinux.org/cower.git
chown -R $user_name cower
cd cower
sudo -u $user_name makepkg
pacman -U cower-*.pkg.tar.xz --noconfirm

cd /tmp
git clone https://aur.archlinux.org/pacaur.git
chown -R $user_name pacaur
cd pacaur
sudo -u $user_name makepkg
pacman -U pacaur-*.pkg.tar.xz --noconfirm

echo "[Install pacaur]"
sudo -u $user_name pacaur -S --noconfirm --noedit  $pacaur_pkg

echo "[System settings]"
sed -i 's/^#greeter-session=.*/greeter-session=lightdm-webkit2-greeter/g' /etc/lightdm/lightdm.conf
sed -i 's/^#display-setup-script=.*/display-setup-script=etc\/lightdm\/display_setup.sh/g' /etc/lightdm/lightdm.conf
systemctl enable lightdm.service
pacman -S nvidia-dkms

echo "[Install GRUB]"
grub-install --recheck /dev/sda --efi-directory=/boot
sed -i 's/^GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo "[Install home]"
cd /tmp
git clone https://github.com/nikalexey/archconfig.git
cp archconfig/etc/udev/hwdb.d/61-key-remap.hwdb /etc/udev/hwdb.d
cp archconfig/etc/lightdm/display_setup.sh /etc/lightdm
cp archconfig/etc/modprobe.d/nvidia.conf /etc/modprobe.d/nvidia.conf
chmod +x /etc/lightdm/display_setup.sh
cp -r archconfig/home/ /home/$user_name/
chown $user_name:users /home/$user_name

echo "[Setting udev]"
udevadm hwdb --update
udevadm trigger

#dbg
# echo -e "exec awesome\n" > /home/$user_name/.xinitrc


echo "[Finish Setup ArchLinux]"
#read
