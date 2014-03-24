# Whatsapp Discover

Una herramienta para obtener el número asociado a los dispositivos móviles que
estén usando Whatapp en la misma red. Se puede especificar la interfaz actual
para interceptar los paquetes en tiempo real o especificarlos ya creados. Dichos
paquetes se procesan en forma de lotes. 

---

### Nota de 0aps

Inicialmente la herramienta se lanzó como una prueba de concepto la cual no tiene
como objetivo ser usada con fines malintencionados, así lo especificó el autor en:
https://github.com/deepakdaswani/whatsapp_discover

Me tomé la molestia de agregar la opción de sniffear en tiempo real así como de traducir
los comentarios y parte del código al español. Finalmente, anexo una pequeña aclaratoria de cómo usar la herramienta y en qué contexto.

¿Cómo crear los paquetes? 
Con alguna herramienta de red que tenga la opción. Tcpdump/Wireshark, por ejemplo.
Leer:
http://www.hackplayers.com/2013/12/que-deberiamos-saber-sobre-tcpdump-1.html
http://www.hackplayers.com/2013/12/que-deberiamos-saber-sobre-tcpdump-2.html
http://www.hackplayers.com/2014/01/que-deberiamos-saber-sobre-tcpdump-3.html
http://blog.iurlek.com/2011/10/tcpdump-avanzado-el-arte-de-capturar-y-analizar-el-trafico-de-la-red/

Cuando intercepto en tiempo real no recibo nada ...

Hay que colocar el sniffer en algún sitio por el que pase todo el tráfico de la red. Esto es posible lograrlo con algunas capacidades de los switches como el Port Mirroring (puertos espejo) o cualquier electrónica de red por la que pase todo el tráfico (Firewalls, TAP, Apliances). Desde luego, en caso de una red nuestra.

En caso contrario, es posible por medio de envenenamiento ARP.
Leer:
es.wikipedia.org/wiki/Puerto_espejo‎
http://es.wikipedia.org/wiki/ARP_Spoofing

¿Por qué esto es así?
Porque en las redes ethernet conmutadas (basada en switches y no en hubs) al
igual que los routers inalámbricos se tiene la red segmentadad por puertos.

Documentación para enteder/instalar las dependencias
http://www.perlmonks.org/?node_id=170648
http://search.cpan.org/~saper/Net-Pcap-0.17/Pcap.pm
http://search.cpan.org/dist/Net-IP/IP.pm
http://search.cpan.org/~spidb/Net-ext-1.011/lib/Net/TCP.pm

Espero les sea útil, y gracia a @dipudaswani por el código.

### Author

Deepak Daswani 

[@dipudaswani](http://twitter.com/dipudaswani)

[http://deepakdaswani.es](http://deepakdaswani.es)

### Uso

	$ ./whatsapp_discover.pl -i interface | -f pcapfile[s]

### Ejemplo

In the example below, the numbers have been darkened with X characters for privacy reasons

	deepak@kali:~/code/whatsapp_discover$ ./whatsapp_discover.pl -f /home/deepak/pcapfiles/*.cap
	
	Whatsapp Discover v1.0  --- Deepak Daswani (@dipudaswani) 2014
	                            http://deepakdaswani.es 
	
	Parsing /home/deepak/pcapfiles/freewifi-01.cap ...
	Got 1 number! S.O: iPhone-2.11.4-5222 Mobile number: +1202XXXXXXX
	Parsing /home/deepak/pcapfiles/freewifi-02.cap ...
	Got 1 number! S.O: Android-2.11.152 Mobile number: +34616XXXXXX
	Got 1 number! S.O: Android-2.11.136 Mobile number: +34663XXXXXX
	Parsing /home/deepak/pcapfiles/freewifi-03.cap ...
	Got 1 number! S.O: BB-2.8.7345-443 Mobile number: +34695XXXXXX
	Parsing /home/deepak/pcapfiles/freewifi-04.cap ...
	Got 1 number! S.O: Symbian-2.11.173-443 Mobile number: +34660XXXXXX
	
	4 files parsed. 5 phone numbers using Whatsapp found...

