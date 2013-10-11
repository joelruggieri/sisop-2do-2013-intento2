ARRIDIR="/home/joel/arribos/"
ACEPDIR="/home/joel/aceptados/"
REPODIR="/home/joel/repositorio"
RECHDIR="/home/joel/rechazados/"
MAEDIR="/home/joel/maestros/"
ARCHIVOS_SALAS="salas.mae"
ARCHIVO_OBRAS="obras.mae"
RUTA_SALAS=$MAEDIR$ARCHIVO_SALAS
RUTA_OBRAS=$MAEDIR$ARCHIVO_OBRAS
NUMERO_DE_CICLO=1
TIEMPO=60 # en segundos

while (true)
do
	perl Grabar_L.pl Recibir_A "Ciclo Numero $NUMERO_DE_CICLO"
	for archivo in `ls $ARRIDIR`
	do
		RUTA_ARCHIVO=$ARRIDIR$archivo
		TIPO_DE_TEXT0="`file $RUTA_ARCHIVO`"
		BIEN_FORMADO=`echo $archivo | grep -c '^[0-9]\+-[^-]*-[^- ]*$'`
		TIPO_TEXTO=`echo $TIPO_DE_TEXTO | grep -c 'text'`
		if [ $TIPO_TEXTO -eq 0 ] -o [$BIEN_FORMADO -eq 0]
		then
			perl Mover_A.pl $RUTA_ARCHIVO $RECHDIR Recibir_A
		elif [ $TIPO_TEXTO -eq 1 ] -a [ $BIEN_FORMADO -eq 1 ]
		then
			id=`echo $archivo | cut -d "-" -f 1`
			correo=`echo $archivo | cut -d "-" -f 2`
			if [ `expr $id % 2` -eq 0 ]
			then
				ID_CORREO_VALIDOS_SALA=`grep '$id-$correo' $RUTA_SALAS` #consultar este grep
			elif [ `expr $id % 2` -eq 1 ]
			then
				ID_CORREO_VALIDOS_OBRAS=`grep '$id-$correo' $RUTA_OBRAS` #consultar este grep
			fi
		fi
		
 	
	
	done
sleep $TIEMPO
let NUMERO_DE_CICLO=NUMERO_DE_CICLO+1
done
