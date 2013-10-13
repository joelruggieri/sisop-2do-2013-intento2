#!/bin/bash

# ESTE SCRIPT DEBE CORRER EN MISMO AMBIENTE EN EL QUE ES LLAMADO, NO COMO HIJO
# ESTE SCRIPT DEBE CORRER EN MISMO AMBIENTE EN EL QUE ES LLAMADO, NO COMO HIJO
# ESTE SCRIPT DEBE CORRER EN MISMO AMBIENTE EN EL QUE ES LLAMADO, NO COMO HIJO

# Programa principal
function main {
	declare local retorno=0
	declare local config="../conf/Instalar_TP.conf"
	declare local demonioCorriendo=0
	declare local ID_Recibir_A=-1
	
	perl Grabar_L.pl Iniciar_A I "Comando Iniciar_A Inicio de Ejecución."
	existeFicheroConPermisos f $config r
	estaAmbienteInicializado
	setearEntorno
	realizarValidaciones
	exportarEntorno
	ejecutarRecibirA
	logFinal
	return 0
}

# Verifica si existe el fichero y tiene los permisos pasados por parametro
function existeFicheroConPermisos { # $1: tipo de fichero (f o d), $2: fichero, $3: permiso1, $4: permiso2, ..., $n: permiso(n-2)
	if [[ $retorno -ne 0 ]]; then return 1; fi
	
	if [ -$1 $2 ]; then
		for i in $@
		do
			if [[ ( $i != $1 ) && ( $i != $2 ) ]]; then
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
	   retorno=1
	   return 1
	fi
	
	return 0
}

# Verifica si el ambiente esta inicializado
function estaAmbienteInicializado {
	if [[ $retorno -ne 0 ]]; then return 1; fi
	existeVariable GRUPO
	existeVariable BINDIR
	existeVariable CONFDIR
	existeVariable MAEDIR
	existeVariable ARRIDIR
	existeVariable DATASIZE
	existeVariable ACEPDIR
	existeVariable RECHDIR
	existeVariable PROCDIR
	existeVariable REPODIR
	existeVariable LOGDIR
	existeVariable LOGEXT
	existeVariable LOGSIZE
	return 0
}

# Verifica la existencia de una variable
function existeVariable { # $1: Nombre de variable
	if [[ $retorno -ne 0 ]]; then return 1; fi
	if [[ ${$1:-no existe} != "no existe" ]]; then
		perl Grabar_L.pl Iniciar_A E "Ambiente ya inicializado. Si quiere reiniciar, termine su sesión e ingrese nuevamente."
		retorno=1
		return 1
	fi
	return 0
}

# Setea todas las variables de entorno SIN exportarlas
function setearEntorno {
	if [[ $retorno -ne 0 ]]; then return 1; fi
	
	conseguirVariable GRUPO
	conseguirVariable BINDIR
	if [[ $retorno -eq 0 ]]; then PATH=$PATH:"$GRUPO/$BINDIR"; fi
	conseguirVariable CONFDIR
	conseguirVariable MAEDIR
	conseguirVariable ARRIDIR
	conseguirVariable DATASIZE
	conseguirVariable ACEPDIR
	conseguirVariable RECHDIR
	conseguirVariable PROCDIR
	conseguirVariable REPODIR
	conseguirVariable LOGDIR
	conseguirVariable LOGEXT
	conseguirVariable LOGSIZE
	return 0
}

# Rescata el valor que corresponde a la variable pasada por parametro
# existente en el archivo de configuracion
function conseguirVariable { # $1: Variable
	if [[ $retorno -ne 0 ]]; then return 1; fi
	declare local vSalida=`grep '^'$1'' $config | sed 's@^[^=]*=\([^=]*\)=[^=]*=[^=]*$@\1@'`
	if [[ "$vSalida" == "" ]]; then
		perl Grabar_L.pl Iniciar_A E "Registro de $1 inexistente o malformado en el archivo de configuracion."
		retorno=1
		return 1
	fi
	eval "$1=$vSalida"
	return 0
}

# Realiza todas las verificaciones pertinentes del Iniciar_A menos la
# existencia del archivo de configuracion y el entorno ya inicializado
function realizarValidaciones {
	if [[ $retorno -ne 0 ]]; then return 1; fi
	existenDirectorios
	existeFicheroConPermisos f "$MAEDIR/salas.mae" r
	existeFicheroConPermisos f "$MAEDIR/obras.mae" r
	existeFicheroConPermisos f "$PROCDIR/combos.dis" r
	estanComandosInstalados
	return 0
}

# Verifica que existan los directorios del sistema y que tengan los permisos adecuados
function existenDirectorios {
	if [[ $retorno -ne 0 ]]; then return 1; fi
	existeFicheroConPermisos d $GRUPO r w x
	existeFicheroConPermisos d $BINDIR r x
	existeFicheroConPermisos d $CONFDIR r w x
	existeFicheroConPermisos d $MAEDIR r w x
	existeFicheroConPermisos d $ARRIDIR r w x
	existeFicheroConPermisos d $ACEPDIR r w x
	existeFicheroConPermisos d $RECHDIR r w x
	existeFicheroConPermisos d $PROCDIR r w x
	existeFicheroConPermisos d $REPODIR r w x
	existeFicheroConPermisos d $LOGDIR r w x
	return 0
}

