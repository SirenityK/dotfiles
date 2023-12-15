#!/usr/bin/zsh

vim /etc/pacman.conf
# delete full disk first
umount -R /mnt
wipefs -a /dev/sda

parted -s /dev/sda mklabel msdos
parted -s /dev/sda mkpart primary 0% 100%
mkfs.ext4 /dev/sda1

mount /dev/sda1 /mnt
pacstrap -K /mnt linux linux-firmware base base-devel grub networkmanager reflector git neovim
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt bash -c 'grub-install /dev/sda; grub-mkconfig -o boot/grub/grub.cfg; ln -sf /usr/share/zoneinfo/Mexico/BajaNorte /etc/localtime; hwclock --systohc; echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; locale-gen; echo "LANG=en_US.UTF-8" >> /etc/locale.conf; systemctl enable NetworkManager; nvim /etc/sudoers; nvim /etc/pacman.conf; useradd -m -G wheel sirenityk; passwd sirenityk; passwd; exit'
umount -R /mnt
echo Installed! rebooting in 2 seconds...
sleep 2
reboot