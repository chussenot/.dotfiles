# shellcheck shell=bash disable=SC2142,SC2139,SC2154,SC2168
# Zsh Aliases
# This file contains all shell aliases

# Navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# List aliases
alias ll='ls -alF'
alias lt='ls -lt'
alias ltr='ls -ltr'

# Git aliases
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
# Note: gst is defined as a function in functions.zsh with error handling
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout main || git checkout master'
alias gd='git diff'
alias gdc='git diff --cached'
alias glog='git log --oneline --graph --decorate'
alias gfa='git fetch --all --prune'

# Development aliases
alias py='python3'
alias pip='pip3'
alias nv='nvim'
alias v='nvim'

# System aliases
alias df='df -h'
alias du='du -h'
alias free='free -h'
# Use htop if available, otherwise fall back to top
if command -v htop &>/dev/null; then
  alias top='htop'
fi

# Docker aliases (basic) - only if docker is installed
if command -v docker &>/dev/null; then
  alias d='docker'
  alias dex='docker exec -it'

  # docker-compose might be a plugin or separate command
  if command -v docker-compose &>/dev/null; then
    alias dc='docker-compose'
  elif docker compose version &>/dev/null; then
    alias dc='docker compose'
  fi
fi

# Kubernetes aliases - only if kubectl is installed
if command -v kubectl &>/dev/null; then
  alias k='kubectl'
  alias kg='kubectl get'
  alias kd='kubectl describe'
  alias kl='kubectl logs'
  alias kx='kubectl exec -it'
fi

# Utility aliases
alias c='clear'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'
# Network aliases (conditional based on available tools)
if command -v netstat &>/dev/null; then
  alias ports='netstat -tulanp'
elif command -v ss &>/dev/null; then
  alias ports='ss -tulanp'
fi

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'

############################
# Tools & Aliases
############################

# Misc
# Conditional systemctl alias (only on systemd systems)
if command -v systemctl &>/dev/null; then
  alias running_services='systemctl list-units --type=service --state=running'
fi

# Terragrunt alias (only if installed)
if command -v terragrunt &>/dev/null; then
  alias tg=terragrunt
fi

# Utils
## Directories
alias sudo='sudo ' # Trick to have ALL aliases available with sudo <3
alias tn='tmux new'
alias ta='tmux attach'
# Conditional aliases for tools that might not be installed
if command -v bat &>/dev/null || command -v batcat &>/dev/null; then
  # shellcheck disable=SC2046,SC2139
  alias b=$(command -v bat 2>/dev/null || command -v batcat 2>/dev/null)
fi
alias vz='v ~/.zshrc'
alias p='python'
alias temp='pushd $(mktemp -d)'

# Tools Sysadmin
# exa/eza aliases (only if exa or eza is installed)
if command -v eza &>/dev/null; then
  alias t='eza -Tll -L 1'
  alias t2='eza -Tll -L 2'
  alias t3='eza -Tll -L 3'
  alias l='eza -ll --group-directories-first'
  alias la='eza -lla --group-directories-first'
elif command -v exa &>/dev/null; then
  alias t='exa -Tll -L 1'
  alias t2='exa -Tll -L 2'
  alias t3='exa -Tll -L 3'
  alias l='exa -ll --group-directories-first'
  alias la='exa -lla --group-directories-first'
