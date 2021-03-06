
#Base changes.
msg_print note "Making base changes..."

function base_setup() {
  msg_print note "Setting up hostname and configuring user..."
  echo "$hostname" > /etc/hostname
  echo "root:$passwd" | chpasswd -c SHA512
  useradd -m -g users -G "$user_groups" -s "$user_shell" "$user_name"
  echo  "$user_name:$passwd" | chpasswd -c SHA512
}

function base_setup_alpine() {
  msg_print note "Setting up hostname and configuring user..."
  echo "$hostname" > /etc/hostname
  echo "root:$passwd" | chpasswd -c SHA512
  adduser -G users -s "$user_shell" -D "$user_name"
  for group_name in $user_groups; do
    addgroup "$user_name" "$group_name"
  done
  echo  "$user_name:$passwd" | chpasswd -c SHA512
}

function locale_setup() {
  msg_print note "Setting up locales..."
  sed -ie "s/#[ ,\t]*$LANG_SYSTEM/$LANG_SYSTEM/" /etc/locale.gen
  echo "LANG=\"$LANG_SYSTEM\"" >> "$1"
  locale-gen
}

function locale_setup_voidlinux() {
  msg_print note "Setting up locales..."
  sed -ie "s/#[ ,\t]*$LANG_SYSTEM/$LANG_SYSTEM/" /etc/default/libc-locales
  sed -ie "1s/en_US.UTF-8/$LANG_SYSTEM/" "$1"
  xbps-reconfigure -f glibc-locales
}

case $distr in
  alpine)
    user_groups="audio video input wheel"
    base_setup_alpine
    msg_print note "Alpine has no support of locales. Skipping."
  ;;
  archlinux)
    user_groups="audio,video,input,network,storage,wheel"
    base_setup
    locale_setup /etc/locale.conf
  ;;
  debian)
    user_groups="audio,video,input,sudo"
    base_setup
    locale_setup /etc/default/locale
  ;;
  voidlinux)
    user_groups="audio,video,input,network,storage,wheel"
    base_setup
    [[ $version_void == "glibc" ]] && locale_setup_voidlinux /etc/locale.conf
  ;;
  *)
    msg_print error "Non-standart distro $distr used. Skipping locale setup."
    user_groups="audio,video,input"
    base_setup
  ;;
esac

msg_print note "Base configured succesfully."
