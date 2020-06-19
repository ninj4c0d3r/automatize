#!/bin/bash
# Autor: Jonatas Fil (@exploitation)
# Data: 19/06/2020
# Automatize ;)


# check if Nmap installation exists
if which nmap >/dev/null; then
   echo '[*][Nmap]: installation found!'
else
   echo '[x]:[warning]:this script require Nmap installed to work'
   echo '[!]:[please wait]: Downloading from network...'
   sleep 3
   sudo apt install nmap -y
fi
sleep 1
# check if sslscan installation exists
if which sslscan >/dev/null; then
   echo '[*][sslscan]: installation found!'
else
   echo '[x]:[warning]:this script require sslscan installed to work'
   echo '[!]:[please wait]: Downloading from network...'
   sleep 3
   sudo apt install sslscan -y
fi
sleep 1
# check if nikto installation exists
if which nikto >/dev/null; then
   echo '[*][nikto]: installation found!'
else
   echo '[x]:[warning]:this script require nikto installed to work'
   echo '[!]:[please wait]: Downloading from network...'
   sleep 3
   sudo apt-get install nikto -y
fi
sleep 1
# check if cutycapt installation exists
if which cutycapt >/dev/null; then
   echo '[*][cutycapt]: installation found!'
else
   echo '[x]:[warning]:this script require cutycapt installed to work'
   echo '[!]:[please wait]: Downloading from network...'
   sleep 3
   sudo apt-get install cutycapt -y
fi
sleep 1
# check if convert installation exists
if which convert >/dev/null; then
   echo '[*][imagemagick]: installation found!'
else
   echo '[x]:[warning]:this script require imagemagick installed to work'
   echo '[!]:[please wait]: Downloading from network...'
   sleep 3
   sudo apt install imagemagick -y
fi
sleep 1
# check if dirsearch installation exists
if ls dirsearch >/dev/null; then
   echo '[*][dirsearch]: installation found!'
else
   echo '[x]:[warning]:this script require dirsearch installed to work'
   echo '[!]:[please wait]: Downloading from network...'
   sleep 3
   git clone https://github.com/maurosoria/dirsearch.git
fi
sleep 1
# check if nuclei installation exists
if ls nuclei >/dev/null; then
   echo '[*][nuclei]: installation found!'
else
  echo '[x]:[warning]:this script require nuclei installed to work'
  echo '[!]:[please wait]: Downloading from network...'
  sleep 3
  git clone https://github.com/projectdiscovery/nuclei.git
  docker build -t projectdiscovery/nuclei nuclei/.
fi
sleep 1

##################### MENU #####################
clear
echo "-> Bem-vindo! <-"
sleep 2
sh_Principal () {

cat <<!
             AUTOMATIZE V1.0
#------------------------------------------#
#      1) - Dominio  -   2) - IP           #
#             e) - Sair                    #
#------------------------------------------#
!
echo -n "Qual a opção desejada ? "
read opcao
case $opcao in
	1) sh_dominio ;;
  2) sh_ip ;;
  e) sh_sair ;;

	*) echo "\"$opcao\" Opção inválida!"; sleep 2; sh_Principal ;;
esac
}

# Dominio
sh_dominio () {
clear
echo -n "Digite o seu dominio: "
read dominio
IP=$(host $dominio | awk '/has address/ { print $4 }' | head -1)
DIR=$dominio
if [ ! -d $DIR ]; then
  mkdir -p $DIR;
fi
printf "\n============================================================"
printf "\nCarregando Nmap..."
nmap -A -Pn $dominio > $DIR/$dominio-nmap.txt
cat $DIR/$dominio-nmap.txt | grep 'open' > $DIR/$dominio-nmap.txt
printf "\nNmap finalizado."
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~"
printf "\nCarregando SSLscan..."
sslscan --no-failed --no-colour $IP | grep 'Accepted\|heartbleed' > $DIR/$dominio-ssl.txt
printf "\nSSLscan finalizado."
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~"
printf "\nCarregando Dirsearch..."
if grep '443' $DIR/$dominio-nmap.txt >/dev/null; then
  python3 dirsearch/dirsearch.py -u https://$dominio -e php -x 403,400,404,429 -b -R 1 -t 50 --plain-text-report=$DIR/$dominio-dirsearch.txt > /dev/nul
else
  python3 dirsearch/dirsearch.py -u http://$dominio -e php -x 403,400,404,429 -b -R 1 -t 50 --plain-text-report=$DIR/$dominio-dirsearch.txt > /dev/nul
fi
printf "\nDirsearch finalizado."
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~"
printf "\nCarregando Nuclei..."
echo "$dominio" | docker run -v ~/Documentos/Vivo/nuclei-templates:/go/src/app/ -i projectdiscovery/nuclei -t "./all/*.yaml" > $DIR/$dominio-nuclei.txt
printf "\nNuclei finalizado."
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~"
printf "\nCarregando Nikto..."
if grep '443' $DIR/$dominio-nmap.txt >/dev/null; then
  nikto -h https://$dominio > $DIR/$dominio-nikto.txt
else
  nikto -h http://$dominio > $DIR/$dominio-nikto.txt
fi
printf "\nNikto finalizado."
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~"

sh_relatorio_dominio;
}

