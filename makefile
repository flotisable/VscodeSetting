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
sync: sync-main-to-local sync-from-local sync-main-from-local sync-to-remote
	@${MAKE} sync-to-local --no-print-directory

.PHONY: sync-init
sync-init:
	@$(if $(shell ${GIT} show-ref ${localBranch}), \
		$(shell), \
		${GIT} update-ref refs/heads/${localBranch} $(word 1,$(shell ${GIT} show-ref ${mainBranch})))

.PHONY: sync-main-to-local
sync-main-to-local: sync-init sync-from-remote
	@$(if $(shell ${GIT} diff-tree ${mainBranch} ${localBranch}), \
		$(info [Sync branch ${mainBranch} to branch ${localBranch}]))
	@${GIT} checkout -q ${localBranch}
ifeq "${OS}" "Windows_NT"
	@powershell -NoProfile -Command 'If( "$$( ${GIT} diff-tree ${mainBranch} ${localBranch} )" -ne "" ) \
	{ \
		${GIT} merge ${mainBranch}; \
		${GIT} mergetool; \
	}'
	@powershell -NoProfile -Command 'If( "$$( ${GIT} diff-index --cached HEAD )" -ne "" ) \
	{ \
		${GIT} commit; \
	}'
else
	@if [ -n "$$( ${GIT} diff-tree ${mainBranch} ${localBranch} )" ]; then \
		${GIT} merge ${mainBranch}; \
		${GIT} mergetool; \
	fi
	@if [ -n "$$( ${GIT} diff-index --cached HEAD )" ]; then \
		${GIT} commit; \
	fi
endif

.PHONY: sync-from-remote
sync-from-remote: sync-init
	$(info [Sync branch ${mainBranch} from remote])
	@${GIT} checkout -q ${mainBranch}
	@${GIT} fetch
ifeq "${OS}" "Windows_NT"
	@powershell -NoProfile -Command 'If( "$$( ${GIT} diff-tree ${mainBranch} ${remoteBranchFull} )" -ne "" ) \
	{ \
		${GIT} pull \
	}'
else
	@if [ -n "$$( ${GIT} diff-tree ${mainBranch} ${remoteBranchFull} )" ]; then \
		${GIT} pull; \
	fi
endif

.PHONY: sync-from-local
sync-from-local: sync-init
	$(info [Sync branch ${localBranch} from local machine])
	@${GIT} checkout -q ${localBranch}
	@${MAKE} copy --no-print-directory
ifeq "${OS}" "Windows_NT"
	@powershell -NoProfile -Command '${GIT} update-index --refresh; \
	If( "$$( ${GIT} diff-index HEAD )" ) \
	{ \
		${GIT} add -i; \
		If( "$$( ${GIT} diff-index --cached HEAD )" ) \
		{ \
			${GIT} commit; \
		}; \
	}'
else
	@${GIT} update-index --refresh || true
	@if [ -n "$$( ${GIT} diff-index HEAD )" ]; then \
		${GIT} add -i; \
		if [ -n "$$( ${GIT} diff-index --cached HEAD )" ]; then \
			${GIT} commit; \
		fi; \
	fi
endif

.PHONY: sync-main-from-local
sync-main-from-local: sync-init
	$(info [Sync branch ${mainBranch} from local machine])
	@${GIT} checkout -q ${localBranch}
	@${MAKE} copy --no-print-directory
ifeq "${OS}" "Windows_NT"
	@powershell -NoProfile -Command '${GIT} update-index --refresh; \
	If( "$$( ${GIT} diff-index HEAD )" ) \
	{ \
		${GIT} stash -q; \
		${GIT} checkout -q ${mainBranch}; \
		${GIT} stash apply -q; \
		${GIT} mergetool; \
		${GIT} add -i; \
		If( "$$( ${GIT} diff-index --cached HEAD )" ) \
		{ \
			${GIT} commit; \
		}; \
		${GIT} stash drop -q; \
	}'
else
	@${GIT} update-index --refresh || true
	@if [ -n "$$( ${GIT} diff-index HEAD )" ]; then \
		${GIT} stash -q; \
		${GIT} checkout -q ${mainBranch}; \
		${GIT} stash apply -q; \
		${GIT} mergetool; \
		${GIT} add -i; \
		if [ -n "$$( ${GIT} diff-index --cached HEAD )" ]; then \
			${GIT} commit; \
		fi; \
		${GIT} stash drop -q; \
	fi
endif

.PHONY: sync-to-remote
sync-to-remote:
	$(info [Sync branch ${mainBranch} to remote])
	@${GIT} checkout -q ${mainBranch}
	@${GIT} fetch
ifeq "${OS}" "Windows_NT"
	@powershell -NoProfile -Command 'If( "$$( ${GIT} diff-tree ${mainBranch} ${remoteBranchFull} )" -ne "" ) \
	{ \
		$$isPush = Read-Host "Push commits to remote server?[y/n]"; \
		If( $$isPush -eq "y" ) \
		{ \
			${GIT} push \
		} \
	}'
else
	@if [ -n "$$( ${GIT} diff-tree ${mainBranch} ${remoteBranchFull} )" ]; then \
		echo -n "Push commits to remote server?[y/n]: "; \
		read isPush; \
		if [ "$$isPush" == "y" ]; then \
			${GIT} push; \
		fi \
	fi
endif

.PHONY: sync-to-local
sync-to-local: sync-init sync-main-to-local
	$(info [Sync branch ${localBranch} to local machine])
	@${GIT} checkout -q ${localBranch}
ifeq "${OS}" "Windows_NT"
	@powershell -NoProfile -Command 'If( "$$( ${GIT} diff-index HEAD )" ) \
	{ \
		${GIT} add -i; \
		${GIT} checkout -p; \
	}'
else
	@if [ -n "$$( ${GIT} diff-index HEAD )" ]; then \
		${GIT} add -i; \
		${GIT} checkout -p; \
	fi
endif
	@${MAKE} install --no-print-directory
