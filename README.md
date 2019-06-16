# Brandon's Dotfiles
Here's where I dump all my config files. Maybe you'll find them useful.

Here's what I have configured so far:
- bash (.bashrc, .bash_aliases, .bash_vars)
- vim (.vimrc)
- git hooks (git-hooks/)

## Install
I put together a little script you can use to install the dotfiles how you like. This script is fairly safe, and will not copy or link dotfiles if there are already existing dotfiles in the home directory. See the usage below:
```
usage: ./install [options]
options:
	-f, --force     Remove existing dotfiles, if they exist
	-c, --copy      Copy dotfiles, rather than use symlinks
	    --apply     Generate command to source new bash_profile
	-v, --version   Show version number and exit
	-h, --help      Show usage

skipping files:
	-b, --skip-bash-profile
			Skip .bash_profile
	-a, --skip-aliases
			Skip .bash_aliases
	-e, --skip-env-vars
			Skip .bash_vars
	--skip-vimrc	Skip .vimrc
	--skip-hooks	Skip git core.hooksPath
```

Here's an example:
```
$ cd ~
$ git clone --depth=1 git@github.com:brandon1024/.dotfiles.git
$ cd ~/.dotfiles
./install.sh
source ~/.bashrc
```
