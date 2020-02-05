# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Aliases
alias gst='git status'
alias ls='ls --color=auto'
alias vim='nvim'

# PS1
# get current branch in git repo
function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ ! "${BRANCH}" == "" ]
	then
		STAT=`parse_git_dirty`
		echo "[${BRANCH}${STAT}]"
	else
		echo ""
	fi
}

# get current status of git repo
function parse_git_dirty {
	status=`git status 2>&1 | tee`
	dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
	untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
	ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
	newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
	renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
	deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
	bits=''
	if [ "${renamed}" == "0" ]; then
		bits=">${bits}"
	fi
	if [ "${ahead}" == "0" ]; then
		bits="*${bits}"
	fi
	if [ "${newfile}" == "0" ]; then
		bits="+${bits}"
	fi
	if [ "${untracked}" == "0" ]; then
		bits="?${bits}"
	fi
	if [ "${deleted}" == "0" ]; then
		bits="x${bits}"
	fi
	if [ "${dirty}" == "0" ]; then
		bits="!${bits}"
	fi
	if [ ! "${bits}" == "" ]; then
		echo " ${bits}"
	else
		echo ""
	fi
}

PS1="\w \e[0;36m\`parse_git_branch\`\[\e[m\] "

# Golang
# TODO: Consolidate
export PATH=$PATH:/usr/local/go/bin
export GOPATH=~/workspace/local-gopath
export PATH=$PATH:~/workspace/local-gopath/bin

# Fasd
eval "$(fasd --init auto)"

# Direnv
eval "$(direnv hook bash)"

# Editor
export EDITOR=nvim

# Missing Commands
source /usr/share/doc/pkgfile/command-not-found.bash

# Start GPG Agent and SSH_AUTH_SOCK
if ! pgrep -x -u "${USER}" gpg-agent >/dev/null 2>&1; then
  gpg-connect-agent /bye >/dev/null 2>&1
fi
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye > /dev/null 2>&1

unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
fi

# Functions

## Adds remotes for each exiting PR
pullify() {
    git config --add remote.origin.fetch '+refs/pull/*/head:refs/remotes/origin/pr/*'
    git fetch origin
}

## Encrypted secrets helpers
load_secrets() {
    encfs ~/.secrets/ ~/secrets/
}

unload_secrets() {
    fusermount -u ~/secrets/
}

## Wifi helpers
wifi_new_connection() {
    ssid=$1
    password=$2
    nmcli d wifi connect "$ssid" password "$password"
}

wifi_connect() {
    ssid=$1
    nmcli c up "$ssid"
}

wifi_disconnect() {
    nmcli d disconnect wlp2s0
}

wifi_list_connections() {
    nmcli c
}

wifi_remove_connection() {
  ssid=$1
  nmcli c delete "$ssid"
}

wifi_list() {
    nmcli d wifi list
}

## Touchscreen helpers
enable_touchscreen() {
  xinput enable "ELAN Touchscreen"
}

disable_touchscreen() {
  xinput disable "ELAN Touchscreen"
}

## Pivotal VPN

connect_pivotal_vpn() {
  sudo openconnect --protocol=gp portal-nasa.vpn.pivotal.io
}

connect_vmware_vpn()  {
  sudo openconnect https://gpu.vmware.com --protocol gp
}

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
