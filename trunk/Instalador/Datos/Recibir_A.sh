#!/bin/bash

ARCHIVO_SALAS="salas.mae"
ARCHIVO_OBRAS="obras.mae"
RUTA_RESERVAR="Reservar_A.sh"
RUTA_SALAS="$GRUPO"/"$MAEDIR"/"$ARCHIVO_SALAS"
RUTA_OBRAS="$GRUPO"/"$MAEDIR"/"$ARCHIVO_OBRAS"
NUMERO_DE_CICLO=1
TIEMPO=10 # en segundos

RECHAZADOS="$GRUPO"/"$RECHDIR"
ACEPTADOS="$GRUPO"/"$ACEPDIR"
REPOSITORIO="$GRUPO"/"$REPODIR"

GRABAR="$GRUPO"/"$BINDIR"/"Grabar_L.pl"
MOVER="$GRUPO"/"$BINDIR"/"Mover_A.pl"
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
while (true)
do
	direccionActual=`pwd`
	cd "$GRUPO"
	cd "$ARRIDIR"
	elementos=`ls`
	cd "$direccionActual"
	
	perl "$GRABAR" Recibir_A I "Ciclo Numero $NUMERO_DE_CICLO"
	for archivo in $elementos
	do
		RUTA_ARCHIVO="$GRUPO"/"$ARRIDIR"/"$archivo"
		TIPO_DE_TEXTO=`file "$RUTA_ARCHIVO"`
		INVITADOS_BIEN_FORMADO=` echo $archivo | grep -c '^[^- ]*\.inv$'`
		RESERVA_BIEN_FORMADO=`echo $archivo | grep -c '^[0-9]\+-[^-]*-[^- ]*$'`
		TIPO_TEXTO=`echo $TIPO_DE_TEXTO | grep -c 'text'`
		TEXTO_VACIO=`echo $TIPO_DE_TEXTO | grep -c 'empty'`
		LANG_GUARDAR=$LANG
		LANG=C
		if [[ ($TIPO_TEXTO -eq 0 && $TEXTO_VACIO -eq 0) || ($RESERVA_BIEN_FORMADO -eq 0 && $INVITADOS_BIEN_FORMADO -eq 0) ]] 
		then
			perl "$MOVER" "$RUTA_ARCHIVO" "$RECHAZADOS" Recibir_A
			perl "$GRABAR" Recibir_A I "El archivo $archivo fue rechazado por ser invalido"
			echo "El archivo $archivo fue rechazado por ser invalido"
		elif [[ ($TIPO_TEXTO -eq 1 || $TEXTO_VACIO -eq 1) && $RESERVA_BIEN_FORMADO -eq 1 ]]
		then
			id=`echo $archivo | cut -d "-" -f 1`
			correo=`echo $archivo | cut -d "-" -f 2`
			if [ `expr $id % 2` -eq 0 ]
			then
				ID_CORREO_VALIDOS_SALA=`grep -c "^$id;[^;]*;[^;]*;[^;]*;[^;]*;$correo" "$RUTA_SALAS"`
				if [ $ID_CORREO_VALIDOS_SALA -eq 1 ]
				then
					perl "$MOVER" "$RUTA_ARCHIVO" "$ACEPTADOS" Recibir_A
					perl "$GRABAR" Recibir_A I "El archivo $archivo de reservas ha sido aceptado"
					echo "El archivo $archivo de reservas ha sido aceptado"
				else
					perl "$MOVER" "$RUTA_ARCHIVO" "$RECHAZADOS" Recibir_A
					perl "$GRABAR" Recibir_A I "El archivo $archivo fue rechazado por par id de Sala-correo invalido/inexistente"
					echo "El archivo $archivo fue rechazado por par id de Sala-correo invalido/inexistente"
				fi
			elif [ `expr $id % 2` -eq 1 ]
			then
				ID_CORREO_VALIDOS_OBRA1=`grep -c "^$id;[^;]*;[^;]*;$correo" "$RUTA_OBRAS"`
				ID_CORREO_VALIDOS_OBRA2=`grep -c "^$id;[^;]*;$correo;[^;]*" "$RUTA_OBRAS"`
				if [[ $ID_CORREO_VALIDOS_OBRA1 -eq 1 || $ID_CORREO_VALIDOS_OBRA2 -eq 1 ]]
				then
					perl "$MOVER" "$RUTA_ARCHIVO" "$ACEPTADOS" Recibir_A
					perl "$GRABAR" Recibir_A I "El archivo $archivo de reservas ha sido aceptado"
					echo "El archivo $archivo de reservas ha sido aceptado"
				else
					
					perl "$MOVER" "$RUTA_ARCHIVO" "$RECHAZADOS" Recibir_A
					perl "$GRABAR" Recibir_A I "El archivo $archivo fue rechazado por par id de Obra-correo invalido/inexistente"
					echo "El archivo $archivo fue rechazado por par id de Obra-correo invalido/inexistente"
				fi
			 
			fi
		elif [[ ($TIPO_TEXTO -eq 1 || $TEXTO_VACIO -eq 1) && $INVITADOS_BIEN_FORMADO -eq 1 ]]	
		then
			perl "$MOVER" "$RUTA_ARCHIVO" "$REPOSITORIO" Recibir_A
			perl "$GRABAR" Recibir_A I "El archivo de invitados  $archivo fue aceptado y movido a $REPOSITORIO"
			echo "El archivo de invitados  $archivo fue aceptado y movido a $REPOSITORIO"
		fi
		
 	
	
	done
	CANTIDAD_DE_FICHEROS_EN_ACEPDIR=`ls -A "$GRUPO"/"$ACEPDIR" | wc -l`
	if [ $CANTIDAD_DE_FICHEROS_EN_ACEPDIR -gt 0 ]
	then
		PID_RESERVAR=$(ps -o pid -C Reservar_A.sh | sed "2q;d")
		if [ "$PID_RESERVAR" == "" ]
		then
			Start_A.sh "$RUTA_RESERVAR" Recibir_A I
			#PID_RESERVAR=`ps -o pid -C Reservar_A.sh | grep '[0-9]$' | sed 's- \(..*\)-\1-'`
			PID_RESERVAR=$(ps -o pid -C Reservar_A.sh | sed "2q;d")
			if [ "$PID_RESERVAR" == "" ] #quiero ver si se inicio el Reservar_A.sh o no. No se si tengo que repetir la linea de asignacion de PID_RESERVAR.
			then
				echo " No se ha podido inciar el proceso de Reservas "
			else 
				echo "El Proces ID de Reservar_A es: $PID_RESERVAR"
			fi
		fi
 	fi	
	sleep $TIEMPO
	let NUMERO_DE_CICLO=NUMERO_DE_CICLO+1
done
IFS=$SAVEIFS
