$settingFile = "./settings.toml"

$scriptDir = "$(Split-Path $PSCommandPath )"

. ${scriptDir}/readSettings.ps1 $settingFile

$root           = Invoke-Expression "Write-Output $($settings['dir']['root'])"
$rcRoot         = ( Get-Item ${scriptDir}/../Settings/$os ).FullName
$rcRootPattern  = "$( $rcRoot -replace '\\', '\\' )\\"

Function removeFile()
{
  $file = $args[0]

  Write-Host "uninstall $file"
  Remove-Item -Force -ErrorAction SilentlyContinue $file
}

ForEach( $file in ( Get-ChildItem -Recurse -FollowSymlink -File $rcRoot ).FullName )
{
  $file       = $file -replace $rcRootPattern, ""
  $targetFile = "$root/$file"

  removeFile $targetFile 
}
