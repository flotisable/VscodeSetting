#!/bin/sh

. ./settings

# setup variables 
if [ ${vscodeSettingsDir} = "" ]; then
  vscodeSettingsDir=$(./defaultPath.sh);
fi

vscodeSettingPath=${vscodeSettingsDir}/${vscodeSettingName}
vscodeKeybindingPath=${vscodeSettingsDir}/${vscodeKeybindingName}
vscodeLocalePath=${vscodeSettingsDir}/${vscodeSettingName}
# end setup variables 

# install
if [ ${installSetting} -eq 1 ]; then
  echo "install setting"
  #mv ./${vscodeSettingSource} ${vscodeSettingPath}
fi

if [ ${installKeybinding} -eq 1 ]; then
  echo "install keybinding"
  #mv ./${vscodeKetbindingSource} ${vscodeKetbindingPath}
fi

if [ ${installLocale} -eq 1 ]; then
  echo "install locale"
  #mv ./${vscodeLocaleSource} ${vscodeLocalePath}
fi

while read extension; do
  echo ${extension};
  #code --install-extension ${extension}
done < extensions
# end install
