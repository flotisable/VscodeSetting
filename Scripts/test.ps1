$oses = "Linux",
        "Windows",
        "Macos"

$testDir     = "Test"
$sourceDir   = "${testDir}/Source"
$targetDir   = "${testDir}/Target"
$targetFile  = "testTarget.txt"

New-Item -ItemType Directory -Force ${sourceDir} > $null

ForEach( $os in ${oses} )
{
  Switch( ${os} )
  {
    "Linux"    { $env:OS = "Linux"      }
    "Windows"  { $env:OS = "Windows_NT" }
    "Macos"    { $env:OS = "Darwin"     }
  }
  $osTargetDir = "${targetDir}/${os}"

  New-Item -ItemType Directory -Force ${osTargetDir} > $null
  New-Item ${osTargetDir}/${targetFile} > $null
  make --no-print-directory copy
  make --no-print-directory uninstall
  make --no-print-directory install
}
Remove-Item -Recurse -Force ${testDir}
