$settingFile = "./settings.toml"

$scriptDir = "$(Split-Path $PSCommandPath )"

. ${scriptDir}/readSettings.ps1 $settingFile

Function removeFile()
{
  $file = $args[0]

  Write-Host "uninstall $file"
  Remove-Item -Force -ErrorAction SilentlyContinue $file
}

$pluginManagerPath = Invoke-Expression "Write-Output $($settings['pluginManager']['path'])"

ForEach( $target in $settings['target'].keys )
{
  $targetFile = Invoke-Expression "Write-Output $($settings['target'][$target])"
  $dirType    = ( $target -eq 'vimrc' ) ? 'vim': 'nvim'
  $dir        = Invoke-Expression "Write-Output $($settings['dir'][$dirType])"

  removeFile $dir/$targetFile 
}

If( $(Get-Item -Path "${pluginManagerPath}/plug.vim" -ErrorAction SilentlyContinue) )
{
  removeFile "${pluginManagerPath}/plug.vim" 
}
