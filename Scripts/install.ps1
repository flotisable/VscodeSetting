$settingFile = "./settings.toml"

$scriptDir = "$(Split-Path $PSCommandPath )"

. ${scriptDir}/readSettings.ps1 $settingFile

$root           = Invoke-Expression "Write-Output $($settings['dir']['root'])"
$rcRoot         = ( Get-Item ${scriptDir}/../Settings/$os ).FullName
$rcRootPattern  = "$( $rcRoot -replace '\\', '\\' )\\"

ForEach( $file in ( Get-ChildItem -Recurse -FollowSymlink -File $rcRoot ).FullName )
{
  $file       = $file -replace $rcRootPattern, ""
  $sourceFile = "$rcRoot/$file"
  $targetFile = "$root/$file"
  $dir        = $(Split-Path -Parent $targetFile)

  If( New-Item -Type Directory -ErrorAction SilentlyContinue $dir)
  {
    Write-Host "create directory" $dir
  }
  Write-Host "install $file"
  Copy-Item $sourceFile $targetFile 
}
If( ! ( Get-Command -ErrorAction SilentlyContinue code ) )
{
  Write-Host "Warning: can not run vscode to install extension"
  Exit
}
ForEach( $extension in $(Get-Content Settings/Root/extensions) )
{
  Write-Host "install ${extension}";
  code --install-extension ${extension}
}
