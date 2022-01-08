#!/bin/sh
settingFile="./settings.toml"

scriptDir="$(dirname $0)"

. ${scriptDir}/readSettings.sh ${settingFile}

removeFile()
{
  local file=$1

  echo "remove $file"
  rm $file
}

targetTableName=$(mapFind "settings" "target")
dirTableName=$(mapFind "settings" "dir")
pluginManagerTableName=$(mapFind "settings" "pluginManager")

for target in $(mapKeys "$targetTableName"); do

  targetFile=$(mapFind "$targetTableName" "$target")

  if [ "$target" == "vimrc" ]; then

    dirType="vim"

  else

    dirType="nvim"

  fi

  dir=$(mapFind "$dirTableName" "$dirType")

  removeFile $dir/$targetFile

done

if [ -e "$(mapFind "$pluginManagerTableName" "path")/plug.vim" ]; then
  removeFile "$(mapFind "$pluginManagerTableName" "path")/plug.vim"
fi
