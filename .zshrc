bindkey -v
bindkey '^R' history-incremental-search-backward
set -o vi 
export EDITOR=vi
export CSCOPE_EDITOR=vi
alias ls='ls -G'
alias ll='ls -lrthG'
alias c='clear'
alias grep='grep --color=always'

##
# Your previous /Users/saratv/.bash_profile file was backed up as /Users/saratv/.bash_profile.macports-saved_2016-02-06_at_21:34:44
##

# MacPorts Installer addition on 2016-02-06_at_21:34:44: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.