# Verifica que esten los comandos instalados y que tengan los permisos adecuados
function estanComandosInstalados {
	if [[ $retorno -ne 0 ]]; then return 1; fi
	
	# Ejecutables Shell Script
	existeFicheroConPermisos f "$BINDIR/Instalar_TP.sh" x
	existeFicheroConPermisos f "$BINDIR/Recibir_A.sh" x
	existeFicheroConPermisos f "$BINDIR/Reservar_A.sh" x
	existeFicheroConPermisos f "$BINDIR/Start_A.sh" x
	existeFicheroConPermisos f "$BINDIR/Stop_A.sh" x
	
	# Ejecutables PERL
	existeFicheroConPermisos f "$BINDIR/diferenciaDias.pl" x
	existeFicheroConPermisos f "$BINDIR/Grabar_L.pl" x
	existeFicheroConPermisos f "$BINDIR/Imprimir_A.pl" x
	existeFicheroConPermisos f "$BINDIR/Imprimir.pl" x
	existeFicheroConPermisos f "$BINDIR/Mover_A.pl" x
	
	return 0
}

# Exporta las variables de entorno
function exportarEntorno {
	if [[ $retorno -ne 0 ]]; then return 1; fi
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
	return 0
}

# Pregunta si se desea arrancar Recibir_A y hace lo que deba hacer segun el caso
function ejecutarRecibirA {
	if [[ $retorno -ne 0 ]]; then return 1; fi
	declare local respuesta
	echo "Desea efectuar la activación de Recibir_A? Si - No"
	read respuesta
	respuesta=${respuesta,,} # lo paso a minusculas
	
	if [[ "$respuesta" == "si" ]]; then
		perl Grabar_L.pl Iniciar_A I "Respuesta positiva del usuario sobre activacion de Recibir_A."
		activarRecibir
		comoDetenerRecibir
	elif [[ "$respuesta" == "no" ]]; then
		perl Grabar_L.pl Iniciar_A I "Respuesta negativa del usuario sobre activacion de Recibir_A."
		comoCorrerRecibir
	else
		echo "Respuesta invalida."
		perl Grabar_L.pl Iniciar_A E "Respuesta inválida del usuario sobre activacion de Recibir_A."
		comoCorrerRecibir
	fi
	return $retorno
}

# Ejecuta Recibir_A
function activarRecibir {
	if [[ $retorno -ne 0 ]]; then return 1; fi
	Start_A Recibir_A.sh Iniciar_A I
	ID_Recibir_A=`ps -o pid -C Recibir_A.sh | grep '[0-9]$' | sed 's- \(..*\)-\1-'`
	if [[ "$ID_Recibir_A" == "" ]]; then return 0; fi # un error aca no debe parar todo el Iniciar_A
	demonioCorriendo=1
	return 0
}

# Le explica al usuario como detener Recibir_A
function comoDetenerRecibir {
	if [[ $retorno -ne 0 ]]; then return 1; fi
	declare local mensaje="Para detener el demonio Recibir_A, ejecutar el comando 'Stop_A Recibir_A.sh' sin las comillas."
	perl Grabar_L.pl Iniciar_A I $mensaje
	echo $mensaje
	return 0
}

# Le explica al usuario como correr Recibir_A
function comoCorrerRecibir {
	if [[ $retorno -ne 0 ]]; then return 1; fi
	declare local mensaje="Para correr el demonio Recibir_A, ejecutar el comando 'Start_A Recibir_A.sh' sin las comillas."
	perl Grabar_L.pl Iniciar_A I $mensaje
	echo $mensaje
	comoDetenerRecibir
	return 0
}

# Loguea el listado de archivos del directorio pasado como segundo parametro
function listarArchivos { # $1: mensaje, $2: directorio
	if [[ $retorno -ne 0 ]]; then return 1; fi
	perl Grabar_L.pl Iniciar_A I "$1: $2"
	declare local archivo=`ls "$2" -1`
	perl Grabar_L.pl Iniciar_A I "Archivos:"
	perl Grabar_L.pl Iniciar_A I "$archivo"
	return 0
}

# Loguea lo pedido en la pagina 24 del enunciado
function logFinal {
	if [[ $retorno -ne 0 ]]; then return 1; fi
	
	perl Grabar_L.pl Iniciar_A I "TP S07508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 3"
	listarArchivos "Librería del Sistema" $CONFDIR
	listarArchivos "Ejecutables" $BINDIR
	listarArchivos "Archivos maestros" $MAEDIR
	
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
	return 0
}

main
# NO HACER EXIT
