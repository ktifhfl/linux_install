#!/bin/bash
###############################################################
### alexpro100 BASH LIBRARY
### Copyright (C) 2021 ALEXPRO100 (ktifhfl)
### License: GPL v3.0
###############################################################
shopt -s expand_aliases
set -e

ALEXPRO100_LIB_VERSION="0.3.1" 
ALEXPRO100_LIB_LOCATION="$(realpath "${BASH_SOURCE[0]}")"
export ALEXPRO100_LIB_VERSION ALEXPRO100_LIB_LOCATION
echo -e "ALEXPRO100 BASH LIBRARY $ALEXPRO100_LIB_VERSION"
export TMP='' CHROOT_ACTIVE_MOUNTS=() CHROOT_CREATED=() ROOTFS_DIR_NO_FIX=0
export ALEXPRO100_LIB_DEBUG="${ALEXPRO100_LIB_DEBUG:-0}"

#NOTE: Take attention to the parentheses (() or {}). They may vary.

# Colors for text.

#Foreground.
export Black="\e[30m"		# Black
export DGray="\e[90m"		# Dark Gray
export DRed="\e[31m"		# Dark Red
export LRed="\e[91m"		# Light Red
export DGreen="\e[32m"	# Dark Green
export LGreen="\e[92m"	# Light Green
export Orange="\e[33m"	# Orange
export Yellow="\e[93m"	# Yellow
export Blue="\e[34m"		# Dark Blue
export LBlue="\e[94m"		# Light Blue
export DPurple="\e[35m"	# Dark Purple
export LPurple="\e[95m"	# Light Purple
export DCyan="\e[36m"		# Dark Cyan
export LCyan="\e[96m"		# Light Cyan
export LGray="\e[37m"		# Light Gray
export White="\e[97m"		# White

# Background.
export On_Black="\e[40m"       # Black
export On_Red="\e[41m"         # Red
export On_Green="\e[42m"       # Green
export On_Yellow="\e[43m"      # Yellow
export On_Blue="\e[44m"        # Blue
export On_Purple="\e[45m"      # Purple
export On_Cyan="\e[46m"        # Cyan
export On_White="\e[47m"       # White

#Special symbols.
export NC="\e[0m"           # Color Reset
export Bold="\e[1m"		      # Bold text
export Cursive="\e[3m"      # Italic text
export Underline="\e[4m"    # Underlined
export Blink="\e[5m"        # Blink (might not work)
export Reverse="\e[7m"      # Negative text
export Crossout="\e[9m"     # Crossed out
export DUnderline="\e[21m"  # Double Underlined

#--DEBUG--

function AP100_DBG() {
  [[ ! $ALEXPRO100_LIB_DEBUG == 1 ]] || "$@"
}
export -f AP100_DBG

#--UI--

function msg_print() {
  [[ -z $2 ]] && echo_help "Usage: ${FUNCNAME[0]} {alert|err|warn|note|msg|debug|prgs} [TEXT]]\nPrint decorated text."
  local TYPE=$1; shift
  while IFS= read -r line; do
    case $TYPE in
	  alert) echo -e "$Bold$White$On_Red$line${NC}";;
	  err|error) echo -e "[${LRed}ERROR${NC}] $line";;
	  warn|warning) echo -e "[${Orange}WARNING${NC}] $line";;
	  note) echo -e "[${LBlue}NOTE${NC}] $line";;
	  msg|meassage) echo -e "[${DGray}MSG${NC}] $line";;
    debug) echo -e "[${LGreen}DEBUG${NC}] $line";;
	  prgs|progress) echo -e "[${Orange}PROGRESS${NC}] $line";;
	  *);;
    esac
  done < <(echo -e "$*")
}
export -f msg_print

function return_err() {
  msg_print error "$1"; return "${2:-1}"
}
export -f return_err

function echo_help() {
  msg_print note "$1"
  return_err "No arguments!"
}
export -f echo_help

