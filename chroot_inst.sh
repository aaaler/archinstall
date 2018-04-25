#!/bin/bash
echo "[Setup ArchLinux]"

host_name="anikiforov_nb"
user_name="anikiforov"
pass_common="1"
pacman_pkg="grub efibootmgr intel-ucode yajl expac dnsutils xorg-server xorg-xinit xorg-iceauth xorg-sessreg xorg-xcmsdb xorg-xbacklight xorg-xgamma xorg-xhost xorg-xinput xorg-xmodmap xorg-xrandr xorg-xrdb xorg-xrefresh xorg-xset xorg-xsetroot mesa python2 python3 git mc zsh openssh wget dialog wpa_supplicant awesome xf86-video-intel xf86-input-synaptics xorg-fonts-cyrillic xorg-fonts-100dpi ttf-ubuntu-font-family lightdm chromium arandr mesa-demos xsel ttf-droid ttf-dejavu xterm dkms linux-headers bumblebee bbswitch nvidia-dkms gdb pavucontrol pulseaudio bluez bluez-utils blueman pulseaudio-bluetooth lib32-libglvnd lib32-mesa lib32-nvidia-utils lib32-virtualgl exfat-utils slock htop iotop dmidecode sysstat fzf lsof tcpdump virtualbox virtualbox-guest-utils qt5-base qt5ct qt5-svg qt5gtk2 meld"
pacaur_pkg="oh-my-zsh-git rxvt-unicode-patched sublime-text-dev ttf-fira-code zsh-syntax-highlighting lightdm-webkit2-greeter fzf-extras nnn"

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
echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" >> /etc/pacman.conf 

echo "[Set hostname]"
echo $host_name > /etc/hostname

echo "[Set clock]"
ln -svf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc --utc

echo "[Install pacman package]"
pacman -Syu
pacman -S --noconfirm --needed $pacman_pkg

echo "[Add user]"
useradd -m -g users -G lp,optical,power,storage,video,audio,wheel,bumblebee -s /bin/zsh $user_name
echo -e "$pass_common\n$pass_common" | passwd
echo -e "$pass_common\n$pass_common" | passwd $user_name
chsh -s /bin/zsh
sed -i 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

echo "[Setup keys]"
sudo -u $user_name gpg --recv-keys --keyserver hkp://keyserver.ubuntu.com 1EB2638FF56C0C53
sudo -u $user_name gpg --recv-keys --keyserver hkp://keyserver.ubuntu.com 702353E0F7E48EDB

echo "[Install pacaur]"
cd /tmp
git clone https://aur.archlinux.org/package-query.git
chown -R $user_name package-query
cd package-query
sudo -u $user_name makepkg
pacman -U package-query-*.pkg.tar.xz --noconfirm

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

echo "[Install pacaur packages]"
sudo -u $user_name pacaur -S --noconfirm --noedit  $pacaur_pkg

echo "[System settings]"
sed -i 's/^#greeter-session=.*/greeter-session=lightdm-webkit2-greeter/g' /etc/lightdm/lightdm.conf
sed -i 's/^#display-setup-script=.*/display-setup-script=etc\/lightdm\/display_setup.sh/g' /etc/lightdm/lightdm.conf

echo "[Install GRUB]"
grub-install --recheck /dev/sda --efi-directory=/boot
sed -i 's/^GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo "[Install home]"
cd /tmp
git clone https://github.com/nikalexey/archconfig.git
chmod +x /etc/lightdm/display_setup.sh
cp -r archconfig/home/* /home/$user_name/
chown $user_name:users /home/$user_name

echo "[Copy system settings]"
cp archconfig/etc/udev/hwdb.d/61-key-remap.hwdb /etc/udev/hwdb.d
cp archconfig/etc/lightdm/display_setup.sh /etc/lightdm
cp archconfig/etc/modprobe.d/nvidia.conf /etc/modprobe.d
cp archconfig/etc/X11/00-keyboard.conf /etc/X11/xorg.conf.d
cp archconfig/etc/X11/10-security.conf /etc/X11/xorg.conf.d
cp archconfig/etc/X11/70-synaptics.conf /etc/X11/xorg.conf.d
cp archconfig/etc/systemd/system/slock@.service /etc/systemd/system

echo "[Setting udev]"
udevadm hwdb --update
udevadm trigger

echo "[Enable service]"
systemctl enable lightdm.service
systemctl enable bumblebeed.service
systemctl enable slock@$user_name.service

#dbg
# echo -e "exec awesome\n" > /home/$user_name/.xinitrc


echo "[Finish Setup ArchLinux]"
#read
