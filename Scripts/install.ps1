$settingFile = "./settings.toml"

$scriptDir = "$(Split-Path $PSCommandPath )"

. ${scriptDir}/readSettings.ps1 $settingFile

ForEach( $target in $settings['target'].keys )
{
  $targetFile = Invoke-Expression "Write-Output $($settings['target'][$target])"
  $sourceFile = Invoke-Expression "Write-Output $($settings['source'][$target])"
  $dir        = Invoke-Expression "Write-Output $($settings['dir']['target'])"

  Write-Host "install $sourceFile"
  Copy-Item $sourceFile $dir/$targetFile 
}
