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

  dir=$(mapFind "$dirTableName" "target")

  if [ -r "$dir/$targetFile" ]; then

    echo "copy $dir/$targetFile to $sourceFile"
    cp $dir/$targetFile $sourceFile

  fi

done
