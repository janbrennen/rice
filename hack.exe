#!/bin/bash

# Rm9yayAhQm9tYnpaeUNBawo=

cat <<'END'

          .                                                      .
        .n                   .                 .                  n.
  .   .dP                  dP                   9b                 9b.    .
 4    qXb         .       dX                     Xb       .        dXp     t
dX.    9Xb      .dXb    __                         __    dXb.     dXP     .Xb
9XXb._       _.dXXXXb dXXXXbo.                 .odXXXXb dXXXXb._       _.dXXP
 9XXXXXXXXXXXXXXXXXXXVXXXXXXXXOo.           .oOXXXXXXXXVXXXXXXXXXXXXXXXXXXXP
  `9XXXXXXXXXXXXXXXXXXXXX'~   ~`OOO8b   d8OOO'~   ~`XXXXXXXXXXXXXXXXXXXXXP'
    `9XXXXXXXXXXXP' `9XX'   DIE    `98v8P'  HUMAN   `XXP' `9XXXXXXXXXXXP'
        ~~~~~~~       9X.          .db|db.          .XP       ~~~~~~~
                        )b.  .dbo.dP'`v'`9b.odb.  .dX(
                      ,dXXXXXXXXXXXb     dXXXXXXXXXXXb.
                     dXXXXXXXXXXXP'   .   `9XXXXXXXXXXXb
                    dXXXXXXXXXXXXb   d|b   dXXXXXXXXXXXXb
                    9XXb'   `XXXXXb.dX|Xb.dXXXXX'   `dXXP
                     `'      9XXXXXX(   )XXXXXXP      `'
                              XXXX X.`v'.X XXXX
                              XP^X'`b   d'`X^XX
                              X. 9  `   '  P )X
                              `b  `       '  d'
                               `             '
END

if [ -z $1 ]
then
	echo -e "Please use the script along with a valid website as an argument.\nexample: ./$0 www.google.com\nDo not use http:// or trailing /, DOMAIN ONLY."
exit 1
fi

dot () { 
	for ((i = 0; i < $1; i++)); do echo -n "."; sleep 0.04; done; echo -e '[\033[00;32mCOMPLETE\033[00;0m]';sleep 0.6
}
echo -n "Enumerating Target"
dot 40
echo -e " [+] Host: $1\n [+] IPv4: $(host $1 | head -n1 | egrep -o [0-9.]+$ )"
echo -n "Opening SOCK5 ports on infected hosts"
dot 21
echo " [+] SSL entry point on 127.0.0.1:1337"
echo -n "Chaining proxies"
dot 42
echo ' [+] 7/7 proxies chained {BEL>AUS>JAP>CHI>NOR>FIN>UKR}'
echo -n "Launching port knocking sequence"
dot 26
echo " [+] Knock on TCP<143,993,587,456,25,587,993,80>"
echo -n "Sending PCAP datagrams for fragmentation overlap"
dot 10
echo " [+] Stack override ***** w00t w00t g0t r00t!"
echo -en '\n['
for i in $(seq 1 65); do echo -n "="; sleep 0.01; done
echo -e '>]\n'
sleep 0.5
echo -n "root@$1:~# "
sleep 5
echo ""
exit 0
