Param( $settingFile )

Function parseValue()
{
  $value = $args[0]

  $value = $value -replace '^\s*"', ''
  $value = $value -replace '"\s*$', ''

  If( $value -is 'String' -and $value -eq 'true'   ) { $value = $True  }
  If( $value -is 'String' -and $value -eq 'false'  ) { $value = $False }

  return $value
}

Function parseToml()
{
  $file = $args[0]

  $toml         = @{}
  $currentTable = $toml
  $isParseArray = $False
  $arrayKey     = $null

  ForEach( $line in Get-Content $file )
  {
    If( $line -match '^\s*#' )
    {
      Continue
    }

    If( $isParseArray )
    {
      If( $line -match '\]\s*$' )
      {
        $isParseArray = $False
        $currentTable[$arrayKey][0] = $currentTable[$arrayKey][0] -replace '^\s*\[\s*', ''
        $currentTable[$arrayKey][0] = $currentTable[$arrayKey][0] -replace '\s*\]\s*$', ''
        $currentTable[$arrayKey][0] = $currentTable[$arrayKey][0] -replace '\s*,\s*', ''
        $currentTable[$arrayKey] = -split $currentTable[$arrayKey][0]
      }
      Else
      {
        $currentTable[$arrayKey][0] += $line
      }

      Continue
    }

    If( $line -match '\[(?<tableName>\w+)\]' )
    {
      $toml[$Matches.tableName] = @{}
      $currentTable             = $toml[$Matches.tableName]
      Continue
    }

    If( $line -match '(?<key>\w+)\s*=\s*(?<value>\S+)' )
    {
      $key    = $Matches.key
      $value  = $Matches.value

      If( $Matches.value -match '\[[^\]]*$' )
      {
        $isParseArray       = $True
        $currentTable[$key] = @( $value )
        $arrayKey           = $key
      }
      Else
      {
        $currentTable[$key] = parseValue( $value )
      }
    }
  }

  return $toml
}

Function osToKey()
{
  If( $env:OS -eq $null )
  {
    $env:OS = $(uname -s)
  }

  Switch( $env:OS )
  {
    Linux       { return "Linux"    }
    Windows_NT  { return "Windows"  }
    Darwin      { return "MacOs"    }
  }
}

$os = osToKey
Write-Host "detected OS: $os"

$settings = parseToml $settingFile
