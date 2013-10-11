#!/bin/perl
use Data::Dumper;

#$variable=$ENV{'v_Ambiente_exportada'};

#$REPODIR= $ENV{'REPODIR'};
#$PROCDIR = $ENV{'PROCDIR'};
#$MAEDIR = $ENV{'MAEDIR'};
$REPODIR= "/home/nicolas/SistemasOperativos/Practica/";
$PROCDIR= "/home/nicolas/SistemasOperativos/Practica/";
#$MAEDIR= "/home/nicolas/SistemasOperativos/Practica/";


&main();

sub main{
	#llamar un script que chequee si existe ya el script ejecutado.	
	local($aArchivo) = 0;
	local($ayuda) = 0;
	local($operacion);
	local($error) = "";
 	my($seleccionOk) = &leerOpciones();
	my($generadorReporte) = 0;
	if($error) {
        	print "$error"."\n";
		$ayuda = 1;
	}	
	if ( ! $seleccionOk && ! $ayuda) {
	   print 'Por favor indique una operacion valida'."\n";
	   $ayuda = 1;
	}

	if ( $ayuda ) {
	  imprimirAyuda();
          exit 0;
	}
	
	my($impresora);
	if( $aArchivo ){
		$impresora = \&imprimirAArchivo;
	} else {
		$impresora = \&imprimirAPantalla;
	}
	$operacion->($impresora);

	exit 0;
	

}

sub leerOpciones{
   my($seleccionado) = 0; 
   #TODO validar que la cantidad de parametros sea una al menos.
   $long = @ARGV;
   if( $long != 1 && $long != 2 ) {
     $error = "Cantidad de parametros incorrecta";
   } else {
	   my $op;
	   while (my ($index, $value) = each @ARGV) {
			if ($value eq "-w") {
		 	  $aArchivo = 1;
		 	  next;
			}
			if ($value eq "-a") {
			  $ayuda = 1;
			  next;
			}
			if ($value eq "-i") {
			  if (!$seleccionado) {
				  $operacion = \&imprimirInvitados;
				  $seleccionado = 1;
			  } else {
				$error = "Por favor, seleccione solo una operacion"			
			  }
			   next;
			}
			if ($value eq "-d") {
			  if (!$seleccionado) {
				  $operacion=  \&imprimirDisponibilidad;
				  $seleccionado = 1;
			  } else {
				$error = "Por favor, seleccione solo una operacion"			
			  }
			  next;
		  	}
			if ($value eq "-r") {
			  if (!$seleccionado) {
				  $operacion = \&imprimirRanking;
				  $seleccionado = 1;
			  } else{
				$error = "Por favor, seleccione solo una operacion"			
			  }
			  next;
			}
			if ($value eq "-t") {
			  if (!$seleccionado) {
				  $operacion=\&imprimirTickets;
				  $seleccionado = 1;
			  } else{
				$error = "Por favor, seleccione solo una operacion"			
			  }
			  next;
			}		     
	   }
	
	   $op = $seleccionado;

   }


}
sub imprimirAyuda {
	print 'Ayuda'."\n";
}

sub existeReferenciaUsuario{
	my ($ref) = @_;
	my ($dir) = "$PROCDIR"."$ref".".inv";
	
	if (  $ref eq "" or not -e $dir or -z $dir ){
		$return = 0;
	}
	else{
		
		if ( $hashRef{$ref} eq ""){ 
			$hashRef{$ref} = 0;
			
		}
		$return = 1;
	}	
}


sub reservasConfirmadas{
	$butacas+= $data[6];
	if($data[8] ne $refanterior){																
		if($hashRef{$refanterior} != 0){													
			$butacas-=$data[6]; #saco la ultima que sume
			$imprimir = "Reservas confirmadas $refanterior.\n Cantidad: $butacas Total: $hashRef{$refanterior} \n";
			imprimirAArchivo($imprimir);	
			$butacas = 0;	
		}					
	$refanterior = $data[8];	
	}

}