function show_progress() {
  [[ -z $3 ]] && echo_help "Usage: ${FUNCNAME[0]} {sp|kit|train} [PROCESS_ID] [TEXT]\nShow progress while until program complete."
  case $1 in
    sp) local sp="|\-/"; s=1;;
    kit) local sp="  .   /|\  ||| <|||> |||  \|/   '  "; s=5;;
    train) local sp="     < <=<=======>=> >  "; s=3;;
    *) sp="----====++++"; s=4;;
  esac
  local i=0;
  while [[ -d /proc/$2 ]]; do
    echo -ne "\e[2K [${sp:(i++)*s%${#sp}:s}]:$3 \r"
    sleep 0.5s
  done
}
export -f show_progress

#--SYS--

function command_exists() {
  AP100_DBG msg_print debug "Checking $1..."
  command -v "$1" &> /dev/null ;
}
export -f command_exists

function get_file_s() {
  [[ -z $2 ]] && echo_help "Usage: ${FUNCNAME[0]} [FILE] [URL]\nDownload to file from url."
  if command_exists wget; then
    AP100_DBG msg_print debug "Using wget."
    wget -q -t 3 -O "$1" "$2" || return_err "Exit code $? while downloading $2!"
  elif command_exists curl; then
    AP100_DBG msg_print debug "Using curl."
    curl -s --retry 3 -f -o "$1" "$2" || return_err "Exit code $? while downloading $2!"
  else
    return_err "Niether wget nor curl are installed."
  fi
}
export -f get_file_s

function check_url() {
  [[ -z $1 ]] && echo_help "Usage: ${FUNCNAME[0]} [URL]\nCheck url to exist."
  if command_exists wget; then
    AP100_DBG msg_print debug "Using wget."
    wget -q --spider "$1"
  elif command_exists curl; then
    AP100_DBG msg_print debug "Using curl."
    curl --head --fail "$1" &>/dev/null
  else
    return_err "Niether wget nor curl are installed."
  fi
}
export -f check_url

function get_file_list_html() {
  sed -n '/<a / s/^.*<a [^>]*href="\([^\"]*\)".*$/\1/p' | awk -F'/' '{print $NF}' | sort -rn
}
export -f get_file_list_html

function create_tmp_dir() {
  [[ -z $1 ]] && echo_help "Usage: ${FUNCNAME[0]} [VARIABLE]\nCreate tempory directory and assign it to variable."
  export "$1=/tmp/.$1_tmp_$RANDOM"
  AP100_DBG msg_print debug "Created tmp dir $1=${!1}."
  mkdir -p "${!1}" &>/dev/null
}
export -f create_tmp_dir

function archive_extract() (
  [[ -z $3 ]] && echo_help "Usage: ${FUNCNAME[0]} [TYPE] [FILE] [DIR]\nExtract archive to directory."
  cd "$3" || return_err "Directory $3 does not exist!"
  local file
  [[ -f "$2" ]] && file="$(realpath "$2")" || file="$2"
  case $1 in
    tar.bz2|tbz2)  tar xjf "$file";;
    tar.gz|tgz)  tar xzf "$file";;
    tar.xz)  tar xJf "$file";;
    tar.zst)  tar -I zstd -xf "$file";;
    lzma)  unlzma "$file";;
    bz2)  bunzip2 "$file";;
    rar)  unrar x -ad "$file";;
    gz)  gunzip "$file";;
    tar)  tar xf "$file";;
    zip)  unzip "$file";;
    Z)  uncompress "$file";;
    7z)  7z x "$file";;
    xz)  unxz "$file";;
    exe|cab)  cabextract "$file";;
    *)  return_err "$file - Unknown archive type.";;
  esac
)
export -f archive_extract

function unpack_initfs_gz() (
  cd -- "$2" || return_err "No directory $2!"
  gunzip -d < "$1" | cpio -iv
)
export -f unpack_initfs_gz

function pack_initfs_cpio() (
  cd -- "$1" || return_err "No directory $1!"
  find . | cpio --quiet -H newc -o
)
export -f pack_initfs_cpio

