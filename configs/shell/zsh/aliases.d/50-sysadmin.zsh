# shellcheck shell=bash disable=SC2142,SC2139,SC2154,SC2168
# Day-to-day sysadmin one-liners, tmux helpers, search utilities,
# small Python/curl wrappers, etc.

# --- Misc conditional tooling ----------------------------------------------

if command -v systemctl &>/dev/null; then
  alias running_services='systemctl list-units --type=service --state=running'
fi

if command -v terragrunt &>/dev/null; then
  alias tg=terragrunt
fi

# --- Sudo + tmux + bat shortcuts -------------------------------------------

alias sudo='sudo ' # Trick to have ALL aliases available with sudo <3
alias tn='tmux new'
alias ta='tmux attach'
alias trl='tmux source-file ~/.tmux.conf && echo "tmux config reloaded"'
if command -v bat &>/dev/null || command -v batcat &>/dev/null; then
  # shellcheck disable=SC2046,SC2139
  alias b=$(command -v bat 2>/dev/null || command -v batcat 2>/dev/null)
fi
alias vz='v ~/.zshrc'
alias p='python3'
alias temp='pushd $(mktemp -d)'

# --- eza (modern ls replacement) -------------------------------------------

if command -v eza &>/dev/null; then
  alias t='eza -Tll -L 1'
  alias t2='eza -Tll -L 2'
  alias t3='eza -Tll -L 3'
  alias l='eza -ll --group-directories-first'
  alias la='eza -lla --group-directories-first'
fi

# --- General sysadmin one-liners -------------------------------------------

# WARNING: Disabling SSL verification is a security risk!
# Only use this if you understand the implications and have a valid reason
# alias git="GIT_SSL_NO_VERIFY=true git"
alias clean-crash='sudo /bin/rm -rf /var/crash/*'
if command -v google-chrome &>/dev/null; then
  alias goog='google-chrome'
fi
alias carbo='docker run -ti fathyb/carbonyl'
alias ipa='ip -br a | grep -vF DOWN | cut -d/ -f1'
# SECURITY: Validate PID before killing to prevent injection
alias kill-click='f(){ _pid=$(get-pid-click); [[ "$_pid" =~ ^[0-9]+$ ]] && sudo kill -9 "$_pid" || echo "Invalid PID"; unset -f f; }; f'
if command -v guvcview &>/dev/null; then
  alias cam-setup='guvcview'
fi
alias yt-dlp='pipx run yt-dlp'
alias yt-dl-likes='yt-dlp --cookies www.youtube.com_cookies.txt -x --audio-format mp3  :ytfav'
alias record-screen='f(){ ffmpeg -video_size 1920x1080 -framerate 30 -f x11grab -i :0.0 -c:v libx264 -crf 0 -preset ultrafast "$1".mkv;  unset -f f; }; f'
alias maxfullscreen='f(){ window_title=$(i3-msg -t get_tree | gron | grep -F "title = " | grep -ioP "\".*\"" | fzf); i3-msg "[title=$window_title] focus ; floating enable ; resize set 3842px 1082px; move position -1px -1px" ;  unset -f f; }; f'
# SECURITY: Use unique temp directory to prevent file collisions
alias flameshotz='f(){ _tmpdir=$(mktemp -d); while true; do flameshot full -p "$_tmpdir/"; sleep 1; done; unset -f f; }; f'
alias update-and-clean='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt clean -y && sudo apt purge -y'
alias show-disk-io='watch -cd -- iostat -h'
alias show-open-ports="sudo ss -latepun | grep -i listen"
# WARNING: Disabling SSH host key checking is a security risk!
# Only use this if you understand the implications (e.g., for temporary test environments)
# For production, use proper SSH key management instead
# alias ssh='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias tmux-bg='f(){ tmux new-window -d zsh -c "echo $@; $@; zsh";  unset -f f; }; f'
alias tmux-split='f(){ tmux split-window -d zsh -c "echo $@; $@; zsh";  unset -f f; }; f'
if command -v qrencode &>/dev/null; then
  alias toqrcode='qrencode -t ANSI -o -'
fi
alias upload='f(){ curl -F"file=@$1" https://0x0.st;  unset -f f; }; f'
# usleep: sleep for a fractional number of seconds (`usleep 0.25`).
# Argument flows through sys.argv so it can't inject Python code, unlike a
# naïve f-string / `$1` interpolation inside `python3 -c`.
alias usleep='python3 -c "import sys, time; time.sleep(float(sys.argv[1]))"'
alias vplay='mpv --no-audio'
# WARNING: Disabling certificate checking is a security risk!
# Only use this if you understand the implications
# alias wget="wget --no-check-certificate"
if command -v nmtui &>/dev/null; then
  alias wifi='nmtui'
