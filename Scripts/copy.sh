#!/bin/sh
settingFile="./settings.toml"

scriptDir="$(dirname $0)"

. ${scriptDir}/readSettings.sh ${settingFile}

targetTableName=$(mapFind "settings" "target")
sourceTableName=$(mapFind "settings" "source")
dirTableName=$(mapFind "settings" "dir")

for target in $(mapKeys "$targetTableName"); do

  targetFile=$(mapFind "$targetTableName" "$target")
  sourceFile=$(mapFind "$sourceTableName" "$target")

  if [ "$target" == "vimrc" ]; then

    dirType="vim"

  else

    dirType="nvim"

  fi

  dir=$(mapFind "$dirTableName" "$dirType")

  if [ -r "$dir/$targetFile" ]; then

    echo "copy $dir/$targetFile to $sourceFile"
    cp $dir/$targetFile $sourceFile

  fi

done
