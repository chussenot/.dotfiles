# shellcheck shell=bash disable=SC2142,SC2139,SC2154,SC2168
# Recon / fuzz / capture helpers — wrappers around curl, tcpdump, nmap, ffuf, etc.

if command -v xdg-open &>/dev/null; then
  alias get-pass-exploits='f(){ xdg-open "https://www.exploitalert.com/search-results.html?search=$@" ;  unset -f f; }; f'
  alias get-pass-info='f(){ xdg-open "https://cirt.net/passwords?criteria=$@" ;  unset -f f; }; f'
  alias get-port-info='f(){ xdg-open "https://www.speedguide.net/port.php?port=$@" ;  unset -f f; }; f'
  alias get-bookhacktricks='f(){ xdg-open "https://book.hacktricks.xyz/?q=$@" ;  unset -f f; }; f'
  alias recon-certspotter='f(){ xdg-open "https://api.certspotter.com/v1/issuances?domain=$1&include_subdomains=true&expand=dns_names&expand=issuer&expand=cert" ;  unset -f f; }; f'
  alias recon-virustotal='f(){ xdg-open "https://www.virustotal.com/gui/domain/$1" ;  unset -f f; }; f'
fi
alias recon-crtsh='f(){ curl -sk "https://crt.sh/?output=json&q=$1" | jq . ; unset -f f; }; f'
alias recon-wayback='f(){ curl -sk "https://web.archive.org/cdx/search/cdx?fl=original&collapse=urlkey&url=*.$1" ; unset -f f; }; f'
alias capture-http='f(){ sudo unbuffer tcpdump -A -s 0 "tcp port $@ and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)" | tr "\\n" "\n" ; unset -f f; }; f'
# SECURITY: Use dynamic interface detection instead of hardcoded value
alias capture-creds='f(){ _iface="${1:-$(ip route | grep default | awk "{print \$5}" | head -1)}"; sudo tcpdump -i "$_iface" port http or port ftp or port smtp or port imap or port pop3 or port telnet -l -A | grep -iEB5 --line-buffered "pass=|pwd=|log=|login=|user=|username=|pw=|passw=|passwd=|password=|pass:|user:|username:|password:|login:|pass |user |authorization:|token"; unset -f f; }; f'
alias nmap-html='nmap --stylesheet https://raw.githubusercontent.com/honze-net/nmap-bootstrap-xsl/master/nmap-bootstrap.xsl'
# arm-vm: removed (required /opt/arm_now which is no longer available)
alias bb-results='find . -iname "nuclei-*" -exec cat {} \; |  cut -d " " -f 3- | sort -uV | grep -vE "http-missing-security-headers|can-i-take-over-dns-fingerprint"; cfu-clean $(find . -name "fu-*.json")'
alias binwalk="binwalk --dd='.*'"
alias cfu-clean-url='f(){ cfu-clean $@ | cut -d"|" -f4- ;  unset -f f; }; f'
alias cfu-clean='f(){ cfu $@ | cut -d "|" -f1,3- | awk -F/ "!_[\$1]++" | sort -u -t: -k1,1 ;  unset -f f; }; f'
alias cfu='f(){ jq -r ".results[] | [(.status|tostring), (.length|tostring), (.lines|tostring), (.words|tostring), .url] | join(\"|\")" $@ | sort -uV;  unset -f f; }; f'
alias crl='curl -sS --path-as-is -gk -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) snap Chromium/83.0.4103.106 Chrome/83.0.4103.106 Safari/537.36"'
alias crli='curl -sS --path-as-is -gk -D /dev/stderr -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) snap Chromium/83.0.4103.106 Chrome/83.0.4103.106 Safari/537.36"'
if command -v inotifywait &>/dev/null; then
  alias dirmon='inotifywait -rm -e create -e moved_to -e modify -e access -e attrib -e close_write -e moved_from'
fi
alias killit='sudo kill -KILL'
alias favhash="python3 -c 'from mmh3 import hash as h;from codecs import encode as e;from sys import argv;favicon = e(open(argv[1], \"rb\").read(), \"base64\");print(f\"https://www.shodan.io/search?query=http.favicon.hash%3A{h(favicon)}\")'"
alias fu='ffuf -mc all -t 2 -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"'
