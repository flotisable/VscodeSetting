$settingFile = "./settings.toml"

$scriptDir = "$(Split-Path $PSCommandPath)"

. ${scriptDir}/readSettings.ps1 $settingFile

$root           = Invoke-Expression "Write-Output $($settings['dir']['root'])"
$rcRoot         = ( Get-Item ${scriptDir}/../Settings/$os ).FullName
$rcRootPattern  = "$( $rcRoot -replace '\\', '\\' )\\"

ForEach( $file in ( Get-ChildItem -Recurse -FollowSymlink -File $rcRoot ).FullName )
{
  $file       = $file -replace $rcRootPattern, ""
  $sourceFile = "$rcRoot/$file"
  $targetFile = "$root/$file"

  If( !( Get-Item -Force -ErrorAction SilentlyContinue $targetFile ) )
  {
    Continue
  }
  Write-Host "copy $targetFile to $sourceFile"
  Copy-Item $targetFile $sourceFile
}