fi
# WARNING: Disabling SSL verification is a security risk!
# Only use this if you understand the implications and have a valid reason
# alias git="GIT_SSL_NO_VERIFY=true git"
alias clean-crash='sudo /bin/rm -rf /var/crash/*'
alias goog='google-chrome'
alias carbo='docker run -ti fathyb/carbonyl'
alias ipa='ip -br a | grep -vF DOWN | cut -d/ -f1'
# SECURITY: Validate PID before killing to prevent injection
alias kill-click='f(){ _pid=$(get-pid-click); [[ "$_pid" =~ ^[0-9]+$ ]] && sudo kill -9 "$_pid" || echo "Invalid PID"; unset -f f; }; f'
alias cam-setup='guvcview'
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
alias toqrcode='qrencode -t ANSI -o -'
alias upload='f(){ curl -F"file=@$1" https://0x0.st;  unset -f f; }; f'
alias usleep='f(){ python3 -c "import time; time.sleep($1)";  unset -f f; }; f'
alias vplay='mplayer -nosound'
# WARNING: Disabling certificate checking is a security risk!
# Only use this if you understand the implications
# alias wget="wget --no-check-certificate"
alias wifi='nmtui'
alias b64d='base64 -d'
alias b64e='base64 -w 0'
alias back-n='sed "s/\\\n/\n/g"'
alias cgrep='grep --color=always'
alias cheat='f(){ curl -s "cheat.sh/$1";  unset -f f; }; f'
alias clean-swap='sudo swapoff -a && sudo swapon -a'
alias cpy='xclip -selection clipboard'
alias decrypt='mdecrypt'
alias digall='f(){ dig +answer +multiline "$1" any @8.8.8.8;  unset -f f; }; f'
alias disable-ipv6='sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1; sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1; sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1'
alias dns-1='echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf'
alias dns-127='echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf'
alias dns-8='echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf'
alias dns-9='echo "nameserver 9.9.9.9" | sudo tee /etc/resolv.conf'
alias encrypt='f(){ PASS=$(cat /dev/urandom | base64 | head -c 20) && echo "$PASS" | xclip -selection c && tar -zcvf "$1.tar.gz" "$1" && echo "$PASS" && mcrypt "$1.tar.gz" && echo "$1.tar.gz $PASS" | xclip -selection c;  unset -f f; }; f'
alias get-badchars='echo -e "\"\x27<?>][]{}_)(*;/\x5c"'
alias get-bytes='for i in {0..255}; do python2 -c "print hex($i)[2:].rjust(2, str(0))"; done'
alias get-chars='for i in {1..255}; do python2 -c "print chr($i)"; done'
alias get-du='du -ch -d 1'
alias get-ip='curl -sS ipinfo.io'
alias get-meteo='curl https://wttr.in/'
alias get-pid-click='xprop _NET_WM_PID | cut -d" " -f3'
alias get-pid-ps='ps fauxw | fzf | awk "{ print \$2}"'
alias get-shell-size='echo "stty rows ${LINES} cols ${COLUMNS}"'
# SECURITY: Variables properly quoted to prevent word splitting/injection
alias git-cloneall-github='curl -sk -H "Authorization: token ${GITHUB_READ_TOKEN}" "https://api.github.com/search/repositories?q=user:${GITHUB_USER}" | jq -r ".items[].ssh_url" | parallel -j10 "git clone {}"'
alias git-cloneall-gitlab='curl -sk -H "Authorization: Bearer ${GITLAB_READ_TOKEN}" "https://gitlab.com/api/v4/projects?owned=true&simple=true" | jq -r ".[].ssh_url_to_repo" | parallel -j10 "git clone {}"'
alias git-pullall='find . -maxdepth 2 -name ".git" | cut -d/ -f2 | parallel -j10 "cd {} && git pull"'
alias nocolor='sed "s/\x1B\[[0-9;]\+[A-Za-z]//g"'
alias nonullbyte='python -c "import sys; sys.stdout.write(sys.stdin.read().replace(chr(0), str()))"'
alias probe-urls='f(){ while read url; do curl -sk "$url" -o /dev/null -w "%{http_code}:%{size_download}:%{url_effective}\n" ; done < "$@" ; ; unset -f f; }; f'
alias pserv='python3 -m http.server -d .'
alias urldecode="python3 -c \"import sys; from urllib.parse import unquote; print(unquote(sys.argv[1]))\""
alias urlencode-deep='f(){ echo -n "$1" | xxd -p | tr -d "\n" | sed "s#..#%&#g";  unset -f f; }; f'
alias urlencode="python3 -c \"import sys; from urllib.parse import quote; print(quote(sys.argv[1], safe=''))\""