fi
alias b64d='base64 -d'
alias b64e='base64 -w 0'
alias back-n='sed "s/\\\n/\n/g"'
alias cgrep='grep --color=always'
alias cheat='f(){ curl -s "cheat.sh/$1";  unset -f f; }; f'
alias clean-swap='sudo swapoff -a && sudo swapon -a'
if command -v xclip &>/dev/null; then
  alias cpy='xclip -selection clipboard'
fi
# decrypt/encrypt: use gpg or age (sops) instead of mcrypt
alias digall='f(){ dig +answer +multiline "$1" any @8.8.8.8;  unset -f f; }; f'
alias disable-ipv6='sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1; sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1; sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1'
alias dns-1='echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf'
alias dns-127='echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf'
alias dns-8='echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf'
alias dns-9='echo "nameserver 9.9.9.9" | sudo tee /etc/resolv.conf'
alias encrypt='f(){ PASS=$(head -c 20 /dev/urandom | base64) && echo "$PASS" | xclip -selection c && tar -zcvf "$1.tar.gz" "$1" && gpg --symmetric --batch --passphrase "$PASS" "$1.tar.gz" && echo "$1.tar.gz.gpg $PASS" | xclip -selection c; unset -f f; }; f'
alias get-badchars='echo -e "\"\x27<?>][]{}_)(*;/\x5c"'
alias get-bytes='for i in {0..255}; do python3 -c "print(hex($i)[2:].rjust(2, str(0)))"; done'
alias get-chars='for i in {1..255}; do python3 -c "print(chr($i))"; done'
alias get-du='du -ch -d 1'
alias get-ip='curl -sS ipinfo.io'
alias get-meteo='curl https://wttr.in/'
if command -v xprop &>/dev/null; then
  alias get-pid-click='xprop _NET_WM_PID | cut -d" " -f3'
fi
alias get-pid-ps='ps fauxw | fzf | awk "{ print \$2}"'
alias get-shell-size='echo "stty rows ${LINES} cols ${COLUMNS}"'
# SECURITY: Variables properly quoted to prevent word splitting/injection
alias git-cloneall-github='curl -sk -H "Authorization: token ${GITHUB_READ_TOKEN}" "https://api.github.com/search/repositories?q=user:${GITHUB_USER}" | jq -r ".items[].ssh_url" | parallel -j10 "git clone {}"'
alias git-cloneall-gitlab='curl -sk -H "Authorization: Bearer ${GITLAB_READ_TOKEN}" "https://gitlab.com/api/v4/projects?owned=true&simple=true" | jq -r ".[].ssh_url_to_repo" | parallel -j10 "git clone {}"'
alias git-pullall='find . -maxdepth 2 -name ".git" | cut -d/ -f2 | parallel -j10 "cd {} && git pull"'
alias nocolor='sed "s/\x1B\[[0-9;]\+[A-Za-z]//g"'
alias nonullbyte='python3 -c "import sys; sys.stdout.write(sys.stdin.read().replace(chr(0), str()))"'
alias probe-urls='f(){ while read url; do curl -sk "$url" -o /dev/null -w "%{http_code}:%{size_download}:%{url_effective}\n" ; done < "$@" ; unset -f f; }; f'
alias pserv='python3 -m http.server -d .'
alias urldecode="python3 -c \"import sys; from urllib.parse import unquote; print(unquote(sys.argv[1]))\""
alias urlencode-deep='f(){ echo -n "$1" | xxd -p | tr -d "\n" | sed "s#..#%&#g";  unset -f f; }; f'
alias urlencode="python3 -c \"import sys; from urllib.parse import quote; print(quote(sys.argv[1], safe=''))\""

# --- Search helpers --------------------------------------------------------

alias vgrep='f(){ grep -rnH "$1" "$2" | fzf --preview="bat --pager never --color always -H {2} -r {2}: -p {1}" --delimiter=: ;  unset -f f; }; f'
# Search file contents with ripgrep, fzf, bat
alias fzf-rg="rg --hidden --glob '' --line-number . | fzf --delimiter ':' --preview 'bat --style=numbers --color=always {1} --highlight-line {2}'"
