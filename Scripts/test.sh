#!/bin/sh
oses="
Linux
Windows
Macos
"

osNameToOsEnv()
{
  local os=$1
  
  case ${os} in

    Linux)    export OS="Linux";;
    Windows)  export OS="Windows_NT";;
    Macos)    export OS="Darwin";;

  esac
}

setPassColor()
{
  if [ -t 1 ]; then
    tput setaf 2
  fi
}

setFailColor()
{
  if [ -t 1 ]; then
    tput setaf 1
  fi
}

resetColor()
{
  if [ -t 1 ]; then
    tput op
  fi
}

testInput()
{
  local target=$1

  case $target in

    sync-main-from-local) echo ':qa';;
    sync-to-local)        echo ':qa';;

  esac
}

testMakefileTarget()
{
  local target=$1

  case $target in

    sync-main-to-local)   prepareTestSyncRemoteToLocal      > /dev/null 2>&1;;
    sync-main-from-local) prepareTestSyncMainFromLocal      > /dev/null 2>&1;;
    sync-to-local)        prepareTestSyncMainToLocalMachine > /dev/null 2>&1;;

  esac

  echo "[Test makefile target '$target']"
  testInput $target | make --no-print-directory $target > /dev/null 2>&1

  if [ $? -eq 0 ]; then
    setPassColor
    echo 'Test pass'
  else
    setFailColor
    echo 'Test fail'
  fi
  resetColor

  case $target in

    sync-main-to-local)   cleanupTestSyncRemoteToLocal;;
    sync-main-from-local) cleanupTestSyncMainFromLocal;;
    sync-to-local)        cleanupTestSyncMainToLocalMachine;;

  esac
}

prepareTestSyncRemoteToLocal()
{
  git clone . ${osTargetDir}/remote
  git clone . ${osTargetDir}/local
  cd ${osTargetDir}/local
  git config --local commit.gpgsign             false
  git config --local pull.rebase                false
  git config --local branch.main.mergeOptions   '--strategy=ort --strategy-option=ours'
  git config --local branch.local.mergeOptions  '--strategy=ort --strategy-option=ours'
  git branch -m main
  git branch local
  git checkout main
  git remote add remote ../remote
  git fetch remote
  git branch --set-upstream-to=remote/main
  sed -i '/remoteBranch\s\+:=/ s/\$.\+$/remoteMain/' makefile
  git commit -am 'change remote branch'
  cd ../remote
  git branch -m main
  git config --local commit.gpgsign false
  sed -i '/remoteBranch\s\+:=/ s/\$.\+$/remoteRemote/' makefile
  git commit -am 'change remote branch'
  cd ../local
  git checkout local
  sed -i '/mainBranch/ s/master/main/;/remoteBranch\s\+:=/ s/\$.\+$/main/' makefile
  git commit -am 'change remote branch'
}

cleanupTestSyncRemoteToLocal()
{
  cd ${rootDir}
}

prepareTestSyncMainFromLocal()
{
  git clone . ${osTargetDir}/main
  cd ${osTargetDir}/main
  git branch -m main
  git config --local commit.gpgsign           false
  git config --local branch.main.mergeOptions '--strategy=ort --strategy-option=ours'
  sed -i '/mainBranch\s\+:=/ s/master/main/' makefile
  git commit -am 'change main branch'
  git checkout -b local
  sed -i '/remoteBranch\s\+:=/ s/\$.\+$/remoteLocal/' makefile
  git commit -am 'change remote branch'
  git checkout main
  sed -i '/remoteBranch\s\+:=/ s/\$.\+$/remoteMain/' makefile
  git commit -am 'change remote branch'
  git checkout local
  sed -i '/remoteBranch\s\+:=/ s/remoteLocal/remoteLocalForStash/' makefile
}

cleanupTestSyncMainFromLocal()
{
  cd ${rootDir}
}

prepareTestSyncMainToLocalMachine()
{
  git clone . ${osTargetDir}/toLocalMachine
  cd ${osTargetDir}/toLocalMachine
  git branch -m main
  mkdir -p ${sourceDir}
  touch ${sourceDir}/testSource.txt
  mkdir -p ${osTargetDir}
  git config --local commit.gpgsign             false
  git config --local branch.local.mergeOptions  '--strategy=ort --strategy-option=ours'
  sed -i '/mainBranch\s\+:=/ s/master/main/' makefile
  git commit -am 'change main branch'
  git branch local
  sed -i '/remoteBranch\s\+:=/ s/\$.\+$/remoteMain/' makefile
  git commit -am 'change remote branch'
  git checkout local
  sed -i '/remoteBranch\s\+:=/ s/\$.\+$/remoteLocal/' makefile
  git commit -am 'change remote branch'
  git checkout main
  sed -i '/remoteBranch\s\+:=/ s/remoteMain/main/' makefile
}

cleanupTestSyncMainToLocalMachine()
{
  cd ${rootDir}
}

export GIT_EDITOR='cat'

testDir="Test"
sourceDir="${testDir}/Source"
targetDir="${testDir}/Target"
targetFile="testTarget.txt"
rootDir=$(pwd)

mkdir -p ${sourceDir}

for os in ${oses}; do

  osNameToOsEnv $os

  osTargetDir="${targetDir}/${os}"

  mkdir -p ${osTargetDir}
  touch ${osTargetDir}/${targetFile}
  testMakefileTarget copy
  testMakefileTarget uninstall
  testMakefileTarget install
  testMakefileTarget sync-main-to-local
  testMakefileTarget sync-main-from-local
  testMakefileTarget sync-to-local

done

rm -rf ${testDir}
