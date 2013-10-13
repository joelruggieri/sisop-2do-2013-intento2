#!/bin/bash

# ESTE SCRIPT DEBE CORRER EN MISMO AMBIENTE EN EL QUE ES LLAMADO, NO COMO HIJO
# ESTE SCRIPT DEBE CORRER EN MISMO AMBIENTE EN EL QUE ES LLAMADO, NO COMO HIJO
# ESTE SCRIPT DEBE CORRER EN MISMO AMBIENTE EN EL QUE ES LLAMADO, NO COMO HIJO

main
# NO HACER EXIT

# Programa principal
function main {
	declare local retorno=0
	declare local config="../conf/Instalar_TP.conf"
	declare local demonioCorriendo=0
	declare local ID_Recibir_A=-1
	
	perl Grabar_L.pl Iniciar_A I "Comando Iniciar_A Inicio de Ejecución."
	retorno=existeFicheroConPermisos f $config r
	retorno=estaAmbienteInicializado
	retorno=setearEntorno
	retorno=realizarValidaciones
	retorno=exportarEntorno
	retorno=ejecutarRecibirA
	retorno=logFinal
}

# Verifica si existe el fichero y tiene los permisos pasados por parametro
function existeFicheroConPermisos { # $1: tipo de fichero (f o d), $2: fichero, $3: permiso1, $4: permiso2, ..., $n: permiso(n-2)
	if [[ $retorno -ne 0 ]]; then return $retorno; fi
	
	if [ -$1 $2 ]; then
		for i in $@
		do
			if [[ $i != $1 -a $i != $2]]; then
				if [ -$i $2 ]; then
					perl Grabar_L.pl Iniciar_A I "El archivo $2 tiene el permiso $i."
				else
					perl Grabar_L.pl Iniciar_A I "El archivo $2 no tiene el permiso $i , se lo agrega."
					chmod +$i $2
				fi
			fi
		done
	else
	   perl Grabar_L.pl Iniciar_A E "El archivo $2 es inexistente."
	   return 1
	fi
	
	return $retorno
}

# Verifica si el ambiente esta inicializado
function estaAmbienteInicializado {
	if [[ $retorno -ne 0 ]]; then return $retorno; fi
	retorno=existeVariable GRUPO
	retorno=existeVariable BINDIR
	retorno=existeVariable CONFDIR
	retorno=existeVariable MAEDIR
	retorno=existeVariable ARRIDIR
	retorno=existeVariable DATASIZE
	retorno=existeVariable ACEPDIR
	retorno=existeVariable RECHDIR
	retorno=existeVariable PROCDIR
	retorno=existeVariable REPODIR
	retorno=existeVariable LOGDIR
	retorno=existeVariable LOGEXT
	retorno=existeVariable LOGSIZE
	return $retorno
}

# Verifica la existencia de una variable
function existeVariable { # $1: Nombre de variable
	if [[ $retorno -ne 0 ]]; then return $retorno; fi
	if [[ ${$1:-no existe} != "no existe" ]]; then
		perl Grabar_L.pl Iniciar_A E "Ambiente ya inicializado. Si quiere reiniciar, termine su sesión e ingrese nuevamente."
		return 1
	fi
	return $retorno
}

# Setea todas las variables de entorno SIN exportarlas
function setearEntorno {
	if [[ $retorno -ne 0 ]]; then return $retorno; fi
	
	# hubiese estado bueno hacer un for aca, pero despues no puedo exportar
	# variables del array con cada nombre que necesito.
	declare local vSalida=""
	
	retorno=conseguirVariable "GRUPO"
	if [[ $retorno -eq 0 ]]; then GRUPO=$vSalida; fi
	
	retorno=conseguirVariable "BINDIR"
	if [[ $retorno -eq 0 ]]; then
		BINDIR=$vSalida
		PATH=$PATH:"$GRUPO/$BINDIR"
	fi
	
	retorno=conseguirVariable "CONFDIR"
	if [[ $retorno -eq 0 ]]; then CONFDIR=$vSalida; fi
	
	retorno=conseguirVariable "MAEDIR"
	if [[ $retorno -eq 0 ]]; then MAEDIR=$vSalida; fi
	
	retorno=conseguirVariable "ARRIDIR"
	if [[ $retorno -eq 0 ]]; then ARRIDIR=$vSalida; fi
	
	retorno=conseguirVariable "DATASIZE"
	if [[ $retorno -eq 0 ]]; then DATASIZE=$vSalida; fi
	
	retorno=conseguirVariable "ACEPDIR"
	if [[ $retorno -eq 0 ]]; then ACEPDIR=$vSalida; fi
	
	retorno=conseguirVariable "RECHDIR"
	if [[ $retorno -eq 0 ]]; then RECHDIR=$vSalida; fi
	
	retorno=conseguirVariable "PROCDIR"
	if [[ $retorno -eq 0 ]]; then PROCDIR=$vSalida; fi
	
	retorno=conseguirVariable "REPODIR"
	if [[ $retorno -eq 0 ]]; then REPODIR=$vSalida; fi
	
	retorno=conseguirVariable "LOGDIR"
	if [[ $retorno -eq 0 ]]; then LOGDIR=$vSalida; fi
	
	retorno=conseguirVariable "LOGEXT"
	if [[ $retorno -eq 0 ]]; then LOGEXT=$vSalida; fi
	
	retorno=conseguirVariable "LOGSIZE"
	if [[ $retorno -eq 0 ]]; then LOGSIZE=$vSalida; fi
	
	return $retorno
}

