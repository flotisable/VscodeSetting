#!/bin/sh

os=$1

case ${os} in

  Linux       ) echo "${HOME}/.config/Code/User";;
  Windows_NT  ) echo "${APPDATA}\\Code\\User";;
  Darwin      ) echo "${HOME}/Library/Application Support/Code/User";;

esac

exit 0
