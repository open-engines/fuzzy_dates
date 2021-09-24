#!/bin/sh

step="Install software-properties-common for adding and removing PPAs"
pkg=software-properties-common
if [ ! "$(dpkg-query -W --showformat='${db:Status-Status}' "$pkg" 2>&1)" = installed ]; then
  printf "\n\e[1;36m%s\e[0m\n\n" "$step"
  sudo apt install $pkg
fi

step="Install stable Swi-Prolog repository"
if ! apt-cache policy | grep -q swi
then
  printf "\n\e[1;36m%s\e[0m\n\n" "$step"
  sudo apt-add-repository ppa:swi-prolog/stable
fi

step="Install last stable Swi-Prolog"
pkg=swi-prolog
if [ ! "$(dpkg-query -W --showformat='${db:Status-Status}' "$pkg" 2>&1)" = installed ]; then
  printf "\n\e[1;36m%s\e[0m\n\n" "$step"
  sudo apt install $pkg -y
fi

step="Install Swi-Prolog abbreviated_dates package"
if [ "$(swipl -g "pack_list_installed()" -t halt | grep -c abbreviated_dates)" = 0 ]; then
  printf "\n\e[1;36m%s\e[0m\n\n" "$step"
  swipl -g "pack_install(abbreviated_dates, [interactive(false)])"  -t halt
fi

printf "\e[1;36m%s\e[0m\n" "Done!"
