#!/usr/bin/env bash

ME=`basename "$0"`
HERE=`pwd`
VERSION='0.0.1'

function help() {
	cat <<EOS
usage: ${ME} [options]
Installs dotfiles from brandon1024/dotfiles.git into the current
user's home directory.

This script must be executed from the dotfiles repository
root directory, otherwise this script will not run correctly.

options:
	-f, --force     Remove existing dotfiles, if they exist
	-c, --copy      Copy dotfiles, rather than use symlinks
	-i, --invert    Invert selection of skipped files
	    --apply	Generate command to source new bash_profile
	-v, --version   Show version number and exit
	-h, --help      Show usage

skipping files:
	-b, --skip-bashrc
			Skip .bashrc
	-a, --skip-aliases
			Skip .bash_aliases
	-e, --skip-env-vars
			Skip .bash_vars
	--skip-vimrc	Skip .vimrc
	--skip-hooks	Skip git core.hooksPath

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
apply=0
sk_bp=0
sk_al=0
sk_var=0
sk_vim=0
sk_hk=0

function parseargs() {
    for arg in "$@"; do
        case $arg in
            -f|--f)
                mode_force=1
                shift
                ;;
            -c|--copy)
                mode_copy=1
                shift
                ;;
            --apply)
                apply=1
                shift
                ;;
            -b|--skip-bashrc)
                sk_bp=1
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
            --skip-hooks)
                sk_hk=1
                shift
                ;;
            -h|--help)
                help
                exit 0
                ;;
            -v|--version)
                version
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

# link .bashrc
if [ "$sk_bp" -eq 0 ]; then
    if [ "$mode_force" -eq 1 ]; then
        if [ "$mode_copy" -eq 1 ]; then
            [ -f ~/.bashrc ] && rm ~/.bashrc
            cp "$HERE/.bashrc" ~/.bashrc
        else
            ln -f -s "$HERE/.bashrc" ~/.bashrc
        fi
    else
        if [ "$mode_copy" -eq 1 ]; then
            [ ! -f ~/.bashrc ] && cp "$HERE/.bashrc" ~/.bashrc
        else
            [ ! -f ~/.bashrc ] && ln -s "$HERE/.bashrc" ~/.bashrc
        fi
    fi
fi

# link .bash_aliases
if [ "$sk_al" -eq 0 ]; then
    if [ "$mode_force" -eq 1 ]; then
        if [ "$mode_copy" -eq 1 ]; then
            [ -f ~/.bash_aliases ] && rm ~/.bash_aliases
            cp "$HERE/.bash_aliases" ~/.bash_aliases
        else
            ln -f -s "$HERE/.bash_aliases" ~/.bash_aliases
        fi
    else
        if [ "$mode_copy" -eq 1 ]; then
            [ ! -f ~/.bash_aliases ] && cp "$HERE/.bash_aliases" ~/.bash_aliases
        else
            [ ! -f ~/.bash_aliases ] && ln -s "$HERE/.bash_aliases" ~/.bash_aliases
        fi
    fi
fi

# link .bash_vars
if [ "$sk_var" -eq 0 ]; then
    if [ "$mode_force" -eq 1 ]; then
        if [ "$mode_copy" -eq 1 ]; then
            [ -f ~/.bash_vars ] && rm ~/.bash_vars
            cp "$HERE/.bash_vars" ~/.bash_vars
        else
            ln -f -s "$HERE/.bash_vars" ~/.bash_vars
        fi
    else
        if [ "$mode_copy" -eq 1 ]; then
            [ ! -f ~/.bash_vars ] && cp "$HERE/.bash_vars" ~/.bash_vars
        else
            [ ! -f ~/.bash_vars ] && ln -s "$HERE/.bash_vars" ~/.bash_vars
        fi
    fi
fi

# link .vimrc
if [ "$sk_vim" -eq 0 ]; then
    if [ "$mode_force" -eq 1 ]; then
        if [ "$mode_copy" -eq 1 ]; then
            [ -f ~/.vimrc ] && rm ~/.vimrc
            cp "$HERE/.vimrc" ~/.vimrc
        else
            ln -f -s "$HERE/.vimrc" ~/.vimrc
        fi
    else
        if [ "$mode_copy" -eq 1 ]; then
            [ ! -f ~/.vimrc ] && cp "$HERE/.vimrc" ~/.vimrc
        else
            [ ! -f ~/.vimrc ] && ln -s "$HERE/.vimrc" ~/.vimrc
        fi
    fi
fi

# configure git core.hooksPath
if [ "$sk_hk" -eq 0 ]; then
    git config --global core.hooksPath "$HERE/git-hooks"
fi

if [ "$apply" -eq 1 ]; then
    echo '. ~/.bash_profile'
fi

