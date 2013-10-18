#!/bin/bash

# ESTE SCRIPT DEBE CORRER EN MISMO AMBIENTE EN EL QUE ES LLAMADO, NO COMO HIJO
# ESTE SCRIPT DEBE CORRER EN MISMO AMBIENTE EN EL QUE ES LLAMADO, NO COMO HIJO
# ESTE SCRIPT DEBE CORRER EN MISMO AMBIENTE EN EL QUE ES LLAMADO, NO COMO HIJO

# Programa principal
function main {
	declare local retorno=0
	export MAINDIR=""
	rescatarMainDir
	declare local config="$MAINDIR/conf/Instalar_TP.conf"
	declare local demonioCorriendo=0
	declare local ID_Recibir_A=-1
	
	declare local mi_direccion=`pwd`
	GRABAR="$mi_direccion"/"Grabar_L.pl"
	
	verificarLoguer
	if [[ $retorno -ne 0 ]]; then return 1; fi
	perl "$GRABAR" Iniciar_A I "Comando Iniciar_A Inicio de Ejecución."
	existeFicheroConPermisos f "$config" r
	estaAmbienteInicializado
	setearEntorno
	
	GRABAR="$GRUPO"/"$BINDIR"/"Grabar_L.pl"
	realizarValidaciones
	exportarEntorno
	ejecutarRecibirA
	logFinal
	if [[ $retorno -ne 0 ]]; then
		perl "$GRABAR" Iniciar_A I "El programa finalizó con errores."
	else
		perl "$GRABAR" Iniciar_A I "El programa finalizó con éxito."
	fi
	perl "$GRABAR" Iniciar_A I "Comando Iniciar_A Fin de Ejecución."
	return 0
}

# Rescata el directorio base de forma manual que vendría a ser igual a $GRUPO
function rescatarMainDir {
	if [[ $retorno -ne 0 ]]; then return 1; fi
	declare local directorioActual=`pwd`
	declare local encontrado=0

	while [[ "$encontrado" == 0 ]]; do
		for directorios in `ls`; do
			if [[ "$directorios" == "conf" ]]; then
				encontrado=1 # Estoy en $grupo! (asumiendo que /conf existe en $grupo sin directorios intermedios
				break
			fi
		done
		if [[ "$encontrado" == 0 ]]; then cd ..; fi
	done

	MAINDIR=`pwd`
	cd "$directorioActual"
	return 0
}

# Verificar existencia del Loguer
function verificarLoguer {
	if [[ $retorno -ne 0 ]]; then return 1; fi
	
	if [ ! -f "$GRABAR" ]; then
		echo "Loguer 'Grabar_L.pl' inexistente."
		echo "Por favor, vuelva a instalar el sistema. Para mas informacion, consulte el README correspondiente."
		retorno=1
		return 1
	fi
	return 0
}

# Verifica si existe el fichero y tiene los permisos pasados por parametro
# tipo: f = archivo || d = directorio
# permisos: r = readable || w = writeable || x = executable
function existeFicheroConPermisos { # $1: tipo de fichero (f o d), $2: fichero, $3: permiso1, $4: permiso2, ..., $n: permiso(n-2)
	# a esta funcion no le importa si hubo un return 1
	
	declare local tipo=""
	if [ "$1" == "f" ]; then tipo="archivo"; fi
	if [ "$1" == "d" ]; then tipo="directorio"; fi
	
	if [ -"$1" "$2" ]; then
		for i in $@
		do
			if [[ ( "$i" == "r" ) || ( "$i" == "w" ) || ( "$i" == "x" ) ]]; then
				if [ -"$i" "$2" ]; then
					perl "$GRABAR" Iniciar_A I "El $tipo $2 tiene el permiso $i."
				else
					perl "$GRABAR" Iniciar_A I "El $tipo $2 no tiene el permiso $i , se lo agrega."
					chmod +"$i" "$2"
				fi
			fi
		done
	else
		perl "$GRABAR" Iniciar_A E "El $tipo $2 es inexistente."
		perl "$GRABAR" Iniciar_A E "Por favor, vuelva a instalar el sistema. Para mas informacion, consulte el README correspondiente."
		retorno=1
		return 1
	fi
	
	return 0
}