sub procesarOpcionDeUsuario{	
	my ($result) = 0;
	my @evento = split("-",$listaOpciones[$opcion]);
	%hashRef;
	$butacas = 0;
	print "@evento\n";	
	if(!open (RESERVAS, "<$PROCDIR".'reservas.ok')){
		$result = "Error al leer el archivo de reservas";		
	} 
	
	else {
		$refanterior="";
		while ($linea=<RESERVAS>){
			@data = split(";", $linea);
			
			$idCombo = $data[7];
			if( $aArchivo ){
					startArchivoInvitados();
			}
			
			if( $evento[0] eq $data[1] and $evento[1] eq $data[2]
				and $evento[2] eq $data[3] and $evento[3]eq $data[5]) {
														
				my ($existeReferencia) = existeReferenciaUsuario($data[8]);
				
				if($existeReferencia){
					&reservasConfirmadas();
										
				}
								
				$imprimir = "Evento: $data[7] Obra: $data[0] $data[1] Fecha y Hora: $data[2] $data[3]Hs. Sala: $data[4] $data[5]\n";
				imprimirAArchivo($imprimir);										
						
				if (!$existeReferencia){
					$imprimir = "\tSin listado de invitados\n";					
					imprimirAArchivo($imprimir);					
				}
				$result = &recorrerListaInvitados($data[8]); 			
				
			}			
						
		}		
		$imprimir = "Reservas confirmadas $refanterior.\n Cantidad: $butacas Total: $hashRef{$refanterior} \n";
		imprimirAArchivo($imprimir);	
		close(RESERVAS);
			
	}
	$return = $result;
	
}
	
sub recorrerListaInvitados{
	my ($ref) = @_;
	my ($dir) = "$PROCDIR"."$ref".".inv";	
	$totalacumulado = $hashRef{$ref};	
	if(!open (REFERENCIA, "<$dir")){
		$result = "Error al leer el archivo de reservas";
		
	} 
	else {
		
		while ($linea=<REFERENCIA>){
			@data = split(";", $linea);
			if($data[2] == 0){
				$aux = chomp($data[2]);	
			}
			else{
				$aux = 0;
			}			
			$totalacumulado+=$aux+1;
			$imprimir = "\t$data[0] $aux $totalacumulado\n";
			imprimirAArchivo($imprimir);	

		}
		$hashRef{$ref} = $totalacumulado;
		close(REFERENCIA);
			
	}

}    
		

sub evaluarOpcionUsuario{
		$imprimir = "Elja una opcion: ";
		imprimirAPantalla($imprimir);
		$opcion = <STDIN>;
		chomp($opcion);
		if($opcion eq "-s"){
				exit 0;
		}
		if( $opcion > $#listaOpciones or $opcion < 0 and $opcion ne "-s"){		
				$imprimir = "A ingresado mal la opcion -s para salir\n ";
				imprimirAPantalla($imprimir);
				&evaluarOpcionUsuario();			
		}
}


sub generarListaEventos{
	
	@listaOpciones;
	my( %hashEventos);
	my (@auxList);
	my ($i) = 0;
	my ($result) = 0;
	if(!open (RESERVAS, "<$PROCDIR".'reservas.ok')){
		
		$result = "Error al leer el archivo de reservas";
		
	} else {
		
		while ($linea=<RESERVAS>){
			@data = split(";", $linea);
			my $clave = "$data[1]-$data[2]-$data[3]-$data[5]";
			if ($hashEventos{"$clave"} eq ""){
				$hashEventos{"$clave"} = $i;				
				$imprimir = "$i- $data[1] $data[2] $data[3] $data[5]\n";
				imprimirAPantalla($imprimir);				
				$listaOpciones[$i] = $clave;
				$i++;			
			}
			
		}
	}
	    
	    close(RESERVAS);	

	$return = $result;
}
	



sub imprimirInvitados{
	#Recibe por parametro la funcion que realiza la impresion
	my($impresora) = @_;
	
	my($linea) = "Invitados"."\n";
	$impresora->($linea);
	$imprimir = "Se listan los eventos candidatos\n";
	$result = &generarListaEventos();
	&evaluarOpcionUsuario();	
	
	$result = &procesarOpcionDeUsuario();
	
	
	if( $aArchivo ){
	   cerrarArchivo();
	} 
	$return = $result;
}


sub startArchivoInvitados{	
	$direccion = "$REPODIR$idCombo.inv";
	if ( not open (ARCHIVO,">$direccion") ){
				print "Error al abrir en modo escritura $direccion";
				exit 1;
	}	
	
}

sub imprimirDisponibilidad{
	#Recibe por parametro la funcion que realiza la impresion  
	my($impresora) = @_;
	my($linea) = "Disponibilidad"."\n";
	if( $aArchivo ){
	   startArchivoDisponibilidad();
	}
	$impresora->($linea);
  	if( $aArchivo ){
	   cerrarArchivo();
	} 
}

