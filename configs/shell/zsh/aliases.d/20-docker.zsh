# shellcheck shell=bash disable=SC2142,SC2139,SC2154,SC2168
# Docker aliases — basic shortcuts, advanced ops, and image-runner tooling.
#
# Note: the "Docker tooling" aliases below depend on `dockit`, which is
# defined in this file — keep dockit above its consumers.

# --- Basic (conditional on docker being installed) -------------------------
if command -v docker &>/dev/null; then
  alias d='docker'
  alias dex='docker exec -it'

  # docker-compose might be a plugin or separate command.
  # Probe for the compose CLI plugin on disk instead of running
  # `docker compose version` — that spawns the docker CLI (+ plugin
  # resolution) and costs ~85ms on every shell start.
  if command -v docker-compose &>/dev/null; then
    alias dc='docker-compose'
  else
    for _compose_plugin in \
      "$HOME/.docker/cli-plugins/docker-compose" \
      /usr/local/lib/docker/cli-plugins/docker-compose \
      /usr/local/libexec/docker/cli-plugins/docker-compose \
      /usr/lib/docker/cli-plugins/docker-compose \
      /usr/libexec/docker/cli-plugins/docker-compose; do
      if [[ -x "$_compose_plugin" ]]; then
        alias dc='docker compose'
        break
      fi
    done
    unset _compose_plugin
  fi
fi

# --- Advanced ops ----------------------------------------------------------
# These assume docker is installed; they fail at call time (not definition
# time) if it isn't.
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

# --- Image-based one-shots (via dockit) ------------------------------------
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
# acunetix: removed — was pinned to ogranc/awvs_scanner:14.6.211220100, a
# Dec-2021 image that has not been updated since. 4+ years of unpatched
# upstream CVEs in the container's userland made it a liability. Re-add
# pointing at a maintained image if you still use it.
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
