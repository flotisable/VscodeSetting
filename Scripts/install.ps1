$settingFile = "./settings.toml"

$scriptDir = "$(Split-Path $PSCommandPath )"

. ${scriptDir}/readSettings.ps1 $settingFile

$pluginManagerPath = Invoke-Expression "Write-Output $($settings['pluginManager']['path'])"

If( $settings['pluginManager']['install'] -and
    -not $(Get-Item -Path "${pluginManagerPath}/plug.vim" -ErrorAction SilentlyContinue) )
{
  Write-Host "install vim-plug"
  curl.exe -fLo ${pluginManagerPath}/plug.vim --create-dirs `
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

ForEach( $target in $settings['target'].keys )
{
  $targetFile = Invoke-Expression "Write-Output $($settings['target'][$target])"
  $sourceFile = Invoke-Expression "Write-Output $($settings['source'][$target])"
  If( $target -eq 'vimrc' )
  {
    $dirType = 'vim'
  }
  Else
  {
    $dirType = 'nvim'
  }
  $dir        = Invoke-Expression "Write-Output $($settings['dir'][$dirType])"

  Write-Host "install $sourceFile"
  Copy-Item $sourceFile $dir/$targetFile 
}
