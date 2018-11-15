#!/bin/sh

os=$1

case ${os} in

  linux   ) echo "${HOME}/.config/Code/User";;
  windows ) echo "%APPDATA%\\Code\\User";;
  macos   ) echo "${HOME}/Library/Application Support/Code/User";;

esac

exit 0
