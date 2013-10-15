#variable ambiente LOGTEXT LOGDIR CONFDIR LOGSIZE 
#$variable=$ENV{'v_Ambiente_exportada'};

#!/usr/bin/perl



#~ $LOGEXT="log";
#~ $LOGDIR="/home/nicolas/SistemasOperativos/Practica/a/qq";
#~ $CONFDIR="/home/nicolas/SistemasOperativos/Practica/a"; # no es una variable ambiente es $grupo/conf
#~ $LOGSIZE="1"; #representado en Kb

$LOGEXT = $ENV{'LOGEXT'};
$LOGDIR = $ENV{'LOGDIR'};
$CONFDIR = "conf";
$GRUPO = $ENV{'GRUPO'};
if(defined $ENV{'LOGSIZE'}) {
	$LOGSIZE = $ENV{'LOGSIZE'};
} else {
	$LOGSIZE="1"; #representado en Kb
}
$MAINDIR = $ENV{'MAINDIR'}; # para Instalar_TP e Iniciar_A previo a la definicion de GRUPO

&main();

sub main{
	%tiposMsj= ("I", 1, "W", 1, "E",1,"SE",1);
	&validarEntrada();
	exit 0;
}

sub lineasLog{
	
	if ( not open (SALIDA,"<$direccion") ){
		print "Error al abrir en modo lecutura $direccion";
		exit 1;
	}
	
	@lineas = <SALIDA>;
	close (SALIDA);	
			
	# $sizeLog = $#lineas cantidad de lineas
		
}
sub truncarLog{
	&lineasLog();
	my $iniciar_lineas = $#lineas - 4;
	my $msjExcedido = "LOG EXCEDIDO\n";
	
	if ( not open (SALIDA,">$direccion") ){
		print "Error al abrir en modo escritura $direccion";
		exit 1;
	}
	
	print SALIDA $msjExcedido;	
	while ($iniciar_lineas <= $#lineas){
			print SALIDA $lineas[$iniciar_lineas];
			$iniciar_lineas +=1;
				
	}
	
	close (SALIDA);	
		
}

sub sizeLog{
	
	if ( not open (SALIDA,"<$direccion") ){
		print "Error al abrir en modo lectura $direccion";
		exit 1;
	}	
	$sizeLog = -s SALIDA;   #en bytes
	# print "$sizeLog\n";	
	close (SALIDA);	
}


sub escribirLog{
	
	&sizeLog();
	if ( $sizeLog > ($LOGSIZE*1000) and $comando ne "Instalar_TP" and $comando ne "Iniciar_A"){
		#Si no es el de instalar y el tamanio supero el maximo se trunca
		&truncarLog();
		
	}
	else {	
			if ( not open (SALIDA,">>$direccion") ){
				print "Error al abrir en modo escritura $direccion";
				exit 1;
			}
			
			$sizeLog = -s SALIDA;   #en bytes
			# print "$sizeLog\n";	
			print SALIDA $escribir;

			close (SALIDA);
	}
		
}

sub modoEscritura{
	my(($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst))=localtime;
	$year+=1900;
	$mon++;
	my $cuando="$mday/$mon/$year $hour:$min:$sec";
	my $quien = getlogin();
	my $donde = $comando;
	my $que = $tip_msj;
	my $pq = $msj;
	$escribir = "$cuando-$quien-$donde-$que-$pq\n";
	
	&escribirLog();
}

sub verificarParametros{
	
	if ($comando eq "Instalar_tp"){		
		$direccion = "$MAINDIR"."/"."$CONFDIR"."/"."Instalar_TP.log";		
 	}
 	elsif ($comando eq "Iniciar_A"){		
		$direccion = "$MAINDIR"."/"."$CONFDIR"."/"."Iniciar_A.log";		
 	}
	else{
		$direccion = "$GRUPO"."/"."$LOGDIR"."/"."$comando"."."."$LOGEXT";
	}
	
	if( not -e $direccion){	
		# si no existe creo el archivo
		if ( not open (SALIDA,">>$direccion") ){
				print "Error al abrir en modo escritura $direccion";
				exit 1;
		}
	}
	&modoEscritura();
	
}

sub validarEntrada{
	
	
	if ($#ARGV < 1 ){
		print "La cantidad de parametros no es la esperada\n";	
		exit 1;		
	}
	$i = 1;
	if ($#ARGV >= 2){ 	
		if ($tiposMsj{$ARGV[1]} == 1 ){		
			$tip_msj = $ARGV[1];
			$i = 2;
		}
	}
	
	while ($i <= $#ARGV){
		$msj.= $ARGV[$i]." ";
		$i++;
	}
	
	$comando = $ARGV[0];
	
	
	&verificarParametros();
	
}




