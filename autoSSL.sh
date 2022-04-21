#!/bin/bash
# download sslscan
# curl -sLO http://archive.ubuntu.com/ubuntu/pool/universe/s/sslscan/sslscan_2.0.7-1_amd64.deb && sudo dpkg -i sslscan_2.0.7-1_amd64.deb && rm -r sslscan_2.0.7-1_amd64.deb
# https://github.com/rbsec/sslscan
pwd=$(pwd)
checkapt(){
    command -v "$1" >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
      printf """\e[1;37m[ + ] installing ${COMMAND} :\n curl -sLO http://archive.ubuntu.com/ubuntu/pool/universe/s/sslscan/sslscan_2.0.7-1_amd64.deb && sudo dpkg -i sslscan_2.0.7-1_amd64.deb && rm -r sslscan_2.0.7-1_amd64.deb\n\e[0m\n"""
      sudo apt install $1 -y
      exit 1
    fi
}
for COMMAND in "figlet" "sslscan" "testssl"; do
    checkapt "${COMMAND}"
done
clear
header(){
  printf """        \e[1;32m-\e[0m\e[1;32m-\e[0m\e[1;32m-\e[0m\e[1;32m-\e[0m\e[1;32m-\e[0m\e[1;32m-\e[0m ---- AutoSSL Cert generate ---- \e[0m\e[1;32m-\e[0m\e[1;32m-\e[0m\e[1;32m-\e[0m\e[1;32m-\e[0m\e[1;32m-\e[0m\e[1;32m-\e[0m
   _______  __   __  _______  _______ \e[30;38;5;197m _______  _______  ___\e[0m
  |   _   ||  | |  ||       ||       |\e[30;38;5;197m|       ||       ||   |\e[0m
  |  |_|  ||  | |  ||_     _||   _   |\e[30;38;5;197m|  _____||  _____||   |\e[0m
  |       ||  |_|  |  |   |  |  | |  |\e[30;38;5;197m| |_____ | |_____ |   |\e[0m
  |       ||       |  |   |  |  |_|  |\e[30;38;5;197m|_____  ||_____  ||   |___\e[0m
  |   _   ||       |  |   |  |       |\e[30;38;5;197m _____| | _____| ||       |\e[0m
  |__| |__||_______|  |___|  |_______|\e[30;38;5;197m|_______||_______||_______|\e[0m
  \e[0m\e[0;37m  Generate: \e[30;38;5;120mPEM/PFX/PFX/P12/DER/P7B/CER/Public & Private-Key\e[0m
  \e[1;37m--------------------------------------------------------------\n
"""
}
header
printf """ _, _  _,   _,_ ___ ___ __,    _,_ ___ ___ __,  _,
 |\ | / \   |_|  |   |  |_)  / |_|  |   |  |_) (_
 | \| \ /   | |  |   |  |   /  | |  |   |  |   , )
 ~  ~  ~    ~ ~  ~   ~  ~      ~ ~  ~   ~  ~    ~

\e[1;37m Domain -> \e[1;33mtarget.com \e[0m\n"""
read -p $'\e[1;32m Domain \e[0m\e[1;37m:~ ' d0mainNumb
printf """ \e[0m"""
clear
header
if curl --output /dev/null --silent --head --fail "$d0mainNumb"; then
  printf "Starting now ..."
  paoutput="$pwd/output"
  if [ ! -d "$paoutput" ]; then
    mkdir output
  fi
  pathfulld0mainNumb="$pwd/output/$d0mainNumb"
  if [ ! -d "$pathfulld0mainNumb" ]; then
    mkdir $pathfulld0mainNumb
  fi
  # key + cer
  cmd1="openssl s_client -connect $d0mainNumb:443 -prexit -showcerts -state -status -tlsextdebug -verify 10"
	gnt1=$(gnome-terminal --geometry=87x21 -- sh -c "$cmd1; echo \"Your target : $d0mainNumb\"; ${SHELL:-bash}");

  cmd2="testssl --fast $d0mainNumb"
	gnt2=$(gnome-terminal --geometry=87x21 -- sh -c "$cmd2; echo \"Your target : $d0mainNumb\"; ${SHELL:-bash}");
  #
  cmd3="sslscan --http --bugs --verbose --show-certificate $d0mainNumb"
	gnt3=$(gnome-terminal --geometry=87x21 -- sh -c "$cmd3; echo \"Your target : $d0mainNumb\"; ${SHELL:-bash}");
  #
  cmd4="sslscan --no-failed $d0mainNumb"
	gnt4=$(gnome-terminal --geometry=87x21 -- sh -c "$cmd4; echo \"Your target : $d0mainNumb\"; ${SHELL:-bash}");
  exitcode=$?;
  #create PEM
  openssl s_client -showcerts -connect $d0mainNumb:443 </dev/null 2>/dev/null|openssl x509 -outform PEM > "$pathfulld0mainNumb/REAL-SSL-CERT-$d0mainNumb.pem"
  openssl s_client -showcerts -connect $d0mainNumb:443 -servername $d0mainNumb  </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "$pathfulld0mainNumb/REAL-SSL-CERT-FULL-$d0mainNumb.pem"
  openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:3072 -out $pathfulld0mainNumb/private-key.pem
  openssl rsa -in $pathfulld0mainNumb/private-key.pem -pubout -out $pathfulld0mainNumb/public-key.pem
  #manual
  clear
  header
  printf "\e[0;37m!!!!\e[0m\e[1;37m[ READ OUTPUT ]!!!!\e[0m\e[0;37m

