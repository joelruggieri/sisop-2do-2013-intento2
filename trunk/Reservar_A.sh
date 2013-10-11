#!/bin/bash

# Se corrobora que la fecha recibida es valida en el calendario
function fechaValida {
	local diaValidar=$1
	local mesValidar=$2
	local anioValidar=$3
	
	if [ $diaValidar -gt 0 -a $diaValidar -le 31 -a $mesValidar -gt 0 -a $mesValidar -le 12 -a $anioValidar -gt 0 -a $anioValidar -le 9999 ]; then
		return 0
	fi
	
	return 1
}

# Se corrobora que la fecha no este vencida ni sea para el mismo
# dia de la funcion
function fechaVencida {
	
	# #10 es para indicar sistema decimal, numeros quer arrancan con 0X
	# los toma como octales y meses como 08 y 09 no son numeros validos.
	local diaFuncion="10#$1"
	local mesFuncion="10#$2"
	local anioFuncion="10#$3"
	
	local diaActual="10#`date +%d`"
	local mesActual="10#`date +%m`"
	local anioActual="10#`date +%Y`"
	
	# Verifico en cascada si la fecha es mayor o igual a la actual
	if [[ "$anioActual" -gt "$anioFuncion" ]]; then
		return 0
	fi
	
	if [[ "$mesActual" -gt "$mesFuncion" ]]; then
		return 0
	fi
	
	if [[ "$mesActual" -eq "$mesFuncion" && "$diaActual" -ge "$diaFuncion" ]]; then
		return 0
	fi
	
	return 1
}

# Se verifica que no haya mas de DIAS_ANTICIPACION dias entre la 
# fecha de reserva y la fecha de la funcion
function pasoFechaLimiteAnticipacion {
	
	DIAS_ANTICIPACION=45
	#DIAS_EN_MES=31
	#MESES_EN_ANIO=12
	
	local diaFuncion="$1"
	local mesFuncion="$2"
	local anioFuncion="$3"
	
	local diaActual="`date +%d`"
	local mesActual="`date +%m`"
	local anioActual="`date +%Y`"
	
	local anioActualCorto="`date +%y`"
	# 2013 lo paso a 13
	local anioFuncionCorto=`echo $anioFuncion | sed 's/.*\([0-9]\)\([0-9]\)$/\1\2/'`
	
	#diferencia=`perl diferenciaDias.pl "$anioFuncion-$diaFuncion-$mesFuncion" "$anioActual-$diaActual-$mesActual"`
	diferencia=`echo $"(( $(date --date="$anioFuncionCorto$mesFuncion$diaFuncion" +%s) - $(date --date="$anioActualCorto$mesActual$diaActual" +%s) ))/(60*60*24)"|bc`
	#echo $diferencia
	
	if [[ $diferencia -gt $DIAS_ANTICIPACION ]]; then
		return 0
	fi
	
	return 1
	
	# Si hay problemas usar: echo $"(( $(date --date="031122" +%s) - $(date --date="021020" +%s) ))/(60*60*24)"|bc
	# ymd
	# echo $"(( $(date --date="$anioFuncionCorto$mesFuncion$diaFuncion" +%s) - $(date --date="$anioActualCorto$mesActual$diaActual" +%s) ))/(60*60*24)"|bc
	
	#local diaLimite="10#$1"
	#local mesLimite="10#$2"
	#local anioLimite="10#$3"
	
	#contador=$DIAS_ANTICIPACION
	#while [[ $contador -gt 0 ]]; do
	#	diaLimite="10#$(($diaLimite-1))"
	#	if [[ diaLimite -eq 0 ]]; then
	#		diaLimite=$DIAS_EN_MES
	#		mesLimite="10#$(($mesLimite-1))"
	#		if [[ mesLimite -eq 0 ]]; then
	#			mesLimite=$MESES_EN_ANIO
	#			anioLimite="10#$(($anioLimite-1))"
	#		fi
	#		echo $mesLimite
	#	fi
	#	contador=$(($contador-1))
	#	#echo $contador
	#done
	
	#echo
	#echo $diaLimite
	#echo $mesLimite
	#echo $anioLimite
}

function esHoraValida {
	local horaValidar=$1
	local minutosValidar=$2
	
	if [[ $horaValidar -ge 0 && $horaValidar -le 23 && $minutosValidar -ge 0 && $minutosValidar -le 59 ]]; then
		return 0
	fi
	
	return 1
}

