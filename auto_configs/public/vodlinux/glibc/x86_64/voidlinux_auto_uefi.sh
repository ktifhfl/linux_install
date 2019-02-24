#!/bin/bash

add_var distr voidlinux
add_var dir /mnt/mnt
add_var hostname voidlinux
add_var user_name alexey
add_var passwd pass
add_var fstab 1
add_var grub2 1
add_var grub2_type uefi
add_var flash_disk 1
add_var graph 1
add_var lightdm_autostart 0
add_var setup_script 1
add_var arch x86_64
add_var version_void glibc
add_var void_add_i386 1
add_var kernel 1
add_var mirror_voidlinux 'https://alpha.de.repo.voidlinux.org/current'
add_var preinstall 'wget terminus-font screen htop rsync bash-completion'
add_var networkmanager 1