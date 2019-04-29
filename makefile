OS ?= $(shell uname -s)

include settings

ifeq "${vscodeSettingsDir}" ''
vscodeSettingsDir := $(shell ./defaultPath.sh ${OS})
endif

vscodeSettingPath    := ${vscodeSettingsDir}/${vscodeSettingName}
vscodeKeybindingPath := ${vscodeSettingsDir}/${vscodeKeybindingName}
vscodeLocalePath     := ${vscodeSettingsDir}/${vscodeLocaleName}

vscodeSettingFiles := \
	${vscodeSettingPath} \
	${vscodeKeybindingPath} \
	${vscodeLocalePath}

.PHONY: default

default:
	cp "${vscodeSettingPath}" .
	cp "${vscodeKeybindingPath}" .
	cp "${vscodeLocalePath}" .

install:
	./install.sh
