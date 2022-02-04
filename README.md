# SharedDataTemplate
  A simple git repository template for syncing files across differnt machines

# Motivation
  I have used the git repository and github to sync my appliation settings such
  as vimrc and emacs init file across different machines with different OSes.
  Different repository for different applications is used to modulize the
  setting files, while there are many scripts similiar in these repositories for
  syncing. I decide to make the scripts for syncing files as a git repository
  template so that I can maintain only one repository and then merged to
  differente setting file modules.

# Goal
  The template is trying to support following features for now
  - perform actions with either [GNU Make](https://www.gnu.org/software/make/)
    or directly run shell scripts

    the make support is for unified UI, and should be an *optional*
  - minimize external dependencies

    so that it can work **without installing any program**
  - cross platform

    at least for **Windows**, **Linux**, **MacOS**

  - install, uninstall files and copy local machine files to the repo
  - using simple [TOML](https://toml.io/en/) as configuration file
  - support local machine setting files with git branch
  - support interactively sync between main, local and remote branch

# Dependencies
  - [Powershell](https://github.com/PowerShell/PowerShell) for Windows and POSIX
    shell, mainly focus on [Bash](https://www.gnu.org/software/bash/), for other
    OSes
  - [Git](https://git-scm.com/) [*Optional*]
  - [GNU Make](https://www.gnu.org/software/make/) [*Optional*]

# Author
  [Flotisable](https://github.com/flotisable) <s09930698@gmail.com>