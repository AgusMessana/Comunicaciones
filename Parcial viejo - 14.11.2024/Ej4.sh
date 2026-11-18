Datos:
srv1 -> DNS (53 UDP/TCP)
srv2 -> DNS y WEB (80, 443 TCP)

***DMZ hacia Internet -> permitido
DMZ hacia LAN -> db puerto 3306 TCP. Lo demás prohibido.
***LAN hacia srv1 -> 53 UDP/TCP
***LAN hacia srv2 -> 53 UDP/TCP, 80 TCP, 443 TCP
***LAN hacia DMZ -> prohibido salvo lo alcarado de srv1 y srv2.
***LAN hacia Interent -> 80 TCP, 443 TCP. Lo demás prohibido. Hacer SNAT.
***db hacia DMZ -> prohibido.
***db hacia Internet -> prhibido

------------------------------------------------------------------------

Resolución:
Interfaces:
eth0: LAN
eth1: DMZ
eth2: Internet

Variables:
#!/bin/sh
I=/sbin/iptables
LAN=192.168.0.0/24
db=192.168.0.254
DMZ=168.96.18.0/29
srv1=168.96.18.2
srv2=168.96.18.3
FW=45.231.2.17

Políticas:
$I -P FORWARD DROP

Reglas de estado:
$I -A FORWARD -m state --state INVALID -j DROP
$I -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

Reglas de filter:
LAN
$I -A FORWARD -i eth0 -s $db -j REJECT
$I -A FORWARD -i eth0 -o eth1 -d $srv1 -p tcp --dport 53 -j ACCEPT
$I -A FORWARD -i eth0 -o eth1 -d $srv1 -p udp --dport 53 -j ACCEPT
$I -A FORWARD -i eth0 -o eth1 -d $srv2 -p tcp -m multiport --dports 53,80,443 -j ACCEPT
$I -A FORWARD -i eth0 -o eth1 -d $srv2 -p udp --dport 53 -j ACCEPT
$I -A FORWARD -i eth0 -o eth2 -p tcp -m multiport --dports 80,443 -j ACCEPT

DMZ
$I -A FORWARD -i eth1 -o eth0 -d $db -p tcp --dport 3306 -j ACCEPT
$I -A FORWARD -i eth1 -o eth2 -j ACCEPT


Reglas NAT
$I -t nat -A POSTROUTING -s $LAN -o eth2 -j SNAT --to $FW