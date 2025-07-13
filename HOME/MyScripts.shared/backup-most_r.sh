#!/usr/bin/zsh

source $HOME/.zshrc-scripts
task=`basename $0`
argumente="$*"
date=`date +%y%m%d%H%M`


################ Optionen ##############

dry_run=""
checksum=""
enforce_backup=""
if [[ "$DEVICE" == "$DEVICES[u]" ]] ; then
    defaultziel=/media/ralf/Toshi_2501
else
    echo '******** Warning: "defaultziel" bisher nur fuer Ubuntu angegeben (/storage/... oder /mnt/... fehlt)   *******'
fi
ziel=$defaultziel
# funktioniert nicht - noch nicht weiter verfolgt
typeset -a exclude_1TB=( "--exclude=WinDebian" )
# folgendes klappt:
# /home/ralf/data_home_disk [3154] > rsync -ua --exclude=WinDebian  --exclude-from=ex Save-pCloud foo
typeset -a exclude_extras

# ggf hier weitere eintragen und dann auch in ~/.exclude_from_backup
# (kein "/" am Ende !! )
typeset -a rsync_ohne_backup=( $BASE_DIRS[$iDEVICES[$DEVICE],19] $BASE_DIRS[$iDEVICES[$DEVICE],18] $BASE_DIRS[$iDEVICES[$DEVICE],s] )
if [[ "$DEVICE" == "$DEVICES[u]" ]]; then
    rsync_ohne_backup=($rsync_ohne_backup /data_home_disk/SAVE-Kopien /data_home_disk/Rsync-Direkt-Linux )
fi

# nimm die zu rsync-enden dirs aus .exclude_from_backup raus
tmp1=$HOME/.tmp/exclude_from_backup.tmp1
tmp2=$HOME/.tmp/exclude_from_backup.tmp2
grep -i -v -e tmp -e temp  $exclude_from > $tmp1
for d in $rsync_ohne_backup ; do
    dd=`basename $d`
    grep -v $dd $tmp1 > $tmp2
    cp $tmp2 $tmp1
done

## more $tmp1
## diff $tmp1 $exclude_from
## exit ############

typeset -a backupdirs_indices=( 1 2 3 9 11 15 16 17 )

backup_von_backup="/media/ralf/Noname_2008"
backup_ab_da=250314_ab_da

HOME_BACKUP_HISTORY=$BACKUP_LOG

#---------------------------------------------------------------------------

