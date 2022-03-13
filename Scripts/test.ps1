Set-Variable -Option Constant passColor 'Green'
Set-Variable -Option Constant failColor 'Red'

$env:GIT_EDITOR = 'powershell -NoProfile -Command Write-Host'
$rootDir        = Get-Location
$testDir        = "${rootDir}/Test"
$sourceDir      = "${testDir}/Source"
$targetDir      = "${testDir}/Target"
$logDir         = "${testDir}/Logs"
$targetFile     = "testTarget.txt"
$isTestPass     = $True

Function main()
{
  $oses = "Linux",
          "Windows",
          "Macos"

  $tests =  "copy",
            "uninstall",
            "install",
            "sync-main-to-local",
            "sync-main-from-local",
            "sync-to-local"

  New-Item -ItemType Directory -Force ${sourceDir}  > $null
  New-Item -ItemType Directory -Force ${logDir}     > $null
  
  ForEach( $os in ${oses} )
  {
    osNameToOsEnv $os
  
    $osTargetDir = "${targetDir}/${os}"
  
    New-Item -ItemType Directory -Force ${osTargetDir}  > $null
    New-Item -Force ${osTargetDir}/${targetFile}        > $null

    ForEach( $test in $tests )
    {
      testMakefileTarget $test $os
    }
  }
  If( $isTestPass )
  {
    Remove-Item -Recurse -Force ${testDir}
  }
}

# test infrastructures
Function osNameToOsEnv( $os )
{
  Switch( ${os} )
  {
    "Linux"    { $env:OS = "Linux"      }
    "Windows"  { $env:OS = "Windows_NT" }
    "Macos"    { $env:OS = "Darwin"     }
  }
}

Function testMakefileTarget( $target, $os )
{
  $log = "${logDir}/${target}_${os}.log"

  prepareTest $target > $log 2>&1

  Write-Host "[Test makefile target '$target']"
  testInput $target | make --no-print-directory $target > $log 2>&1

  If( $LastExitCode -eq 0 )
  {
    Write-Host -ForegroundColor $passColor 'Test pass'
    Remove-Item -Force $log
  }
  Else
  {
    Write-Host -ForegroundColor $failColor 'Test fail'
    $isTestPass = $False
  }
  cleanupTest
}

Function testInput( $target )
{
  Switch( $target )
  {
    'sync-main-from-local'  { Write-Output ':qa' }
    'sync-to-local'         { Write-Output ':qa' }
  }
}

Function prepareTest( $target )
{
  Switch( $target )
  {
    'sync-main-to-local'    { prepareTestSyncRemoteToLocal      }
    'sync-main-from-local'  { prepareTestSyncMainFromLocal      }
    'sync-to-local'         { prepareTestSyncMainToLocalMachine }
  }
}

Function cleanupTest( $target )
{
  Switch( $target )
  {
    Default {}
  }
  Set-Location ${rootDir}
}
# end test infrastructures

# individual test settings
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
# end individual test settings

main