\e[30;38;5;120m[ next ]\e[0m\e[1;37m enter information that will be incorporated \e[30;38;5;120m$d0mainNumb\e[0m

"
  openssl req -newkey rsa:2048 -nodes -keyout "$pathfulld0mainNumb/KEY_$d0mainNumb.key" -x509 -days 1000 -subj "/CN=www.$d0mainNumb/O=$d0mainNumb/C=IN" -out "$pathfulld0mainNumb/CN_$d0mainNumb.crt"
  openssl req -new -x509 -key $pathfulld0mainNumb/private-key.pem -out $pathfulld0mainNumb/cert.pem -days 360
  #generate password
  openssl pkcs12 -export -inkey $pathfulld0mainNumb/private-key.pem -in $pathfulld0mainNumb/cert.pem -out $pathfulld0mainNumb/cert.pfx
  openssl x509 -outform der -in $pathfulld0mainNumb/cert.pem -out "$pathfulld0mainNumb/DER-$d0mainNumb.der"
  openssl x509 -inform PEM -in $pathfulld0mainNumb/cert.pem -outform DER -out "$pathfulld0mainNumb/CER-$d0mainNumb.cer"
  openssl crl2pkcs7 -nocrl -certfile "$pathfulld0mainNumb/CER-$d0mainNumb.cer" -out "$pathfulld0mainNumb/P7B-$d0mainNumb.p7b" -certfile $pathfulld0mainNumb/cert.pem
  openssl pkcs12 -in "$pathfulld0mainNumb/cert.pfx" -out "$pathfulld0mainNumb/PEM-$d0mainNumb.pem" -nodes
  openssl pkey -in $pathfulld0mainNumb/public-key.pem -pubin -text
  openssl dgst -md5 "$pathfulld0mainNumb/REAL-SSL-CERT-FULL-$d0mainNumb.pem"
  openssl md5 "$pathfulld0mainNumb/REAL-SSL-CERT-FULL-$d0mainNumb.pem"
  openssl dgst -sha1 "$pathfulld0mainNumb/REAL-SSL-CERT-FULL-$d0mainNumb.pem"
  openssl dgst -sha384 "$pathfulld0mainNumb/REAL-SSL-CERT-FULL-$d0mainNumb.pem"
  testssl -p -s -f -U -S -P --jsonfile-pretty="$pathfulld0mainNumb/SSL.json" $d0mainNumb 
  printf """
    \e[30;48;5;118m┌────────────────────────────────────────┐\e[0m
    \e[30;48;5;118m│       ▄▄                               │\e[0m
    \e[30;48;5;118m│       ██                               │\e[0m
    \e[30;48;5;118m│  ▄███▄██   ▄████▄   ██▄████▄   ▄████▄  │\e[0m
    \e[30;48;5;118m│ ██▀  ▀██  ██▀  ▀██  ██▀   ██  ██▄▄▄▄██ │\e[0m
    \e[30;48;5;118m│ ██    ██  ██    ██  ██    ██  ██▀▀▀▀▀▀ │\e[0m
    \e[30;48;5;118m│ ▀██▄▄███  ▀██▄▄██▀  ██    ██  ▀██▄▄▄▄█ │\e[0m
    \e[30;48;5;118m│   ▀▀▀ ▀▀    ▀▀▀▀    ▀▀    ▀▀    ▀▀▀▀▀  │\e[0m
    \e[30;48;5;118m│  PATH                                  │\e[0m
    \e[30;48;5;118m└────────────────────────────────────────┘\e[0m
\e[1;37m$pathfulld0mainNumb\e[0m\n
"""
else
  clear
  header
  printf "\e[0;37m!!!!\e[0m\e[30;38;5;197m[
 _______
(_______)
 _____    ____ ____ ___   ____
|  ___)  / ___) ___) _ \ / ___)
| |_____| |  | |  | |_| | |
|_______)_|  |_|   \___/|_|

 ]\e[0m!!!!\n $d0mainNumb not url...\n"
  sleep 3
  $0
fi
