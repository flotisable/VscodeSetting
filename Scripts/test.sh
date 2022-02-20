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

testMakefileTarget()
{
  local target=$1

  echo "[Test makefile target '$target']"
  make --no-print-directory $target
}

testDir="Test"
sourceDir="${testDir}/Source"
targetDir="${testDir}/Target"
targetFile="testTarget.txt"

mkdir -p ${sourceDir}

for os in ${oses}; do

  osNameToOsEnv $os

  osTargetDir="${targetDir}/${os}"

  mkdir -p ${osTargetDir}
  touch ${osTargetDir}/${targetFile}
  testMakefileTarget copy
  testMakefileTarget uninstall
  testMakefileTarget install

done

rm -rf ${testDir}
