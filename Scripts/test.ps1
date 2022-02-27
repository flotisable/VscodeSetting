$oses = "Linux",
        "Windows",
        "Macos"

Set-Variable -Option Constant passColor 'Green'
Set-Variable -Option Constant failColor 'Red'

Function osNameToOsEnv( $os )
{
  Switch( ${os} )
  {
    "Linux"    { $env:OS = "Linux"      }
    "Windows"  { $env:OS = "Windows_NT" }
    "Macos"    { $env:OS = "Darwin"     }
  }
}

Function testInput( $target )
{
  Switch( $target )
  {
    'sync-main-from-local' { Write-Output ':qa' }
  }
}

Function testMakefileTarget( $target )
{
  Switch( $target )
  {
    'sync-main-to-local'    { prepareTestSyncRemoteToLocal      > $null 2>&1 }
    'sync-main-from-local'  { prepareTestSyncMainFromLocal      > $null 2>&1 }
    'sync-to-local'         { prepareTestSyncMainToLocalMachine > $null 2>&1 }
  }

  Write-Host "[Test makefile target '$target']"
  testInput $target | make --no-print-directory $target > $null 2>&1

  If( $LastExitCode -eq 0 )
  {
    Write-Host -ForegroundColor $passColor 'Test pass'
  }
  Else
  {
    Write-Host -ForegroundColor $failColor 'Test fail'
  }

  Switch( $target )
  {
    'sync-main-to-local'    { cleanupTestSyncRemoteToLocal      }
    'sync-main-from-local'  { cleanupTestSyncMainFromLocal      }
    'sync-to-local'         { cleanupTestSyncMainToLocalMachine }
  }
}

Function prepareTestSyncRemoteToLocal()
{
  git clone . ${osTargetDir}/remote
  git clone . ${osTargetDir}/local
  Set-Location ${osTargetDir}/local
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
  $(Get-Content makefile) -replace '(remoteBranch\s+:=\s+)\$.+$', '${1}remoteMain' | Set-Content makefile
  git commit -am 'change remote branch'
  Set-Location ../remote
  git branch -m main
  git config --local commit.gpgsign false
  $(Get-Content makefile) -replace '(remoteBranch\s+:=\s+)\$.+$', '${1}remoteRemote' | Set-Content makefile
  git commit -am 'change remote branch'
  Set-Location ../local
  git checkout local
  $(Get-Content makefile) -replace '(mainBranch\s+:=\s+)master',  '${1}main' | Set-Content makefile
  $(Get-Content makefile) -replace '(remoteBranch\s+:=\s+)\$.+$', '${1}main' | Set-Content makefile
  git commit -am 'change remote branch'
}

Function cleanupTestSyncRemoteToLocal()
{
  Set-Location ${rootDir}
}

Function prepareTestSyncMainFromLocal()
{
  git clone . ${osTargetDir}/main
  Set-Location ${osTargetDir}/main
  git branch -m main
  git config --local commit.gpgsign           false
  git config --local branch.main.mergeOptions '--strategy=ort --strategy-option=ours'
  $(Get-Content makefile) -replace '(mainBranch\s+:=\s+)master', '${1}main' | Set-Content makefile
  git commit -am 'change main branch'
  git checkout -b local
  $(Get-Content makefile) -replace '(remoteBranch\s+:=\s+)\$.+$', '${1}remoteLocal' | Set-Content makefile
  git commit -am 'change remote branch'
  git checkout main
  $(Get-Content makefile) -replace '(remoteBranch\s+:=\s+)\$.+$', '${1}remoteMain' | Set-Content makefile
  git commit -am 'change remote branch'
  git checkout local
  $(Get-Content makefile) -replace '(remoteBranch\s+:=\s+)remoteLocal', '${1}remoteLocalForStash' | Set-Content makefile
}

Function cleanupTestSyncMainFromLocal()
{
  Set-Location ${rootDir}
}

Function prepareTestSyncMainToLocalMachine()
{
  git clone . ${osTargetDir}/toLocalMachine
  Set-Location ${osTargetDir}/toLocalMachine
  git branch -m main
  New-Item -ItemType Directory -Force ${sourceDir}
  New-Item ${sourceDir}/testSource.txt
  New-Item -ItemType Directory -Force ${osTargetDir}
  git config --local commit.gpgsign             false
  git config --local branch.local.mergeOptions  '--strategy=ort --strategy-option=ours'
  $(Get-Content makefile) -replace '(mainBranch\s+:=\s+)master', '${1}main' | Set-Content makefile
  git commit -am 'change main branch'
  git branch local
  $(Get-Content makefile) -replace '(remoteBranch\s+:=\s+)\$.+$', '${1}remoteMain' | Set-Content makefile
  git commit -am 'change remote branch'
  git checkout local
  $(Get-Content makefile) -replace '(remoteBranch\s+:=\s+)\$.+$', '${1}remoteLocal' | Set-Content makefile
  git commit -am 'change remote branch'
  git checkout main
  $(Get-Content makefile) -replace '(remoteBranch\s+:=\s+)remoteMain', '${1}main' | Set-Content makefile
}

Function cleanupTestSyncMainToLocalMachine()
{
  Set-Location ${rootDir}
}

$env:GIT_EDITOR = 'powershell -NoProfile -Command Write-Host'
$testDir        = "Test"
$sourceDir      = "${testDir}/Source"
$targetDir      = "${testDir}/Target"
$targetFile     = "testTarget.txt"
$rootDir        = Get-Location

New-Item -ItemType Directory -Force ${sourceDir} > $null

ForEach( $os in ${oses} )
{
  osNameToOsEnv $os

  $osTargetDir = "${targetDir}/${os}"

  New-Item -ItemType Directory -Force ${osTargetDir} > $null
  New-Item ${osTargetDir}/${targetFile} > $null
  testMakefileTarget copy
  testMakefileTarget uninstall
  testMakefileTarget install
  testMakefileTarget sync-main-to-local
  testMakefileTarget sync-main-from-local
  testMakefileTarget sync-to-local
}
Remove-Item -Recurse -Force ${testDir}
