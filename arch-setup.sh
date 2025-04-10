#!/usr/bin/zsh

set -e

yn() {
    if [ -f /.dockerenv ]; then
        return false
    fi
    local prompt="$1"
    local default="${2:-n}"
    local response

    while true; do
        read -p "$prompt (y/n) " response
        case $response in
        [yY]*)
            return 0
            ;;
        [nN]*)
            return 1
            ;;
        *)
            if [ -z "$response" ]; then
                case $default in
                [yY]*)
                    return 0
                    ;;
                [nN]*)
                    return 1
                    ;;
                esac
            fi
            ;;
        esac
    done
}

PACKAGES="linux base vim"
read -p "Enter your username: " USER
if [ -z "$USER" ]; then
    echo "Username cannot be empty"
    exit 1
fi

yn "This script will format your disk. Do you want to continue?" || exit 1
! yn "Minimum install? (no networking, no devtools, only kernel, vim and base)" && {
    PACKAGES+="base-devel grub networkmanager reflector git"
    MINIMAL=true
    yn "Install linux-firmware" && {
        PACKAGES+="linux-firmware"
    }
    yn "Add yay" && {
        YAY=1
    }
}

# function as string
CHROOT_CMD='ln -sf /usr/share/zoneinfo/Mexico/BajaNorte /etc/localtime; hwclock --systohc; echo "en_US.UTF-8 UTF-8" >>/etc/locale.gen; locale-gen; echo "LANG=en_US.UTF-8" >>/etc/locale.conf; vim /etc/sudoers; vim /etc/pacman.conf; useradd -m -G wheel $USER; passwd $USER; passwd'

if [ -z $YAY ]; then
    CHROOT_CMD+=";sudo pacman -S git && git clone https://aur.archlinux.org/yay-bin.git yay && cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay"
fi

vim /etc/pacman.conf
# delete full disk first
umount -R /mnt || true
wipefs -a /dev/sda

parted -s /dev/sda mklabel msdos
parted -s /dev/sda mkpart primary 0% 100%
mkfs.ext4 /dev/sda1

mount /dev/sda1 /mnt
rm -fr /etc/gnupg
pacstrap -K /mnt $PACKAGES
genfstab -U /mnt >>/mnt/etc/fstab
arch-chroot /mnt bash $CHROOT_CMD
umount -R /mnt
echo Installed! rebooting in 2 seconds...
sleep 2
reboot
