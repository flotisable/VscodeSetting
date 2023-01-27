#!/bin/sh
settingFile="./settings.toml"

scriptDir="$(dirname $0)"

. ${scriptDir}/readSettings.sh ${settingFile}

removeFile()
{
  local file=$1

  echo "remove $file"
  rm -f $file
}

dirTableName=$(mapFind "settings" "dir")

root=$(mapFind "$dirTableName" "root")

for file in $(find -L "Settings/$os" -type f -printf '%P\n'); do

  targetFile="$root/$file"
  sourceFile="Settings/$os/$file"

  removeFile $targetFile

done