# Rescata el valor que corresponde a la variable pasada por parametro
# existente en el archivo de configuracion
function conseguirVariable { # $1: Nombre de variable
	if [[ $retorno -ne 0 ]]; then return $retorno; fi
	vSalida=`grep '^'$1'' $config | sed 's@^[^=]*=\([^=]*\)=[^=]*=[^=]*$@\1@'`
	if [[ "$vSalida" == "" ]]; then
		perl Grabar_L.pl Iniciar_A E "Registro de $1 inexistente o malformado en el archivo de configuracion."
		return 1
	fi
	return $retorno
}

# Realiza todas las verificaciones pertinentes del Iniciar_A menos la
# existencia del archivo de configuracion y el entorno ya inicializado
function realizarValidaciones {
	if [[ $retorno -ne 0 ]]; then return $retorno; fi
	retorno=existenDirectorios
	retorno=existeFicheroConPermisos f "$MAEDIR/salas.mae" r
	retorno=existeFicheroConPermisos f "$MAEDIR/obras.mae" r
	retorno=existeFicheroConPermisos f "$PROCDIR/combos.dis" r
	retorno=estanComandosInstalados
	return $retorno
}

# Verifica que existan los directorios del sistema y que tengan los permisos adecuados
function existenDirectorios {
	if [[ $retorno -ne 0 ]]; then return $retorno; fi
	retorno=existeFicheroConPermisos d $GRUPO r w x
	retorno=existeFicheroConPermisos d $BINDIR r x
	retorno=existeFicheroConPermisos d $CONFDIR r w x
	retorno=existeFicheroConPermisos d $MAEDIR r w x
	retorno=existeFicheroConPermisos d $ARRIDIR r w x
	retorno=existeFicheroConPermisos d $ACEPDIR r w x
	retorno=existeFicheroConPermisos d $RECHDIR r w x
	retorno=existeFicheroConPermisos d $PROCDIR r w x
	retorno=existeFicheroConPermisos d $REPODIR r w x
	retorno=existeFicheroConPermisos d $LOGDIR r w x
	return $retorno
}

# Verifica que esten los comandos instalados y que tengan los permisos adecuados
function estanComandosInstalados {
	if [[ $retorno -ne 0 ]]; then return $retorno; fi
	
	# Ejecutables Shell Script
	retorno=existeFicheroConPermisos f "$BINDIR/Instalar_TP.sh" x
	retorno=existeFicheroConPermisos f "$BINDIR/Recibir_A.sh" x
	retorno=existeFicheroConPermisos f "$BINDIR/Reservar_A.sh" x
	retorno=existeFicheroConPermisos f "$BINDIR/Start_A.sh" x
	retorno=existeFicheroConPermisos f "$BINDIR/Stop_A.sh" x
	
	# Ejecutables PERL
	retorno=existeFicheroConPermisos f "$BINDIR/diferenciaDias.pl" x
	retorno=existeFicheroConPermisos f "$BINDIR/Grabar_L.pl" x
	retorno=existeFicheroConPermisos f "$BINDIR/Imprimir_A.pl" x
	retorno=existeFicheroConPermisos f "$BINDIR/Imprimir.pl" x
	retorno=existeFicheroConPermisos f "$BINDIR/Mover_A.pl" x
	
	return $retorno
}

# Exporta las variables de entorno
function exportarEntorno {
	if [[ $retorno -ne 0 ]]; then return $retorno; fi
	export GRUPO
	export BINDIR
	export CONFDIR
	export MAEDIR
	export ARRIDIR
	export DATASIZE
	export ACEPDIR
	export RECHDIR
	export PROCDIR
	export REPODIR
	export LOGDIR
	export LOGEXT
	export LOGSIZE
	return $retorno
}

