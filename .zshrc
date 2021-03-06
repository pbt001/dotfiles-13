icons=(                     )
icon="${icons[RANDOM % $#icons + 1]}"
tmux bind-key c new-window -n $icon

bindkey -e
setopt autocd autopushd pushd_ignore_dups interactivecomments
setopt bang_hist extended_history inc_append_history share_history hist_ignore_space hist_verify

autoload -Uz select-word-style && select-word-style bash
autoload -Uz bracketed-paste-url-magic && zle -N bracketed-paste $_

(( $+commands[rg] )) && export FZF_DEFAULT_COMMAND='rg --files --follow'

export HISTFILE="${HOME}/.zhistory" HISTSIZE=10000 SAVEHIST=10000 \
  GEOMETRY_PROMPT=(geometry_hydrate geometry_todo geometry_status) \
  GEOMETRY_RPROMPT=(geometry_exec_time geometry_path geometry_git geometry_jobs geometry_rustup) \
  GEOMETRY_GIT_SEPARATOR=" " \
  ZSH_AUTOSUGGEST_STRATEGY="match_prev_cmd"

(( $+commands[brew] )) && {
  test -f ~/.brew_env || brew shellenv > ~/.brew_env; source ~/.brew_env

  alias \
    brewi='brew install' \
    brewl='brew list' \
    brews='brew search' \
    brewu='brew upgrade' \
    brewx='brew uninstall' \
    caski='brew install' \
    caskl='brew list' \
    casku='brew upgrade' \
    caskx='brew uninstall'
}

if [[ ! -f ~/.zr/init.zsh ]] || [[ ~/.zshrc -nt ~/.zr/init.zsh ]]; then
  zr load \
    sorin-ionescu/prezto/modules/git/alias.zsh \
    zsh-users/zsh-autosuggestions \
    zdharma/fast-syntax-highlighting \
    changyuheng/zsh-interactive-cd \
    jedahan/geometry-hydrate \
    jedahan/geometry-todo \
    geometry-zsh/geometry \
    ael-code/zsh-colored-man-pages \
    momo-lab/zsh-abbrev-alias \
    jedahan/laser \
    csurfer/tmuxrepl
fi
source ~/.zr/init.zsh

alias manual=$commands[man] \
 find=${commands[fd]:-$commands[find]} \
 grep=${commands[rg]:-$commands[grep]} \
 ls=${commands[exa]:-$commands[ls]} \
 cat=${commands[bat]:-$commands[cat]}

(( $+commands[tldr] )) && function man {
  tldr -q $* && return
  tldr -q -o linux $*
}

abbrev-alias help=man \
 h=man \
 x=exit \
 o=open \
 n=nvim \
 c=lolcat \
 _=sudo \
 s=grep \
 f=find \
 repl=tmuxrepl \
 l=ls \
 ll='ls -l' \
 ,='clear && ls'

function twitch { streamlink --twitch-oauth-token=$STREAMLINK_TWITCH_OAUTH_TOKEN twitch.tv/$1 ${2:-best} }
git() ( test -d .dotfiles && export GIT_DIR=$PWD/.dotfiles GIT_WORK_TREE=$PWD; command git "$@" )
function up { # upgrade everything
  uplog=/tmp/up; rm -rf $uplog >/dev/null; touch $uplog

  (( $+commands[tmux] )) && {
    window_name=`tmux list-windows -F '#{?window_active,#{window_name},}'`
    tmux select-window -t  2>/dev/null || tmux rename-window 
    tmux split-window -d -p 40 -t  "tail -f $uplog"
  }

  function e { if [ $? -eq 0 ]; then c <<< $1; else echo ":("; fi }
  function fun { (( $+aliases[$1] || $+functions[$1] || $+commands[$1] )) && echo -n "updating $2..." }

  c <<< "  $uplog"
  fun config 'dotfiles' && { config pull }                         &>> $uplog; e 
  fun zr 'zsh plugins'  && { zr update }                           &>> $uplog; e ▲ && s 'Updating [a-f0-9]{6}\.\.[a-f0-9]{6}' -B1 $uplog
  fun tldr 'tldr'       && { tldr --update }                       &>> $uplog; e ⚡
  fun brew 'brews'      && { brew cask upgrade; brew upgrade }     &>> $uplog; e  && s 🍺 $uplog | cut -d'/' -f5-6 | cut -d':' -f1
  fun nvim 'neovim'     && { nvim '+PlugUpdate!' '+PlugClean!' '+qall' } &>> $uplog; e  && s 'Updated!\s+(.+/.+)' -r '$1' -N $uplog | paste -s -
  fun rustup 'rust'     && { rustup update }                       &>> $uplog; e  && s 'updated.*rustc' -N $uplog | cut -d' ' -f7 | paste -s -
  fun cargo 'crates'    && { cargo install-update --all }          &>> $uplog; e  && s '(.*)Yes$' --replace '$1' $uplog | paste -s -
  fun mas 'apps'        && { mas upgrade }                         &>> $uplog; e && s -A1 'outdated applications' -N $uplog | tail -n1

  (( $+commands[tmux] )) && {
    tmux kill-pane -t :.{bottom}
    tmux rename-window ${window_name//[[:space:]]/}
  }
}

function par {
  parity \
    --config=$HOME/.config/parity/config.toml \
    --cache-size 1024 \
    --db-compaction ssd \
    --pruning fast \
    --mode active \
    --jsonrpc-threads 4 &
  sleep 5 && sudo cputhrottle $(ps aux | awk '/[p]arity/ {print $2}') 50
}
