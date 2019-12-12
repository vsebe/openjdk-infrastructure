#!/bin/bash
set -eu

osToDestroy=''
force=False
# Takes in all arguments
processArgs()
{
	while [[ $# -gt 0 ]] && [[ ."$1" = .-* ]] ; do
		local opt="$1";
		shift;
		case "$opt" in
			"--OS" | "-o" )
				if [[ -z "${1:-}" ]]; then
					echo "Please specifiy an OS with the '-o' option"
					usage
					exit 1
				else
					osToDestroy=$1;
				fi
				shift;;
			"--force" | "-f" )
				force=True;;
			"--help" | "-h" )
				usage; exit 0;;
			*) echo >&2 "Invalid option: ${opt}"; echo "This option was unrecognised."; usage; exit 1;;
		esac
	done
}

usage() {
	   echo "Usage: ./vmDestroy.sh (<options>) -o <os_list>
		--OS | -o		Specifies the OS of the vagrant VMs you want to destroy
		--force | -f		Force destroy the VMs without asking confirmation
		--help | -h		Displays this help message"
		listOS
}

checkOS() {
	local OS=$osToDestroy
        case "$OS" in
                "Ubuntu1604" | "U16" | "u16" )
			osToDestroy="U16";;
                "Ubuntu1804" | "U18" | "u18" )
                        osToDestroy="U18";;
                "CentOS6" | "centos6" | "C6" | "c6" )
                        osToDestroy="C6" ;;
                "CentOS7" | "centos7" | "C7" | "c7" )
                        osToDestroy="C7" ;;
                "Windows2012" | "Win2012" | "W12" | "w12" )
                        osToDestroy="W2012";;
                "all" )
                        osToDestroy="U16 U18 C6 C7 W2012" ;;
		"")
			echo "No OS detected. Did you miss the '-o' option?" ; usage; exit 1;;
		*) echo "$OS is not a currently supported OS" ; listOS; exit 1;
        esac
}

listOS() {
	echo
	echo "Currently supported OSs:
		- Ubuntu1604
		- Ubuntu1804
		- CentOS6
		- CentOS7
		- Win2012"
	echo
}

destroyVMs() {
	local OS=$1
	vagrant global-status --prune | awk "/adoptopenjdk$OS/ { print \$1 }" | xargs vagrant destroy -f
	echo "Destroyed all $OS Vagrant VMs"
}

processArgs $*
checkOS
if [[ "$force" == False ]]; then
	userInput=""
	echo "Are you sure you want to destroy ALL Vms with the following OS(s)? (Y/n)"
	echo "$osToDestroy"
	read userInput
	if [ "$userInput" != "Y" ] && [ "$userInput" != "y" ]; then
		echo "Cancelling ..."
		exit 1;
	fi
fi	
for OS in $osToDestroy 
do
	destroyVMs $OS
done
