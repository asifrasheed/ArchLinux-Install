#!/bin/bash
clear
echo "Setting up ArchLinux..."
pacman -Syy

# Setting Locale
timedatectl set-timezone Asia/Dubai # Default Location: Dubai
locale-gen
echo LANG=en_GB.UTF-8 > /etc/locale.conf
export LANG=en_GB.UTF-8

# Network Configuration
echo myarch > /etc/hostname
touch /etc/hosts
echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1    localhost" >> /etc/hosts
echo "127.0.1.1    myarch" >> /etc/hosts

# User Accounts
clear
echo "Setting up root user..."
passwd

user = "user"
read -p "Enter new username (default: user):" user
useradd -m -G wheel $user
passwd $user
pacman -S sudo

cp /etc/sudoers /etc/sudoers.bak
sed '82c\
%wheel    ALL=(ALL)   ALL
' /etc/sudoers.bak > /etc/sudoers

# Installing bootloader
pacman -S grub efibootmgr
mkdir /boot/efi
mount $1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg

# Desktop environment setup
pacman -S xorg xorg-server plasma sddm git wget
systemctl enable sddm

git clone https://www.opencode.net/marianarlt/sddm-sugar-candy
mkdir /usr/share/sddm/themes/sugar-candy
mv sddm-sugar-candy/* /usr/share/sddm/themes/sugar-candy
rm -rf sugar-candy

wget https://unsplash.com/photos/H7nMkBMgcNw/download
mv download /usr/share/sddm/themes/sugar-candy/Backgrounds/wallpaper.jpg

cp /usr/lib/sddm/sddm.conf.d/default.conf /usr/lib/sddm/sddm.conf.d/default.bak
sed '33c\
Current=sugar-candy
' /usr/lib/sddm/sddm.conf.d/default.bak > /usr/lib/sddm/sddm.conf.d/default.conf

cp /usr/share/sddm/themes/sugar-candy/theme.conf /usr/share/sddm/themes/sugar-candy/theme.bak
sed '3c\
Background="Backgrounds/wallpaper.jpg"
' /usr/share/sddm/themes/sugar-candy/theme.bak > /usr/share/sddm/themes/sugar-candy/theme.conf

cp /usr/share/sddm/themes/sugar-candy/theme.conf /usr/share/sddm/themes/sugar-candy/theme.bak
sed '21c\
PartialBlur="false"
' /usr/share/sddm/themes/sugar-candy/theme.bak > /usr/share/sddm/themes/sugar-candy/theme.conf

sed '34c\
FormPosition="center"
' /usr/share/sddm/themes/sugar-candy/theme.bak > /usr/share/sddm/themes/sugar-candy/theme.conf

sed '47c\
AccentColor="#5e5e5e"
' /usr/share/sddm/themes/sugar-candy/theme.bak > /usr/share/sddm/themes/sugar-candy/theme.conf

sed '119c\
HeaderText=""
' /usr/share/sddm/themes/sugar-candy/theme.bak > /usr/share/sddm/themes/sugar-candy/theme.conf

# Network Manager
systemctl enable NetworkManager.service

# Finishing up
clear
echo "The Setup will install VLC, Image View, Firefox, Python3, Geany, GCC, Make and Terminal by default"
read -p "Please enter all the extra package that you wish to install (default: None): " packages
pacman -S vlc viewnior firefox python3 python-pip geany gcc make dolphin alacritty base-devel xf86-video-vesa $packages
systemctl set-default graphical.target

rm -rf $0