# Tools Hacking
alias get-pass-exploits='f(){ xdg-open "https://www.exploitalert.com/search-results.html?search=$@" ;  unset -f f; }; f'
alias get-pass-info='f(){ xdg-open "https://cirt.net/passwords?criteria=$@" ;  unset -f f; }; f'
alias get-exploitalert='f(){ xdg-open "https://www.exploitalert.com/search-results.html?search=$@" ;  unset -f f; }; f'
alias get-port-info='f(){ xdg-open "https://www.speedguide.net/port.php?port=$@" ;  unset -f f; }; f'
alias get-bookhacktricks='f(){ xdg-open "https://book.hacktricks.xyz/?q=$@" ;  unset -f f; }; f'
alias recon-certspotter='f(){ xdg-open "https://api.certspotter.com/v1/issuances?domain=$1&include_subdomains=true&expand=dns_names&expand=issuer&expand=cert" ;  unset -f f; }; f'
alias recon-virustotal='f(){ xdg-open "https://www.virustotal.com/gui/domain/$1" ;  unset -f f; }; f'
alias recon-crtsh='f(){ curl -sk "https://crt.sh/?output=json&q=$1" | jq . ; unset -f f; }; f'
alias recon-wayback='f(){ curl -sk "https://web.archive.org/cdx/search/cdx?fl=original&collapse=urlkey&url=*.$1" ; unset -f f; }; f'
alias capture-http='f(){ sudo unbuffer tcpdump -A -s 0 "tcp port $@ and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)" | tr "\\n" "\n" ; unset -f f; }; f'
# SECURITY: Use dynamic interface detection instead of hardcoded value
alias capture-creds='f(){ _iface="${1:-$(ip route | grep default | awk "{print \$5}" | head -1)}"; sudo tcpdump -i "$_iface" port http or port ftp or port smtp or port imap or port pop3 or port telnet -l -A | grep -iEB5 --line-buffered "pass=|pwd=|log=|login=|user=|username=|pw=|passw=|passwd=|password=|pass:|user:|username:|password:|login:|pass |user |authorization:|token"; unset -f f; }; f'
alias nmap-html='nmap --stylesheet https://raw.githubusercontent.com/honze-net/nmap-bootstrap-xsl/master/nmap-bootstrap.xsl'
alias arm-vm='source /opt/arm_now/.py3/bin/activate && arm_now start --redir tcp:1234:1234 --clean --sync armv7-eabihf'
alias bb-results='find . -iname "nuclei-*" -exec cat {} \; |  cut -d " " -f 3- | sort -uV | grep -vE "http-missing-security-headers|can-i-take-over-dns-fingerprint"; cfu-clean $(find . -name "fu-*.json")'
alias binwalk="/usr/bin/binwalk --dd='.*'"
alias cfu-clean-url='f(){ cfu-clean $@ | cut -d"|" -f4- ;  unset -f f; }; f'
alias cfu-clean='f(){ cfu $@ | cut -d "|" -f1,3- | awk -F/ "!_[\$1]++" | sort -u -t: -k1,1 ;  unset -f f; }; f'
alias cfu='f(){ jq -r ".results[] | [(.status|tostring), (.length|tostring), (.lines|tostring), (.words|tostring), .url] | join(\"|\")" $@ | sort -uV;  unset -f f; }; f'
alias crl='curl -sS --path-as-is -gk -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) snap Chromium/83.0.4103.106 Chrome/83.0.4103.106 Safari/537.36"'
alias crli='curl -sS --path-as-is -gk -D /dev/stderr -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) snap Chromium/83.0.4103.106 Chrome/83.0.4103.106 Safari/537.36"'
alias dirmon='inotifywait -rm -e create -e moved_to -e modify -e access -e attrib -e close_write -e moved_from'
alias killit='sudo kill -KILL'
alias favhash="python3 -c 'from mmh3 import hash as h;from codecs import encode as e;from sys import argv;favicon = e(open(argv[1], \"rb\").read(), \"base64\");print(f\"https://www.shodan.io/search?query=http.favicon.hash%3A{h(favicon)}\")'"
alias fu='ffuf -mc all -t 2 -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"'

# Tools Misc
alias vgrep='f(){ grep -rnH "$1" "$2" | fzf --preview="bat --pager never --color always -H {2} -r {2}: -p {1}" --delimiter=: ;  unset -f f; }; f'

