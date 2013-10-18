#!/bin/perl
use Data::Dumper;

#$variable=$ENV{'v_Ambiente_exportada'};

$REPODIR= $ENV{'GRUPO'}."/".$ENV{'REPODIR'};
$PROCDIR = $ENV{'GRUPO'}."/".$ENV{'PROCDIR'};
$MAEDIR = $ENV{'GRUPO'}."/".$ENV{'MAEDIR'};
#$REPODIR= "/home/nicolas/SistemasOperativos/Practica/";
#$PROCDIR= "/home/nicolas/SistemasOperativos/Practica/";
#$MAEDIR= "/home/nicolas/SistemasOperativos/Practica/";

#$PROCDIR = "/home/administrador/Escritorio/Repo/procesados";
#$REPODIR = "/home/administrador/Escritorio/Repo/repo";
#$PROCDIR = "/home/administrador/Escritorio/sisop2";
#$REPODIR = "/home/administrador/Escritorio/sisop2";



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
	print "-a Ayuda\n";
	print "-i Generacion del listado de invitados a un evento\n";
	print "-d Listado de disponibles\n";
	print "-r Generar ranking\n";
	print "-t Generar el listado de tickets a imprimir\n";
	print "-w Opcion de grabacion esta opcion es combinable con las opciones anteriores\n";
}

