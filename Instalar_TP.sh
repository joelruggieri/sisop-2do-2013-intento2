#!/bin/bash
function Verificar_perl {
	Perl=`perl --version`
	Version=`echo $Perl | sed -n 's/.*v\([0-9]\)\.[0-9][0-9]\.[0-9].*/\1/p'`
	if [[ $Version -lt 5 ]]; then
		echo "Version vieja de Perl"
		#LOGUEAR y salir
	fi
	echo "Version nueva Perl" #loguear	
}
#Recibe 4 parametros [variable a guardar el resultado,salida en pantalla y log, log fracaso,pathdefecto]
function Obtener_path {
	#devolucion de parametros basada en http://www.linuxjournal.com/content/return-values-bash-functions
    local  Resultado=$1
    local  Resultadoparcial
    echo $2
    read Resultadoparcial
    if [[ "$Resultadoparcial" == "" ]]; then
		Resultadoparcial=$MAINDIR/$4		
	else
		Resultadoparcial=$MAINDIR/$Resultadoparcial
	fi
    eval $Resultado="'$Resultadoparcial'"
}
#Recibe 3 parametros [variable a guardar el resultado,salida en pantalla y log,pathdefecto]
function Obtener_valor {
	#devolucion de parametros basada en http://www.linuxjournal.com/content/return-values-bash-functions
    local  Resultado=$1
    local  Resultadoparcial
    echo $2
    read Resultadoparcial
    if [[ "$Resultadoparcial" == "" ]]; then
		Resultadoparcial=$3
	fi
    eval $Resultado="'$Resultadoparcial'"
}
#Recibe 5 parametros [variable a guardar el resultado,salida en pantalla y log, log error, pathdefecto, cota]
function Obtener_numero {
	#devolucion de parametros basada en http://www.linuxjournal.com/content/return-values-bash-functions
    local  Resultado=$1
    local  Resultadoparcial
    echo $2
    read Resultadoparcial
    if [[ $Resultadoparcial -lt $5 ]]; then
		Resultadoparcial=$4
	fi
    eval $Resultado="'$Resultadoparcial'"
}
#programa ppal
mkdir CONFDIR
MAINDIR="/home/ad/Desktop/Grupo_3"

echo "Inicio de ejecucion" >> CONFDIR/Instalar_TP.log
echo "Log del Comando Instalar_TP: CONFDIR/Instalar_TP.log" >> CONFDIR/Instalar_TP.log
echo "Directorio de Configuración: CONFDIR" >> $MAINDIR/CONFDIR/Instalar_TP.log
#verifico si ya fue instalado previamente
if [ -f "CONFDIR/Instalar_TP.conf" ]; then
	echo "El paquete ya fue instalado previamente" >> $MAINDIR/CONFDIR/Instalar_TP.log
	else
	echo "El paquete no fue instalado previamente" >> $MAINDIR/CONFDIR/Instalar_TP.log
	touch  CONFDIR/Instalar_TP.conf
	# terminos y condiciones
	echo  "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 03 \n A T E N C I O N: Al instalar TP SO7508 Segundo Cuatrimestre 2013 UD. expresa aceptar los términos y Condiciones del \"ACUERDO DE LICENCIA DE SOFTWARE\" incluido en este paquete. 
Acepta? Si – No"
	Acepta="null"
	while [ "$Acepta" != "si" -a "$Acepta" != "no" ]
	do
		read Acepta
		if [ "$Acepta" != "si" -a "$Acepta" != "no" ]; then
			echo "No se ingreso una opcion valida. Acepta? Si - No"
		fi
	done
	if [ $Acepta == "no" ]; then
		exit 0
	fi
fi
Verificar_perl
#solicito valor de BINDIR
Obtener_path BINDIR "Defina el directorio de instalacion de los archivos maestros($MAINDIR/bin):" "Marquesinafracaso" "bin"
#solicito valor de ARRIDIR
Obtener_path ARRIDIR "Defina el directorio de arribo de archivos externos($MAINDIR/arribos):" "Marquesinafracaso" "arribos"
#solicito valor minimo en la carpeta arribos
Obtener_numero DATASIZE "Defina el tamanio minimo en Mb(100):" "error" "100" 1
#COMPRUEBO ESPACIO EN DISCO
Espaciodisco=`df -h | grep 'sda'| tr -s " " | sed 's/.*[A-Za-z].*[A-Za-z].\(.*\)[A-Za-z].*/\1/'`
#solicito valor de ACEPDIR
Obtener_path ACEPDIR "Defina el directorio de arribo de archivos externos ACEPTADOS($MAINDIR/aceptados):" "Marquesinafracaso" "aceptados"
#solicito valor de RECHDIR
Obtener_path RECHDIR "Defina el directorio de arribo de archivos externos RECHAZADOS($MAINDIR/rechazados):" "Marquesinafracaso" "rechazados"
#solicito valor de PROCDIR
Obtener_path PROCDIR "Defina el directorio de arribo de archivos externos PROCESADOS($MAINDIR/procesados):" "Marquesinafracaso" "procesados"
#solicito valor de c
Obtener_path REPODIR "Defina el directorio de arribo de LISTADOS DE SALIDA($MAINDIR/listados):" "Marquesinafracaso" "listados"
#solicito valor de LOGDIR
Obtener_path LOGDIR "Defina el directorio de LOS LOGS($MAINDIR/log):" "Marquesinafracaso" "log"
#solicito valor de LOGEXT (EXTENSION)
Obtener_valor LOGEXT "Defina el directorio de LOS LOGS(.log):" ".log" #revisar punto
#verifico valor maximo para los archivos de log LOGSIZE
Obtener_numero LOGSIZE "Defina el tamanio maximo de los archivos de log en Kb(400):" "error" "400" 1

rm -R "CONFDIR" #borrar cuando terminen pruebas
#imprimo variables
echo $BINDIR
echo $ARRIDIR
echo $DATASIZE
echo $ACEPDIR
echo $RECHDIR
echo $PROCDIR
echo $REPODIR
echo $LOGDIR
echo $LOGEXT
echo $LOGSIZE