# Verifica si el ambiente esta inicializado
function estaAmbienteInicializado {
	if [[ $retorno -ne 0 ]]; then return 1; fi
	existeVariable "$GRUPO"
	existeVariable "$BINDIR"
	existeVariable "$CONFDIR"
	existeVariable "$MAEDIR"
	existeVariable "$ARRIDIR"
	existeVariable "$DATASIZE"
	existeVariable "$ACEPDIR"
	existeVariable "$RECHDIR"
	existeVariable "$PROCDIR"
	existeVariable "$REPODIR"
	existeVariable "$LOGDIR"
	existeVariable "$LOGEXT"
	existeVariable "$LOGSIZE"
	return 0
}

# Verifica la existencia de una variable
function existeVariable { # $1: Nombre de variable
	if [[ $retorno -ne 0 ]]; then return 1; fi
	if [[ ${1:+existe} == "existe" ]]; then
		perl "$GRABAR" Iniciar_A E "Ambiente ya inicializado. Si quiere reiniciar, termine su sesión e ingrese nuevamente."
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
	if [[ $retorno -eq 0 ]]; then PATH="$PATH":"$GRUPO"/"$BINDIR"; fi
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
	declare local vSalida=`grep '^'$1'' "$config" | sed 's@^[^=]*=\([^=]*\)=[^=]*=[^=]*$@\1@'`
	if [[ "$vSalida" == "" ]]; then
		perl "$GRABAR" Iniciar_A E "Registro de $1 inexistente o malformado en el archivo de configuracion."
		retorno=1
		return 1
	fi
	eval "$1=\"$vSalida\""
	return 0
}

# Realiza todas las verificaciones pertinentes del Iniciar_A menos la
# existencia del archivo de configuracion y el entorno ya inicializado
function realizarValidaciones {
	if [[ $retorno -ne 0 ]]; then return 1; fi
	existenDirectorios
	existeFicheroConPermisos f "$GRUPO/$MAEDIR/salas.mae" r
	existeFicheroConPermisos f "$GRUPO/$MAEDIR/obras.mae" r
	existeFicheroConPermisos f "$GRUPO/$PROCDIR/combos.dis" r
	estanComandosInstalados
	return 0
}

# Verifica que existan los directorios del sistema y que tengan los permisos adecuados
function existenDirectorios {
	if [[ $retorno -ne 0 ]]; then return 1; fi
	existeFicheroConPermisos d "$GRUPO" r w x
	existeFicheroConPermisos d "$GRUPO/$BINDIR" r x
	existeFicheroConPermisos d "$GRUPO/$CONFDIR" r w x
	existeFicheroConPermisos d "$GRUPO/$MAEDIR" r w x
	existeFicheroConPermisos d "$GRUPO/$ARRIDIR" r w x
	existeFicheroConPermisos d "$GRUPO/$ACEPDIR" r w x
	existeFicheroConPermisos d "$GRUPO/$RECHDIR" r w x
	existeFicheroConPermisos d "$GRUPO/$PROCDIR" r w x
	existeFicheroConPermisos d "$GRUPO/$REPODIR" r w x
	existeFicheroConPermisos d "$GRUPO/$LOGDIR" r w x
	return 0
}

