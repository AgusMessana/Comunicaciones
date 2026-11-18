Datos:
Las direcciones IPv6 de terminales de red interna no se deben ver desde el exterior.
La resolución directa debe verse desde interior y exterior de formas distintas.
La vista exterior no cuenta con resolución inversa.

Red interna: FDe4:8dba:82e1::/64
Red externa: 2001:db8:54fe::/64

En red interna:
primary.com.ar / Fde4:8fe6:82e1::6 -> slave
www.matbarofex.com.ar / FDe4:8dba:82e1::3 -> servicio web
info.matbarofex.com.ar / FDe4:8dba:82e1::20 -> servidor de correo
dns.matbarofex.com.ar / FDe4:8dba:82e1::3 -> dns maestro
dns2.primary.com.ar / FDe4:8fe6:82e1::6 -> dns esclavo

-------------------------------------------------------------------------

Resolución:
Ejercicio 1:
acl red_interna { FDe4:8dba:82e1::/64; };
acl red_externa { 2001:db8:54fe::/64; };

named.conf en dns.matbarofex.com.ar
view "interna" {
  match-clients { red_interna; };
  zone "matbarofex.com.ar" {
    type master;
    file "/etc/bind/db.matbarofex.interna";
  };
  zone "0.0.0.0.1.e.2.8.a.b.d.8.4.e.D.F.ip6.arpa" {
    type master;
    file "/etc/bind/rev.matbarofex.interna";
  };
  zone "primary.com.ar" {
    type slave;
    masters { Fde4:8fe6:82e1::6; };
    file "/var/cache/bind/db.primary.interna";
  };
};

view "externa" {
  match-clients { red_externa; };
  zone "matbarofex.com.ar" {
    type master;
    file "/etc/bind/db.matbarofex.externa";
  };
};

Ejercicio 2
$TTL 1D
$ORIGIN matbarofex.com.ar.
@ IN SOA dns.matbarofex.com.ar. hostmaster.matbarofex.com.ar. (2026111801; 5h; 15m; 3w12h; 2h20m)
  IN NS dns.matbarofex.com.ar.
  IN NS dns2.primary.com.ar.
  IN MX 10 info.matbarofex.com.ar.
dns IN AAAA FDe4:8dba:82e1::3
www IN AAAA FDe4:8dba:82e1::3
info IN AAAA FDe4:8dba:82e1::20