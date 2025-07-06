if test -x "$(which bat)"; then
    alias batcat="bat --theme ansi"
fi

alias psms="ps -x |grep sms |grep -v grep"
alias pbatt="ps -x |grep batt |grep -v grep"
alias ptermux="ps -x |grep termux |grep -v grep"

latest18()
{
    list-latest-files.sh -type-dir -max 4 -n 100 $1 $BASE_DIRS[$iDEVICES[$DEVICE],18] | grep "/25"
}

alias ht="history |tail -20"
alias h="history "
alias df="df -H"
#alias m=more
alias m=batcat
alias h1="head -10"
alias h2="head -20"
alias h3="head -30"
alias h4="head -40"
alias h5="head -50"
alias t1="tail -10"
alias t2="tail -20"
alias t3="tail -30"
alias t4="tail -40"
alias t5="tail -50"

alias j=jobs
alias dusk="du -s -x -k"
alias dusm="du -s -x -m -h"
alias dusb="du -s -x -b"
alias ls="ls -F --color=auto"
alias ll='ls -l'
alias ls_fulltime='ls -l --time-style=+%y%m%d%H%M%S'
alias lt=ls_fulltime
alias la='ls -la'
alias grep="grep --directories=skip --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}"

alias mmkdir='mkdir -m 770 -p'

alias pingtest="ping  wikipedia.de"

alias lui=log-any-on_off-UI.sh

# vorher: cd /home/ralf/data_home_disk/Rsync-Direkt-Linux/MainCloud-Rsync/Backup/250123_ab_da
alias large_backup_dirs='dusm *_0* |grep "[0-9]M" |grep -v ","'

alias cdflac="cd /home/ralf/data_home_disk/11_MeineMusik"
alias cmu="cdflac ; cmus"
musicfind()
{
    cdflac
    ls */*${1}*${2}*${3}* | grep :
}

alias dfsd="df|grep sd"

# Evtl vorher:
# mtp-detect |grep bus
# dann ps -uax|grep fs
# dann alle Prozesse killen, die mit obigen bus/dev Nummern zu tun haben
alias mount_mtp_d="jmtpfs $HOME/DeskTablet-jmtpfs ; ls $HOME/DeskTablet-jmtpfs "
alias umount_mtp_d="fusermount -u  $HOME/DeskTablet-jmtpfs ; echo ls $HOME/DeskTablet-jmtpfs ; ls $HOME/DeskTablet-jmtpfs  "

alias setusbnetzenv="$HOME/MyScripts.Ubuntu/scriptlib/setusbipenv.sh ; source $HOME/.zshrc-ohne-ohmyzsh"
alias snu=setusbnetzenv
alias setnetzenv="$HOME/MyScripts.shared/scriptlib/setipenv.sh ; source $HOME/.zshrc-ohne-ohmyzsh"
alias sne=setnetzenv
alias setnetzenv_nodist="$HOME/MyScripts.shared/scriptlib/setipenv.sh -no-distribution ; source $HOME/.zshrc-ohne-ohmyzsh"
alias snend=setnetzenv_nodist
alias setnetz_refresh="source $HOME/.zshrc-ohne-ohmyzsh ; $HOME/MyScripts.shared/setrcloneconf.sh "
alias snr=setnetz_refresh

alias satamount="sudo mount /mnt/SATA_intern"
alias satamountrw="sudo umount /mnt/SATA_intern ; sudo mount -o rw /mnt/SATA_intern"
alias satamountro="sudo umount /mnt/SATA_intern ; sudo mount -o ro /mnt/SATA_intern"
alias sataumount="sudo umount /mnt/SATA_intern"

alias tarpunktfiles="tar cf Temp/Punktfiles-Handy.tar .????*"

alias rsatamount="ssh root@$IP_PC mount /mnt/SATA_intern "
alias rsataumount="ssh root@$IP_PC umount /mnt/SATA_intern "
alias rhalt="ssh root@$IP_PC shutdown -h "
alias rhaltnow="rhalt now "
alias sftppc="sftp ralf@$IP_PC"

alias ftp_start="sudo systemctl restart vsftpd"
alias ftp_stop="sudo systemctl stop vsftpd"

alias sshstart="sudo systemctl start sshd"
alias sshrestart="sudo systemctl restart sshd"
alias sshstatus="sudo systemctl status sshd"
alias sshstop="sudo systemctl stop sshd"

alias sshdwindebian="sudo mkdir /run/sshd ; sudo /usr/sbin/sshd"