# Verifica si existe el evento en el archivo combos.
function existeEvento {
	local nombreArchivo="$1"
	local diaFuncion="$2"
	local mesFuncion="$3"
	local anioFuncion="$4"
	local horaFuncion="$5"
	local minutosFuncion="$6"
	
	id=`echo $nombreArchivo | cut -d "-" -f 1`

	if [[ $(($id%2)) == 0 ]]; then
		# Si el ID es par, busco en el archivo segun ID de sala
		status=`grep '^[^;]*;[^;]*;'"$diaFuncion"'/'"$mesFuncion"'/'"$anioFuncion"';'"$horaFuncion"':'"$minutosFuncion"';'"$id"';.*' "$PROCDIR/combos.dis"`
		if [[ $status ]]; then
			return 0
		fi
		return 1
	else
		# Si el ID es impar, busco en el archivo segun el ID de obra
		status=`grep '^[^;]*;'"$id"';'"$diaFuncion"'/'"$mesFuncion"'/'"$anioFuncion"';'"$horaFuncion"':'"$minutosFuncion"';.*' "$PROCDIR/combos.dis"`
		if [[ $status ]]; then
			return 0
		fi
		return 1
	fi
}

function hayDisponibilidad {
	local nombreArchivo="$1"
	local diaFuncion="$2"
	local mesFuncion="$3"
	local anioFuncion="$4"
	local horaFuncion="$5"
	local minutosFuncion="$6"
	local butacasPedidas="$7"
	
	id=`echo $nombreArchivo | cut -d "-" -f 1`

	# Recupero el combo correspondiente
	if [[ $(($id%2)) == 0 ]]; then
		# Si el ID es par, busco en el archivo segun ID de sala
		comboRegistro=`grep '^[^;]*;[^;]*;'"$diaFuncion"'/'"$mesFuncion"'/'"$anioFuncion"';'"$horaFuncion"':'"$minutosFuncion"';'"$id"';.*' "$PROCDIR/combos.dis"`
	else
		# Si el ID es impar, busco en el archivo segun el ID de obra
		comboRegistro=`grep '^[^;]*;'"$id"';'"$diaFuncion"'/'"$mesFuncion"'/'"$anioFuncion"';'"$horaFuncion"':'"$minutosFuncion"';.*' "$PROCDIR/combos.dis"`
	fi
	
	comboID=`echo $comboRegistro | cut -d ";" -f 1` 
	#echo $comboRegistro
	
	if [[ ${mapaDispo["$comboID"]} ]]; then
		comboDispo=${mapaDispo["$comboID"]}
	else
		comboDispo=`echo $comboRegistro | cut -d ";" -f 7`
		mapaDispo["$comboID"]="$comboDispo"
	fi
		
	if [[ $butacasPedidas -le $comboDispo ]]; then
		#diferencia=$(($comboDispo-$butacasPedidas))
		#echo
		#echo $diferencia
		#mapaDispo["$comboID"]="$diferencia"		
		return 0
	else
		return 1
	fi
}

# Actualizo el contador y el DISPONIBLE del combo
function actualizarRegistrosOk {
	local butacasPedidasLocal=$1
	regOk="$(($regOk+1))"
	#echo $regOk

	comboDispo=${mapaDispo["$comboID"]}
	diferencia=$(($comboDispo-$butacasPedidasLocal))
	#echo $diferencia
	mapaDispo["$comboID"]="$diferencia"
}

