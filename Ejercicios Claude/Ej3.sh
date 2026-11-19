La consultora Verdana desea usar vistas DNS. Las direcciones de los equipos internos no deben ser visibles desde el exterior, ni en la resolución directa ni en la inversa. La resolución directa de verdana.com.ar debe verse de forma distinta desde adentro y desde afuera. La vista externa no cuenta con resolución inversa. No poner en el named.conf las zonas por defecto.

Redes:

Red interna: 10.8.0.0/24
Red externa: cualquier otra

Servidores y equipos:

dns.verdana.com.ar (10.8.0.10) — maestro del dominio, en ambas vistas
ns2.hosting.net.ar (45.12.80.7) — esclavo externo de la resolución directa
www.verdana.com.ar (10.8.0.20) — servidor web
mail.verdana.com.ar (10.8.0.21) — servidor de correo
intranet.verdana.com.ar (10.8.0.30) — equipo interno
deposito.verdana.com.ar (10.8.0.31) — equipo interno

Además, dentro de la vista interna, dns.verdana.com.ar es esclavo del dominio contable.net.ar, cuyo maestro es 10.8.0.200.

La resolución inversa de 10.8.0.0/24 tiene como maestro a dns.verdana.com.ar.

Desde el exterior solo deben poder resolverse los servicios públicos (web, correo y el propio DNS); los equipos internos no.

Se pide:

El named.conf de dns.verdana.com.ar.
La resolución directa de la vista interna.
La resolución directa de la vista externa.
La resolución inversa.

--------------------------------------------------------------------------------

Datos:
Red interna: 10.8.0.0/24
Red externa: cualquiera

dns.verdana.com.ar / 10.8.0.10 -> master en ambas vistas
ns2.hosting.net.ar / 45.12.80.7 -> slave externo en res.directa
www.verdana.com.ar / 10.8.0.20 -> servidor web
mail.verdana.com.ar / 10.8.0.21 -> servidor de correo
intranet.verdana.com.ar / 10.8.0.30 -> equipo interno
deposito.verdana.com.ar / 10.8.0.31 -> equipo interno

Dominio contable.net.ar
  10.8.0.200 -> master
  En interna: dns.verdana.com.ar -> slave

Res. inversa 10.8.0.0/24
dns.verdana.com.ar -> master

Desde el exterior se resuelven servicios públicos solamente

--------------------------------------------------------------------------------

Resolución:
Ejercicio 1:
acl red_interna { 10.8.0.0/24; };

named.conf en dns.verdana.com.ar
view "interna" {
  match-clients { red_interna; };
  zone "verdana.com.ar" {
    type master;
    file "/etc/bind/db.verdana.interna";
  };
  zone "contable.net.ar" {
    type slave;
    masters { 10.8.0.200; };
    file "/var/cache/bind/db.contable.interna";
  };
  zone "0.8.10.in-addr.arpa" {
    type master;
    file "/etc/bind/rev.10.8.0.interna";
  };
};
view "externa" {
  match-clients { any; };
  zone "verdana.com.ar" {
    type master;
    file "/etc/bind/db.verdana.externa";
  };
};

Ejercicio 2
$TTL 1D
$ORIGIN verdana.com.ar.
@ IN SOA dns.verdana.com.ar. hostmaster.verdana.com.ar. (2026111801; 5h; 15m; 3w12h; 2h20m)
  IN NS dns.verdana.com.ar.
  IN NS ns2.hosting.net.ar.
  IN MX 10 mail.verdana.com.ar.
dns IN A 10.8.0.10
www IN A 10.8.0.20
mail IN A 10.8.0.21
intranet IN A 10.8.0.30
deposito IN A 10.8.0.31

Ejercicio 3
$TTL 1D
$ORIGIN verdana.com.ar.
@ IN SOA dns.verdana.com.ar. hostmaster.verdana.com.ar. (2026111801; 5h; 15m; 3w12h; 2h20m)
  IN NS dns.verdana.com.ar.
  IN NS ns2.hosting.net.ar.
  IN MX 10 mail.verdana.com.ar.
dns IN A 10.8.0.10
www IN A 10.8.0.20
mail IN A 10.8.0.21

Ejercicio 4
$TTL 1D
$ORIGIN 0.8.10.in-addr.arpa.
@ IN SOA dns.verdana.com.ar. hostmaster.verdana.com.ar. (2026111801; 5h; 15m; 3w12h; 2h20m)
  IN NS dns.verdana.com.ar.
10 IN PTR dns.verdana.com.ar.
20 IN PTR www.verdana.com.ar.
21 IN PTR mail.verdana.com.ar.
30 IN PTR intranet.verdana.com.ar.
31 IN PTR deposito.verdana.com.ar.