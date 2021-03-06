read_param "" "$M_HOSTNAME" "$distr-$RANDOM" hostname text
read_param "" "$M_USER" "$user_name" user_name text
read_param "" "$M_SHELL" "$user_shell" user_shell text
read_param "" "$M_PASS" '' passwd secret_empty
if [[ -z $passwd ]]; then
  add_var "declare -gx" passwd "$passwd_default"
  print_param warning "$M_PASS_NO $passwd."
fi
if mountpoint -q "$dir" && [[ $(findmnt -funcevo SOURCE $dir) != tmpfs ]]; then
  read_param "" "$M_FSTAB" '' fstab yes_or_no
  read_param "" "$M_BOOTLOADER" '' bootloader yes_or_no
  if [[ $bootloader == "1" ]]; then
    if [[ -d /sys/firmware/efi/efivars ]]; then
      bootloader_type_default=uefi
    else
      bootloader_type_default=bios
    fi
    while ! [[ $bootloader_type == "bios" || $bootloader_type == "uefi" ]]; do
      read_param "" "$M_BOOTLOADER_TYPE" "$bootloader_type_default" bootloader_type text
    done
    read_param "" "$M_BOOTLOADER_NAME" "grub2" bootloader_name text
    [[ $bootloader_type == bios ]] && read_param "" "$M_BOOTLOADER_PATH" "$(findmnt -funcevo SOURCE $dir)" bootloader_bios_place text
    read_param "" "$M_BOOTLOADER_REMOVABLE" '' removable_disk no_or_yes
  fi
else
  bootloader=0
fi

read_param "" "$M_COPYSCRIPT" '' copy_setup_script yes_or_no

read_param "" "$M_ADD_SOFT" '' add_soft yes_or_no
if [[ $add_soft == "1" ]]; then
# read_param "" "$M_GRAPH" '' graphics yes_or_no
# [[ $graphics == "1" ]] && read_param "" "$M_DM" '' dm_install yes_or_no
  read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no
  read_param "" "$M_PULSEAUDIO" '' pulseaudio yes_or_no
  read_param "" "$M_BLUETOOTH" '' bluetooth yes_or_no
  read_param "" "$M_PRINTERS" '' printers yes_or_no
fi

parse_arch $(uname -m)