# El registro es valido y se genera la reserva
function generarRegistroOk {
	local nombreArchivo="$1"
	local diaFuncion="$2"
	local mesFuncion="$3"
	local anioFuncion="$4"
	local horaFuncion="$5"
	local minutosFuncion="$6"
	local butacasPedidas="$7"
	local refIntSolicitante="$8"
	
	# Construyo el registro
	
	id=`echo $nombreArchivo | cut -d "-" -f 1`
	if [[ $(($id%2)) == 0 ]]; then
		# Si el ID es par, me quedo con el ID de Sala y el nombre de Sala
		idSala="$id"
		comboRegistro=`grep '^[^;]*;[^;]*;'"$diaFuncion"'/'"$mesFuncion"'/'"$anioFuncion"';'"$horaFuncion"':'"$minutosFuncion"';'"$id"';.*' "$PROCDIR/combos.dis"`
		idObra=`echo "$comboRegistro" | cut -d ";" -f 2`
	else
		# Sino con el ID de Obra y el 
		idObra="$id"
		comboRegistro=`grep '^[^;]*;'"$id"';'"$diaFuncion"'/'"$mesFuncion"'/'"$anioFuncion"';'"$horaFuncion"':'"$minutosFuncion"';.*' "$PROCDIR/combos.dis"`
		idSala=`echo "$comboRegistro" | cut -d ";" -f 5`	
	fi
	
	obraRegistro=`grep '^'"$idObra"';.*' $MAEDIR/obras.mae`
	salaRegistro=`grep '^'"$idSala"';.*' $MAEDIR/salas.mae`
	nombreObra=`echo "$obraRegistro" | cut -d ";" -f 2`
	nombreSala=`echo "$salaRegistro" | cut -d ";" -f 2`
	
	comboID=`echo $comboRegistro | cut -d ";" -f 1`
	correo=`echo $nombreArchivo | cut -d "-" -f 2`
	fecha=`date +%d/%m/%Y-%H:%M`
	
	#echo "--inicio registro Ok--"
	#echo $idObra
	#echo $nombreObra
	#echo $diaFuncion/$mesFuncion/$anioFuncion
	#echo $horaFuncion
	#echo $minutosFuncion
	#echo $idSala
	#echo $nombreSala
	#echo $butacasPedidas
	#echo $comboID
	#echo $refIntSolicitante
	#echo $butacasPedidas
	#echo $correo
	#echo $USER
	#echo $fecha
	#echo "--fin registro Ok--"
	
	# Escribo el archivo reservas.ok
	echo "$idObra;$nombreObra;$diaFuncion/$mesFuncion/$anioFuncion;$horaFuncion:$minutosFuncion;$idSala;$nombreSala;$butacasPedidas;$comboID;$refIntSolicitante;$butacasPedidas;$correo;$USER;$fecha" >> "$PROCDIR/reservas.ok"
	
	actualizarRegistrosOk $butacasPedidas
	
	return 0
}

function generarRegistroNok {
	local nombreArchivo="$1"
	local diaFuncion="$2"
	local mesFuncion="$3"
	local anioFuncion="$4"
	local horaFuncion="$5"
	local minutosFuncion="$6"
	local butacasPedidas="$7"
	local refIntSolicitante="$8"
	local motivo="$9"
	local lineaArchivo=${10}
	
	# Construyo el registro
	
	id=`echo $nombreArchivo | cut -d "-" -f 1`
	if [[ $(($id%2)) == 0 ]]; then
		# Si el ID es par, me quedo con el ID de Sala y el nombre de Sala
		idSala="$id"
		comboRegistro=`grep '^[^;]*;[^;]*;'"$diaFuncion"'/'"$mesFuncion"'/'"$anioFuncion"';'"$horaFuncion"':'"$minutosFuncion"';'"$id"';.*' "$PROCDIR/combos.dis"`
		idObra=`echo "$comboRegistro" | cut -d ";" -f 2`
		if [[ ! $idObra ]]; then
			idObra="Falta OBRA"
		fi
	else
		# Sino con el ID de Obra y el 
		idObra="$id"
		comboRegistro=`grep '^[^;]*;'"$id"';'"$diaFuncion"'/'"$mesFuncion"'/'"$anioFuncion"';'"$horaFuncion"':'"$minutosFuncion"';.*' "$PROCDIR/combos.dis"`
		idSala=`echo "$comboRegistro" | cut -d ";" -f 5`
		if [[ ! $idSala ]]; then
			idSala="Falta SALA"
		fi
	fi
	
	nroFila=`echo $lineaArchivo | cut -d ";" -f 4`
	nroButaca=`echo $lineaArchivo | cut -d ";" -f 5`
	
	correo=`echo $nombreArchivo | cut -d "-" -f 2`
	fecha=`date +%d/%m/%Y-%H:%M`
	
	#echo "--Inicio Registro Nok--"
	#echo $refIntSolicitante
	#echo $diaFuncion/$mesFuncion/$anioFuncion
	#echo $horaFuncion
	#echo $minutosFuncion
	#echo $nroFila
	#echo $nroButaca
	#echo $motivo
	#echo $idSala
	#echo $idObra
	#echo $correo
	#echo $USER
	#echo $fecha
	#echo "--fin Registro Nok--"
	
	echo "$refIntSolicitante;$diaFuncion/$mesFuncion/$anioFuncion;$horaFuncion:$minutosFuncion;$nroFila;$nroButaca;$motivo;$idSala;$idObra;$correo;$USER;$fecha" >> "$PROCDIR/reservas.nok"
	
	# Actualizo el contador
	regNok="$(($regNok+1))"
}

