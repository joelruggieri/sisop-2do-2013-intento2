#Esta funcion permite mover archivos de un lugar a otro
# debe ser ejecuta -origen -destingo -opcional

use File::Copy;
use File::Path;


&main();


sub main{
	
	%logComando = ("Instalar_TP",1,"Iniciar_A",1,"Recibir_A",1,"Reservar_A",1);
			
	&validarEntrada();
		
	if ($logComando{$comando} == 1 ){
		$status=`perl Grabar_L.pl $comando $tipoMsj $msj`;
	}	
	exit 0;	
}

sub salir{
	print "$ERROR";
	#Se logea el tipo de error ;
	
	if ($logComando{$comando} == 1 ){
		$status=`perl Grabar_L.pl $comando $tipoMsj $ERROR`;
	}
	exit -1;
	
	
}

sub moverArchivo{
	
	my ($auxDir);
	if (opendir(DIRH,$destino)){
		@flist = readdir(DIRH);
		closedir(DIRH);
	}
	else{	
		$tipoMsj="E";	
		$ERROR = "El directorio $destino no se pudo abrir\n";
		&salir();		
	}
	
	$tipoMsj="I";
	$msj = "El archivo $archivo se movio exitosamente";
	
	foreach (@flist){
		# ignorar . y .. :
		next if ($_ eq "." || $_ eq "..");
		
		if ( "$archivo" eq "$_" ){
						
			&verificarDuplicados();
			$destino = $dir_dupli;
			rename ("$dir_origen/$archivo","$dir_origen/$archivo_aux");
			$tipoMsj="W";
			$msj = "El archivo $archivo ya existe en el destino se movio a $destino/dup";
			
			$archivo = $archivo_aux;
			
						
		}		
	}
	
	$auxDir = $dir_origen.'/'.$archivo;	
	move($auxDir,$destino);
	
}


sub verificarDuplicados{
	
	$dir_dupli = $destino."/dup";
	
	if ( not -e $dir_dupli){
		mkpath($dir_dupli);
	}
	
	my ($aux) = 1;
	my (@vecaux);
	
	if (opendir(DIRH,$dir_dupli)){
		@flist = readdir(DIRH);
		closedir(DIRH);
	}
	else{
		$tipoMsj="E";			
		$ERROR="El directorio $dir_dupli no se pudo abrir\n";
		exit 1;		
	}
	
	foreach (@flist){
		# ignorar . y .. :
		next if ($_ eq "." || $_ eq "..");		
		
		@vecaux = split ('\.',$_);
		pop(@vecaux);
		$text_dupli = join ('.',@vecaux);		
		
		if ($text_dupli eq $archivo ){
			$aux += 1;					
		}		
	}
	
	$archivo_aux = $archivo.'.'.$aux;
	
}




sub verificarParametros{
	my (@vector) = split("/",$origen);
	
	$archivo = $vector[$#vector];
	pop (@vector);
	$dir_origen = join ("/",@vector);
	
#	print $dir_origen;
#	print $dir_origen;
	
	#Si origen y destino son iguales no mover
	if ( "$dir_origen" eq "$destino" ){
		$tipoMsj="E";	
		$ERROR= "No se produzco la accion, destino y origen son los mismo\n";
		&salir();
	}
	
	#Si origen o destino no existe no mover
	if(not -e $origen or not -e $dir_origen or  not -e $destino){
		$tipoMsj="E";		
		$ERROR="Algunos de los parametros no existe\n";
		&salir();		
	}
	#Si el origen no contiene un archivo y que el destino no contenga un archivo
	if ( not(-d $destino) ) {#|| not(-r $archivo) ){
		$tipoMsj="E";	
		$ERROR="Error en la forma de los parametros\n";
		&salir();
	}	
	&moverArchivo();
}


sub validarEntrada{
	
	if ($#ARGV < 1 or $#ARGV > 2 ){
		$tipoMsj="SE";
		$ERROR="La cantidad de parametros no es la esperada\n";
		
		print "$ARGV[0]\n";
		print "$ARGV[1]\n";
		print "$ARGV[2]\n";
		
		&salir();
	}
	
	$origen = $ARGV[0];
	$destino = $ARGV[1];
	$comando = $ARGV[2];
	
		
	
	&verificarParametros();
	
}

