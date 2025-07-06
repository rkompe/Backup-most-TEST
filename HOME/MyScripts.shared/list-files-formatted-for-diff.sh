#!/usr/bin/zsh
source $HOME/.zshrc-scripts

if [[ "$1" = "-h" ]]; then
        echo "Aufruf:" `basename $0` " output_list_file dirs"
        exit
fi


output_list=$1 ; shift
dirs=$*

tmp=$HOME/.tmp/list-files-formatted-for-diff.tmp.txt.$$

find $dirs -type f -print  |\
        parallel   ls -l --time-style=+%y%m%d%H%M {} \
        > $tmp


	gawk '{A=$7;B=$6;C=$5; $1=""; $2="";$3="";$4="";$5="";$6=""; printf("%s        %s     %s\n",$0,B,C)}' $tmp | sort > $output_list.times

	gawk '{A=$7;B=$6;C=$5; $1=""; $2="";$3="";$4="";$5="";$6=""; printf("%s        %s\n",$0,C)}' $tmp | sort > $output_list

rm $tmp
wc -l $output_list $output_list.times
