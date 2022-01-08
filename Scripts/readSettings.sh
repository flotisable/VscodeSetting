#!/bin/sh
file=$1

defaultPathFile="./defaultPath.toml"
mapPrefix="_map"

# mapInit <map name>
mapInit()
{
  local name=$1

  eval "${mapPrefix}_${name}="
}

# mapInsert <map name> <key> <value>
mapInsert()
{
  local name=$1
  local key=$2
  local value=$3

  eval  " ${mapPrefix}_${name}+=\"
          $key\"
          ${mapPrefix}_${name}_${key}=\"${value}\"
        "
}

# mapSet <map name> <key> <value>
mapSet()
{
  local name=$1
  local key=$2
  local value=$3

  eval "${mapPrefix}_${name}_${key}='${value}'"
}

# mapFind <map name> <key>
mapFind()
{
  local name=$1
  local key=$2

  eval "echo \${${mapPrefix}_${name}_${key}}"
}

# mapKeys <map name>
mapKeys()
{
  local name=$1

  eval "echo \$${mapPrefix}_${name}"
}

# isMap <map name>
isMap()
{
  local name=$1

  if [ -n "$(eval "echo \"\${${mapPrefix}_${name}+exist}\"")" ]; then

    echo 1

  else

    echo 0

  fi
}

# parseValue <value>
parseValue()
{
  local value=$1

  value=$(echo $value | sed 's/^"//; s/"$//; s/\btrue\b/1/; s/\bfalse\b/0/')

  echo $value
}

# osTokey <os>
osToKey()
{
  case ${OS:-$(uname -s)} in

    Linux       ) echo "linux";;
    Windows_NT  ) echo "windows";;
    Darwin      ) echo "macos";;

  esac
}

# parseToml <file> <map name>
parseToml()
{
  local file=$1
  local mapName=$2

  local tableName="$mapName"
  local isParseArray=0
  local line
  local key
  local value

  mapInit "$mapName"

  while read line; do
  
    if [ -n "$(echo $line | grep '^\s*#')" ]; then

      continue

    fi

    # parse array
    if [ $isParseArray -eq 1 ]; then

      if [ -n "$(echo $line | grep '\]\s*$')" ]; then

        line=$(echo $line | sed 's/\]\s*$//')
        array+="$line"
        mapInsert "$tableName" "$key" "$(echo $array | sed 's/,/ /g' )"
        isParseArray=0

      else

        array+="$line"

      fi

      continue

    fi
    # end parse array

    # parse table
    if [ -n "$(echo $line | grep '\[\w\+\]')" ]; then
  
      tableName="$(echo $line | sed 's/\[\(\w\+\)\]/\1/')"
      mapInsert "$mapName" "$tableName" "$tableName"
      mapInit   "$tableName"
  
    fi
    # end parse table
  
    # parse assignment
    if [ -n "$(echo $line | grep '\w\+\s*=\s*[\"0-9a-zA-Z.]\+')" ]; then
  
      key=$(echo $line | cut -d'=' -f1 | sed 's/\s\+//g')
      value=$(parseValue $(echo $line | cut -d'=' -f2 | sed 's/\s\+//g'))
  
      mapInsert "$tableName" "$key" "$value"
  
    fi

    if [ -n "$(echo $line | grep '\w\+\s*=\s*\[.*')" ]; then
  
      key=$(echo $line | cut -d'=' -f1 | sed 's/\s\+//g')
      array="$(echo $line | cut -d'=' -f2 | sed 's/\s*\[\s*//g')"
      isParseArray=1
  
    fi
    # end parse assignment
  
  done < $file
}

os=$(osToKey)
echo "detected OS: ${os}"

parseToml "$file"             "settings"
parseToml "$defaultPathFile"  "defaults"

dirMapName=$(mapFind "settings" "dir")

# set default values if the target is not set
if [ -z "$(mapFind "$dirMapName" "nvim")" ]; then

  nvimDirMapName=$(mapFind "defaults" "nvimDir")

  mapSet "$dirMapName" "nvim" $(mapFind "$nvimDirMapName" "$os")

fi
# end set default values if the target is not set
