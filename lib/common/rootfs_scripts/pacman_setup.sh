 
#Pacman setup.
msg_print note "Pacman setup..."
pacman_install="pacman -Suy --needed --noconfirm"

sed -i "s/#Color/Color/" /etc/pacman.conf
[[ $multilib == "1" ]] && sed -i '$!N;s|\#\[multilib\]\n\#Include|\[multilib\]\nInclude|;P;D' /etc/pacman.conf #>_<
mv /etc/pacman.d/mirrorlist{,.pacnew}
mv /etc/pacman.d/mirrorlist{.used,}

to_install="$postinstall" to_enable=''
[[ -n "$to_install" ]] && $pacman_install $to_install

msg_print note "Pacman is ready."