sub startArchivoDisponibilidad{
	print "Abre Archivo disponibilidad"."\n";
}

sub imprimirRanking{
	#Recibe por parametro la funcion que realiza la impresion  
	my($impresora) = @_;
	my($error,$errorGeneracion, $result) = (0,0,0);
	if( $aArchivo ){
	  my($nombreArchivo) = crearNombreArchivoRanking();
	  if($nombreArchivo) {
		if(! abrirArchivoCrear("$nombreArchivo")){
		    $error = "Error al crear el archivo";	
		}
	  } else {
		$error = "No se pudo abrir el directorio de salida";
	  }
	}
	
	if(!$error) {
		$errorGeneracion = generarReporteRanking(\&$impresora);
	}
	
	
	if($aArchivo && !$error){
	   cerrarArchivo();
	} 
	
	if($errorGeneracion) {
		$result = $errorGeneracion;
	}
	if($error) {
		$result = $error;
	}
	$return = $result;
}

sub crearNombreArchivoRanking{
	print "Abre Archivo ranking"."\n";
	my(@numeros, $nArchivo);
	my($numero) = 0;
	if (opendir(DIRECTORIO,"$REPODIR")){
		@flist=readdir(DIRECTORIO);	
		closedir(DIRECTORIO);
		foreach $nombre (@flist){
			if($nombre =~ m/^ranking\.\d+$/){
				#una vez que matchea me quedo con el numero
			   my($index) = index($nombre, '.');
			   push(@numeros, substr($nombre,$index +1));	
			}
		}
		#tomo el mayor de los numeros + 1
		if(@numeros > 0){
			@numeros = sort { $a <=> $b } @numeros;
			$numero = pop(@numeros) + 1;
			
		} else {
			#redundante pero mas claro
			$numero = 0;
			
		}
		
	
		#abro el archivo... si... dsps de todo eso ya se como se va a llamar..
		$nArchivo = "$REPODIR".'ranking'.".$numero";
		$return = $nArchivo;
	} else {
		$return = "";
	}

}

sub generarReporteRanking{
	#no esta muy bueno el uso de una variable local pero se mambeó cuand quise hacerla my.
	my($impresora) = @_;
	my(%hash);
	my($result) = leerReservas(\%hash);
	if(!$result){
			#print Dumper(\%hash);
			foreach my $key ( keys %hash ) {
			  #TODO FILTRAR LOS PRIMEROS 10, ORDENAR POR KEY Y OBTENER UN NUEVO MAPA DONDE LA CLAVE SEA EL MAIL Y EL VALOR LA CANTIDAD
			  $impresora->("key: $key, value: $hash{$key}\n");
			}
			
	} else {
	
	}
	$return = $result;

		
}
#Retorna un string con el error si hay, y carga el hash con los datos de las reservas.
sub leerReservas{
	#print "<$PROCDIR".'reservas.ok\n';
	my($hash) = @_;
	my($result) = 0;
	if(!open (RESERVAS, "<$PROCDIR".'reservas.ok')){
		$result = "Error al leer el archivo de reservas";
	} else {
		while ($linea=<RESERVAS>){
			@data = split(";", $linea);		
			$hash->{"$data[0]"} = $hash->{"$data[0]"} + $data[6];
		}
	    close(RESERVAS);
	}
	
	$return = $result;
}
sub imprimirTickets{
	#Recibe por parametro la funcion que realiza la impresion  
	my($impresora) = @_;
	my($linea) = "Tickets"."\n";
	if( $aArchivo ){
	   startArchivoTickets();
	}
	$impresora->($linea);
	if( $aArchivo ){
	   cerrarArchivo();
	} 
}

sub startArchivoTickets{
	print "Abre Archivo tickets"."\n";
}

sub imprimirAArchivo{
	my($linea) = @_;
	#ACA SE HACE REFERENCIA AL MANEJADOR.
	print ARCHIVO $linea;
        #Imprime por pantalla tambien
	imprimirAPantalla($linea);
}

sub imprimirAPantalla{
	my($linea) = @_;
	#sale por standard
	print "$linea";
}

#Abre un archivo y si no existe lo crea
sub abrirArchivoCrear{
#no es muy copado que maneje un identificador global pero es lo mas rapido de implementar.
	my($path) = @_;
	print 'abre archivo'."$path"."\n";
	open (ARCHIVO,">$path")
}

sub cerrarArchivo{
	print 'cierra archivo'."\n";
	close(ARCHIVO);
}
