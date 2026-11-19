La editorial Kalpa tiene la red de la figura. En la DMZ hay tres servidores: web ofrece HTTP y HTTPS (80 y 443 tcp), correo ofrece SMTP de transferencia (25 tcp), SMTP de envío (587 y 465 tcp), IMAPS (993 tcp) y POP3S (995 tcp), y dns ofrece DNS (53 tcp y udp). En la LAN hay un servidor de archivos files que escucha en el puerto 445 tcp.

DMZ 200.45.70.0/28              Internet
  web    = .2                      ↑
  correo = .3                      │
  dns    = .4                      │
      │                      eth2 = 190.17.3.88
   eth1 (.1) ──── [FIREWALL] ──────┘
      │
   eth0 (.1)
      │
LAN 172.20.0.0/16
  files = 172.20.0.50

Requerimientos:
* Las PC de la LAN pueden usar los servicios de correo y de DNS de la DMZ, y la web del servidor correspondiente. Nada más de esa red.
* Las PC de la LAN pueden navegar a Internet (80 y 443 tcp) y usar cualquier otro servicio externo, excepto DNS, que deben consultar en la DMZ.
* Los servidores de la DMZ no pueden acceder a la LAN, salvo el servidor de correo, que necesita llegar al servidor de archivos en su puerto 445 tcp.
* Los servidores de la DMZ pueden salir a Internet sin restricciones.
* Desde Internet solo se puede acceder a la web (80 y 443), al DNS (53 tcp y udp) y al SMTP de transferencia del servidor de correo (solo 25 tcp).
* El servidor de archivos no puede salir de la LAN.
* Implementar NAT solo donde sea indispensable.

Se pide: las reglas de filtrado y de NAT.

--------------------------------------------------------------------------------

Datos:
web -> 80 TCP, 443 TCP
correo -> 25 TCP, 587 TCP, 465 TCP, 993 TCP, 995 TCP
dns -> 53 UDP, 53 TCP
files -> 445 TCP

LAN hacia correo -> 25, 587, 465, 993, 995 TCP
LAN hacia dns -> 53 UDP, 53 TCP
LAN hacia web -> 80, 443 TCP
LAN hacia DMZ -> prohibido salvo lo especificado para correo, dns y web
LAN hacia Internet -> Prohibido 53 TCP/UDP. Todo lo demás permitido. SNAT
files hacia DMZ -> prohibido
files hacia Internet -> prohibido
correo hacia files -> 445 TCP. Lo demás prohibido.
DMZ hacia LAN -> prohibido salvo lo especificado para files.
DMZ hacia Internet -> permitido.
Internet hacia web -> 80, 443 TCP
Internet hacia dns -> 53 UDP/TCP
Internet hacia correo -> 25 TCP. Lo demás prohibido
Internet hacia LAN -> prohibido
Internet hacia DMZ -> prohibido salvo lo especificado para web, dns y correo

--------------------------------------------------------------------------------

Resolución:
Interfaces:
eth0 -> LAN
eth1 -> DMZ
eth2 -> Internet

Variables
#!/bin/sh
I=/sbin/iptables
LAN=172.20.0.0/16
files=172.20.0.50
DMZ=200.45.70.0/28
web=200.45.70.2
correo=200.45.70.3
dns=200.45.70.4
FW=190.17.3.88

Políticas:
$I -P FORWARD DROP

Reglas de estado:
$I -A FORWARD -m state --state INVALID -j DROP
$I -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

Reglas de filter:
LAN
$I -A FORWARD -i eth0 -s $files -j REJECT
$I -A FORWARD -i eth0 -o eth1 -d $correo -p tcp -m multiport --dports 25,587,465,993,995 -j ACCEPT
$I -A FORWARD -i eth0 -o eth1 -d $dns -p tcp --dport 53 -j ACCEPT
$I -A FORWARD -i eth0 -o eth1 -d $dns -p udp --dport 53 -j ACCEPT
$I -A FORWARD -i eth0 -o eth1 -d $web -p tcp -m multiport --dports 80,443 -j ACCEPT
$I -A FORWARD -i eth0 -o eth2 -p tcp --dport 53 -j REJECT
$I -A FORWARD -i eth0 -o eth2 -p udp --dport 53 -j REJECT
$I -A FORWARD -i eth0 -o eth2 -j ACCEPT

DMZ
$I -A FORWARD -i eth1 -s $correo -o eth0 -d $files -p tcp --dport 445 -j ACCEPT
$I -A FORWARD -i eth1 -o eth2 -j ACCEPT

Internet
$I -A FORWARD -i eth2 -o eth1 -d $web -p tcp -m multiport --dports 80,443 -j ACCEPT
$I -A FORWARD -i eth2 -o eth1 -d $dns -p tcp --dport 53 -j ACCEPT
$I -A FORWARD -i eth2 -o eth1 -d $dns -p udp --dport 53 -j ACCEPT
$I -A FORWARD -i eth2 -o eth1 -d $correo -p tcp --dport 25 -j ACCEPT


Reglas nat
$I -t nat -A POSTROUTING -s $LAN -o eth2 -j SNAT --to $FW