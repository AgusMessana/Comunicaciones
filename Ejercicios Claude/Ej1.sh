La cadena de gimnasios Olympo desea configurar su DNS. No poner en los named.conf las zonas por defecto.

Dominio principal: olympo.com.ar, con página web www.olympo.com.ar (190.45.12.10) y servidor de correo mail.olympo.com.ar (190.45.12.11).
Subdominios: socios.olympo.com.ar y sedes.olympo.com.ar.
La resolución directa de olympo.com.ar tiene como maestro a ns1.olympo.com.ar (190.45.12.5) y dos esclavos: ns2.sedes.olympo.com.ar (190.45.12.6) y ns.datacenter.net.ar (200.80.14.90), este último externo.
El subdominio socios será delegado. Su maestro es ns.socios.olympo.com.ar (190.45.12.40) y su esclavo es ns1.olympo.com.ar. Dentro de este subdominio hay dos terminales: altas (190.45.12.41) y bajas (190.45.12.42).
El subdominio sedes tiene correo propio en mail.sedes.olympo.com.ar (190.45.12.20) y dos terminales: centro (190.45.12.21) y norte (190.45.12.22).
La resolución inversa de la red 190.45.12.0/24 tiene como maestro a ns1.olympo.com.ar y como esclavo a ns.datacenter.net.ar.

Se pide:
Realizar el named.conf de ns1.olympo.com.ar y de ns.socios.olympo.com.ar.
Realizar la resolución directa de ns1.olympo.com.ar.
Realizar la resolución inversa de ns1.olympo.com.ar.

--------------------------------------------------------------------------------

Datos:
Dominio principal: olympo.com.ar
  www.olympo.com.ar / 190.45.12.10 -> web
  mail.olympo.com.ar / 190.45.12.11 -> servidor de mail
Res. directa olympo.com.ar
  ns1.olympo.com.ar / 190.45.12.5 -> master
  ns2.sedes.olympo.com.ar / 190.45.12.6 -> slave
  ns.datacenter.net.ar / 200.80.14.90 -> slave externo
Subdominio 1: socios.olympo.com.ar -> delegado
  ns.socios.olympo.com.ar / 190.45.12.40 -> master
  ns1.olympo.com.ar -> slave
  Terminales:
    altas / 190.45.12.41
    bajas / 190.45.12.42
Subdominio 2: sedes.olympo.com.ar
  mail.sedes.olympo.com.ar / 190.45.12.20 -> servidor de correo
  Terminales:
    centro / 190.45.12.21
    norte / 190.45.12.22
Res. inversa de 190.45.12.0/24
  ns1.olympo.com.ar -> master
  ns.datacenter.net.ar -> slave

--------------------------------------------------------------------------------

Resolución
Ejercicio 1
named.conf en ns1.olympo.com.ar
zone "olympo.com.ar" {
  type master;
  file "/etc/bind/db.olympo";
};
zone "socios.olympo.com.ar" {
  type slave;
  masters { 190.45.12.40; };
  file "/var/cache/bind/db.socios.olympo";
};
zone "12.45.190.in-addr.arpa" {
  type master;
  file "/etc/bind/rev.190.45.12";
};

named.conf en ns.socios.olympo.com.ar
zone "socios.olympo.com.ar" {
  type master;
  file "/etc/bind/db.socios.olympo";
};

Ejercicio 2
$TTL 1D
$ORIGIN olympo.com.ar.
@ IN SOA ns1.olympo.com.ar. hostmaster.olympo.com.ar. (2026111801; 5h; 15m; 3w12h; 2h20m)
  IN NS ns1.olympo.com.ar.
  IN NS ns2.sedes.olympo.com.ar.
  IN NS ns.datacenter.net.ar.
  IN MX 10 mail.olympo.com.ar.
ns1 IN A 190.45.12.5
ns2.sedes IN A 190.45.12.6
www IN A 190.45.12.10
mail IN A 190.45.12.11
sedes IN MX 10 mail.sedes.olympo.com.ar.
mail.sedes IN A 190.45.12.20
centro.sedes IN A 190.45.12.21
norte.sedes IN A 190.45.12.22
socios IN NS ns.socios.olympo.com.ar.
ns.socios IN A 190.45.12.40

Ejercicio 3
$TTL 1D
$ORIGIN 12.45.190.in-addr.arpa.
@ IN SOA ns1.olympo.com.ar. hostmaster.olympo.com.ar. (2026111801; 5h; 15m; 3w12h; 2h20m)
  IN NS ns1.olympo.com.ar.
  IN NS ns.datacenter.net.ar.
5 IN PTR ns1.olympo.com.ar.
6 IN PTR ns2.sedes.olympo.com.ar.
10 IN PTR www.olympo.com.ar.
11 IN PTR mail.olympo.com.ar.
20 IN PTR mail.sedes.olympo.com.ar.
21 IN PTR centro.sedes.olympo.com.ar.
22 IN PTR norte.sedes.olympo.com.ar.
40 IN PTR ns.socios.olympo.com.ar.
41 IN PTR altas.socios.olympo.com.ar.
42 IN PTR bajas.socios.olympo.com.ar.