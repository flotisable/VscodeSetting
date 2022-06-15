#!/bin/sh
target=$1

settingFile="./settings.toml"

scriptRoot="$(dirname $(readlink -f $0))"

. ${scriptRoot}/readSettings.sh ${settingFile}

mainBranch="$(mapFind $(mapFind 'settings' 'branch') 'main')"
localBranch="$(mapFind $(mapFind 'settings' 'branch') 'local')"
remote="$(git config --get branch.${mainBranch}.remote)"
remoteBranch="$(git config --get branch.${mainBranch}.merge | sed 's:refs/heads/::')"
remoteBranchFull="${remote}/${remoteBranch}"

main()
{
  local target=$1
  
  init

  case $target in

    sync-main-to-local)
      syncFromRemote
      syncMainToLocal
      ;;
    sync-main-from-local)
      syncFromLocal
      syncMainFromLocal
      ;;
    sync-to-local)
      syncToLocal
      ;;
    *)
      syncFromRemote
      syncMainToLocal

      syncFromLocal
      syncMainFromLocal

      syncToRemote

      syncMainToLocal
      syncToLocal
      ;;

  esac
}

init()
{
  if [ -z "$(git show-ref ${localBranch})" ]; then
    git update-ref "refs/heads/${localBranch}" "$(git show-ref ${mainBranch} | head -n 1 | awk '{ print $1 }')"
  fi
}

syncMainToLocal()
{
  git checkout -q ${localBranch}

  if [ $? -ne 0 ]; then
    exit 1
  fi

  if [ -n "$(git diff-tree ${mainBranch} ${localBranch})" ]; then

    echo "[Sync branch ${mainBranch} to branch ${localBranch}]"
    git merge ${mainBranch}
    git mergetool

    if [ -z "$(git diff-index --cached HEAD)" ]; then
      return
    fi

    git commit
  fi
}

syncFromRemote()
{
  echo "[Sync branch ${mainBranch} from remote]"
  git checkout -q ${mainBranch}

  if [ $? -ne 0 ]; then
    exit 1
  fi

  git fetch

  if [ -z "$(git diff-tree ${mainBranch} ${remoteBranchFull})" ]; then
    return
  fi

  git merge ${remoteBranchFull}
}

syncFromLocal()
{
  echo "[Sync branch ${localBranch} from local machine]"

  git checkout -q ${localBranch}

  if [ $? -ne 0 ]; then
    exit 1
  fi

  ${scriptRoot}/copy.sh
  git update-index --refresh

  if [ -z "$(git diff-index HEAD)" ]; then
    return
  fi

  git add -i

  if [ -z "$(git diff-index --cached HEAD)" ]; then
    return
  fi

  git commit
}

# assume already in local branch
syncMainFromLocal()
{
  echo "[Sync branch ${mainBranch} from local machine]"

  if [ -z "$(git diff-index HEAD)" ]; then
    return
  fi

  git stash -q
  git checkout -q ${mainBranch}
  git stash apply -q
  git mergetool
  git add -i

  if [ -n "$(git diff-index --cached HEAD)" ]; then
    git commit
  fi

  git stash drop -q
}

# assume git fetch is already run
syncToRemote()
{
  echo "[Sync branch ${mainBranch} to remote]"
  git checkout -q ${mainBranch}

  if [ $? -ne 0 ]; then
    exit 1
  fi

  if [ -z "$(git diff-tree ${mainBranch} ${remoteBranchFull})" ]; then
    return
  fi

  echo -n "Push commits to remote server?[y/n]: "
  read isPush

  if [ "$isPush" != "y" ]; then
    return
  fi

  git push
}

syncToLocal()
{
  local isStashNeeded=0

  echo "[Sync branch ${localBranch} to local machine]"

  if [ -n "$(git diff-index HEAD)" ]; then
    isStashNeeded=1
  fi

  if [ $isStashNeeded -eq 1 ]; then
    git stash -q
  fi

  git checkout -q ${localBranch}

  if [ $isStashNeeded -eq 1 ]; then

    git stash apply -q
    git mergetool

  fi

  if [ -n "$(git diff-index HEAD)" ]; then

    git add -i
    git checkout -p

  fi
  $scriptRoot/install.sh

  if [ $isStashNeeded -eq 1 ]; then
    git stash drop -q
  fi
}

main $target
