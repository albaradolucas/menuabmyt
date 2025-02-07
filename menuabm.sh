#!/bin/bash

##########################################################################################
#                                                                                        #
#  Owner: devilssj018                                                                    #
#  Date: 05/02/25                                                                        #
#  Objetive: Gestión de Usuarios, Grupos y Permisos en Linux                             #
#  Tasks:                                                                                #
#       + Crear un script para la gestión de usuarios en Linux.                          #
#       + Permitir la creación, modificación y eliminación de usuarios.                  #
#       + Administrar permisos y grupos de usuarios.                                     #
#                                                                                        #
#  Requirements:                                                                         #
#       + El script debe permitir agregar usuarios con su respectiva passwd              #
#       + Debe permitir modificar usuarios existentes (cambiar grupo, contraseña, etc).  #
#       + Debe permitir eliminar usuarios con opción de eliminar su directorio home      #
#       + Debe gestionar permisos en archivos y directorios.                             #
#       + Debe propocionar una interfaz de línea de comandos amigable con menús.         #
#                                                                                        #
##########################################################################################

clear

while true; ## << mientras que sea verdadero  
do ## vamos a hacer esto
clear

echo ""
echo "#################################################################################"
echo "#							  			#"
echo "#		Menú de gestión de Usuarios, Grupos y Pemisos en Linux		#"
echo "#										#"
echo "#		Hora: $(date +%H:%M) 							#"
echo "#		Usuario: $(whoami)							#"
echo "#										#"
echo "#################################################################################"
echo ""
echo ""
echo "1) Crear usuario nuevo"
echo "2) Modificar permisos de un usuario sobre archivos o directorios"
echo "3) Modificar password de un usuario"
echo "4) Modificar grupo de un usuario"
echo "5) Eliminar un usuario"


read -p "Ingrese la opción [de 1 a 5] o [s/S] para salir: " opcion


wrk_fnt() {
	echo ""
	echo -n "[ "

	for ((i=0; i<10; i++)) do
		printf "+ "
		sleep 1
	done
	echo "]"
	echo ""
}


