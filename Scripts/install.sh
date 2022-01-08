#!/bin/sh
settingFile="./settings.toml"

scriptDir="$(dirname $0)"

. ${scriptDir}/readSettings.sh ${settingFile}

installFile()
{
  local sourceFile=$1
  local targetFile=$2
  local fileMessage=$3

  echo "install $fileMessage"
  cp $sourceFile $targetFile 
}

targetTableName=$(mapFind "settings" "target")
sourceTableName=$(mapFind "settings" "source")
dirTableName=$(mapFind "settings" "dir")
pluginManagerTableName=$(mapFind "settings" "pluginManager")

if [ "$(mapFind "$pluginManagerTableName" "install")" == "1" -a ! -e $(mapFind "$pluginManagerTableName" "path")/plug.vim ]; then
  echo "install vim-plug";
  curl -fLo $(mapFind "$pluginManagerTableName" "path")/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim;
fi

for target in $(mapKeys "$targetTableName"); do

  targetFile=$(mapFind "$targetTableName" "$target")
  sourceFile=$(mapFind "$sourceTableName" "$target")

  if [ "$target" == "vimrc" ]; then

    dirType="vim"

  else

    dirType="nvim"

  fi

  dir=$(mapFind "$dirTableName" "$dirType")

  installFile $sourceFile $dir/$targetFile $target

done
