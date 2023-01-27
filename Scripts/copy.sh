#!/bin/sh
settingFile="./settings.toml"

scriptDir="$(dirname $0)"

. ${scriptDir}/readSettings.sh ${settingFile}

dirTableName=$(mapFind "settings" "dir")

root=$(mapFind "$dirTableName" "root")

for file in $(find -L "Settings/$os" -type f -printf '%P\n'); do

  targetFile="$root/$file"
  sourceFile="Settings/$os/$file"

  if [ ! -r "$targetFile" ]; then
    continue
  fi

  echo "copy $targetFile to $sourceFile"
  cp $targetFile $sourceFile

done