while  test $# -gt 0 ; do
    case $1 in
        [-]h* )
            echo `basename $0` "[-h] [[--]checksum] [-no-lists] [--enforce_backup] [[--] dry*] [1804|1TB|toi] [WD|wd] [tra] [toe] [lex]"
            echo
            echo "Default disk : $ziel"
            echo "Nur bei dieser wird ((fast)) alles kopiert und auch immer ein Backup durchgefuehrt."
            echo "Das Backupverzeichnis wird zusaetzlich nach $backup_von_backup ge-rsync-ed."
            echo
            echo "Bei den 1TB drives : $exclude_1TB "
            echo
            echo "toi = Toshi_1804 "
            echo "toe = Toshiba_ext_1GB  (in Wirklichkeit 1TB :-)  )"
            echo "tra = Transcend_1TB"
            echo "lex = 60C8-1916 = 1TB Lexar SD Karte"
            echo
            echo "--checksum:     Es werden zwei rsync Durchgaenge gemacht: erst ohne --checksum, dann mit."
            echo
            echo "--enforce_backup:    Vermutlich Backup nur zur Sicherheit. Am besten gleich wieder loeschen, weil Platte zu klein."
            echo
            echo "Rsync-ohne-backup immer ohne --delete. Ggf rsync --delete manuell starten."
            echo
            echo "-no-lists:  Erzeuge keine file und dir Listen. Nur fuer Debugging sinnvoll."
            exit
            ;;
        Toe* | toe* | tousb | tou* | Toshiba_ext_1GB )
            if [[ "$DEVICE" == "$DEVICES[u]" ]] ; then
                ziel=/media/ralf/Toshiba_ext
            else
                echo disk name not yet specified
                exit
            fi
            exclude_extras=$exclude_1TB
            shift
            ;;
        *1804* | toi* | Toi* | 1TB | Toshiba_1TB_HDD_SATA )
            if [[ "$DEVICE" == "$DEVICES[u]" ]] ; then
                ziel=/media/ralf/Toshi_1804
            else
                ziel=4ACE-C1DA
            fi
            exclude_extras=$exclude_1TB
            shift
            ;;
        Lex* | lex* | 1TBLex* | 60* | 60C8-1916 )
            ziel="/media/ralf/60C8-1916"        # 1TB Lexar SD Karte
            exclude_extras=$exclude_1TB
            shift
            ;;
        Tra* | tra* | Transcend_1TB )
            if [[ "$DEVICE" == "$DEVICES[u]" ]] ; then
                ziel=/media/ralf/Transcend_1TB
            else
                echo disk name not yet specified
                exit
            fi
            echo 'ERST: passende Verzeichnisstruktur erstellen -- bisherige Verzeichnisse entsprechend verschieben'  ############
            echo 'Rsync-Direkt-Linux-Backup.alt erstellen in "/" (oberhalb von Rsync-ohne-Backup): bisheriges Backup-Verzeichnisse dorthin verschieben, dann manuell rsync -uav /data_home_disk/Rsyn*.alt/'  ############
            exit  #############
            exclude_extras=$exclude_1TB
            shift
            ;;
        WD* | wd* | ext* | WDextern )
            if [[ "$DEVICE" == "$DEVICES[u]" ]] ; then
                ziel=/media/ralf/WDextern
            else
                ziel=/storage/0201-4D74
            fi
            exclude_extras=$exclude_1TB
            shift
            ;;
        --enforce_backup* | enforce_backup* )
            enforce_backup=enforce_backup
            echo "will enforce backup"
            shift
            ;;
        --checksum* | checksum* )
            # ich hab's getestet:
            # touch --date="1988-11-11 11:11:11" x.txt
            # backup-most.sh
            # vi x.txt # nur 2 Buchstaben vertauscht
            # touch --date="1988-11-11 11:11:11" x.txt
            # backup-most.sh           : x.txt ist nicht im Backup
            # backup-most.sh  checksum : x.txt ist       im Backup
            # "backup-most.sh  checksum"  dauert 1-5 Stunden je nach Dockingstation
            checksum=--checksum
            shift
            ;;
        -no-li* )
            no_lists="no_lists"
            echo "don't create fdir and file lists"
            shift
            ;;
        --dry* | dry* )
            dry_run=--dry-run
            echo "do dry run"
            shift
            ;;
        * )
            echo "Wrong argument: $1  ---  Usage:"
            $task -h
            exit
            ;;
    esac
done

if [[ "$ziel" == "" ]]; then
    echo 'Backup "ziel" angeben!'
    exit
fi

initial_timestamp=`date +%s`

disk=$ziel
outbase=/$disk
outdir=$outbase

backup_1stbase=$ziel/Backup.backup-most
mkdir -p $backup_1stbase
backup_base=$backup_1stbase/$backup_ab_da
mkdir -p $backup_base
backupdir=$backup_base/$date
mkdir -p $backupdir

err_base=$ziel/Error
mkdir -p $err_base
mkdir -p $err_base/Alt
touch $err_base/2.foo
## folgendes ist unter Android nicht erlaubt
## mv $err_base/2* $err_base/Alt
# daher umstaendlicher:
rsync -ua $err_base/2* $err_base/Alt
rm -rf $err_base/2*
errdir=$err_base/$date
mkdir -p $errdir
err=$errdir/err.main-rsync



if [[ "$ziel" == "$defaultziel" || "$enforce_backup" != "" ]]; then
    do_backup=do_backup
fi

echo -e "\n ############  $DEVICE  START   $task       $date     #################"  | tee -a $err

echo "$bold $fg[green]" | tee -a $err
echo -e "\n**** use $ziel *****\n" | tee -a $err
message1="Error files are written in"
echo -e "Backup files are written in \t$backupdir\n\n$fg[magenta]$message1 $fg[green]\t$errdir $fg[cyan]   ---  !!!!!!    NICHT in .tmp   !!!!!!\n" | tee -a $err
echo -e " $reset \n" | tee -a $err


#######################################

if [[ "$ziel" != "$defaultziel" ]]; then
    df -H $outbase
    echo "Genug freier Speicherplatz? y|n [ y ] :  "
    read n
    if [[ "$n" == "n" ]] ; then
        echo "Alte backups loeschen und ueberfluessiges in Rsync-ohne-backup bzw SAVE-only-here"
        exit
    fi
else
    gemounted=`mount_mine |grep $backup_von_backup`
    if [[ "$gemounted" == "" ]]; then
        echo "$backup_von_backup ist nicht gemounted"
        exit
    fi
fi

