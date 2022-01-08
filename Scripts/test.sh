#!/bin/sh
oses="
Linux
Windows
Macos
"

testDir="Test"
sourceDir="${testDir}/Source"
targetDir="${testDir}/Target"
targetFile="testTarget.txt"

mkdir -p ${sourceDir}

for os in ${oses}; do

  case ${os} in

    Linux)    export OS="Linux";;
    Windows)  export OS="Windows_NT";;
    Macos)    export OS="Darwin";;

  esac

  osTargetDir="${targetDir}/${os}"

  mkdir -p ${osTargetDir}
  touch ${osTargetDir}/${targetFile}
  make --no-print-directory copy
  make --no-print-directory uninstall
  make --no-print-directory install

done

rm -rf ${testDir}
