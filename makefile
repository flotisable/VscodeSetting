OS ?= $(shell uname -s)

GIT := git

scriptDir := Scripts

mainBranch       := master
localBranch      := local
remote           := $(shell ${GIT} config --get branch.${mainBranch}.remote)
remoteBranch     := $(subst refs/heads/,,$(shell ${GIT} config --get branch.${mainBranch}.merge))
remoteBranchFull := ${remote}/${remoteBranch}

.PHONY: default
default: copy

.PHONY: copy
copy:
ifeq "${OS}" "Windows_NT"
	@powershell -NoProfile ./${scriptDir}/copy.ps1
else
	@./${scriptDir}/copy.sh
endif

.PHONY: install
install:
ifeq "${OS}" "Windows_NT"
	@powershell -NoProfile ./${scriptDir}/install.ps1
else
	@./${scriptDir}/install.sh
endif

.PHONY: uninstall
uninstall:
ifeq "${OS}" "Windows_NT"
	@powershell -NoProfile ./${scriptDir}/uninstall.ps1
else
	@./${scriptDir}/uninstall.sh
endif

.PHONY: sync
sync:
ifeq "${OS}" "Windows_NT"
	@powershell -NoProfile ./${scriptDir}/sync.ps1
else
	@./${scriptDir}/sync.sh
endif

.PHONY: sync-main-to-local
sync-main-to-local:
ifeq "${OS}" "Windows_NT"
	@powershell -NoProfile ./${scriptDir}/sync.ps1 $@
else
	@./${scriptDir}/sync.sh $@
endif

.PHONY: sync-main-from-local
sync-main-from-local:
ifeq "${OS}" "Windows_NT"
	@powershell -NoProfile ./${scriptDir}/sync.ps1 $@
else
	@./${scriptDir}/sync.sh $@
endif

.PHONY: sync-to-local
sync-to-local:
ifeq "${OS}" "Windows_NT"
	@powershell -NoProfile ./${scriptDir}/sync.ps1 $@
else
	@./${scriptDir}/sync.sh $@
endif

.PHONY: test
test:
ifeq "${OS}" "Windows_NT"
	@powershell -NoProfile ./${scriptDir}/test.ps1
else
	@./${scriptDir}/test.sh
endif