# Achtung kein --size-only wegen Fotos-Konserven
typeset -a rsync_options_basic=($dry_run -uav --modify-window=2 $exclude_extras )
typeset -a rsync_options_basic2=($rsync_options_basic --delete --exclude-from=$exclude_from )

errc=""
echo "$bold $fg[green] \n\n STATUS $fg[yellow]  ############## $fg[green] START loop on $fg[cyan]  $backupdirs_indices $fg[yellow] ############## \n\n $fg[$standard_fg_color] " | tee -a $err
for d in $backupdirs_indices ; do

    ## echo "dir Index $d "  ##############

    # / am Ende notwendig
    indir=$BASE_DIRS[$iDEVICES[$DEVICE],$d]/

    if [[ "$indir" != "" ]] ; then

        indir_base=`basename $indir`
        outdir=$ziel/$indir_base
        mkdir -p $outdir


        if [[ "$do_backup" != "" ]]; then
            this_backupdir=$backupdir/$indir_base
            mkdir $this_backupdir
            rsync_options=($rsync_options_basic2 --backup --backup-dir=$this_backupdir )
        else
            rsync_options=($rsync_options_basic2 )
        fi

        echo "$bold $fg[green] \n\n STATUS ************** $indir_base ************** \n\n $fg[$standard_fg_color] " | tee -a $err

        date | tee -a  $err
        set_start_time

        echo "$fg[yellow]" | tee -a $err
        echo \
            rsync $rsync_options  $indir $outdir \
            | tee -a $err

        echo "\n$bold $fg[magenta]" | tee -a $err

        rsync $rsync_options  $indir $outdir \
            2>&1 | tee -a $err |& grep -v -e "symlink" -e "cannot delete non-empty directory" -e ".*\/$"

        echo "$reset" | tee -a $err
        print_time_used rsync | tee -a  $err

        #----------------------------------------------------
        # Bei --checksum erst einen Durchgang ohne --checksum und dann dasselbe mit --checksum
        # Beim Durchgang mit --checksum sollten keine Dateien mehr im Backup sein.
        if [[ "$checksum" != "" ]]; then
            echo -e "\n\n STATUS ********** rsync --checksum  ************\n" | tee -a $errc
            errc=$errdir/err.rsync-checksum
            echo -e "\n\n"
            date |  tee  -a $errc
            set_start_time
            echo "$fg[yellow]" | tee -a $errc

            echo rsync --checksum $rsync_options  $indir $outdir \
                | tee -a $errc

        echo "$fg["magenta] | tee -a $errc

                        rsync --checksum $rsync_options  $indir $outdir \
                                2>&1 | tee -a $errc |& grep -v -e "symlink" -e "cannot delete non-empty directory" -e ".*\/$"

                        echo "$reset" | tee -a $errc
                        print_time_used rsync-checksum | tee -a  $errc
                fi


                any_errors=`grep -i error $err $errc |grep -v -e $message1 -e "Ignoring --track-renames" -e "if any" -e "Error file" -e "some files/attrs"`
                if [[ "$any_errors" != "" ]]; then
                    echo "$bold $fg[magenta] \n\n !!!!!!!!!!!!!!! possible Error(s) :\n $reset  " | tee -a $err
                        echo "$bold $fg[cyan] $any_errors " | tee -a $err
                        echo "$reset  " | tee -a $err
                        varred -p "Continue (default) or abort (a)? " x
                        if [[ "$x" == "a" ]]; then
                            exit
                        fi
                fi

                #----------------------------------------------------
                if [[ "$dry_run" == "" && "$no_lists" == "" && "$do_backup" != "" ]]; then

                        echo -e "\n\nSTATUS : create dir and file lists\n" | tee -a $err
                        echo -e "find $outdir -type d -print > $backup_base/$date.$indir_base.dirs.list \n" | tee -a $err
                        find $outdir -type d -print > $backup_base/$date.$indir_base.dirs.list

                        set_start_time
                        echo
                        echo " list-files-formatted-for-diff.sh $backup_base/$date.$indir_base.files.list  $outdir " | tee -a $err
                        echo `date` "        Das kann ein bisschen dauern ... " | tee -a $err
                        list-files-formatted-for-diff.sh $backup_base/$date.$indir_base.files.list  $outdir |& tee -a $err
                        echo Listen fertig `date` | tee -a $err

                        print_time_used Listen | tee -a  $err
                fi
        fi

done
echo "$fg[green] \n\n STATUS ############## $fg[green] FINISHED loop on $fg[cyan]  $backupdirs_indices $fg[yellow] ############## \n\n $fg[$standard_fg_color] " | tee -a $err



