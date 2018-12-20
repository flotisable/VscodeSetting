#!/bin/sh

. ./settings

# setup variables 
if [ -z ${vscodeSettingsDir} ]; then
  vscodeSettingsDir=$(./defaultPath.sh ${os});
fi

vscodeSettingPath=${vscodeSettingsDir}/${vscodeSettingName}
vscodeKeybindingPath=${vscodeSettingsDir}/${vscodeKeybindingName}
vscodeLocalePath=${vscodeSettingsDir}/${vscodeLocaleName}
# end setup variables 

# install
if [ ${installSetting} -eq 1 ]; then
  echo "install setting"
  cp ./${vscodeSettingSource} ${vscodeSettingPath}
fi

if [ ${installKeybinding} -eq 1 ]; then
  echo "install keybinding"
  cp ./${vscodeKeybindingSource} ${vscodeKeybindingPath}
fi

if [ ${installLocale} -eq 1 ]; then
  echo "install locale"
  cp ./${vscodeLocaleSource} ${vscodeLocalePath}
fi

while read extension; do
  echo "install ${extension}";
  code --install-extension ${extension}
done < extensions
# end install
