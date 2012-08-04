#!/bin/bash
# This script is currently in the Public Domain

# On ^C, bash may give an malloc/free error
# I don't think this is an error that can be fixed easily
# in this script, but if you managed to do so, help
# would be nice. 

trap 'tput cnorm;clear;exit' INT HUP QUIT ABRT TERM CHLD ALRM

declare -i f=75 s=12 r=3000 t=0 c=1 n=0 l=0
declare -ir w=$(tput cols) h=$(tput lines)
declare -i x=$((w/2)) y=$((h/2))
declare -ar v=( [00]="\x83" [01]="\x8f" [03]="\x93"
        [10]="\x9b" [11]="\x81" [12]="\x93"
        [21]="\x97" [22]="\x83" [23]="\x9b"
        [30]="\x97" [32]="\x8f" [33]="\x81" )

OPTIND=1
while getopts "f:s:r:h" arg; do
case $arg in
    f) ((f=($OPTARG>19 && $OPTARG<101)?$OPTARG:$f));;
    s) ((s=($OPTARG>4 && $OPTARG<16 )?$OPTARG:$s));;
    r) ((r=($OPTARG>0)?$OPTARG:$r));;
    h) echo -e "Usage: pipes [OPTION]..."
        echo -e "Creates an animation similar to the old \"pipes\" screensaver.\n"
        echo -e " -f [20-100]\tframerate (Default 75)."
        echo -e " -s [5-15]\tprobability of a straight fitting (Default 12)."
        echo -e " -r LIMIT\treset after x characters (Default 3000)."
        echo -e " -h\t\thelp (This screen).\n"
        exit 0;;
    esac
done

tput smcup
tput reset
tput civis
while ! read -t0.0$((1000/$f)) -n1; do
    # New position:
    (($l%2)) && ((x+=($l==1)?1:-1))
    ((!($l%2))) && ((y+=($l==2)?1:-1))

    # Loop on edges (change color on loop):
    ((c=($x>$w || $x<0 || $y>$h || $y<0)?(($RANDOM%8)+($RANDOM%16)/32):$c))
    ((x=($x>$w)?0:(($x<0)?$w:$x)))
    ((y=($y>$h)?0:(($y<0)?$h:$y)))

    # New random direction:
    ((n=$RANDOM%$s-1))
    ((n=($n>1||$n==0)?$l:$l+$n))
    ((n=($n<0)?3:$n%4))

    # Print:
    tput cup $y $x
    echo -ne "\033[1;3${c}m\xe2\x94${v[$l$n]}"
    (($t>$r)) && tput reset && tput civis && t=0 || ((t++))
    l=$n
done
tput rmcup
