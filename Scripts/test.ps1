$oses = "Linux",
        "Windows",
        "Macos"

Function osNameToOsEnv( $os )
{
  Switch( ${os} )
  {
    "Linux"    { $env:OS = "Linux"      }
    "Windows"  { $env:OS = "Windows_NT" }
    "Macos"    { $env:OS = "Darwin"     }
  }
}

Function testMakefileTarget( $target )
{
  Write-Host "[Test makefile target '$target']"
  make --no-print-directory $target
}

$testDir     = "Test"
$sourceDir   = "${testDir}/Source"
$targetDir   = "${testDir}/Target"
$targetFile  = "testTarget.txt"

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
}
Remove-Item -Recurse -Force ${testDir}
