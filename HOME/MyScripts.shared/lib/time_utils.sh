

START_time=0
END_TIME=0

set_start_time()
{
    START_time=`date +%s`
}

print_time_used()
{
    local msg1=$1 ; shift
    local msg2
    local start_t=$START_time

    test $# -gt 0 && { msg2="$1"; shift }
    test $# -gt 0 && { start_t="$1" }

    #echo msg1=$msg1
    #echo msg2=$msg2
    #echo "start time = $start_t"

    END_TIME=`date +%s`
    time_diff $start_t $END_TIME
    echo `date` "$msg1 FINISHED in $stunden_time_diff h $minuten_time_diff m $sekunden_time_diff s $msg2"
}

time_diff()
{
    local t1=$1
    local t2=$2

    # Differenz in Sekunden berechnen
    local diff=$(( t2 - t1 ))

    # Tage, Stunden und Minuten berechnen
    tage_time_diff=$(( diff / 86400 ))
    stunden_time_diff=$(( (diff % 86400) / 3600 ))
    minuten_time_diff=$(( (diff % 3600) / 60 ))
    sekunden_time_diff=$(( diff % 60 ))

}

min_two_digits()
{
    if test $1 -lt 0 || test $1 -gt 9 ; then
        echo $1
    else
        echo 0$1
    fi
}

print_hours_min()
{
    local h
    local m
    h=`min_two_digits $1`
    m=`min_two_digits $2`
    echo "${h}:$m"
}

# returns the absolute time as return value which can be re-used as an argument
# returns date in readable format as echo
datum_vom_tag_vorher()
{
    typeset -i dat

    if [[ "$1" != "" ]]; then
        dat=$1
    else
        dat=$(date +%s)
    fi
    dat=$(($dat - (24 * 3600)))
    ##gestern=$(date -d "@$dat" +%y/%m/%d)
    echo $dat 
}
