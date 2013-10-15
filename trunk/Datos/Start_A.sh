#!/bin/bash
 #TODO asignar el path donde estan los scripts
 pathMadre=$GRUPO
 params=$# 
 #TODO validar que el sistema este inicializado
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
		 if  [ "$var" == "" ];  then
			extension=$(echo $archivo | sed 's/.*\(\..*\)$/\1/') 			
			
			if [ $extension == ".pl" ]; then
				perl $archivo
			else
				#echo "$extension"
				$archivo & > /dev/null 	
			fi
			#echo "Arrancado el comando"
			if [ $params -gt 1 ]; then
				perl Grabar_L.pl $2 $3 "Se ejecuta el comando '$1'"
			fi
								
		 else
			if [ $params -gt 1 ]; then
				perl Grabar_L.pl $2 $3 "El comando '$1' ya se encuentra corriendo"
			fi		
		 fi
	 fi
 fi