# Pregunta si se desea arrancar Recibir_A y hace lo que deba hacer segun el caso
function ejecutarRecibirA {
	if [[ $retorno -ne 0 ]]; then return $retorno; fi
	declare local respuesta
	echo "Desea efectuar la activación de Recibir_A? Si - No"
	read respuesta
	respuesta=${respuesta,,} # lo paso a minusculas
	
	if [[ "$respuesta" == "si" ]]; then
		perl Grabar_L.pl Iniciar_A I "Respuesta positiva del usuario sobre activacion de Recibir_A."
		retorno=activarRecibir
		retorno=comoDetenerRecibir
	elif [[ "$respuesta" == "no" ]]
		perl Grabar_L.pl Iniciar_A I "Respuesta negativa del usuario sobre activacion de Recibir_A."
		retorno=comoCorrerRecibir
	else
		echo "Respuesta invalida."
		perl Grabar_L.pl Iniciar_A E "Respuesta inválida del usuario sobre activacion de Recibir_A."
		retorno=comoCorrerRecibir
	fi
	return $retorno
}

# Ejecuta Recibir_A
function activarRecibir {
	if [[ $retorno -ne 0 ]]; then return $retorno; fi
	Start_A Recibir_A.sh Iniciar_A I
	ID_Recibir_A=`ps -o pid -C Recibir_A.sh | grep '[0-9]$' | sed 's- \(..*\)-\1-'`
	if [[ "$ID_Recibir_A" == "" ]]; then return 0; fi # un error aca no debe parar todo el Iniciar_A
	demonioCorriendo=1
	return $retorno
}

# Le explica al usuario como detener Recibir_A
function comoDetenerRecibir {
	if [[ $retorno -ne 0 ]]; then return $retorno; fi
	declare local mensaje="Para detener el demonio Recibir_A, ejecutar el comando 'Stop_A Recibir_A.sh' sin las comillas."
	perl Grabar_L.pl Iniciar_A I $mensaje
	echo $mensaje
	return $retorno
}

# Le explica al usuario como correr Recibir_A
function comoCorrerRecibir {
	if [[ $retorno -ne 0 ]]; then return $retorno; fi
	declare local mensaje="Para correr el demonio Recibir_A, ejecutar el comando 'Start_A Recibir_A.sh' sin las comillas."
	perl Grabar_L.pl Iniciar_A I $mensaje
	echo $mensaje
	retorno=comoDetenerRecibir
	return $retorno
}

# Loguea el listado de archivos del directorio pasado como segundo parametro
function listarArchivos { # $1: mensaje, $2: directorio
	if [[ $retorno -ne 0 ]]; then return $retorno; fi
	perl Grabar_L.pl Iniciar_A I "$1: $2"
	declare local archivo=`ls "$2" -1`
	perl Grabar_L.pl Iniciar_A I "Archivos:"
	perl Grabar_L.pl Iniciar_A I "$archivo"
	return $retorno
}

# Loguea lo pedido en la pagina 24 del enunciado
function logFinal {
	if [[ $retorno -ne 0 ]]; then return $retorno; fi
	
	perl Grabar_L.pl Iniciar_A I "TP S07508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 3"
	retorno=listarArchivos "Librería del Sistema" $CONFDIR
	retorno=listarArchivos "Ejecutables" $BINDIR
	retorno=listarArchivos "Archivos maestros" $MAEDIR
	
	perl Grabar_L.pl Iniciar_A I "Directorio de arribo de archivos externos: $ARRIDIR"
	perl Grabar_L.pl Iniciar_A I "Archivos externos aceptados: $ACEPDIR"
	perl Grabar_L.pl Iniciar_A I "Archivos externos rechazados: $RECHDIR"
	perl Grabar_L.pl Iniciar_A I "Reportes de salida: $REPODIR"
	perl Grabar_L.pl Iniciar_A I "Archivos procesados: $PROCDIR"
	perl Grabar_L.pl Iniciar_A I "Logs de auditoría del Sistema: $LOGDIR/<comando>.$LOGEXT"
	perl Grabar_L.pl Iniciar_A I "Estado del Sistema: INICIALIZADO"
	
	if [[ "$demonioCorriendo" -ne 0 ]]; then
		perl Grabar_L.pl Iniciar_A I "Demonio corriendo bajo el no.: $ID_Recibir_A"
	fi
	return $retorno
}
