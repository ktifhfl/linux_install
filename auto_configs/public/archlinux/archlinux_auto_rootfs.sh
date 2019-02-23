#!/bin/bash

add_var distr archlinux
add_var dir /mnt/mnt
add_var hostname archlinux
add_var user_name alexey
add_var passwd pass
add_var fstab 0
add_var grub2 0
add_var grub2_type ''
add_var arch x86_64
add_var mirror_archlinux 'http://mirrors.evowise.com/archlinux'
add_var preinstall 'wget terminus-font'
add_var postinstall 'base-devel screen htop rsync bash-completion'
add_var networkmanager 0