case $opcion in
	1) ## agregar un usuario
		clear
		echo ""
		read -p "Ingresar el nombre del nuevo usuario (6 ch. max): " new_user

		if [ -z "$new_user" ]; then ## << SI (if) está vacía (-z) la variable $new_user; ENTONCES (then) 
			echo "Debe ingresar un nombre para generar un usuario."
			sleep 2 ## << sleep = dormir , ESPERE 2 segundos 
			return
		fi
		if [ "${#new_user}" -gt 6 ]; then ## -gt greater than = MAYOR QUE
			sleep 1
			echo ""
			echo "El nombre de usuario no puede ser mayor a 6 dígitos."
			sleep 2
		else
			if ! id "$new_user" >/dev/null 2>&1; then
				sleep 1
				while true; do
					echo ""
					read -p "¿Está seguro de crear el usuario '$new_user'? [y/n]: " answer

					if [ -z "$answer" ]; then
						sleep 1
						echo "Debe ingresar una respuesta."
						break
					fi

					if [ "$answer" = "n" ] || [ "$answer" = "N" ]; then # < || > OR = o es una cosa O la otra
						sleep 2
						echo ""
						echo "Se canceló sin errores la creación del usuario '$new_user'."
						sleep 2
						break # < parar - frenar 

					elif [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then # O SI
						if sudo useradd -m "$new_user" 2>/tmp/err.log ; then # (if) SI la exec del comando está ok
							sleep 1
							echo ""
							echo "Se ha creado con éxito el usuario '$new_user', con el directorio '/home/$new_user'."
							sleep 2
							
							# setear la clave del nuevo usuario en 123456
							echo "$new_user:123456" | sudo chpasswd

							sudo passwd -e "$new_user" > /dev/null 2>&1
							echo ""
							echo "El usuario deberá ingresar con '123456' en el primer ingreso, y le pedirá cambio."
							sleep 2
							break
						else ## sino
							sleep 2
							echo ""
							echo "Hubo un error al crear el usuario '$new_user'."
							echo ""
							cat /tmp/err.log | tail -n 3
							sleep 2
							break
						fi
					else # o sino
						sleep 2
						echo ""
						echo "Opción no válida. Debes ingresar [y] o [n]."
						sleep 2
					fi
				done
			else
				sleep 1
				echo ""
				echo "El usuario '$new_user' ya existe."
				sleep 2
			fi
		fi
	;;
	
	2) ## << modificar permisos de usuarios sobre archivos o directorios en nuestro sistema / modificar el owner, (propietario)
		clear
		read -p "Ingresar el nombre del archivo o directorio que quiera modificar: " mdfy_answer

		if [ -z "$mdfy_answer" ]; then
			echo "Debe ingresar un archivo o directorio para modificar."
			sleep 2
		else
			read -p "Ingresar la ruta del directorio absoluta, separa por '/': " mdfy_route

			if [ -z "$mdfy_route" ]; then
				echo "Debe ingresar una ruta para buscar."
				sleep 2
			else
				mdfy_full_path=$(find "$mdfy_route" -iname "$mdfy_answer" 2>/tmp/err.log | head -n 1) ## head = cabeza (lee de arriba a abajo), tail = cola, (lee de abajo a 															arriba)
				if [ -z "$mdfy_full_path" ]; then
					echo ""
					echo ""
					echo "No se encontró el archivo o directorio '$mdfy_answer' en '$mdfy_route'."
					sleep 2
				else

					clear
					echo ""
					echo "1) Cambiar Owner (Propietario)"
					echo "2) Modificar permisos"
					echo ""
					read -p "Seleccione una opción [de 1 a 2 ] o [s/S] para salir: " mdfy_choice


					case "$mdfy_choice" in
						1) ## cambiar de propietario
							clear
							echo ""
							read -p "Ingrese el nuevo propietario (user): " mdfynw_owner
							if id "$mdfynw_owner" >/dev/null 2>/tmp/err.log; then
								clear
								echo ""
								sleep 1
								sudo chown "$mdfynw_owner" "$mdfy_full_path"
								wrk_fnt	
								echo "Se cambió el propietario de '$mdfy_answer' a '$mdfynw_owner' satisfactoriamente."
								sleep 2
							else
								echo ""
								echo "El usuario '$mdfynw_owner' no existe."
								sleep 2
							fi
							;;
						2) ## modificar permisos de archivo o directorio
							read -p "Ingrese los nuevos permisos en formato OCTAL (ej 644): " mdfy_prms

							if [[ ! "$mdfy_prms" =~ ^[0-7]{3,4}$ ]]; then ## 0 => 7, 4 read 2 write 1 ex => suma da 7, 3 prms nr 4 prms esp. user, groups, oth
								echo ""
								echo "Debe ingresar permisos válidos, en formato OCTAL (ej 644 / 755)."
								sleep 2
							else
								clear
								sleep 1
								echo ""
								sudo chmod "$mdfy_prms" "$mdfy_full_path" 2>/tmp/err.log
								echo "Se modificaron correctamente los permisos de '$mdfy_answer'."
								sleep 2
							fi
							;;
						s|S)
							clear
							return
							;;
						*)
							echo "Opción inválida."
							sleep 2
							;;
					esac
				fi
			fi
								
								
		fi

	;;
	3) ## modificar password de un usuario > blanquear la clave y setearla a 123456
		clear
		echo ""
		
		read -p "Ingrese el username que se desea modificar la clave: " mdfypd_user

		if [ -z "$mdfypd_user" ]; then
			echo ""
			echo "Debe ingresar un username para modificar."
			sleep 2
		fi

		if id "$mdfypd_user" >/dev/null 2>&1; then
			sleep 2
			while true; do
				echo ""
				read -p "¿Está seguro de blanquear la clave del usuario '$mdfypd_user'? [y/n]: " mdfypd_answer

				if [ "$mdfypd_answer" = "n" ] || [ "$mdfypd_answer" = "N" ]; then
					sleep 1
					echo ""
					echo "No se realizó ninguna modificación en el usuario '$mdfypd_user'."
					sleep 2
					break
				elif [ "$mdfypd_answer" = "y" ] || [ "$mdfypd_answer" = "Y" ]; then
					sleep 1
					echo ""
					echo "$mdfypd_user:123456" | sudo chpasswd # user:password
					sudo passwd -e "$mdfypd_user" > /dev/null 2>&1 # expired expirado
					echo ""
					echo "Se modificó la clave del usuario '$mdfypd_user' a 123456." 
					echo ""
					echo "Le pedirá cambio en el primer ingreso."
					sleep 3
					break
				else
					sleep 1
					echo ""
					echo "Opción no válida, debes ingresar [y] o [n]"
					sleep 2
				fi
			done
		else
			sleep 2
			echo ""
			echo "El usuario '$mdfypd_user' no existe."
			sleep 2
		fi

		;;
	s|S)
		clear
		exit
		;;
	*)
		echo "Opción inválida."
		sleep 2
		;;
	esac
done
