#!/bin/sh

# The PPA is registered using apt-add-repository, which is by default available on desktops, but not on servers or Linux
# containers. It is installed using:

pkg=software-properties-common
status="$(dpkg-query -W --showformat='${db:Status-Status}' "$pkg" 2>&1)"
if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
  echo "\n$(tput setaf 6)Install software-properties-common for adding and removing PPAs$(tput sgr0)\n"
  sudo apt install $pkg
fi

pkg=swi-prolog
status="$(dpkg-query -W --showformat='${db:Status-Status}' "$pkg" 2>&1)"
if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
  echo "\n$(tput setaf 6)Install last stable Swi-Prolog$(tput sgr0)\n"
  sudo apt install $pkg
fi

test=`swipl -g "pack_list_installed()"  -t halt| grep abbreviated_dates`
if [ -z "$test" ]
then
  echo "\n$(tput setaf 6)Install Swi-Prolog abbreviated_dates package$(tput sgr0)\n"
  swipl -g "pack_install(abbreviated_dates, [interactive(false)])"  -t halt
fi

echo "$(tput setaf 6)Done!$(tput sgr0)"