# IP
sh_ip () {
clear
echo -n "Digite o seu IP: "
read IP
DIR=$IP
if [ ! -d $DIR ]; then
  mkdir -p $DIR;
fi
printf "\n============================================================"
printf "\nCarregando Nmap..."
nmap -A -Pn $IP > $DIR/$IP-nmap.txt
cat $DIR/$dominio-nmap.txt | grep 'open' > $DIR/$dominio-nmap.txt
printf "\nNmap finalizado."
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~"
printf "\nCarregando SSLscan..."
sslscan --no-failed --no-colour $IP | grep 'Accepted\|heartbleed' > $DIR/$IP-ssl.txt
printf "\nSSLscan finalizado."
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~"
printf "\nCarregando Dirsearch..."
if grep '443' $DIR/$IP-nmap.txt >/dev/null; then
  python3 dirsearch/dirsearch.py -u https://$IP -e php -x 403,400,404,429 -b -R 1 -t 50 --plain-text-report=$DIR/$IP-dirsearch.txt > /dev/nul
else
  python3 dirsearch/dirsearch.py -u http://$IP -e php -x 403,400,404,429 -b -R 1 -t 50 --plain-text-report=$DIR/$IP-dirsearch.txt > /dev/nul
fi
printf "\nDirsearch finalizado."
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~"
printf "\nCarregando Nuclei..."
echo "$IP" | docker run -v ~/Documentos/Vivo/nuclei-templates:/go/src/app/ -i projectdiscovery/nuclei -t "./all/*.yaml" > $DIR/$IP-nuclei.txt
printf "\nNuclei finalizado."
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~"
printf "\nCarregando Nikto..."
if grep '443' $DIR/$IP-nmap.txt >/dev/null; then
  nikto -h https://$IP > $DIR/$IP-nikto.txt
else
  nikto -h http://$IP > $DIR/$IP-nikto.txt
fi
printf "\nNikto finalizado."
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~"

sh_relatorio_ip;
}

# Relatorio
sh_relatorio_dominio () {
printf "\nGerando relatórios..."
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~"
cat $DIR/$dominio-nmap.txt | convert -fill white -scale 100% -background black label:@- $DIR/nmap-scan.png
cat $DIR/$dominio-dirsearch.txt | convert -fill white -scale 100% -background black label:@- $DIR/dirsearch-scan.png
cat $DIR/$dominio-ssl.txt | convert -fill white -scale 100% -background black label:@- $DIR/ssl-scan.png
cat $DIR/$dominio-nikto.txt | convert -fill white -scale 100% -background black label:@- $DIR/nikto-scan.png
printf "\nRelatórios gerados."
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~"

sh_screenshot_dominio;
}

# Screenshot
sh_screenshot_dominio () {
printf "\nGerando Screenshot..."
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~"
if grep '443' $DIR/$dominio-nmap.txt >/dev/null; then
  cutycapt --insecure --url=https://$dominio --out=$DIR/$dominio-screen.png --max-wait=50000
else
  cutycapt --insecure --url=http://$dominio --out=$DIR/$dominio-screen.png --max-wait=50000
fi
printf "\nScreenshot gerados."
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~"

sh_Principal;
}

# Relatorio
sh_relatorio_ip () {
printf "\nGerando relatórios..."
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~"
cat $DIR/$IP-nmap.txt | convert -fill white -scale 100% -background black label:@- $DIR/nmap-scan.png
cat $DIR/$IP-dirsearch.txt | convert -fill white -scale 100% -background black label:@- $DIR/dirsearch-scan.png
cat $DIR/$IP-ssl.txt | convert -fill white -scale 100% -background black label:@- $DIR/ssl-scan.png
cat $DIR/$IP-nikto.txt | convert -fill white -scale 100% -background black label:@- $DIR/nikto-scan.png
printf "\nRelatórios gerados."
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~"

sh_screenshot_ip;
}

# Screenshot
sh_screenshot_ip () {
printf "\nGerando Screenshot..."
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~"
if grep '443' $DIR/$IP-nmap.txt >/dev/null; then
  cutycapt --insecure --url=https://$IP --out=$DIR/$IP-screen.png --max-wait=50000
else
  cutycapt --insecure --url=http://$IP --out=$DIR/$IP-screen.png --max-wait=50000
fi
printf "\nScreenshot gerados."
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~"
sleep 5

sh_Principal;
}

# Exit
sh_sair () {
echo "Saindo..."
sleep 2
clear
exit
}

sh_Principal
