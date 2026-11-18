Datos:
Dominio principal: rolex.com
dns.rolex.com -> servidor maestro
www.rolex.com / 173.223.153.242 -> web
email.rolex.com / 64.233.180.108 -> servidor de mail

Subdominios:
watches.rolex.com
  Terminales específicas:
    clasicos / 173.223.153.241
    profesionales / 173.223.153.240
perpetual-initiatives.rolex.com -> delegado
  Terminales específicas:
    science / 173.223.153.141
    sport / 173.223.153.140

Res. directa dom. principal
master: dns.rolex.com / 173.223.153.242
slave: ns.rolex.org / 52.101.73.8 (externo)

Res. inversa dom. principal / 72.32.138.0/24
master: dns.perpetual-initiatives.rolex.com

Res. directa perpetual-initiatives.rolex.com
master: dns.perpetual-initiatives.rolex.com / 173.223.153.142
slave: ns.rolex.org / 52.101.73.8 (externo)

------------------------------------------------------------------------

Resolución:
Ejercicio 1
named.conf en dns.rolex.com
zone "rolex.com" {
  type master;
  file "/etc/bind/db.rolex";
};

named.conf en dns.perpetual-inititatives.rolex.com
zone "perpetual-initiatives.rolex.com" {
  type master;
  file "/etc/bind/db.perpetual";
};
zone "153.223.173.in-addr.arpa" {
  type master;
  file "/etc/bind/rev.rolex";
};

Ejercicio 2
$TTL 1D
$ORIGIN rolex.com.
@ IN SOA dns.rolex.com. hostmaster.rolex.com. (2026111801; 5h; 15m; 3w12h; 2h20m)
  IN NS dns.rolex.com.
  IN NS ns.rolex.org.
  IN MX 10 email.rolex.com.
dns IN A 173.223.153.242
www IN A 173.223.153.242
email IN A 64.233.180.108
clasicos.watches IN A 173.223.153.241
profesionales.watches IN A 173.223.153.240
perpetual-initiatives IN NS dns.perpetual-initiatives.rolex.com.
dns.perpetual-initiatives IN A 173.223.153.142