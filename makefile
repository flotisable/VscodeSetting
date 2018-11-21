include settings

ifeq "${vscodeSettingsDir}" ''
vscodeSettingsDir := $(shell ./defaultPath.sh ${os})
endif

vscodeSettingPath    := ${vscodeSettingsDir}/${vscodeSettingName}
vscodeKeybindingPath := ${vscodeSettingsDir}/${vscodeKeybindingName}
vscodeLocalePath     := ${vscodeSettingsDir}/${vscodeLocaleName}

vscodeSettingFiles := \
	${vscodeSettingPath} \
	${vscodeKeybindingPath} #\
	${vscodeLocalePath}

.PHONY: default

default: ${vscodeSettingFiles}
	cp ${vscodeSettingPath} .
	cp ${vscodeKeybindingPath} .
	#cp ${vscodeLocalePath} .

install:
	./install.sh