# Recibe cada registro del archivo y lo procesa
function procesarRegistros {
	local lineaArchivo="$1"
	local nombreArchivo="$2"
	#echo "$lineaArchivo"
	
	# Recupero la fecha en formato dd/mm/aaaa para poder verificarla
	fecha=`echo $lineaArchivo | cut -d ";" -f 2`
	# Recupero la hora en formato hh:mm
	horario=`echo $lineaArchivo | cut -d ";" -f 3`
	
	dia=`echo $fecha | cut -d "/" -f 1`
	mes=`echo $fecha | cut -d "/" -f 2`
	anio=`echo $fecha | cut -d "/" -f 3`
	
	hora=`echo $horario | cut -d ":" -f 1`
	minuto=`echo $horario | cut -d ":" -f 2`
	
	butacasDispoRegistro=`echo $lineaArchivo | cut -d ";" -f 6`
	refIntSolicitante=`echo $lineaArchivo | cut -d ";" -f 1`

	motivoRechazo=""

	fechaValida "$dia" "$mes" "$anio"
	if [[ $? != 0 ]]; then
		motivoRechazo="Fecha Invalida"
		#echo "$motivoRechazo"
	fi
	
	if [[ "$motivoRechazo" == "" ]]; then
		fechaVencida "$dia" "$mes" "$anio"
		if [[ $? == 0 ]]; then
			motivoRechazo="Reserva tardia"
			#echo "$motivoRechazo"
		fi
	fi
	
	if [[ "$motivoRechazo" == "" ]]; then
		pasoFechaLimiteAnticipacion "$dia" "$mes" "$anio"
		if [[ $? == 0 ]]; then
			motivoRechazo="Reserva anticipada. Aun no se pueden confirmar reservas para esta funcion"
			#echo "$motivoRechazo"
		fi
	fi
	
	if [[ "$motivoRechazo" == "" ]]; then
		esHoraValida "$hora" "$minuto"
		if [[ $? != 0 ]]; then
			motivoRechazo="Hora invalida"
			#echo "$motivoRechazo"
		fi
	fi
	
	if [[ "$motivoRechazo" == "" ]]; then
		existeEvento "$nombreArchivo" "$dia" "$mes" "$anio" "$hora" "$minuto"
		if [[ $? != 0 ]]; then
			motivoRechazo="No existe el evento solicitado"
			#echo "$motivoRechazo"
		fi
	fi	
		
	if [[ "$motivoRechazo" == "" ]]; then
		hayDisponibilidad "$nombreArchivo" "$dia" "$mes" "$anio" "$hora" "$minuto" "$butacasDispoRegistro"
		if [[ $? != 0 ]]; then
			motivoRechazo="Falta disponibilidad"
			#echo "$motivoRechazo"
		fi
	fi
	
	if [[ "$motivoRechazo" == "" ]]; then
		generarRegistroOk "$nombreArchivo" "$dia" "$mes" "$anio" "$hora" "$minuto" "$butacasDispoRegistro" "$refIntSolicitante"
	else
		generarRegistroNok "$nombreArchivo" "$dia" "$mes" "$anio" "$hora" "$minuto" "$butacasDispoRegistro" "$refIntSolicitante" "$motivoRechazo" "$lineaArchivo"
	fi
	return 0
} 
 
# Se procesan los archivos en ACEPDIR
function procesarArchivos {
	
	for archivo in `ls $ACEPDIR`;
	do
		perl Grabar_L.pl Reservar_A I "Archivo a procesar: $ACEPDIR/$archivo"
		#echo "$archivo"
		while IFS='' read -r linea || [ -n "$linea" ]; do
			procesarRegistros "$linea" "$archivo" 
		done < $ACEPDIR/$archivo
		# Muevo el archivo a PROCDIR
		perl Grabar_L.pl Reservar_A I "Moviendo archivo a $PROCDIR"
		perl Mover_A.pl $ACEPDIR/$archivo $PROCDIR "Reservar_A"
	done
	
	return 0
}