function squashfs_rootfs_pack() (
  cd -- "$1" || return_err "No directory $1!"
  mksquashfs . "$2" -noappend -comp "$3"
)
export -f squashfs_rootfs_pack

#--- ROOTFS MOUNT: BEGIN
function chroot_add_mount() {
  if [[ ! -e $3 ]]; then
    [[ $1 == dir ]] && mkdir -p "$3"; [[ $1 == file ]] && touch "$3"
    AP100_DBG msg_print debug "Created $1 $3."
    CHROOT_CREATED=("$3" "${CHROOT_CREATED[@]}")
  fi
  AP100_DBG msg_print debug "Mounting $2..."
  shift; mount "$@" || msg_print warning "$2 not mounted!"
  CHROOT_ACTIVE_MOUNTS=("$2" "${CHROOT_ACTIVE_MOUNTS[@]}")
}
export -f chroot_add_mount

function chroot_setup() {
  AP100_DBG msg_print debug "Running ${FUNCNAME[*]}..."
  chroot_add_mount dir proc "$1/proc" -t proc -o nosuid,noexec,nodev
  chroot_add_mount dir sys "$1/sys" -t sysfs -o nosuid,noexec,nodev,ro
  if [[ -d '/sys/firmware/efi/efivars' ]]; then
    chroot_add_mount dir efivarfs "$1/sys/firmware/efi/efivars" -t efivarfs -o nosuid,noexec,nodev
  fi
  chroot_add_mount dir udev "$1/dev" -t devtmpfs -o mode=0755,nosuid
  chroot_add_mount dir devpts "$1/dev/pts" -t devpts -o mode=0620,gid=5,nosuid,noexec
  chroot_add_mount dir shm "$1/dev/shm" -t tmpfs -o mode=1777,nosuid,nodev
  if [[ ! -d "$1/etc" ]]; then
    mkdir -p "$1/etc"; CHROOT_CREATED=("$1/etc" "${CHROOT_CREATED[@]}")
    AP100_DBG msg_print debug "Created $1/etc."
  fi
  for mp in etc/hosts etc/resolv.conf; do 
    chroot_add_mount file "/$mp" "$1/$mp" --bind
  done
  chroot_add_mount dir "/run" "$1/run" --bind
  chroot_add_mount dir tmp "$1/tmp" -t tmpfs -o mode=1777,strictatime,nodev,nosuid
  AP100_DBG msg_print debug "Completed ${FUNCNAME[*]}."
}
export -f chroot_setup

function chroot_setup_light() {
  for mount_point in proc sys dev dev/pts dev/shm run tmp; do
    chroot_add_mount dir "/$mount_point" "$1/$mount_point" --bind
  done
  for mount_point in etc/hosts etc/resolv.conf; do
    chroot_add_mount file "/$mount_point" "$1/$mount_point" --bind
  done
}
export -f chroot_setup_light

