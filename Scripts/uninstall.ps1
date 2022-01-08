$settingFile = "./settings.toml"

$scriptDir = "$(Split-Path $PSCommandPath )"

. ${scriptDir}/readSettings.ps1 $settingFile

Function removeFile()
{
  $file = $args[0]

  Write-Host "uninstall $file"
  Remove-Item -Force -ErrorAction SilentlyContinue $file
}

ForEach( $target in $settings['target'].keys )
{
  $targetFile = Invoke-Expression "Write-Output $($settings['target'][$target])"
  $dir        = Invoke-Expression "Write-Output $($settings['dir']['target'])"

  removeFile $dir/$targetFile 
}
