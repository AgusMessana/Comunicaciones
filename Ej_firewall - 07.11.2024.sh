Ejercicio firewall 07/11/2024

# ---- Datos ---- #
LAN hacia srv1 (WEB) -> 53 tcp/udp, 80, 443
LAN hacia srv2 (MAIL) -> 53 tcp/udp, 25, 587, 465, 995, 993
LAN hacia proxy -> 3128
LAN hacia Internet -> prohibido 53 tcp/udp, 80, 443. Los demás permitidos, con NAT (SNAT)
DMZ hacia LAN -> prohibido
DMZ hacia Internet -> total
Internet hacia LAN -> prohibido
Internet hacia srv1 -> 53 tcp/udp, 80, 443
Internet hacia srv2 -> 53 tcp/udp, 25


# ---- Interfaces ---- #
eth0 -> LAN
eth1 -> DMZ
eth2 -> Internet


#!/bin/sh
# ---- Variables ---- #
I=/sbin/iptables
srv1=168.96.18.2
srv2=168.96.18.3
proxy=168.96.18.4
LAN=192.168.0.0/24
FW=45.231.2.17


# ---- Política de estado ---- #
$I -P FORWARD DROP


# ---- Reglas de estado ---- #
$I -A FORWARD -m state --state INVALID -j DROP
$I -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT


# ---- Reglas de filter ---- #
# ---- LAN ---- #
$I -A FORWARD -i eth0 -o eth1 -d $srv1 -p tcp -m multiport --dports 53,80,443 -j ACCEPT
$I -A FORWARD -i eth0 -o eth1 -d $srv1 -p udp --dport 53 -j ACCEPT
$I -A FORWARD -i eth0 -o eth1 -d $srv2 -p tcp -m multiport --dports 53,25,587,465,993,995 -j ACCEPT
$I -A FORWARD -i eth0 -o eth1 -d $srv2 -p udp --dport 53 -j ACCEPT
$I -A FORWARD -i eth0 -o eth1 -d $proxy -p tcp --dport 3128 -j ACCEPT
$I -A FORWARD -i eth0 -o eth1 -j REJECT
$I -A FORWARD -i eth0 -o eth2 -p tcp -m multiport --dports 53,80,443 -j REJECT
$I -A FORWARD -i eth0 -o eth2 -p udp --dport 53 -j REJECT
$I -A FORWARD -i eth0 -j ACCEPT

# ---- DMZ ---- #
$I -A FORWARD -i eth1 -o eth0 -j REJECT
$I -A FORWARD -i eth1 -j ACCEPT

# ---- Internet ---- #
$I -A FORWARD -i eth2 -o eth1 -d $srv1 -p tcp -m multiport --dports 53,80,443 -j ACCEPT
$I -A FORWARD -i eth2 -o eth1 -d $srv1 -p udp --dport 53 -j ACCEPT
$I -A FORWARD -i eth2 -o eth1 -d $srv2 -p tcp -m multiport --dports 53,25 -j ACCEPT
$I -A FORWARD -i eth2 -o eth1 -d $srv2 -p udp --dport 53 -j ACCEPT
$I -A FORWARD -i eth2 -j DROP


# ---- NAT ---- #
$I -t nat -A POSTROUTING -s $LAN -o eth2 -j SNAT --to $FW