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

for target in $(mapKeys "$targetTableName"); do

  targetFile=$(mapFind "$targetTableName" "$target")
  sourceFile=$(mapFind "$sourceTableName" "$target")

  dir=$(mapFind "$dirTableName" "target")

  installFile $sourceFile $dir/$targetFile $target

done

while read extension; do
  echo "install ${extension}";
  code --install-extension ${extension}
done < extensions
