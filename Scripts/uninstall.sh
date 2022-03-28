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

for target in $(mapKeys "$targetTableName"); do

  targetFile=$(mapFind "$targetTableName" "$target")

  dir=$(mapFind "$dirTableName" "target")

  removeFile $dir/$targetFile

done
