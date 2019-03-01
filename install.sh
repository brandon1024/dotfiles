#!/usr/bin/env bash

ME=`basename "$0"`
HERE=`pwd`
VERSION='0.1.0'

function help() {
	cat <<EOS
usage: ${ME} [options]
Installs dotfiles from brandon1024/dotfiles.git into the current
user's home directory.

This script must be executed from the dotfiles repository
root directory, otherwise this script will not run correctly.

options:
	-f, --force	Remove existing dotfiles, if they exist
	-c, --copy	Copy dotfiles, rather than use symlinks
	-i, --invert	Invert selection of skipped files
	-v, --version	Show version number and exit
	    --osx	Generate .bash_profile
	-h, --help	Show usage

skipping files:
	-b, --skip-bashrc
			Skip .bashrc
	-a, --skip-aliases
			Skip .bash_aliases
	-e, --skip-env-vars
			Skip .bash_vars
	--skip-vimrc
			Skip .vimrc
	--skip-gitconfig
			Skip .gitconfig

EOS
}

function version() {
    cat <<EOS
${ME} ${VERSION}
Author: Brandon Richardson
EOS
}

mode_force=0
mode_copy=0
sk_brc=0
sk_al=0
sk_var=0
sk_vim=0
sk_gc=0
gen_bp=0

function parseargs() {
	for arg in "$@"; do
		case $arg in
			-f|--force)
				mode_force=1
				shift
				;;
			-c|--copy)
				mode_copy=1
				shift
				;;
			--osx)
				gen_bp=1
				shift
				;;
			-b|--skip-bashrc)
				sk_brc=1
				shift
				;;
			-a|--skip-aliases)
				sk_al=1
				shift
				;;
			-e|--skip-env-vars)
				sk_var=1
				shift
				;;
			--skip-vimrc)
				sk_vim=1
				shift
				;;
			--skip-gitconfig)
				sk_gc=1
				shift
				;;
			-h|--help)
				help
				exit 0
				;;
			-v|--version)
				version
				exit 0
				;;
			*)
				echo "Unknown option: $arg"
				help
				exit 1
				;;
		esac
	done
}

parseargs "$@"

for file in .bashrc .bash_aliases .bash_vars .vimrc .gitconfig; do
	if [ "$file" = ".bashrc" ] && [ "$sk_brc" -eq 1 ]; then
		echo "Skipping .bashrc"
		continue;
	fi

	if [ "$file" = ".bash_aliases" ] && [ "$sk_al" -eq 1 ]; then
		echo "Skipping .bash_aliases"
		continue;
	fi

	if [ "$file" = ".bash_vars" ] && [ "$sk_var" -eq 1 ]; then
		echo "Skipping .bash_vars"
		continue;
	fi

	if [ "$file" = ".vimrc" ] && [ "$sk_vim" -eq 1 ]; then
		echo "Skipping .vimrc"
		continue;
	fi

	if [ "$file" = ".gitconfig" ] && [ "$sk_gc" -eq 1 ]; then
    		echo "Skipping .gitconfig"
    		continue;
    	fi

	if [ "$mode_force" -eq 1 ]; then
		if [ "$mode_copy" -eq 1 ]; then
			[ -f "$HOME/$file" ] && rm -v $HOME/$file
			cp -v $HERE/$file $HOME/$file
		else
			ln -v -f -s $HERE/$file $HOME/$file
		fi
	else
		if [ "$mode_copy" -eq 1 ]; then
			[ ! -f "$HOME/$file" ] && cp -v $HERE/$file $HOME/$file
		else
			[ ! -f "$HOME/$file" ] && ln -v -s $HERE/$file $HOME/$file
		fi
	fi
done

if [ "$gen_bp" -eq 1 ]; then
	echo 'Generating .bash_profile'
	echo 'source ~/.bashrc' > $HOME/.bash_profile
fi