function chroot_teardown() {
  AP100_DBG msg_print debug "Running ${FUNCNAME[*]}..."
  if (( ${#CHROOT_ACTIVE_MOUNTS[@]} )); then
    for name in "${CHROOT_ACTIVE_MOUNTS[@]}"; do
      AP100_DBG msg_print debug "Unmounting $name..."
      umount -l "$name" || msg_print warning "Not 0 code exit!"
    done
    if [[ "$1" == "--remove-created" ]]; then
      for name in "${CHROOT_CREATED[@]}"; do
        AP100_DBG msg_print debug "Removing $name..."
        rm -rf "$name" || msg_print warning "Not 0 code exit!"
      done
    fi
  fi
  unset CHROOT_ACTIVE_MOUNTS CHROOT_CREATED
  AP100_DBG msg_print debug "Completed ${FUNCNAME[*]}."
}
export -f chroot_teardown

function chroot_rootfs() {
  [[ -z $3 ]] && echo_help "Usage: ${FUNCNAME[0]} {main|light} [DIRECTORY] [SHELL]\nChroot to directory mounting necessary directories."
  [[ -d $2 ]] || return_err "$2 is not a directory!"
  AP100_DBG msg_print debug "Preparing to chroot..."
  case $1 in
    light) local ADD_COMMAND=_light;;
    main|*) :;;
  esac
  local CHROOT_DIR="$2"; shift 2; [[ -z $CHROOT_COMMAND ]] && local CHROOT_COMMAND=chroot
  if [[ $ROOTFS_DIR_NO_FIX == 0 ]] && ! mountpoint -q "$CHROOT_DIR"; then
    msg_print warning "Not mounted directory. Bypassing..."
    chroot_add_mount dir "$CHROOT_DIR" "$CHROOT_DIR" --bind
  fi
  chroot_setup"$ADD_COMMAND" "$CHROOT_DIR"
  AP100_DBG msg_print debug "Running chroot..."
  unshare --fork $CHROOT_COMMAND "$CHROOT_DIR" "$@" || local EXIT_CODE=$? 
  chroot_teardown ""
  if [[ -n $EXIT_CODE && $EXIT_CODE != "0" ]]; then 
    msg_print err "Something went wrong! Code exit is $EXIT_CODE."
    return $EXIT_CODE
  fi
}
export -f chroot_rootfs

function parse_arch() {
  case $1 in
    i[3-6]86|x86) export alpine_arch=x86 debian_arch=i386 arch_arch=i686 void_arch=i686 qemu_arch=i386;;
    x86_64|amd64) export alpine_arch=x86_64 debian_arch=amd64 arch_arch=x86_64 void_arch=x86_64 qemu_arch=x86_64;;
    aarch64|arm64|armv8l) export alpine_arch=aarch64 debian_arch=arm64 arch_arch=aarch64 void_arch=aarch64 qemu_arch=aarch64;;
    armv7|armv7h) export alpine_arch=armv7 debian_arch=armhf arch_arch=armv7h void_arch=armv7l qemu_arch=arm;;
    armhf|armv6h) export alpine_arch=armhf debian_arch=armhf arch_arch=armv6h void_arch=armv6l qemu_arch=arm ;;
    arm|armel) export alpine_arch=armhf debian_arch=armel arch_arch=arm void_arch=armv6l qemu_arch=arm;;
    # TODO: Add and fix another arches (old arm, mips).
    *) 
    alpine_arch="$(uname -m)" debian_arch="$(uname -m)" arch_arch="$(uname -m)" void_arch="armv6l" qemu_arch="$(uname -m)"
    export alpine_arch debian_arch arch_arch void_arch qemu_arch
    ;;
  esac
  AP100_DBG msg_print debug "Exported alpine_arch=$alpine_arch debian_arch=$debian_arch arch_arch=$arch_arch void_arch=$void_arch qemu_arch=$qemu_arch."
}
export -f parse_arch

function qemu_chroot() {
  [[ -z $3 ]] && echo_help "Usage: ${FUNCNAME[0]} [ARCH] [DIRECTORY] [SHELL]\nChroot to directory using qemu static, mounting necessary directories."
  local QEMU_STATIC_BIN_DIR=${QEMU_STATIC_BIN_DIR:-"/usr/bin"}
  # If arch set to check, we just check ability to use qemu static.
  [[ "$1" == "check" ]] && shift
  parse_arch "$1"; shift
  if [[ -f $QEMU_STATIC_BIN_DIR/qemu-$qemu_arch-static ]]; then
    AP100_DBG msg_print debug "Using $QEMU_STATIC_BIN_DIR/qemu-$qemu_arch-static."
    [[ "$#" == 1 ]] && return 0
    cp "$QEMU_STATIC_BIN_DIR/qemu-$qemu_arch-static" "$1/usr/bin/qemu-$qemu_arch-static"
    local qemu_dir=$1; shift
	  chroot_rootfs main "$qemu_dir" "qemu-$qemu_arch-static" "$@"
    rm -rf "$1/usr/bin/qemu-$qemu_arch-static"
  else
    return_err "File $QEMU_STATIC_BIN_DIR/qemu-$qemu_arch-static not found! Check qemu-static package."
  fi
}
export -f qemu_chroot

