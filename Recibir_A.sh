#!/bin/bash
ARRIDIR="/home/joel/Documentos/Sistemas_Operativos/arribos/"
ACEPDIR="/home/joel/Documentos/Sistemas_Operartivos/aceptados"
REPODIR="/home/joel/Documentos/Sistemas_Operativos/repositorio"
RECHDIR="/home/joel/Documentos/Sistemas_Operativos/rechazados/"
MAEDIR="/home/joel/Documentos/Sistemas_Operativos/maestros/"
DEMONIO_RUTA="/home/joel/Documentos/Sistemas_Operativos/demonio.sh"
ARCHIVO_SALAS="salas.mae"
ARCHIVO_OBRAS="obras.mae"
RUTA_RESERVAR="/home/joel/TP-SO/Reservar_A.sh"
RUTA_SALAS="$MAEDIR$ARCHIVO_SALAS"
RUTA_OBRAS="$MAEDIR$ARCHIVO_OBRAS"
NUMERO_DE_CICLO=1
TIEMPO=60 # en segundos

while (true)
do
	perl Grabar_L.pl Recibir_A "Ciclo Numero $NUMERO_DE_CICLO"
	for archivo in `ls $ARRIDIR`
	do
		RUTA_ARCHIVO=$ARRIDIR$archivo
		TIPO_DE_TEXTO="`file $RUTA_ARCHIVO`"
		INVITADOS_BIEN_FORMADO=` echo $archivo | grep -c '^[^- ]*\.inv$'`
		RESERVA_BIEN_FORMADO=`echo $archivo | grep -c '^[0-9]\+-[^-]*-[^- ]*$'`
		TIPO_TEXTO=`echo $TIPO_DE_TEXTO | grep -c 'text'`
		if [[ $TIPO_TEXTO -eq 0 || ($RESERVA_BIEN_FORMADO -eq 0 && $INVITADOS_BIEN_FORMADO -eq 0) ]] 
		then
			perl Mover_A.pl $RUTA_ARCHIVO $RECHDIR Recibir_A
			perl Grabar_L.pl Recibir_A "El archivo $archico fue rechazado por ser invalido"
		elif [[ $TIPO_TEXTO -eq 1 && $RESERVA_BIEN_FORMADO -eq 1 ]]
		then
			id=`echo $archivo | cut -d "-" -f 1`
			correo=`echo $archivo | cut -d "-" -f 2`
			if [ `expr $id % 2` -eq 0 ]
			then
				ID_CORREO_VALIDOS_SALA=`grep -c "^$id;[^;]*;[^;]*;[^;]*;[^;]*;$correo" $RUTA_SALAS`
				if [ $ID_CORREO_VALIDOS_SALA -eq 1 ]
				then
					perl Mover_A.pl $RUTA_ARCHIVO $ACEPDIR Recibir_A
					perl Grabar_L.pl Recibir_A "El archivo $archivo de reservas ha sido aceptado"
				else
					perl Mover_A.pl $RUTA_ARCHIVO $RECHDIR Recibir_A
					perl Grabar_L.pl Recibir_A "El archivo $archivo fue rechazado por par id de Sala-correo invalido/inexistente"
				fi
			elif [ `expr $id % 2` -eq 1 ]
			then
				ID_CORREO_VALIDOS_OBRA1=`grep -c "^$id;[^;]*;[^;]*;$correo" $RUTA_OBRAS`
				ID_CORREO_VALIDOS_OBRA2=`grep -c "^$id;[^;]*;$correo;[^;]*" $RUTA_OBRAS`
				if [[ $ID_CORREO_VALIDOS_OBRA1 -eq 1 || $ID_CORREO_VALIDOS_OBRA2 -eq 1 ]]
				then
					perl Mover_A.pl $RUTA_ARCHIVO $ACEPDIR Recibir_A
					perl Grabar_L.pl Recibir_A "El archivo $archivo de reservas ha sido aceptado"
				else
					perl Mover_A.pl $RUTA_ARCHIVO $RECHDIR Recibir_A
					perl Grabar_L.pl Recibir_A "El archivo $archivo fue rechazado por par id de Obra-correo invalido/inexistente"
				fi
			 
			fi
		elif [[ $TIPO_TEXTO -eq 1 && $INVITADOS_BIEN_FORMADO -eq 1 ]]	
		then
			perl Mover_A.pl $RUTA_ARCHIVO $REPODIR Recibir_A
			perl Grabar_L.pl Recibir_A "El archivo de invitados  $archivo fue aceptado y movido a $REPODIR" 	
		fi
		
 	
	
	done
	CANTIDAD_DE_FICHEROS_EN_ACEPDIR=` ls -A $ACEPDIR | wc -l`
	if [ $CANTIDAD_DE_FICHEROS_EN_ACEPDIR -gt 0 ]
	then
		PID_RESERVAR=$(ps -o pid -C Reservar_A.sh | sed "2q;d")
		if [ "$PID_RESERVAR" == "" ]
		then
			$RUTA_RESERVAR & > /dev/null
			if [ "$PID_RESERVAR" == "" ] #quiero ver si se inicio el Reservar_A.sh o no. No se si tengo que repetir la linea de asignacion de PID_RESERVAR.
			then
				echo " No se ha podido inciar el proceso de Reservas "
			fi
		fi
 	fi	
sleep $TIEMPO
let NUMERO_DE_CICLO=NUMERO_DE_CICLO+1
done