# Docker Utils (advanced)
alias docker-norestart='docker update --restart=no $(docker ps -q)'
alias docker-stopall='docker stop $(docker ps -q)'
alias docker-get-image-size='f(){ docker manifest inspect -v "$1" | jq -c "if type == \"array\" then .[] else . end" |  jq -r "[ ( .Descriptor.platform | [ .os, .architecture, .variant, .\"os.version\" ] | del(..|nulls) | join(\"/\") ), ( [ .SchemaV2Manifest.layers[].size ] | add ) ] | join(\" \")" | numfmt --to iec --format "%.2f" --field 2 | column -t ;  unset -f f; }; f'
alias dockex='docker exec -it $(docker ps | grep -vF "CONTAINER ID" | fzf | cut -d" " -f1)'
alias dockit='docker run --rm -it -v "$PWD":/host --net=host'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias wipe-docker-all='docker system prune -a -f --volumes'
alias wipe-docker-image='docker rmi -f $(docker images -q)'
alias wipe-docker-network='docker network rm $(docker network ls -q | tr "\n" " ")'
alias wipe-docker-process='docker rm $(docker ps -a -q)'
alias wipe-docker-volume='docker volume rm $(docker volume ls -q | tr "\n" " ")'

# Docker Tooling
## Git stuff
alias git-trufflehog='dockit trufflesecurity/trufflehog:latest'
alias git-leaks="dockit zricethezav/gitleaks"
alias git-allsecrets='dockit --entrypoint sh abhartiya/tools_gitallsecrets'

## Recon
alias recon-amass='dockit caffix/amass'
alias recon-findomain='dockit edu4rdshl/findomain:latest findomain'
alias recon-gcert='dockit hessman/gcert'
alias recon-witnessme='dockit -w /host byt3bl33d3r/witnessme --threads 5 screenshot'
alias recon-wappa='dockit wappalyzer/cli -r -D 2 -P -a "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) snap Chromium/83.0.4103.106 Chrome/83.0.4103.106 Safari/537.36" $@'

## Fuzz & Crawl
alias supptruder="dockit elsicarius/supptruder"
alias acunetix='docker run --rm -it -p 3443:3443 -d ogranc/awvs_scanner:14.6.211220100; echo "Remember to run /home/acunetix/.acunetix/change_credentials.sh"'
alias htcap-crawl='f(){ OUT=$(echo "$1" | tr "/" "_"); dockit htcap htcap crawl -m aggressive -s domain -U "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) snap Chromium/83.0.4103.106 Chrome/83.0.4103.106 Safari/537.36" "$1" "/host/$OUT.db" ; dockit htcap htcap scan native "/host/$OUT.db"; dockit htcap htcap util report "/host/$OUT.db" "/host/$OUT.html" ; unset -f f; }; f'
alias rustscan='dockit rustscan/rustscan'
alias oneforall='dockit tardis07/oneforall'
alias getfuzz='f(){ echo "<fuzz1>\"fuzz2'"'"'fuzz3\`%}})fuzz4\${{fuzz5\\";  unset -f f; }; f'

## Compliance
alias ssh-audit="dockit positronsecurity/ssh-audit"
alias ssh-scan="dockit mozilla/ssh_scan /app/bin/ssh_scan"
alias ssl-scan="dockit zeitgeist/docker-sslscan"
alias ssl-test='dockit drwetter/testssl.sh'

## Hash cracking
alias john='dockit phocean/john_the_ripper_jumbo'
alias hashcat='dockit -w /host dizcza/docker-hashcat:intel-cpu hashcat'

## Exploits
alias metasploit='dockit -v /tmp/msf:/tmp/msf -e MSF_UID=0 -e MSF_GID=0 metasploitframework/metasploit-framework:latest /bin/bash'
alias wpscan="dockit wpscanteam/wpscan"
alias drupwn="dockit immunit/drupwn"

## Misc
alias retdec='dockit blacktop/retdec'

## Sysadmin
alias sysdig='docker run --rm -it --privileged --net=host -v /var/run/docker.sock:/host/var/run/docker.sock -v /dev:/host/dev -v /proc:/host/proc:ro -v /boot:/host/boot:ro -v /src:/src -v /lib/modules:/host/lib/modules:ro -v /usr:/host/usr:ro -v /etc:/host/etc:ro -d --name sysdig docker.io/sysdig/sysdig'
alias swagger-editor='dockit swaggerapi/swagger-editor'
alias crypt-pad='mkdir datastore; docker run --rm -it -p 3000:3000 -v "$PWD/datastore:/cryptpad/datastore" arno0x0x/docker-cryptpad'

# Search file contents with ripgrep, fzf, bat
alias fzf-rg="rg --hidden --glob '' --line-number . | fzf --delimiter ':' --preview 'bat --style=numbers --color=always {1} --highlight-line {2}'"

alias pre-commit=prek
