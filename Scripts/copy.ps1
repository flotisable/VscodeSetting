$settingFile = "./settings.toml"

$scriptDir = "$(Split-Path $PSCommandPath)"

. ${scriptDir}/readSettings.ps1 $settingFile

ForEach( $target in $settings['target'].keys )
{
  $targetFile = Invoke-Expression "Write-Output $($settings['target'][$target])"
  $sourceFile = Invoke-Expression "Write-Output $($settings['source'][$target])"
  If( $target -eq 'vimrc' )
  {
    $dirType  = 'vim'
  }
  Else
  {
    $dirType  = 'nvim'
  }
  $dir        = Invoke-Expression "Write-Output $($settings['dir'][$dirType])"

  If( !( Get-Item -Force -ErrorAction SilentlyContinue $dir/$targetFile ) )
  {
    Continue
  }
  Write-Host "copy $dir/$targetFile to $sourceFile"
  Copy-Item $dir/$targetFile $sourceFile
}