# Verifica que esten los comandos instalados y que tengan los permisos adecuados
function estanComandosInstalados {
	if [[ $retorno -ne 0 ]]; then return 1; fi
	
	# Ejecutables Shell Script
	existeFicheroConPermisos f "$GRUPO/$BINDIR/Recibir_A.sh" x
	existeFicheroConPermisos f "$GRUPO/$BINDIR/Reservar_A.sh" x
	existeFicheroConPermisos f "$GRUPO/$BINDIR/Start_A.sh" x
	existeFicheroConPermisos f "$GRUPO/$BINDIR/Stop_A.sh" x
	
	# Ejecutables PERL
	existeFicheroConPermisos f "$GRUPO/$BINDIR/Grabar_L.pl" x
	existeFicheroConPermisos f "$GRUPO/$BINDIR/Imprimir_A.pl" x
	existeFicheroConPermisos f "$GRUPO/$BINDIR/Mover_A.pl" x
	
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
		perl "$GRABAR" Iniciar_A I "Respuesta positiva del usuario sobre activacion de Recibir_A."
		activarRecibir
		comoDetenerRecibir
	elif [[ "$respuesta" == "no" ]]; then
		perl "$GRABAR" Iniciar_A I "Respuesta negativa del usuario sobre activacion de Recibir_A."
		comoCorrerRecibir
	else
		echo "Respuesta invalida."
		perl "$GRABAR" Iniciar_A E "Respuesta inválida del usuario sobre activacion de Recibir_A."
		comoCorrerRecibir
	fi
	return $retorno
}

# Ejecuta Recibir_A
function activarRecibir {
	if [[ $retorno -ne 0 ]]; then return 1; fi
	Start_A.sh Recibir_A.sh Iniciar_A I
	ID_Recibir_A=`ps -o pid -C Recibir_A.sh | grep '[0-9]$' | sed 's- \(..*\)-\1-'`
	if [[ "$ID_Recibir_A" == "" ]]; then return 0; fi # un error aca no debe parar todo el Iniciar_A
	demonioCorriendo=1
	return 0
}

# Le explica al usuario como detener Recibir_A
function comoDetenerRecibir {
	if [[ $retorno -ne 0 ]]; then return 1; fi
	declare local mensaje="Para detener el demonio Recibir_A, ejecutar el comando 'Stop_A.sh Recibir_A.sh' sin las comillas."
	perl "$GRABAR" Iniciar_A I "$mensaje"
	echo "$mensaje"
	return 0
}

# Le explica al usuario como correr Recibir_A
function comoCorrerRecibir {
	if [[ $retorno -ne 0 ]]; then return 1; fi
	declare local mensaje="Para correr el demonio Recibir_A, ejecutar el comando 'Start_A.sh Recibir_A.sh' sin las comillas."
	perl "$GRABAR" Iniciar_A I "$mensaje"
	echo "$mensaje"
	comoDetenerRecibir
	return 0
}

# Loguea el listado de archivos del directorio pasado como segundo parametro
function listarArchivos { # $1: mensaje, $2: directorio
	if [[ $retorno -ne 0 ]]; then return 1; fi
	perl "$GRABAR" Iniciar_A I "$1: $2"
	declare local archivo=`ls "$GRUPO/$2" -1`
	perl "$GRABAR" Iniciar_A I "	Archivos:"
	for i in $archivo
	do
		perl "$GRABAR" Iniciar_A I "		$i"
	done
	return 0
}

# Loguea lo pedido en la pagina 24 del enunciado
function logFinal {
	if [[ $retorno -ne 0 ]]; then return 1; fi
	
	perl "$GRABAR" Iniciar_A I "TP S07508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 3"
	listarArchivos "Librería del Sistema" "$CONFDIR"
	listarArchivos "Ejecutables" "$BINDIR"
	listarArchivos "Archivos maestros" "$MAEDIR"
	
	perl "$GRABAR" Iniciar_A I "Directorio de arribo de archivos externos: $ARRIDIR"
	perl "$GRABAR" Iniciar_A I "Archivos externos aceptados: $ACEPDIR"
	perl "$GRABAR" Iniciar_A I "Archivos externos rechazados: $RECHDIR"
	perl "$GRABAR" Iniciar_A I "Reportes de salida: $REPODIR"
	perl "$GRABAR" Iniciar_A I "Archivos procesados: $PROCDIR"
	perl "$GRABAR" Iniciar_A I "Logs de auditoría del Sistema: $LOGDIR/<comando>.$LOGEXT"
	perl "$GRABAR" Iniciar_A I "Estado del Sistema: INICIALIZADO"
	
	if [[ "$demonioCorriendo" -ne 0 ]]; then
		perl "$GRABAR" Iniciar_A I "Demonio corriendo bajo el no.: $ID_Recibir_A"
	fi
	return 0
}

main
# NO HACER EXIT