# Se verifica si hay archivos vacios en ACEPDIR, si los 
# hay, se los mueve a RECHDIR
function revisarArchivosVacios {
	
	for i in `find $ACEPDIR -type f -empty`
	do
		perl Grabar_L.pl Reservar_A I "Archivo a procesar: $i"
		perl Grabar_L.pl Reservar_A I "Archivo $i vacio, se rechaza"
		perl Mover_A.pl $i $RECHDIR "Reservar_A"
	done
	
	return 0
}

function revisarRegistrosMalFormados {
	
	return 0
}

# Se realizan verificaciones a nivel archivo, tales como duplicados,
# archivos vacios, etc
function validacionesNivelArchivo {
	revisarDuplicados
	revisarArchivosVacios
	#revisarRegistrosMalFormados
	return 0
}

# Si hay un archivo en ACEPDIR que ya existe en PROCDIR, se lo mueve a 
# RECHDIR
function revisarDuplicados {
	
	for i in `ls $ACEPDIR`
	do
		for j in `ls $PROCDIR`;
		do
			if [ $i == $j ]; then
				perl Grabar_L.pl Reservar_A I "Archivo a procesar: $i"
				perl Grabar_L.pl Reservar_A I "Archivo $i duplicado, se rechaza"
				perl Mover_A.pl $ACEPDIR/$i $RECHDIR "Reservar_A"
			fi
		done
	done
	
	return 0
}

function filalizarProceso {
	
	perl Grabar_L.pl Reservar_A I "La cantidad de registros en reservas.ok grabados es $regOk"
	perl Grabar_L.pl Reservar_A I "La cantidad de registros en reservas.nok grabados es $regNok"
	perl Grabar_L.pl Reservar_A I "Actualizacion del archivo disponibilidad"
	
	# Actualizo el archivo combo.dis
	for idCombo in "${!mapaDispo[@]}"
	do
		#echo $idCombo
		#echo ${mapaDispo[$idCombo]}
		sed -i 's/^\('"$idCombo"';[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;\)[^;]*\(;[^;]*\)/\1'${mapaDispo[$idCombo]}'\2/' $PROCDIR/combos.dis
	done
	
	perl Grabar_L.pl Reservar_A I "Fin de Reservar_A"
}

function inicializarProceso {
	cantidadArchivos=`ls $ACEPDIR | wc -l`
	#echo "Log:Inicio de Reservar_A. La cantidad de archivos en el directorio es $cantidadArchivos"
	perl Grabar_L.pl Reservar_A I "Inicio de Reservar_A"
	perl Grabar_L.pl Reservar_A I "La cantidad de archivos en $ACEPDIR es $cantidadArchivos"
	
	# Creo un hash global para la DISPONIBILIDAD
	declare -A -g mapaDispo
	# Creo contadores para llevar la cuenta de registros ok y nok
	regOk=0
	regNok=0
}

function verificarAmbiente {
	
	if [[ ! $PROCDIR || ! $ACEPDIR || ! $RECHDIR || ! $MAEDIR || ! $LOGEXT || ! $LOGDIR || ! $CONFDIR || ! $LOGSIZE ]]; then
		echo "Ambiente no inicilizado"
		exit 1
	fi
	
	return 0
}

# Cuerpo principal.

# TEMPORAL:Defino el path hasta que lo reciba del iniciar
#ACEPDIR="/home/nicolas/Escritorio/grupo_tres/aceptados"
#RECHDIR="/home/nicolas/Escritorio/grupo_tres/rechazados"
#PROCDIR="/home/nicolas/Escritorio/grupo_tres/procesados"

ACEPDIR="/home/maxi/Desktop/grupo_tres/aceptados"
RECHDIR="/home/maxi/Desktop/grupo_tres/rechazados"
PROCDIR="/home/maxi/Desktop/grupo_tres/procesados"
MAEDIR="/home/maxi/Desktop/grupo_tres/maestros"

LOGEXT="log"
LOGDIR="/home/maxi/Desktop/grupo_tres/conf/log_dir"
CONFDIR="/home/maxi/Desktop/grupo_tres/conf"
LOGSIZE="1000"	 #representado en Kb

export LOGEXT
export LOGDIR
export CONFDIR
export LOGSIZE

verificarAmbiente
inicializarProceso
validacionesNivelArchivo
procesarArchivos
filalizarProceso

exit 0


