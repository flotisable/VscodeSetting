Param( $target )

$settingFile  = "./settings.toml"
$scriptRoot   = "$PSScriptRoot"

. ${scriptRoot}/readSettings.ps1 $settingFile

$mainBranch       = $settings['branch']['main']
$localBranch      = $settings['branch']['local']
$remote           = "$(git config --get branch.${mainBranch}.remote)"
$remoteBranch     = "$(git config --get branch.${mainBranch}.merge)" -replace 'refs/heads/', ''
$remoteBranchFull = "${remote}/${remoteBranch}"

Function main( $target )
{
  init

  Switch( $target )
  {
    'sync-main-to-local'
    {
      syncFromRemote
      syncMainToLocal
    }
    'sync-main-from-local'
    {
      syncFromLocal
      syncMainFromLocal
    }
    'sync-to-local'
    {
      syncToLocal
    }
    Default
    {
      syncFromRemote
      syncMainToLocal

      syncFromLocal
      syncMainFromLocal

      syncToRemote

      syncMainToLocal
      syncToLocal
    }
  }
}

Function init()
{
  If( "$(git show-ref ${localBranch})" -eq "" )
  {
    git update-ref "refs/heads/${localBranch}" $(-split $(git show-ref ${mainBranch})[0])[0]
  }
}

Function syncMainToLocal()
{
  git checkout -q ${localBranch}

  If( $LastExitCode -ne 0 )
  {
    exit 1
  }
  If( "$(git diff-tree ${mainBranch} ${localBranch})" -eq "" )
  {
    return
  }
  Write-Host "[Sync branch ${mainBranch} to branch ${localBranch}]"
  git merge ${mainBranch}
  git mergetool

  If( "$(git diff-index --cached HEAD)" -eq "" )
  {
    return
  }
  git commit
}

Function syncFromRemote()
{
  Write-Host "[Sync branch ${mainBranch} from remote]"
  git checkout -q ${mainBranch}

  If( $LastExitCode -ne 0 )
  {
    exit 1
  }
  git fetch

  If( "$(git diff-tree ${mainBranch} ${remoteBranchFull})" -eq "" )
  {
    return
  }
  git merge ${remoteBranchFull}
}

Function syncFromLocal()
{
  Write-Host "[Sync branch ${localBranch} from local machine]"

  git checkout -q ${localBranch}

  If( $LastExitCode -ne 0 )
  {
    exit 1
  }

  & ${scriptRoot}/copy.ps1
  git update-index --refresh

  If( "$(git diff-index HEAD)" -eq "" )
  {
    return
  }
  git add -i

  If( "$(git diff-index --cached HEAD)" -eq "" )
  {
    return
  }
  git commit
}

# assume already in local branch
Function syncMainFromLocal()
{
  Write-Host "[Sync branch ${mainBranch} from local machine]"

  If( "$(git diff-index HEAD)" -eq "" )
  {
    return
  }
  git stash -q
  git checkout -q ${mainBranch}
  git stash apply -q
  git mergetool
  git add -i

  If( "$(git diff-index --cached HEAD)" -ne "" )
  {
    git commit
  }
  git stash drop -q
}

# assume git fetch is already run
Function syncToRemote()
{
  Write-Host "[Sync branch ${mainBranch} to remote]"
  git checkout -q ${mainBranch}

  If( $LastExitCode -ne 0 )
  {
    exit 1
  }
  If( "$(git diff-tree ${mainBranch} ${remoteBranchFull})" -eq "" )
  {
    return
  }
  $isPush = Read-Host "Push commits to remote server?[y/n]: "

  If( "$isPush" -ne "y" )
  {
    return
  }
  git push
}

Function syncToLocal()
{
  $isStashNeeded = $False

  Write-Host "[Sync branch ${localBranch} to local machine]"

  If( "$(git diff-index HEAD)" -ne "" )
  {
    $isStashNeeded = $True
  }

  If( $isStashNeeded )
  {
    git stash -q
  }

  git checkout -q ${localBranch}

  If( $isStashNeeded )
  {
    git stash apply -q
    git mergetool
  }

  If( "$(git diff-index HEAD)" -ne "" )
  {
    git add -i
    git checkout -p
  }
  & $scriptRoot/install.ps1

  If( $isStashNeeded )
  {
    git stash drop -q
  }
}

main $target
