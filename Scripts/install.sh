#!/bin/sh
settingFile="./settings.toml"

scriptDir="$(dirname $0)"

. ${scriptDir}/readSettings.sh ${settingFile}

installFile()
{
  local sourceFile=$1
  local targetFile=$2
  local fileMessage=$3

  local dir
  dir="$(dirname $targetFile)"

  mkdir -vp $dir  
  echo "install $fileMessage"
  cp $sourceFile $targetFile 
}

dirTableName=$(mapFind "settings" "dir")

root=$(mapFind "$dirTableName" "root")

for file in $(find -L "Settings/$os" -type f -printf '%P\n'); do

  targetFile="$root/$file"
  sourceFile="Settings/$os/$file"


  installFile $sourceFile $targetFile $file

done

if ! which code > /dev/null 2>&1; then
  echo "Warning: can not run vscode to install extension"
  exit
fi

while read extension; do
  echo "install ${extension}";
  code --install-extension ${extension}
done < Settings/Root/extensions
