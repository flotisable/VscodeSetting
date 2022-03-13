#!/bin/sh
export GIT_EDITOR='cat'

rootDir=$(pwd)
testDir="${rootDir}/Test"
sourceDir="${testDir}/Source"
targetDir="${testDir}/Target"
logDir="${testDir}/Logs"
targetFile="testTarget.txt"
isTestPass=1

main()
{
  local oses="
  Linux
  Windows
  Macos
  "

  local tests="
  copy
  uninstall
  install
  sync-main-to-local
  sync-main-from-local
  sync-to-local
  "

  mkdir -p ${sourceDir}
  mkdir -p ${logDir}

  for os in ${oses}; do
  
    osNameToOsEnv $os
  
    osTargetDir="${targetDir}/${os}"
  
    mkdir -p ${osTargetDir}
    touch ${osTargetDir}/${targetFile}

    for test in $tests; do
      testMakefileTarget $test $os
    done
  
  done
  
  if [ $isTestPass -eq 1 ]; then
    rm -rf ${testDir}
  fi
}

# test infrastructure
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

testMakefileTarget()
{
  local target=$1
  local os=$2

  local log="${logDir}/${target}_${os}.log"

  prepareTest $target > $log 2>&1

  echo "[Test makefile target '$target']"
  testInput $target | make --no-print-directory $target > $log 2>&1

  if [ $? -eq 0 ]; then
    setPassColor
    echo 'Test pass'
    rm -f $log
  else
    setFailColor
    echo 'Test fail'
    isTestPass=0
  fi
  resetColor

  cleanupTest $target
}

testInput()
{
  local target=$1

  case $target in

    sync-main-from-local) echo ':qa';;
    sync-to-local)        echo ':qa';;

  esac
}

prepareTest()
{
  local target=$1

  case $target in

    sync-main-to-local)   prepareTestSyncRemoteToLocal;;
    sync-main-from-local) prepareTestSyncMainFromLocal;;
    sync-to-local)        prepareTestSyncMainToLocalMachine;;

  esac
}

cleanupTest()
{
  local target=$1

  case $target in

    *) ;;

  esac

  cd ${rootDir}
}
# end test infrastructure

# individual test settings
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
# end individual test settings

main
