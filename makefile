include settings

ifeq "${vscodeSettingsDir}" ''
vscodeSettingsDir := $(shell ./defaultPath.sh ${os})
endif

vscodeSettingPath    := ${vscodeSettingsDir}/${vscodeSettingName}
vscodeKeybindingPath := ${vscodeSettingsDir}/${vscodeKeybindingName}
vscodeLocalePath     := ${vscodeSettingsDir}/${vscodeLocaleName}

.PHONY: default

default: ${vscodeSettingPath} ${vscodeKeybindingPath} ${vscodeLocalePath}
	cp $^ .

install:
	./install.sh
