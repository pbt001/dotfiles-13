# Clone zgen if not found
ZGEN="${ZDOTDIR:-$HOME}/.zgen/zgen.zsh"

ZGEN_RESET_ON_CHANGE=(${HOME}/.zshrc)
source $ZGEN || git clone git@github.com:tarjoilija/zgen.git $(dirname $ZGEN)
if ! zgen saved; then
  zgen prezto
  zgen prezto 'homebrew'
  zgen prezto 'git'
  zgen prezto 'history-substring-search'
  zgen load djui/alias-tips
  zgen load rimraf/k
  zgen load jimmijj/zsh-syntax-highlighting
  zgen load tarruda/zsh-autosuggestions

  zgen prezto editor key-bindings 'emacs'
  zgen prezto editor dot-expansion 'yes' # convert .... to ../..

  zgen load mafredri/zsh-async # required for pure
  zgen load sindresorhus/pure

  zgen save
fi
zgen init

alias gist='gist -c'
alias of='open .'
alias c='lolcat'
alias h='head'
alias ,='clear && ls .'
alias ,.='cd .. && ,'
alias ,-='cd - && ,'
alias duth='dut | head'
alias dfh='df -hl'
alias rm='nocorrect trash'
alias deploy='gp && deliver'
alias dp='deploy'
alias ascii='asciiio -y'
alias gpum='git push upstream master'
alias localip='ipconfig getifaddr en0'

function f() { find . -name "$1" }
# View HTTP traffic
alias sniff="sudo ngrep -d 'en0' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i en0 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

function yell { figlet -f slant "$@" | sed "s/\(.\+\)/    \1/g"}

function git {  hub "$@" } # must be a function for completions to work
function cd, { cd "$@" && clear && ls }

function up {
  brew update
  brew upgrade
  brew cleanup
  brew prune

  brew cask cleanup
  ls -l /Users/jedahan/.homebrew/Library/Formula | grep homebrew-cask | awk '{print $9}' | for evil_symlink in $(cat -); do rm -v /usr/local/Library/Formula/$evil_symlink; done

  brew doctor
}

# open atom in a given location, or this directory if no location was specified
function a() {  atom ${@:-'.'} }

# open vim in a given location, or this directory if no location was specified
function v() {  vim ${@:-'.'} }

# open a given location, or this directory if no location was specified
function o() {  open ${@:-'.'} }

alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
alias x='exit'

function play {
    # Skip DASH manifest for speed purposes. This might actually disable
    # being able to specify things like 'bestaudio' as the requested format,
    # but try anyway.
    # Get the best audio that isn't WebM, because afplay doesn't support it.
    # Use "$*" so that quoting the requested song isn't necessary.
    youtube-dl --default-search=ytsearch: \
               --youtube-skip-dash-manifest \
               --output="${TMPDIR:-/tmp/}%(title)s-%(id)s.%(ext)s" \
               --restrict-filenames \
               --format="bestaudio[ext!=webm]" \
               --exec=afplay "$*"
}

function mp3 {
    # Get the best audio, convert it to MP3, and save it to the current
    # directory.
    youtube-dl --default-search=ytsearch: \
               --restrict-filenames \
               --format=bestaudio \
               --extract-audio \
               --audio-format=mp3 \
               --audio-quality=1 "$*"
}

alias vim='nvim'

zle-line-init() {
  zle autosuggest-start
}
zle -N zle-line-init
