El estudio contable Arrieta tiene la red de la figura.

DMZ 190.63.40.0/29                      Internet
  web = .2  (80, 443 tcp)                  ↑
  dns = .3  (53 tcp y udp)                 │
       │                            eth2 = 201.44.7.9
    eth1 (.1) ──── [FIREWALL] ─────────────┘
       │
    eth0 (.1)
       │
  LAN 10.40.0.0/16
    contab = 10.40.0.80  (servidor contable, 1521 tcp)

El firewall tiene además un servidor SSH (22 tcp) para su administración y una interfaz web de gestión en el puerto 10000 tcp.

Requerimientos:
* Las PC de la LAN pueden acceder al servicio web y al DNS de los servidores de la DMZ, y a nada más de esa red.
* Las PC de la LAN pueden salir a Internet sin restricciones, salvo DNS, que resuelven en la DMZ.
* Los servidores de la DMZ pueden salir a Internet sin restricciones, pero no pueden acceder a la LAN bajo ningún concepto.
* Desde Internet solo se puede acceder al servicio web (80 y 443 tcp) y al DNS (53 tcp y udp) de los servidores correspondientes.
* El servidor contable debe poder ser consultado desde Internet en su puerto 1521 tcp, únicamente desde la IP 200.5.5.5 (estudio asociado). El servidor contable no puede iniciar conexiones hacia ninguna otra red.
* El firewall solo puede ser administrado por SSH y por su interfaz web desde la máquina 10.40.0.5 de la LAN. Ningún otro acceso al firewall está permitido.
* El firewall necesita salir a Internet a los puertos 80 y 443 tcp para actualizar sus paquetes, y consultar DNS (53 tcp y udp) a los servidores de la DMZ. Nada más.
* Implementar NAT solo donde sea indispensable.

Se pide: las reglas de filtrado (FORWARD, INPUT y OUTPUT) y las de NAT.

lase	Rango
A	10.0.0.0/8 → 10.0.0.0 a 10.255.255.255
B	172.16.0.0 a 172.31.255.255
C	192.168.0.0 a 192.168.255.255

--------------------------------------------------------------------------------

Resolución
Datos:
LAN hacia web -> 80 TCP, 443 TCP.
LAN hacia dns -> 53 UDP, 53 TCP.
LAN hacia Internet -> prohibido 53 UDP, 53 TCP. Lo demás permitido. SNAT.
DMZ hacia Internet -> permitido.
DMZ hacia LAN -> prohibido.
Internet hacia web -> 80 TCP, 443 TCP.
Internet hacia dns -> 53 UDP, 53 TCP.
Internet hacia DMZ -> prohibido salvo lo especificado para web y dns.
Internet (200.5.5.5) hacia contab -> 1521 TCP. DNAT
Internet hacia LAN -> prohibido.
contab hacia DMZ -> prohibido.
contab hacia Internet -> prohibido.
LAN (10.40.0.5) hacia Firewall -> 22 TCP, 10000 TCP. Lo demás prohibido.
Firewall hacia Internet -> 80 TCP, 443 TCP. Lo demás prohibido.
Firewall hacia dns -> 53 UDP, 53 TCP.
Firewall hacia DMZ -> prohibido salvo lo especificado para dns.
Firewall hacia LAN -> prohibido.

Interfaces
eth0 -> LAN
eth1 -> DMZ
eth2 -> Internet

Variables
#!/bin/sh
I=/sbin/iptables
LAN=10.40.0.0/16
contab=10.40.0.80
DMZ=190.63.40.0/29
web=190.63.40.2
dns=190.63.40.3
est_asoc=200.5.5.5
FW_LAN=10.40.0.1
FW_EXT=201.44.7.9
adminFW=10.40.0.5


Politicas
$I -P FORWARD DROP
$I -P INPUT DROP
$I -P OUTPUT DROP

Reglas de estado
$I -A FORWARD -m state --state INVALID -j DROP
$I -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
$I -A INPUT -m state --state INVALID -j DROP
$I -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$I -A OUTPUT -m state --state INVALID -j DROP
$I -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

Reglas filter
LAN
$I -A FORWARD -s $contab -j REJECT
$I -A FORWARD -i eth0 -o eth1 -d $web -p tcp -m multiport --dports 80,443 -j ACCEPT
$I -A FORWARD -i eth0 -o eth1 -d $dns -p udp --dport 53 -j ACCEPT
$I -A FORWARD -i eth0 -o eth1 -d $dns -p tcp --dport 53 -j ACCEPT
$I -A FORWARD -i eth0 -o eth2 -p udp --dport 53 -j REJECT
$I -A FORWARD -i eth0 -o eth2 -p tcp --dport 53 -j REJECT
$I -A FORWARD -i eth0 -o eth2 -j ACCEPT
$I -A INPUT -i eth0 -s $adminFW -d $FW_LAN -p tcp -m multiport --dports 22,10000 -j ACCEPT

DMZ
$I -A FORWARD -i eth1 -o eth2 -j ACCEPT

Internet
$I -A FORWARD -i eth2 -o eth1 -d $web -p tcp -m multiport --dports 80,443 -j ACCEPT
$I -A FORWARD -i eth2 -o eth1 -d $dns -p udp --dport 53 -j ACCEPT
$I -A FORWARD -i eth2 -o eth1 -d $dns -p tcp --dport 53 -j ACCEPT
$I -A FORWARD -i eth2 -s $est_asoc -o eth0 -d $contab -p tcp --dport 1521 -j ACCEPT

Firewall
$I -A OUTPUT -o eth2 -p tcp -m multiport --dports 80,443 -j ACCEPT
$I -A OUTPUT -o eth1 -d $dns -p udp --dport 53 -j ACCEPT
$I -A OUTPUT -o eth1 -d $dns -p tcp --dport 53 -j ACCEPT


Reglas nat
$I -t nat -A POSTROUTING -s $LAN -o eth2 -j SNAT --to $FW_EXT
$I -t nat -A PREROUTING -i eth2 -s $est_asoc -d $FW_EXT -p tcp --dport 1521 -j DNAT --to $contab