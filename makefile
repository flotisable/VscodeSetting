OS ?= $(shell uname -s)

PWSH      := powershell
PWSHFLAGS := -NoProfile
PERL      := perl

scriptDir := Scripts

ifeq "${OS}" "Windows_NT"
	runScript = ${PWSH} ${PWSHFLAGS} ./${scriptDir}/${1}.ps1 ${2}
else
	runScript = ./${scriptDir}/${1}.sh ${2}
endif

.PHONY: default
default: copy

.PHONY: copy
copy:
	@$(call runScript,$@,)

.PHONY: install
install:
	@$(call runScript,$@,)

.PHONY: uninstall
uninstall:
	@$(call runScript,$@,)

.PHONY: sync
sync:
	@$(call runScript,$@,)

.PHONY: sync-main-to-local
sync-main-to-local:
	@$(call runScript,sync,$@)

.PHONY: sync-main-from-local
sync-main-from-local:
	@$(call runScript,sync,$@)

.PHONY: sync-to-local
sync-to-local:
	@$(call runScript,sync,$@)
