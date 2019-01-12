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
    branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/')
        inworktree=$(git rev-parse --is-inside-work-tree 2> /dev/null)

        if [ "$inworktree" = "false" ]; then
            echo -e '\033[0;00m'
            return
        fi

        git diff-files --quiet 2> /dev/null
        if [ $? -eq 0 ]; then
            echo -e '\033[0;32m'
        else
            echo -e '\033[0;31m'
        fi
}

export PS1="\u@\h \W \[\$(get_branch_colour)\]\$(get_branch)\[\033[0;00m\] → "

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

function startSSHAgent() {
    eval `ssh-agent -s`
    ssh-add
}

# Environment Variables

# Aliases
alias ll="ls -la"
alias swe="cd ~/dev/IntelliJ/swe-senior-design"
alias ssha="startSSHAgent"
alias relprof=". ~/.bash_profile"
