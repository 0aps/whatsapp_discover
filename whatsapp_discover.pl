#!/usr/bin/perl

# WHATSAPP DISCOVER 1.0
# Author: Deepak Daswani (@dipudaswani)
# Website: http://deepakdaswani.es
# Date: March, 2014

# Sniffing en tiempo real -> github.com/0aps

use Getopt::Long;
use Net::Pcap;
use NetPacket::IP;
use NetPacket::TCP;

my ($pcap,$err,$dev,$help,$interface,@files);
my $count = 0;
my $file_count = 0;
my $hoffset = -1;

# Definición de uso
sub usage {

print "Opcion desconocida: @_\n\n" if ( @_ );
print "\nWhatsapp Discover v1.0 --- Deepak Daswani (\@dipudaswani) 2014\n";
print " http://deepakdaswani.es \n";
print "Uso: whatsapp_discover -i interfaz | -f archivo_pcap[s]\n";
print "---------------------------------------------------------------\n\n\n";
exit;
}

# Procesar los args de la linea de comandos
usage() if (@ARGV < 1 or ! GetOptions('help|?' => \$help, 'i=s' => \$interface, 'f=s{,}' => \@files) or defined $help);


if (!defined $interface && ! @files) {
print "Por favor, selecciona una opcion:\n";
usage();
}


if (defined $interface && @files) {
print "Por favor selecciona una interfaz o un/a [unico|lista] de archivo/s cap/pcap[s]\n";
usage();
}

# Imprimir el encabezado
print "\nWhatsapp Discover v1.0 --- Deepak Daswani (\@dipudaswani) 2014\n";
print " http://deepakdaswani.es \n\n";

# Sniffear o procesar el archivo pcap file[s]
if (defined $interface) { sniff(); }
if (@files) {
foreach (@files) {
print "Procesando $_ ...\n";
parse_file($_);
$file_count++;
}
}

#Crear el objeto pcap desde la interfaz
sub sniff {
#print "\nReal time snifing was disabled in this initial version. \nSorry for the trouble\n\n";
#exit;
$dev = $interface;

my ($address, $netmask);
if (Net::Pcap::lookupnet($dev, \$address, \$netmask, \$err)) {
    die 'No se encontró la interfaz ', $dev, ' - ', $err;
}

#interfaz, len de la captura, modo promiscuo, time en ms, err
$pcap = Net::Pcap::open_live($dev, 1500, 1, 0, \$err); 
unless (defined $pcap) {
    die 'No se pudo crear el paquete o captuar la interfaz ', $dev, ' - ', $err;
}

    meh();
}

# Procesar el archivo pcap en lotes.
sub parse_file () {

my $file = $_;
$pcap = Net::Pcap::open_offline ("$file", \$err) or next;

meh();

}

# Ajustar el desplazamiento
sub meh
{

my $datalink;
$datalink = Net::Pcap::datalink($pcap);
# Fake a case block
CASE: {
# EN10MB capture files
($datalink == 1) && do {
$hoffset = 14;
last CASE;
};

# Linux cooked socket capture files
($datalink == 113) && do {
$hoffset = 16;
last CASE;
};

# DLT_IEEE802_11 capture files
($datalink == 105) && do {
$hoffset = 32;
last CASE;
}

}

my $filter = "tcp && (port 5222 or port 443 or port 5223)"; # Filtrar el trafico de Whatsapp's
my $filter_t;
Net::Pcap::compile( $pcap, \$filter_t, $filter, 1, 0 );
Net::Pcap::setfilter( $pcap, $filter_t );
Net::Pcap::loop( $pcap, 0, \&process_pkt, '' ); # procesar el pcap en la función callback
Net::Pcap::close($pcap); # Cerrar el paquete pcap

}

# Funcion callback aplicada a todo pcap
sub process_pkt {

my ($data, $header, $packet) = @_;
my $unpacket = unpack('H*', substr($packet, 0,1));
if (($hoffset == 32) && ($unpacket == 88)) {
$hoffset = 34; # Se añaden 2 byes al encabezado si el frame es IEEE 802.11 QOS 
}	

my $paquete = substr($packet, $hoffset); # Hack para procesar ambos frames (Ethernet, IEEE 802.11)
my $ip_obj = NetPacket::IP->decode( $paquete );
my $tcp_obj = NetPacket::TCP->decode( $ip_obj->{data} );

if ($tcp_obj->{data} =~ /^WA.*?([a-zA-Z\-\.0-9]+).*?([0-9]{6,})/) { # Expresión regular para procesar el paquete
my $version = $1;
my $telefono = $2;
print "Se encontró un número! S.O: $version Número: +$telefono\n";
$count++;
}

}

print "\n$file_count archivos procesados. Se encontraron $count números...\n\n";

##################################################

# Function for printing a packet. Only for debug purposes
#sub print_pkt {
#    my ($packet) = @_;
#my $i;
#    $i=0;
#    while ($i < length($packet)) {
#        print (substr($packet, $i, 4) . " ");
#        $i = $i + 4;
#        # mod 32 since we are dealing with ascii values, not hex values
#        # (two characters instead of one byte)
#        if (($i % 32) == 0) { print "\n"; };
#    }
#    print "\n\n";
#}

# End of file