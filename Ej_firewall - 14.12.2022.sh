Ejercicio firewall 14/12/2022

# ---- Datos ----#
Internet (168.96.249.11) hacia host1 -> tcp 8006, tcp 22. Lo demás prohibido. DNAT
Internet hacia vm1 -> tcp 80, tcp 443, tcp 53, udp 53. Lo demás prohibido. DNAT
Internet (168.96.249.11) hacia vm1 -> tcp 22. DNAT
Internet hacia vm2 -> tcp 80, tcp 443, tcp 81, tcp 53, udp 53. Lo demás prohibido. DNAT
Internet (168.96.249.11) hacia vm2 -> tcp 22. DNAT
host1 hacia Internet -> tcp 80, tcp 443. Lo demás prohibido. SNAT
vm1 hacia Internet -> tcp 80, tcp 443, tcp 53, udp 53. Lo demás prohibido. SNAT
vm2 hacia Internet -> tcp 80, tcp 443, tcp 53, udp 53. Lo demás prohibido. SNAT
Internet (168.96.249.11) hacia firewall -> tcp 443. Lo demás prohibido. Sin NAT
firewall hacia Internet -> permitido, sin restricciones


#!/bin/sh
# ---- Variables ---- #
I=/sbin/iptables
host1=10.233.0.2
vm1=10.233.0.66
vm2=10.233.0.67
admin=168.96.249.11
FW_EXT=168.96.210.22
INTERNA=10.233.0.0/24

# ---- Políticas de estado ---- #
$I -P FORWARD DROP
$I -P INPUT DROP
$I -P OUTPUT ACCEPT


# ---- Reglas de estado ---- #
$I -A FORWARD -m state --state INVALID -j DROP
$I -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
$I -A INPUT -m state --state INVALID -j DROP
$I -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT


# ---- Reglas de filter ----#
# ---- host1 ---- #
$I -A FORWARD -s $host1 -p tcp -m multiport --dports 80,443 -j ACCEPT

# ---- Internet ---- #
$I -A FORWARD -d $vm1 -p tcp -m multiport --dports 80,443,53 -j ACCEPT
$I -A FORWARD -d $vm1 -p udp --dport 53 -j ACCEPT
$I -A FORWARD -d $vm2 -p tcp -m multiport --dports 80,81,443,53 -j ACCEPT
$I -A FORWARD -d $vm2 -p udp --dport 53 -j ACCEPT
$I -A FORWARD -s $admin -d $host1 -p tcp -m multiport --dports 8006,22 -j ACCEPT
$I -A FORWARD -s $admin -d $vm1 -p tcp --dport 22 -j ACCEPT
$I -A FORWARD -s $admin -d $vm2 -p tcp --dport 22 -j ACCEPT
$I -A INPUT -s $admin -d $FW_EXT -p tcp --dport 443 -j ACCEPT

# ---- vm1 ---- #
$I -A FORWARD -s $vm1 -p tcp -m multiport --dports 80,443,53 -j ACCEPT
$I -A FORWARD -s $vm1 -p udp --dport 53 -j ACCEPT

# ---- vm2 ---- #
$I -A FORWARD -s $vm2 -p tcp -m multiport --dports 80,443,53 -j ACCEPT
$I -A FORWARD -s $vm2 -p udp --dport 53 -j ACCEPT


# ---- NAT ---- #
$I -t nat -A POSTROUTING -s $INTERNA -j SNAT --to $FW_EXT
$I -t nat -A PREROUTING -s $admin -d $FW_EXT -p tcp --dport 22 -j DNAT --to $vm1
$I -t nat -A PREROUTING -s $admin -d $FW_EXT -p tcp --dport 8006 -j DNAT --to $host1
$I -t nat -A PREROUTING -d $FW_EXT -p tcp -m multiport --dports 80,443,53 -j DNAT --to $vm1
$I -t nat -A PREROUTING -d $FW_EXT -p udp --dport 53 -j DNAT --to $vm1


# ---- ACLARACIÓN ----#
El firewall dispone de una única IP pública (168.96.210.22), por lo que no es posible publicar simultáneamente los mismos puertos de vm1 y vm2 (80, 443 y 53 tcp, 53 udp) ni el puerto 22 de las tres máquinas, ya que cada puerto de la IP pública solo puede redirigirse a un destino.

Se resolvió publicar los servicios de vm1 y el acceso administrativo al host (8006). Las reglas de filtrado de vm2 quedan igualmente escritas, de modo que el filtrado esté completo: solo resta el DNAT correspondiente, que requeriría una dirección pública adicional o una traducción a puertos alternativos (por ejemplo, 8081 externo hacia el 80 de vm2).

Se observa además que el enunciado indica que las VM tienen direcciones públicas, pero las direcciones asignadas (10.233.0.66 y 10.233.0.67) pertenecen al rango privado, razón por la cual se requiere DNAT. La red 45.10.234.64/29 de la interfaz interna no se utiliza, ya que ningún requerimiento la involucra.