function qemu_run_bin() {
  [[ -z $2 ]] && echo_help "Usage: ${FUNCNAME[0]} [ARCH] [BINARY]\nRun binary using qemu static."
  local QEMU_STATIC_BIN_DIR=${QEMU_STATIC_BIN_DIR:-"/usr/bin"}
  if [[ -f "$QEMU_STATIC_BIN_DIR/qemu-$qemu_arch-static" ]]; then
    AP100_DBG msg_print debug "Found $QEMU_STATIC_BIN_DIR/qemu-$qemu_arch-static."
    shift; "$QEMU_STATIC_BIN_DIR/qemu-$qemu_arch-static" "$@"
  else
    return_err "File $QEMU_STATIC_BIN_DIR/qemu-$qemu_arch-static not found! Check qemu-static package."
  fi
}
export -f qemu_run_bin

function genfstab_light() {
  [[ -z $1 ]] && echo_help "Usage: ${FUNCNAME[0]} [DIRECTORY]\nMake fstab file for directory."
  local root
  root=$(realpath "$1")
  declare -A pseudofs_types=([anon_inodefs]=1 [autofs]=1 [bdev]=1 [bpf]=1 [binfmt_misc]=1 [cgroup]=1 [cgroup2]=1 [configfs]=1 [cpuset]=1 [debugfs]=1
  [devfs]=1 [devpts]=1 [devtmpfs]=1 [dlmfs]=1 [efivarfs]=1 [fuse.gvfsd-fuse]=1 [fuse.gvfs-fuse-daemon]=1 [fusectl]=1 [gvfsd-fuse]=1 [hugetlbfs]=1 [mqueue]=1 [nfsd]=1 [none]=1 [pipefs]=1
  [proc]=1 [pstore]=1 [ramfs]=1 [rootfs]=1 [rpc_pipefs]=1 [securityfs]=1 [sockfs]=1 [spufs]=1 [sysfs]=1 [tracefs]=1 [tmpfs]=1)
  declare -A fsck_types=([cramfs]=1 [exfat]=1 [ext2]=1 [ext3]=1 [ext4]=1 [ext4dev]=1 [jfs]=1 [minix]=1 [msdos]=1 [reiserfs]=1 [vfat]=1 [xfs]=1)
  findmnt -Recvruno SOURCE,TARGET,FSTYPE,OPTIONS,FSROOT "$root" |
  while read -r src target fstype opts fsroot; do
    (( pseudofs_types["$fstype"] )) && continue
    dump=0 pass=0
    target=${target#$root}
    if [[ $fsroot != "/" && $fstype != "btrfs" ]]; then
      src=$(findmnt -funcevo TARGET "$src")$fsroot #bind mount
      [[ ! $src -ef "$target" ]] && echo -ne "\n# $src\n$src\t/${target#/}\tnone\t$opts,bind\t$dump $pass\n"
      continue
    fi
    (( fsck_types["$fstype"] )) && pass=2
    case $fstype in
      fuseblk) fstype=$(lsblk -no FSTYPE "$src");; #For ntfs-3g
      fuse*) continue;; #We just ignore fuse mounts.
      *) findmnt "$src" "$root" >/dev/null && pass=1;;
    esac
    echo -ne "\n# $src"; 
    label=$(lsblk -rno LABEL "$src" 2>/dev/null)
    [[ -n $label ]] && echo -ne " LABEL=$label"
    echo -ne "\nUUID=$(lsblk -rno UUID "$src" 2>/dev/null)\t/${target#/}\t$fstype\t$opts\t$dump $pass\n"
  done
}
export -f genfstab_light
#--- ROOTFS MOUNT: END
