#!/bin/bash
#$1=subdirectorio $2=expresion que matchea, $3 dir destino
function Copiar_archivos {
	declare local directorioActual=`pwd`
	cd "$1"
	ListaArchivos=`ls $2`
	for Archivo in $ListaArchivos;
	do
		local Nombre_archivo=`echo $Archivo | sed -n 's/.*[/]\([^/]*\)/\1/p'`
		if [[ ! -f "$3"/$Nombre_archivo ]]; then
			cp -a "$Archivo" "$3"
		fi
	done
	cd "$directorioActual"
}
function Crear_directorios {

	local Dir=`echo $1 | sed  's-\([^/]*\)\/.*-\1-'`
	local Subdir=`echo $1 | sed -n 's-[^/]*\/\(.*\)-\1-p'`
	if [[ ! -d "$2/$Dir" ]]; then
		mkdir "$2/$Dir"
	fi
	if [[ "$Subdir" != "" ]]; then 
		Crear_directorios "$Subdir" "$2/$Dir"
	fi
}
function Verificar_perl {
	Perl=`perl --version`
	Version=`echo $Perl | sed -n 's/.*v\([0-9]\)\.[0-9][0-9]\.[0-9].*/\1/p'`
	if [[ $Version -lt 5 ]]; then
		echo "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 03
Para instalar el TP es necesario contar con  Perl 5 o superior instalado. Efectúe su instalación e inténtelo nuevamente. 
Proceso de Instalación Cancelado" >> "$CONFDIR"/Instalar_TP.log
		echo "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 03
Para instalar el TP es necesario contar con  Perl 5 o superior instalado. Efectúe su instalación e inténtelo nuevamente. 
Proceso de Instalación Cancelado" 
		exit 0
	fi
	echo "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 03
Perl Version: $Version" >> "$CONFDIR"/Instalar_TP.log
	echo "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 03
Perl Version: $Version"
}
#Recibe 4 parametros [variable a guardar el resultado,salida en pantalla y log, log fracaso,pathdefecto]
function Obtener_path {
	#devolucion de parametros basada en http://www.linuxjournal.com/content/return-values-bash-functions
    local  Resultado=$1
    local  Resultadoparcial
    echo $2
    read Resultadoparcial
    if [[ "$Resultadoparcial" == "" ]]; then
		Resultadoparcial=$3	
	else
		Resultadoparcial=$Resultadoparcial
	fi
	echo "$2 $Resultadoparcial" >> "$CONFDIR"/Instalar_TP.log
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
function Pregunta_sn {
	echo  $1
	local Acepta="null"
	while [ "$Acepta" != "si" -a "$Acepta" != "no" ]
	do
		read Acepta
		if [ "$Acepta" != "si" -a "$Acepta" != "no" ]; then
			echo "No se ingreso una opcion valida. Acepta? si - No"
		fi
	done
	if [ "$Acepta" == "no" ]; then
		return 0
	fi	
	return 1
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

# Rescata el valor que corresponde a la variable pasada por parametro
# existente en el archivo de configuracion
function conseguirVariable { # $1: Variable
	
	declare local vSalida=`grep '^'$1'' "$MAINDIR/$CONFDIR/Instalar_TP.conf" | sed 's@^[^=]*=\([^=]*\)=[^=]*=[^=]*$@\1@'`
	if [[ "$vSalida" == "" ]]; then
		#perl Grabar_L.pl Iniciar_A E "Registro de $1 inexistente o malformado en el archivo de configuracion."
		echo "Error: registro mal formado"
		echo "Error: registro mal formado" >> "$CONFDIR"/Instalar_TP.log
		exit 1
	fi
	eval "$1=\"$vSalida\""
	return 0
}

function Verificar_faltantes {
	#verifico que se instalo en la etapa anterior
	ERROR=0
	echo "- $linea. Archivos:"
	echo "- $linea. Archivos:" >> "$CONFDIR"/Instalar_TP.log
	conseguirVariable BINDIR
		#verifico cada archivo
		if [[ ! -f "$MAINDIR/$BINDIR/Grabar_L.pl" ]]; then
			Faltantes="$Faltantes 
			Grabar_L.pl"
			if [[ ! -f  "$MAINDIR/Datos/Grabar_L.pl" ]]; then
				ERROR=1
			fi
		else
			echo "/$BINDIR/Grabar_L.pl" 
			echo "/$BINDIR/Grabar_L.pl" >> "$CONFDIR"/Instalar_TP.log
		fi
		if [[ ! -f "$MAINDIR/$BINDIR/Mover_A.pl" ]]; then
			Faltantes="$Faltantes 
			Mover_A.pl"
			if [[ ! -f  "$MAINDIR/Datos/Mover_A.pl" ]]; then
				ERROR=1
			fi
		else
			echo "/$BINDIR/Mover_A.pl" 
			echo "/$BINDIR/Mover_A.pl" >> "$CONFDIR"/Instalar_TP.log
		fi
		if [[ ! -f "$MAINDIR/$BINDIR/Recibir_A.sh" ]]; then
			Faltantes="$Faltantes 
			Recibir_A.sh"
			if [[ ! -f  "$MAINDIR/Datos/Recibir_A.sh" ]]; then
				ERROR=1
			fi
		else
			echo "/$BINDIR/Recibir_A.sh" 
			echo "/$BINDIR/Recibir_A.sh" >> "$CONFDIR"/Instalar_TP.log
		fi
		if [[ ! -f "$MAINDIR/$BINDIR/Reservar_A.sh" ]]; then
			Faltantes="$Faltantes 
			Reservar_A.sh "
			if [[ ! -f  "$MAINDIR/Datos/Reservar_A.sh" ]]; then
				ERROR=1
			fi
		else
			echo "/$BINDIR/Reservar_A.sh"
			echo "/$BINDIR/Reservar_A.sh" >> "$CONFDIR"/Instalar_TP.log
		fi
		if [[ ! -f "$MAINDIR/$BINDIR/diferenciaDias.pl" ]]; then
			Faltantes="$Faltantes 
			diferenciaDias.pl"
			if [[ ! -f  "$MAINDIR/Datos/diferenciaDias.pl" ]]; then
				ERROR=1
			fi
		else
			echo "/$BINDIR/diferenciaDias.pl" 
			echo "/$BINDIR/diferenciaDias.pl" >> "$CONFDIR"/Instalar_TP.log
		fi
		if [[ ! -f "$MAINDIR/$BINDIR/Imprimir.pl" ]]; then
			Faltantes="$Faltantes 
			Imprimir.pl"
			if [[ ! -f  "$MAINDIR/Datos/Imprimir.pl" ]]; then
				ERROR=1
			fi
		else
			echo "/$BINDIR/Imprimir.pl" 
			echo "/$BINDIR/Imprimir.pl" >> "$CONFDIR"/Instalar_TP.log
		fi
		if [[ ! -f "$MAINDIR/$BINDIR/Imprimir_A.pl" ]]; then
			Faltantes="$Faltantes 
			Imprimir_A.pl"
			if [[ ! -f  "$MAINDIR/Datos/Imprimir_A.pl" ]]; then
				ERROR=1
			fi
		else
			echo "/$BINDIR/Imprimir_A.pl" 
			echo "/$BINDIR/Imprimir_A.pl" >> "$CONFDIR"/Instalar_TP.log
		fi
		if [[ ! -f "$MAINDIR/$BINDIR/Iniciar_A.sh" ]]; then
			Faltantes="$Faltantes 
			Imprimir_A.pl"
			if [[ ! -f  "$MAINDIR/Datos/Iniciar_A.sh" ]]; then
				ERROR=1
			fi
		else
			echo "/$BINDIR/Iniciar_A.sh" 
			echo "/$BINDIR/Iniciar_A.sh" >> "$CONFDIR"/Instalar_TP.log
		fi
		if [[ ! -f "$MAINDIR/$BINDIR/Start_A.sh" ]]; then
			Faltantes="$Faltantes 
			Start_A.sh"
			if [[ ! -f  "$MAINDIR/Datos/Start_A.sh" ]]; then
				ERROR=1
			fi
		else
			echo "/$BINDIR/Start_A.sh" 
			echo "/$BINDIR/Start_A.sh" >> "$CONFDIR"/Instalar_TP.log
		fi
		if [[ ! -f "$MAINDIR/$BINDIR/Stop_A.sh" ]]; then
			Faltantes="$Faltantes 
			Start_A.sh"
			if [[ ! -f  "$MAINDIR/Datos/Stop_A.sh" ]]; then
				ERROR=1
			fi
		else
			echo "/$BINDIR/Stop_A.sh" 
			echo "/$BINDIR/Stop_A.sh" >> "$CONFDIR"/Instalar_TP.log
		fi

	#verifico cada archivo MAEDIR
		conseguirVariable MAEDIR
		if [[ ! -f "$MAINDIR/$MAEDIR/obras.mae" ]]; then
			Faltantes="$Faltantes 
			obras.mae"
			if [[ ! -f  "$MAINDIR/Datos/obras.mae" ]]; then
				ERROR=1
			fi
		else
			echo "/$MAEDIR/obras.mae" 
			echo "/$MAEDIR/obras.mae" >> "$CONFDIR"/Instalar_TP.log
		fi
		if [[ ! -f "$MAINDIR/$MAEDIR/salas.mae" ]]; then
			Faltantes="$Faltantes 
			salas.mae"
			if [[ ! -f  "$MAINDIR/Datos/salas.mae" ]]; then
				ERROR=1
			fi
		else
			echo "/$MAEDIR/salas.mae"
			echo "/$MAEDIR/salas.mae" >> "$CONFDIR"/Instalar_TP.log
		fi

	#Listo confdir
	ls "$CONFDIR"

	#guardo el resto de los valores ya configurados
	conseguirVariable ARRIDIR
	conseguirVariable DATASIZE
	conseguirVariable ACEPDIR
	conseguirVariable RECHDIR
	conseguirVariable REPODIR
	conseguirVariable PROCDIR
	conseguirVariable LOGDIR
	conseguirVariable LOGEXT
	conseguirVariable LOGSIZE
		
	#imprimo faltantes
	echo "Faltan: $Faltantes"
	if [[ "$Faltantes" == "" ]]; then
		echo "Estado de la instalacion: COMPLETA
Proceso de instalacion cancelado." 
		echo "Estado de la instalacion: COMPLETA
Proceso de instalacion cancelado." >> "$CONFDIR"/Instalar_TP.log
		exit 0;
	else 
		echo "Estado de la instalacion: Incompleto"
		echo "Estado de la instalacion: Incompleto" >> "$CONFDIR"/Instalar_TP.log
		Pregunta_sn "Desea completar la instalacion? (si-no)"
		if [[ "$?" == 0 ]]; then
			exit 0
		else 
			if [[ $ERROR == 1 ]]; then
				echo "No se encuentran los archivos fuentes."
				exit 0;
			fi
		fi
	fi
}
#declaraciones 
MAINDIR=`pwd`
CONFDIR="conf"
#programa ppal
clear
Instalacion_previa=0
if [[ "$1" != "restart1"  && "${13}" != "restart13" ]];then 
	#si es la primera vez que entro
	if [[ ! -d "$CONFDIR" ]]; then
		mkdir "$CONFDIR"
	fi
	echo "Inicio de Ejecucion" >> "$CONFDIR/Instalar_TP.log"
	echo "Log del Comando Instalar_TP: $CONFDIR/Instalar_TP.log" >> "$CONFDIR"/Instalar_TP.log
	echo "Log del Comando Instalar_TP: $CONFDIR/Instalar_TP.log"
	echo "Directorio de Configuración: $MAINDIR/$CONFDIR" >> "$MAINDIR"/"$CONFDIR"/Instalar_TP.log
	echo "Directorio de Configuración: $MAINDIR/$CONFDIR" 
	#verifico si ya fue instalado previamente
	if [ -f "$CONFDIR/Instalar_TP.conf" ]; then
			echo "El paquete ya fue instalado previamente
Estructura de archivos:"
			echo "El paquete ya fue instalado previamente" >> "$MAINDIR"/"$CONFDIR"/Instalar_TP.log
			Verificar_faltantes
			Instalacion_previa=1
		else
		echo "El paquete no fue instalado previamente" >> "$MAINDIR"/"$CONFDIR"/Instalar_TP.log
		# terminos y condiciones
		Pregunta_sn "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 03 \n A T E N C I O N: Al instalar TP SO7508 Segundo Cuatrimestre 2013 UD. expresa aceptar los términos y Condiciones del \"ACUERDO DE LICENCIA DE SOFTWARE\" incluido en este paquete. 
	Acepta? Si – No"
		if [ "$?" == 0 ]; then
			exit 0
		fi
	fi
	Verificar_perl
fi
#si se instala por primera ves 
if [[ $Instalacion_previa == 0 ]]; then
	#solicito valor de BINDIR
	if [ "$2" == "" ]; then
		Obtener_path BINDIR "Defina el directorio de instalacion de los ejecutables ($MAINDIR/bin):" "bin"
	else
		Obtener_path BINDIR "Defina el directorio de instalacion de los ejecutables ($MAINDIR/$2):" "$2"
	fi
	#solicito valor de MAEDIR
	if [ "$3" == "" ]; then
		Obtener_path MAEDIR "Defina el directorio de instalacion de los archivos maestros ($MAINDIR/mae):" "mae"
	else
		Obtener_path MAEDIR "Defina el directorio de instalacion de los archivos maestros ($MAINDIR/$3):" "$3"
	fi
	#solicito valor de ARRIDIR
	if [ "$4" == "" ]; then
		Obtener_path ARRIDIR "Defina el directorio de arribo de archivos externos ($MAINDIR/arribos):" "arribos"
	else 
		Obtener_path ARRIDIR "Defina el directorio de arribo de archivos externos ($MAINDIR/$4):" "$4"
	fi
	#solicito valor minimo en la carpeta arribos
	if [ "$5" == "" ]; then
		Obtener_numero DATASIZE "Defina el espacio minimo libre para el arribo de archivos externos en Mbytes (100):" "error" "100" 1
	else
		Obtener_numero DATASIZE "Defina el espacio minimo libre para el arribo de archivos externos en Mbytes ($5):" "error" "$5" 1
	fi
	#COMPRUEBO ESPACIO EN DISCO
		#Espaciodisco=`df -h | grep 'sda'| tr -s " " | sed 's/.*[A-Za-z].*[A-Za-z].\(.*\)[A-Za-z].*/\1/'`
		Espaciodisco=40	
		let Espaciodisco=`expr $Espaciodisco*1024`
		while [ $Espaciodisco -lt $DATASIZE ]
		do
			echo "Insuficiente espacio en disco.
Espacio disponible: $Espaciodisco Mb.
Cancele la instalacion e intentelo mas tarde o vuelva a intentarlo con otro valor"
echo "Insuficiente espacio en disco.
Espacio disponible: $Espaciodisco Mb.
Cancele la instalacion e intentelo mas tarde o vuelva a intentarlo con otro valor">> "$CONFDIR"/Instalar_TP.log
		Pregunta_sn "Desea cancelar? (si) o elegir un nuevo espacio para el arribo de archivos externos(no) si-no"
		if [ "$?" == 1 ]; then
			exit 0
		fi
		if [ "$5" == "" ]; then
			Obtener_numero DATASIZE "Defina el espacio minimo libre para el arribo de archivos externos en Mbytes (100):" "error" "100" 1
		else
			Obtener_numero DATASIZE "Defina el espacio minimo libre para el arribo de archivos externos en Mbytes ($5):" "error" "$5" 1
		fi		
		done
	#solicito valor de ACEPDIR
	if [ "$6" == "" ]; then
		Obtener_path ACEPDIR "Defina el directorio de grabacion de  los archivos externos aceptados ($MAINDIR/aceptados):" "aceptados"
	else
		Obtener_path ACEPDIR "Defina el directorio de grabacion de  los archivos externos aceptados ($MAINDIR/$6):" "$6"
	fi
	#solicito valor de RECHDIR
	if [ "$7" == "" ]; then
		Obtener_path RECHDIR "Defina el directorio de grabacion de los archivos externos rechazados ($MAINDIR/rechazados):" "rechazados"
	else
		Obtener_path RECHDIR "Defina el directorio de grabacion de los archivos externos rechazados ($MAINDIR/$7):" "$7"
	fi
	#solicito valor de PROCDIR
	if [ "$8" == "" ]; then
		Obtener_path PROCDIR "Defina el directorio de grabacion de los archivos procesados ($MAINDIR/procesados):" "procesados"
	else
		Obtener_path PROCDIR "Defina el directorio de grabacion de los archivos procesados ($MAINDIR/$8):" "$8"
	fi
	#solicito valor de REPODIR
	if [ "$9" == "" ]; then
		Obtener_path REPODIR "Defina el directorio de grabacion de los listados de salida ($MAINDIR/listados):" "listados"
	else	
		Obtener_path REPODIR "Defina el directorio de grabacion de los listados de salida ($MAINDIR/$9):" "$9"
	fi
	#solicito valor de LOGDIR
	if [ "${10}" == "" ]; then
		Obtener_path LOGDIR "Defina el directorio de logs ($MAINDIR/log):" "log"
	else
		Obtener_path LOGDIR "Defina el directorio de logs ($MAINDIR/${10}):" "${10}"
	fi
	#solicito valor de LOGEXT (EXTENSION)
	if [ "${11}" == "" ]; then
	Obtener_valor LOGEXT "Ingrese la extension para los archivos de log (log):" "log" 
	else
	Obtener_valor LOGEXT "Ingrese la extension para los archivos de log (${11}):" "${11}" 
	fi
	LOGEXT="$LOGEXT"
	#verifico valor maximo para los archivos de log LOGSIZE
	if [ "${12}" == "" ]; then
		Obtener_numero LOGSIZE "Defina el tamaño maximo de $LOGEXT en Kbytes (400):" "error" "400" 1
	else
		Obtener_numero LOGSIZE "Defina el tamaño maximo de $LOGEXT en Kbytes (${12}):" "error" "${12}" 1
	fi
fi
#imprimo variables
clear
echo "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 03
Librería del Sistema: /$CONFDIR/ 
Ejecutables: /$BINDIR/ 
Archivos maestros: /$MAEDIR/ 
Directorio de arribo de archivos externos: /$ARRIDIR/
Espacio mínimo libre para arribos: $DATASIZE Mb
Archivos externos aceptados: /$ACEPDIR/
Archivos externos rechazados: /$RECHDIR/
Archivos procesados: /$PROCDIR/
Reportes de salida: /$REPODIR/
Logs de auditoria del Sistema: $LOGDIR/<comando>.$LOGEXT
Tamaño máximo para los archivos de log del sistema: $LOGSIZE Kb
Estado de la instalacion: LISTA"

echo "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 03
Librería del Sistema: /$CONFDIR/ 
Ejecutables: /$BINDIR/ 
Archivos maestros: /$MAEDIR/ 
Directorio de arribo de archivos externos: /$ARRIDIR/
Espacio mínimo libre para arribos: $DATASIZE Mb
Archivos externos aceptados: /$ACEPDIR/
Archivos externos rechazados: /$RECHDIR/
Archivos procesados: /$PROCDIR/
Reportes de salida: /$REPODIR/
Logs de auditoria del Sistema: $LOGDIR/<comando>.$LOGEXT
Tamaño máximo para los archivos de log del sistema: $LOGSIZE Kb
Estado de la instalacion: LISTA" >> "$CONFDIR"/Instalar_TP.log
if [[ $Instalacion_previa == 0 ]]; then
	Pregunta_sn "Esta seguro de que desea estos path?(si/no)"  
	if [[ "$?" == 0 ]]; then
		#reinicio con valores guardados
		bash Instalar_TP.sh "restart1" "$BINDIR" "$MAEDIR" "$ARRIDIR" "$DATASIZE" "$ACEPDIR" "$RECHDIR" "$PROCDIR" "$REPODIR" "$LOGDIR" "$LOGEXT" "$LOGSIZE" "restart13"
		exit 0
	fi 
fi
Pregunta_sn "Instalacion lista. Confirma(si/no)" 
if [[ "$?" == 0 ]]; then
	exit 0 
fi 
#Creo directorios
echo "Creando estructuras de directorio . . . ."
echo "/$BINDIR/"
Crear_directorios "$BINDIR" "$MAINDIR"
echo "/$MAEDIR/"
Crear_directorios "$MAEDIR" "$MAINDIR"
echo "/$ARRIDIR/"
Crear_directorios "$ARRIDIR" "$MAINDIR"
echo "/$ACEPDIR/"
Crear_directorios "$ACEPDIR" "$MAINDIR"
echo "/$RECHDIR/"
Crear_directorios "$RECHDIR" "$MAINDIR"
echo  "/$PROCDIR/"
Crear_directorios "$PROCDIR" "$MAINDIR"
echo "/$REPODIR/"
Crear_directorios "$REPODIR" "$MAINDIR"
echo "/$LOGDIR/"
Crear_directorios "$LOGDIR" "$MAINDIR"
#instalo archivos
echo "Instalando Archivos Maestros"
Copiar_archivos "$MAINDIR"/"Datos" "*.mae" "$MAINDIR"/"$MAEDIR"
echo "Instalando Archivo de disponibilidad"
Copiar_archivos "$MAINDIR"/"Datos" "*.dis" "$MAINDIR"/"$PROCDIR"
echo "Instalando Programas y funciones"
Copiar_archivos "$MAINDIR"/"Datos" "*.sh" "$MAINDIR"/"$BINDIR"
Copiar_archivos "$MAINDIR"/"Datos" "*.pl" "$MAINDIR"/"$BINDIR"
#Actualizo archivos de configuracion
if [[ -f $CONFDIR/Instalar_TP.conf ]]; then
	rm $CONFDIR/Instalar_TP.conf
fi
fecha=`date`
echo "GRUPO=$MAINDIR=$USER=$fecha
CONFDIR=$CONFDIR=$USER=$fecha
BINDIR=$BINDIR=$USER=$fecha
MAEDIR=$MAEDIR=$USER=$fecha
ARRIDIR=$ARRIDIR=$USER=$fecha
DATASIZE=$DATASIZE=$USER=$fecha
ACEPDIR=$ACEPDIR=$USER=$fecha
RECHDIR=$RECHDIR=$USER=$fecha
PROCDIR=$PROCDIR=$USER=$fecha
REPODIR=$REPODIR=$USER=$fecha
LOGDIR=$LOGDIR=$USER=$fecha
LOGEXT=$LOGEXT=$USER=$fecha
LOGSIZE=$LOGSIZE=$USER=$fecha" >> "$CONFDIR"/Instalar_TP.conf
echo "Intalacion CONCLUIDA"
echo "Intalacion CONCLUIDA" >> "$CONFDIR"/Instalar_TP.log
