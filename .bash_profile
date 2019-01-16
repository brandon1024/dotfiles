get_branch() {
    branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/')
    inworktree=$(git rev-parse --is-inside-work-tree 2> /dev/null)

    if [ "$inworktree" = "false" ]; then
        echo ""
    else
        echo $branch
    fi
}

get_branch_colour() {
    local inworktree=$(git rev-parse --is-inside-work-tree 2> /dev/null)
    if [ "$inworktree" = "false" ] || [ "$inworktree" = "" ]; then
        echo -e '\033[0;00m'
        return
    fi

    [[ -z $(git ls-files --others --exclude-standard) ]]
    local untrackedchanges=$?
    git diff-files --quiet 2> /dev/null
    local trackedchanges=$?
    git diff-index --cached --quiet HEAD 2> /dev/null
    local stagedchanges=$?

    if [ $stagedchanges -eq 1 ]; then
        echo -e '\033[1;33m'
    elif [ $trackedchanges -eq 1 ] || [ $untrackedchanges -eq 1 ]; then
        echo -e '\033[0;31m'
    else
        echo -e '\033[0;32m'
    fi
}

export PS1="\u@\h \W \[\$(get_branch_colour)\]\$(get_branch)\[\033[0;00m\] → "

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

# Environment Variables
if [ -f ~/.bash_vars ]; then
    source ~/.bash_vars
fi

# Aliases
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi