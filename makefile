OS ?= $(shell uname -s)

PWSH      := powershell
PWSHFLAGS := -NoProfile

scriptDir := Scripts

.PHONY: default
default: copy

.PHONY: copy
copy:
ifeq "${OS}" "Windows_NT"
	@${PWSH} ${PWSHFLAGS} ./${scriptDir}/copy.ps1
else
	@./${scriptDir}/copy.sh
endif

.PHONY: install
install:
ifeq "${OS}" "Windows_NT"
	@${PWSH} ${PWSHFLAGS} ./${scriptDir}/install.ps1
else
	@./${scriptDir}/install.sh
endif

.PHONY: uninstall
uninstall:
ifeq "${OS}" "Windows_NT"
	@${PWSH} ${PWSHFLAGS} ./${scriptDir}/uninstall.ps1
else
	@./${scriptDir}/uninstall.sh
endif

.PHONY: sync
sync:
ifeq "${OS}" "Windows_NT"
	@${PWSH} ${PWSHFLAGS} ./${scriptDir}/sync.ps1
else
	@./${scriptDir}/sync.sh
endif

.PHONY: sync-main-to-local
sync-main-to-local:
ifeq "${OS}" "Windows_NT"
	@${PWSH} ${PWSHFLAGS} ./${scriptDir}/sync.ps1 $@
else
	@./${scriptDir}/sync.sh $@
endif

.PHONY: sync-main-from-local
sync-main-from-local:
ifeq "${OS}" "Windows_NT"
	@${PWSH} ${PWSHFLAGS} ./${scriptDir}/sync.ps1 $@
else
	@./${scriptDir}/sync.sh $@
endif

.PHONY: sync-to-local
sync-to-local:
ifeq "${OS}" "Windows_NT"
	@${PWSH} ${PWSHFLAGS} ./${scriptDir}/sync.ps1 $@
else
	@./${scriptDir}/sync.sh $@
endif

.PHONY: test
test:
ifeq "${OS}" "Windows_NT"
	@${PWSH} ${PWSHFLAGS} ./${scriptDir}/test.ps1
else
	@./${scriptDir}/test.sh
endif
