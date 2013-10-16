#!/bin/bash
 #TODO asignar el path donde estan los scripts
 pathMadre=$GRUPO
 params=$# 

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
	
	if [[ ${1:-existe} == "existe" ]]; then
		retorno=1
		return 0
	fi
	return 1
}

function main {
 #echo $params
 if  [ $params -ne 3 ] && [ $params -ne 1 ]; then
	echo "Numero incorrecto de parametros"
 else

	 retorno=0
	 archivo="$1"
	 estaAmbienteInicializado
	 if [[ $retorno -ne 0 ]]; then	
		
		echo "No se encuentra inicializado el ambiente"
		return 1
	 fi
	 if  [ ! -f "$archivo" ] ; then 
		if [ $params -gt 1 ]; then
			perl Grabar_L.pl $2 $3 "No se encontro el comando $1"
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
				perl Grabar_L.pl $2 $3 "Se ejecuta el comando $1"
			fi
								
		 else
			if [ $params -gt 1 ]; then
				perl Grabar_L.pl $2 $3 "El comando $1 ya se encuentra corriendo"
			fi		
		 fi
	 fi
 fi

}

main $@
