#!/bin/bash
 #TODO asignar el path donde estan los scripts
 pathMadre=$GRUPO
 params=$# 
 #echo $params
 if  [ $params -ne 3 ] && [ $params -ne 1 ]; then
	echo "Numero incorrecto de parametros"
 else
	 archivo="$1"
	 if  [ ! -f "$archivo" ] ; then 
		if [ $params -gt 1 ]; then
			perl Grabar_L.pl $2 $3 "No se encontro el comando '$1'"
		fi	
	 	#echo "Nombre de comando invalido"
	 else
		 var=$(ps -o pid -C $1 | sed "2q;d")
		 if  [ "$var" == "" ]; then
			if [ $params -gt 1 ]; then
				perl Grabar_L.pl $2 $3 "El comando '$1' no se encuentra corriendo aun"
			fi	
		    	#echo "El comando '$1' no se encuentra corriendo aun"
		 else
			kill -9 $var > /dev/null 
			#echo "Lo hice bosta"
			if [ $params -gt 1 ]; then
				perl Grabar_L.pl $2 $3 "El comando '$1' ha sido parado"
			fi	


		 fi
	 fi
 fi
