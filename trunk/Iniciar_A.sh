#!/bin/bash

# ESTE SCRIPT DEBE CORRER EN MISMO AMBIENTE EN EL QUE ES LLAMADO, NO COMO HIJO
# ESTE SCRIPT DEBE CORRER EN MISMO AMBIENTE EN EL QUE ES LLAMADO, NO COMO HIJO
# ESTE SCRIPT DEBE CORRER EN MISMO AMBIENTE EN EL QUE ES LLAMADO, NO COMO HIJO

# Inicializa el archivo de logueo
function iniciarLog {
	if [[ "$retorno" -ne 0 ]]; then return $retorno
	fi
	
	perl Grabar_L.pl Iniciar_A I "Comando Iniciar_A Inicio de Ejecución\n"
	return 0
}

# TODO !! TODO !! TODO !! TODO !! TODO !! TODO !! TODO !! TODO !! TODO !!
#	Validaciones:
#		a. esta el archivo de configuracion?
#		b. estan los comandos instalados?
#		c. estan los archivos maestros?
#		d. esta el archivo de disponibilidad?
#		e. tienen todos los archivos y ejecutables los permisos adecuados?
#		f. el ambiente ya estaba inicializado?
function realizarValidaciones {
	if [[ "$retorno" -ne 0 ]]; then return $retorno
	fi
	
	return 0
}

# Rescata el valor que corresponde a la variable pasada por parametro
# existente en el archivo de configuracion
function conseguirVariable { # $1 = Nombre de variable
	if [[ "$retorno" -ne 0 ]]; then return $retorno
	fi
	
	vSalida=`grep '^'$1'' $config | sed 's@^[^=]*=\([^=]*\)=[^=]*=[^=]*$@\1@'`
	if [[ "$vSalida" == "" ]]; then
		perl Grabar_L.pl Iniciar_A E "Registro de $1 inexistente o malformado en el archivo de configuracion."
		return 1
	fi
	return 0
}

# Setea todas las variables de entorno
function setearEntorno {
	if [[ "$retorno" -ne 0 ]]; then return $retorno
	fi
	
	# hubiese estado bueno hacer un for aca, pero despues no puedo exportar
	# variables del array con cada nombre que necesito.
	
	retorno=conseguirVariable "GRUPO"
	if [[ "$retorno" -eq 0 ]]; then export GRUPO=$vSalida
	fi
	retorno=conseguirVariable "BINDIR"
	if [[ "$retorno" -eq 0 ]]; then
		export BINDIR=$vSalida
		PATH=$PATH:"$GRUPO/$BINDIR"
	fi
	retorno=conseguirVariable "CONFIGDIR"
	if [[ "$retorno" -eq 0 ]]; then export CONFIGDIR=$vSalida
	fi
	retorno=conseguirVariable "MAEDIR"
	if [[ "$retorno" -eq 0 ]]; then export MAEDIR=$vSalida
	fi
	retorno=conseguirVariable "ARRIDIR"
	if [[ "$retorno" -eq 0 ]]; then export ARRIDIR=$vSalida
	fi
	retorno=conseguirVariable "DATASIZE"
	if [[ "$retorno" -eq 0 ]]; then export DATASIZE=$vSalida
	fi
	retorno=conseguirVariable "ACEPDIR"
	if [[ "$retorno" -eq 0 ]]; then export ACEPDIR=$vSalida
	fi
	retorno=conseguirVariable "RECHDIR"
	if [[ "$retorno" -eq 0 ]]; then export RECHDIR=$vSalida
	fi
	retorno=conseguirVariable "PROCDIR"
	if [[ "$retorno" -eq 0 ]]; then export PROCDIR=$vSalida
	fi
	retorno=conseguirVariable "REPODIR"
	if [[ "$retorno" -eq 0 ]]; then export REPODIR=$vSalida
	fi
	retorno=conseguirVariable "LOGDIR"
	if [[ "$retorno" -eq 0 ]]; then export LOGDIR=$vSalida
	fi
	retorno=conseguirVariable "LOGEXT"
	if [[ "$retorno" -eq 0 ]]; then export LOGEXT=$vSalida
	fi
	retorno=conseguirVariable "LOGSIZE"
	if [[ "$retorno" -eq 0 ]]; then export LOGSIZE=$vSalida
	fi
	
	return 0
}

# TODO !! TODO !! TODO !! TODO !! TODO !! TODO !! TODO !! TODO !! TODO !!
#	Preguntar si se desea arrancar Recibir_A.
#		a. SI => Start_A Recibir_A + los parametros que pida y explicar como detenerlo con Stop_A.
#		b. NO => Explicar como se hace el paso a.
function ejecutarRecibirA {
	if [[ "$retorno" -ne 0 ]]; then return $retorno
	fi
	
	return 0
}

# Loguea el listado de archivos del directorio pasado como segundo parametro
function listarArchivos { # $1: mensaje // $2: directorio
	if [[ "$retorno" -ne 0 ]]; then return $retorno
	fi
	
	perl Grabar_L.pl Iniciar_A I "$1: $2"
	archivo=`ls "$2" -1`
	perl Grabar_L.pl Iniciar_A I "Archivos:"
	perl Grabar_L.pl Iniciar_A I "$archivo"
	return 0
}

# Loguea lo pedido en la pagina 24 del enunciado
function logFinal {
	if [[ "$retorno" -ne 0 ]]; then return $retorno
	fi
	
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
	
	if [[ "$demonioCorriendo" -eq 1 ]]; then
		perl Grabar_L.pl Iniciar_A I "Demonio corriendo bajo el no.: $ID_Recibir_A"
	fi
	
	return 0
}

retorno=0
config="../conf/Instalar_TP.conf"
demonioCorriendo=0
ID_Recibir_A=-1
#~ retorno=iniciarLog
#~ retorno=realizarValidaciones
#~ retorno=setearEntorno
#~ retorno=ejecutarRecibirA
#~ retorno=logFinal

# NO HACER EXIT
