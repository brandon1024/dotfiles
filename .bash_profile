# Git branch in prompt.
parse_git_branch() {
    branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/')
    inworktree=$(git rev-parse --is-inside-work-tree 2> /dev/null)

    if [ "$inworktree" = "false" ]; then
        echo "$branch"
        return
    fi

    git diff-files --quiet 2> /dev/null
    if [ $? -eq 0 ]; then
        echo -e "\033[32m$branch\033[00m"
    else
        echo -e "\033[31m$branch\033[00m"
    fi
}

export PS1="\u@\h \W\$(parse_git_branch) \$ "

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
