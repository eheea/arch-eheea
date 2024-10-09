#!/bin/bash

echo "insert the user name"
read -r username
echo "        "

echo "please insert your root password"
read -r rootpasswd
echo "        "

echo "please insert your user password"
read -r userpasswd

#going into the newly installed system
arch-chroot /mnt /bin/bash

#clock config
ln -sf /usr/share/zoneinfo/Asia/Baghdad /etc/localtime
hwclock --systohc

#locale config
locale-gen
echo "LANG=en_US.UTF-8" >> locale.conf

#Network Configuration
echo "arch" >> /etc/hostname
systemctl enable NetworkManager

#setting root password
{ echo "$rootpasswd"
echo "$rootpasswd"

} | passwd

#installing grub
mkdir -p /boot/grub
grub-mkconfig -o /boot/grub/grub.cfg
grub-install

#adding a user
useradd -m -G wheel,input,users -s /bin/bash "$username"
{ echo "$userpasswd"
echo "$userpasswd"

} | passwd "$username"

#making the user able to use sudo
SUDO="/etc/sudoers.d/my_custom_sudoers"
if [ -f "$SUDO" ]; then
    echo "File $SUDO already exists. Exiting."
    exit 1
fi

echo "$username ALL=(ALL) NOPASSWD: ALL" > "$SUDO"
chmod 440 "$SUDO"
visudo -c
echo "Custom sudoers file created successfully."
sleep 1

#enabling multilib
sed -i '92s/^#//' /etc/pacman.conf
sed -i '93s/^#//' /etc/pacman.conf
sudo pacman -Sy
echo "Multilib repository enabled and package database updated."

#installing the AUR helper
if [ ! -f /usr/bin/yay ]; then
sudo pacman -S --noconfirm  --needed git go base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm
else echo "yay is already installed"
fi

#installing the desktop and apps
sudo pacman -Sy --noconfirm gnome gdm neofetch fastfetch gedit go samba sane cups flatpak kitty bluez bluez-utils timeshift btop vlc vulkan-radeon lib32-vulkan-radeon gnome-tweaks fuse wget
yay -S --needed --noconfirm arch-gaming-meta thorium-browser-bin vesktop ttf-ms-fonts auto-cpufreq protonup-qt
flatpak install -y flathub com.mattjakeman.ExtensionManager
flatpak install -y flathub it.mijorus.gearlever
flatpak install -y flathub io.github.peazip.PeaZip
flatpak install -y flathub com.dec05eba.gpu_screen_recorder
sudo systemctl enable gdm
echo "operation is finished. rebooting.."