sub existeReferenciaUsuario{
	my ($ref) = @_;
	my ($dir) = "$REPODIR"."/"."$ref".".inv";
	
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
	if(!open (RESERVAS, "<$PROCDIR"."/".'reservas.ok')){
		$result = "Error al leer el archivo de reservas";		
	} 
	
	else {
		$refanterior="";
		while ($linea=<RESERVAS>){
			@data = split(";", $linea);
			
						
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
		if ($hashRef{$refanterior} ne ""){	
			$imprimir = "Reservas confirmadas $refanterior.\n Cantidad: $butacas Total: $hashRef{$refanterior} \n";
			imprimirAArchivo($imprimir);	
		}
		close(RESERVAS);
			
	}
	$return = $result;
	
}
	
sub recorrerListaInvitados{
	my ($ref) = @_;
	my ($dir) = "$REPODIR"."/"."$ref".".inv";	
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
		

sub evaluarOpcionUsuarioListado{
		$imprimir = "Elija una opcion (-s para salir): ";
		imprimirAPantalla($imprimir);
		$opcion = <STDIN>;
		chomp($opcion);
		if($opcion eq "-s"){
				exit 0;
		}
		if( $opcion > $#listaOpciones or $opcion < 0 and $opcion ne "-s"){		
				$imprimir = "A ingresado mal la opcion -s para salir\n ";
				imprimirAPantalla($imprimir);
				&evaluarOpcionUsuarioListado();			
		}
}


sub generarListaEventos{
	
	@listaOpciones;
	%hashEventos;
	my (@auxList);
	my ($i) = 0;
	my ($result) = 0;
	if(!open (RESERVAS, "<$PROCDIR"."/".'reservas.ok')){
		
		$result = "Error al leer el archivo de reservas";
		
	} else {
		print "as\n";
		while ($linea=<RESERVAS>){
			@data = split(";", $linea);
			my $clave = "$data[1]-$data[2]-$data[3]-$data[5]";
			if ($hashEventos{"$clave"} eq ""){
				$idCombo = $data[7];
				$hashEventos{"$clave"} = $idCombo;				
				$imprimir = "$i- $data[1] $data[2] $data[3] $data[5]\n";
				imprimirAPantalla($imprimir);				
				$listaOpciones[$i] = $clave;
				$i++;			
			}
			
		}
		close(RESERVAS);
	}
	    
	    	

	$return = $result;
}
	



sub imprimirInvitados{
	#Recibe por parametro la funcion que realiza la impresion
	my($impresora) = @_;
	
	my($linea) = "Invitados"."\n";
	$impresora->($linea);
	$imprimir = "Se listan los eventos candidatos\n";
	$result = &generarListaEventos();
	&evaluarOpcionUsuarioListado();	
	$idCombo = $hashEventos{$listaOpciones[$opcion]};
	imprimirAPantalla($idCombo);
	if( $aArchivo ){
		startArchivoInvitados();
	}
	$result = &procesarOpcionDeUsuario();
	
	
	if( $aArchivo ){
	   cerrarArchivo();
	} 
	$return = $result;
}


sub startArchivoInvitados{	
	$direccion = "$REPODIR"."/"."$idCombo.inv";
	if ( not open (ARCHIVO,">$direccion") ){
				print "Error al abrir en modo escritura $direccion";
				exit 1;
	}	
	
}

sub evaluarOpcionUsuarioDisponibilidad{
	$imprimir = "Ingrese una opcion:\n 1-Id Obra\n 2-Id Sala\n 3-Rango Id Obra\n 4-Rango Id Sala\n";
	&imprimirAPantalla($imprimir);
	$imprimir = "Opcion: ";
	&imprimirAPantalla($imprimir);
	$opcion = <STDIN>;
	chomp($opcion);
	if( $opcion > 4 or $opcion <= 0){		
			$imprimir = "Opcion incorrecta..\n";
			&imprimirAPantalla($imprimir);
			&evaluarOpcionUsuarioDisponibilidad();			
	}	
}

sub procesarOpcionUsuario{	
	
	if( $opcion == 1 ){
		$imprimir = "Ingrese ID Obra:\n";
	}
	if( $opcion == 2 ){
		$imprimir = "Ingrese Id de sala:\n";
		$i = 1;
	}
	if( $opcion == 3 ){
		$imprimir = "Ingrese Rango id obra separado de '-': \n";
		$i = 2;
	}
	if( $opcion == 4 ){
		$imprimir = "Ingrese id de sala separado de '-':\n";
		$i = 3;
	}
	&imprimirAPantalla($imprimir);
	$opcion2 = <STDIN>;
	
	chomp($opcion2);
	$listaOpcionD[$i]=$opcion;
	if($opcion == 4 or $opcion == 3){
		@rango = split("-",$opcion2);
		print "@rango";
		if($#rango != 1){
			$imprimir = "Ingreso  mal la separacion en el rango\n";
			&imprimirAPantalla($imprimir);
			&procesarOpcionUsuario();
		}
	}	
}


sub recorrerArchivoCombosSegunOpcion{	
	
	if( $opcion == 1){
		if($data[1] == $opcion2){
			$entro = 1;
			$imprimir = "$data[0]-$data[1]-$data[2]-$data[3]-$data[4]-$data[5]-$data[6]\n";
			&imprimirAArchivo($imprimir);
		}
	}
	if($opcion == 2){
		if($data[4] == $opcion2){
			$entro = 1;
			$imprimir = "$data[0]-$data[1]-$data[2]-$data[3]-$data[4]-$data[5]-$data[6]\n";
			&imprimirAArchivo($imprimir);
		}	
	}
	if( $opcion == 3){
		$max = $rango[1];
		$min = $rango[0];
		if($data[1] >= $min and $data[1] <= $max){
			$entro = 1;
			$imprimir = "$data[0]-$data[1]-$data[2]-$data[3]-$data[4]-$data[5]-$data[6]\n";
			&imprimirAArchivo($imprimir);
		}					
	}
	if($opcion == 4){
		$max = $rango[1];
		$min = $rango[0];
		if($data[4] >= $min and $data[4] <= $max){
			$entro = 1;
			$imprimir = "$data[0]-$data[1]-$data[2]-$data[3]-$data[4]-$data[5]-$data[6]\n";
			&imprimirAArchivo($imprimir);
		}			
	}
	
}
sub leerArchivoCombos{
	$entro = 0;
	my ($result) = 0;

	if(!open (COMBOS, "<$PROCDIR"."/".'combos.dis')){
		print "\booo";
		$result = "Error al leer el archivo de reservas";
		
	} else {		
		while ($linea=<COMBOS>){
			
			@data = split(";", $linea);
			&recorrerArchivoCombosSegunOpcion();		
		}
	   
	   close(COMBOS);	
	}
	if ($entro == 0 ){
		$imprimir = "\nEl parametro ingresado es erroneo ingreselo nuevamente:\n";
		&imprimirAPantalla($imprimir);
		&procesarOpcionUsuario();
		&leerArchivoCombos();
	}
	$return = $result;
}	
	
sub imprimirDisponibilidad{
	
		
	&evaluarOpcionUsuarioDisponibilidad();
	&procesarOpcionUsuario();
	if( $aArchivo ){
	   startArchivoDisponibilidad();
	}
	$result = &leerArchivoCombos();
	
	
  	if( $aArchivo ){
	   cerrarArchivo();
	} 
	$retun = $result;
	
}

sub startArchivoDisponibilidad{
	$imprimir = "\nIngrese el nombre del archivo donde se va a imprimir listado\n";
	&imprimirAPantalla($imprimir);
	$nombre = <STDIN>;
	chomp($nombre);
	while ($nombre eq "combos") {
		print "El nombre no puede ser combos, intente nuevamente:\n";
		$nombre = <STDIN>;
		chomp($nombre);
	}
	
	$direccion = "$REPODIR"."/"."$nombre.dis";
	if ( not open (ARCHIVO,">$direccion") ){
				print "Error al abrir en modo escritura $direccion";
				exit 1;
	}	
	
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
		$nArchivo = "$REPODIR"."/".'ranking'.".$numero";
		$return = $nArchivo;
	} else {
		$return = "";
	}

}

sub generarReporteRanking{
	#no esta muy bueno el uso de una variable local pero se mambeó cuand quise hacerla my.
	my($impresora) = @_;
	my(%hash);
	%hashTitulo;
	%hashFecha;
	%hashNSala;
	%hashHora;
	leerReservas_campos();
	my($result) = leerReservas(\%hash);
	if(!$result){
			#print Dumper(\%hash);
			#Ordeno hash por valor (basado en ejemplo de: http://stackoverflow.com/questions/10901084/how-to-sort-perl-hash-on-values-and-order-the-keys-correspondingly-in-two-array)
			my @ClavesOrdenadas = sort { $hash{$b} <=> $hash{$a} } keys(%hash);
			my($long) = $#ClavesOrdenadas+1;
			my($index)=0;
			if ($long > 10){
				#filtro las primeras 10
				$long = 10;
			}
			
			for ($index=0 ; $index<$long ; $index++){
				my($key)=$ClavesOrdenadas[$index];
				$impresora->("Titulo:$hashTitulo->{$key}, Nombre Sala:$hashNSala->{$key}, Fecha:$hashFecha->{$key}, Hora:$hashHora->{$key}, Cantidad entradas:$hash{$key}\n");
			}
	} else {
	
	}
	$return = $result;

		
}
#Retorna un string con el error si hay, y carga el hash con los datos de las reservas.
sub leerReservas{
	#print "<$PROCDIR"."/".'reservas.ok\n';
	my($hash) = @_;
	my($result) = 0;
	if(!open (RESERVAS, "<$PROCDIR"."/".'reservas.ok')){
		$result = "Error al leer el archivo de reservas";
		exit 1;
	} else {
		while ($linea=<RESERVAS>){
			@data = split(";", $linea);		
			#indexado por idpelicula,fecha,hora,idsala
			$hash->{"$data[0]$data[2]$data[3]$data[4]"} = $hash->{"$data[0]$data[2]$data[3]$data[4]"} + $data[6];
		}
	    close(RESERVAS);
	}
	$resultado=$result
	
}
#Retorna un string con el error si hay, y carga el hash con los datos de las reservas.
sub leerReservas_campos{
	#print "<$PROCDIR"."/".'reservas.ok\n';
	my($result) = 0;
	if(!open (RESERVAS, "<$PROCDIR"."/".'reservas.ok')){
		$result = "Error al leer el archivo de reservas";
		exit 1;
	} else {
		while ($linea=<RESERVAS>){
			@data = split(";", $linea);
			$hashTitulo->{"$data[0]$data[2]$data[3]$data[4]"} = $data[1];
			$hashFecha->{"$data[0]$data[2]$data[3]$data[4]"} = $data[2];
			$hashNSala->{"$data[0]$data[2]$data[3]$data[4]"} = $data[5];			
			$hashHora->{"$data[0]$data[2]$data[3]$data[4]"} = $data[3];	
		}
	    close(RESERVAS);
	}	
}
sub obtenerComboID {
	print "Ingrese el ID de un combo valido: \n";
	$comboID = <STDIN>;
	chomp($comboID);
	my($encontrado)=0;
	
	if(!open(COMBOS, "<$PROCDIR"."/".'combos.dis')){
		print "Error: no se pudo abrir combos.dis";
		exit 1;
	} else {
		@array = <COMBOS>;
		
		while (!$encontrado) {
			# Asigna al arreglo todos los registros del archivo.
			foreach (@array){
				$i=index($_,"$comboID"); # busca el string “print”
				if ($i > -1){
					$encontrado = 1;
				}
			}
			if (!$encontrado) {
				print "No es un combo valido, vuela a ingresar:\n";
				$comboID = <STDIN>;
				chomp($comboID);
			}
		}
		$return = $comboID
	}
	
}

sub procesarRegistroDelCombo {
	my($registroCompleto, $impresora) = @_;
	
	#print "El registro completo es: $registroCompleto\n";
	my(@data) = split(";", $registroCompleto);
	my($cantButacas) = $data[6];
	my($ticketsX1)=0;
	my($ticketsX2)=0;
	my($campoTickets)="";
	my($nombreObra)=$data[1];
	my($fechaFunc)=$data[2];
	my($horaFunc)=$data[3];
	my($nombreSala)=$data[5];
	my($refInt)=$data[8];
	my($correo)=$data[10];
	my($registro)="";
	
	$cantButacas = $cantButacas - 2;
	while ($cantButacas >= 0) {
		$ticketsX2 = $ticketsX2 + 1;
		$cantButacas = $cantButacas - 2;
	}
	
	$ticketsX1 = $data[6] - 2 * $ticketsX2;
	
	$registro = "$nombreObra;"."$fechaFunc;"."$horaFunc;"."$nombreSala;"."$refInt;"."$correo;"."$registro";
	
	for ($i = 0; $i < $ticketsX2; $i++) {
		$linea="VALE POR 2 ENTRADAS;"."$registro\n";
		$impresora->($linea);
	}
	
	for ($i = 0; $i < $ticketsX1; $i++) {
		$linea="VALE POR 1 ENTRADA;"."$registro\n";
		$impresora->($linea);
	}
}

sub procesarRegistroCombo {
	my($comboID, $impresora) = @_;
	
	if(!open(RESERVAS, "<$PROCDIR"."/".'reservas.ok')){
		print "Error al leer el archivo de reservas.ok";
		exit 1;
	} else {
		@array = <RESERVAS>;
		
		# Asigna al arreglo todos los registros del archivo.
		foreach (@array){
			$i=index($_,"$comboID"); # busca el string “print”
			if ($i > -1){
				procesarRegistroDelCombo("$_", $impresora);
			}
		}
	}
}

sub imprimirTickets{
	#Recibe por parametro la funcion que realiza la impresion  
	my($impresora) = @_;
	
	my($comboID) = &obtenerComboID;
	
	if( $aArchivo ){
	   startArchivoTickets ($comboID);
	}
	
	&procesarRegistroCombo ($comboID, $impresora);
	
	if( $aArchivo ){
	   cerrarArchivo();
	} 
}

sub startArchivoTickets {
	my($nombreArch) = @_;
	abrirArchivoCrear("$REPODIR"."/"."$nombreArch".".tck");
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
	#print "Imprime Pantalla\n";
	print "$linea";
}


#Abre un archivo y si no existe lo crea
sub abrirArchivoCrear{
#no es muy copado que maneje un identificador global pero es lo mas rapido de implementar.
	my($path) = @_;
	#print 'abre archivo'."$path"."\n";
	open (ARCHIVO,">$path")
}

sub cerrarArchivo{
	#print 'cierra archivo'."\n";
	close(ARCHIVO);
}
