.data 
sopa: .asciiz "sopa.txt" 
resusuario: .space 3 #memoria que se utliza para respuesta usuario
yes:  .asciiz "y"	# Caracter y
palabra: .space 100 	#memoria que se utliza para letra del usuario

#mensajes utilizados 
der: .asciiz "\n La palabra se orienta hacia la derecha \n"
izq: .asciiz "\n La palabra se orienta hacia la izquierda \n"
arr: .asciiz "\n La palabra se orienta la arriba \n"
aba: .asciiz "\n La palabra se orienta hacia la abajo \n"
cord: .asciiz "La palabra inicia en: "
fila: .asciiz "\n fila: "
col: .asciiz "\n columna: "
intro: .asciiz 	"\n Ingrese la palabra a buscar en la sopa de letras:\n "
none : .asciiz 	"No se encontro la palabra\n"
pregunta: .asciiz "Quieres buscar otra Palabra?\n(y) para continuar buscando palabras..\n o usa CUALQUIER OTRA para terminar el pregrama\n"					

# memoria destinada para la sopa de letras.
.align 2
archivo: .space 5100		# memoria que se utliza para importar la sopa de letras.
.align 2
archivolimpio: .space 5100 	# memoria que se utliza para almacenar la sopa de letras limpia.
.text

main: 				# main:(Inicio del Programa)
	
	jal	importar	# importa la sopa de letras
otra:
	jal 	leer 		# ejecuta el metodo leer 
	jal	buscar		# ejecuta el metodo buscar
	j 	exit            # ejecuta el metodo salir          

importar:
	#abre el archivo
	li $v0, 13	
	la $a0, sopa 		
	li $a1, 0		
	syscall			
	move $s0, $v0		
	#  lee archivo
	li $v0, 14		
	move $a0, $s0		
	la $a1, archivo		
	li $a2, 5068		
	syscall	
	#limpiar archivo
	la $t1,archivolimpio
	la $v0,archivo	
p_loop:			
	lb $t2,0($v0)
	beq $t2,$zero,chao	#hace finalizar el metodo de limpiar con esta condiccion
	beq $t2,0x20,actind 	#ignora el caracter espacio en blanco
	beq $t2,0x0d,actind	#ignora el caracter de retorno
	sb $t2,0($t1)
	addi $t1,$t1,1
actind:				
	addi $v0,$v0,1		#aumenta el apuntador							
	j p_loop
chao:
	jr $ra	      		

leer:
	#escribe mensaje "intro"
	li $v0, 4		
	la $a0, intro	
	syscall		
	
	#lee la palabra a buscar por el usuario		
	li $v0, 8		
	la $a0, palabra	
	li $a1, 100		
	syscall			
	jr $ra
	
# este metodo se encarga de encontrar las coincidencias de letras en la sopa de letras
buscar:		
	la $t1,archivolimpio	#sopa de letras
	la $s1,palabra		#palabra a buscar
	li $a2,1		#Filas
	li $a3,1		#Columnas
	lb $t3,0($s1)		
	li $t9,0		#con este registro sabremos como se orienta la palabra a buscar
loopsopa:	
	lb $t2,0($t1)	
	beqz $t2,avanza		#hace un salto a "avanza" si hay un zero en el registro
	beq $t2,$t3,arriba	#si hay coincidencia comienza... 	
	addi $t1,$t1,1		#verificando por arriba para luego...
	addi $a3,$a3,1		#seguir con las otras direcciones.
	bne $t2,0x0a,loopsopa	#si hay un salto de linea, no saltara a loopsopa
	addi $a2,$a2,1		#aumentamos las filas
	li $a3,1 		#reiniciamos las columnas
	j loopsopa
	
#comprueba las coincidencias de forma vertical hacia arriba	 
arriba:	
	move $s3,$t1	#copia sopa en s3
	move $s4,$s1	#copia palabras usuario a s4
	move $s5,$a2	#copia filas a s5
arribaloop:	
	addi $s3,$s3,-51		#nos movemos en la memoria
	addi $s4,$s4,1			#movemos el apuntador de la palabra a buscar
	addi $s5,$s5,-1			#reducimos las filas en 1
	lb $t4,0($s3) 			#caracter sopa
	lb $t5,0($s4)			#caracter palabra usuario
	li $t9,1			#con este registro sabremos como se orienta la palabra a buscar
	beq $t5,0x0a,imprimirexitoso	#cumple va a imprimir
	beq $s5,0,abajo			#si cumple pasa a la otra busqueda
	beq $t4,$t5,arribaloop		#se repite el ciclo

#comprueba las coincidencias de forma vertical hacia abajo
abajo:			
	move $s3,$t1 	#copia sopa en s3
	move $s4,$s1	#copia palabras usuario a s4
	move $s5,$a2	#copia filas a s5
	
abajoloop:		
	addi $s3,$s3,51			#nos movemos en la memoria
	addi $s4,$s4,1			#movemos el apuntador de la palabra a buscar
	addi $s5,$s5,1			#aumentamos las filas en 1
	lb $t4,0($s3) 			#caracter sopa
	lb $t5,0($s4)			#caracter palabra usuario
	li $t9,2			#con este registro sabremos como se orienta la palabra a buscar
	beq $t5,0x0a,imprimirexitoso 	#cumple va a imprimir
	beq $s5,51,derecha    		#si cumple pasa a la otra busqueda
	beq $t4,$t5,abajoloop		#cumple se repite el ciclo
derecha: 
	move $s3,$t1		#copia la sopa en s3
	move $s4,$s1		#copia palabra usuario a s4
	move $s6,$a3		#copia columnas a s6
derechaloop:
	addi $s3,$s3,1			#nos movemos en la memoria
	addi $s4,$s4,1			#movemos el apuntador de la palabra a buscar
	addi $s6,$s6,1			#aumentamos las columnas en 1
	lb $t4,0($s3) 			#caracter sopa
	lb $t5,0($s4)			#caracter palabra usuario
	li $t9,3			#con este registro sabremos como se orienta la palabra a buscar
	beq $t5,0x0a,imprimirexitoso 	#cumple hacia derecha todo
	beq $t4,0x0a,izquierda       	#dado que no cumple pasa a la otra busqueda
	beq $t4,$t5,derechaloop		#si se cumple, repetimos derechaloop
izquierda:
	move $s3,$t1		#copia la sopa en s3
	move $s4,$s1		#copia palabra usuario a s4
	move $s6,$a3		#copia columnas a s6
izquierdaloop:
	addi $s3,$s3,-1			#nos movemos en la memoria
	addi $s4,$s4,1			#movemos el apuntador de la palabra a buscar
	addi $s6,$s6,-1			#reducimos las columnas en 1
	lb $t4,0($s3) 			#caracter sopa
	lb $t5,0($s4)			#caracter palabra usuario
	li $t9,4			#con este registro sabremos como se orienta la palabra a buscar
	beq $t5,0x0a,imprimirexitoso 	#cumple hacia derecha todo
	beq $t4,0x0a,preloopsopa      	#si encuentra un salto de linea saltaremos a preloopsopa
	beq $t4,$t5,izquierdaloop	#si se cumple, repetimos izquierdaloop
preloopsopa:
	addi $t1,$t1,1		#aumentamos el apuntador de la sopa de letras
	addi $a3,$a3,1		#aumentamos las columnas
	j loopsopa	 	
	
#con este metodo sabremos verificamos como se orienta la palabra que se busco
imprimirexitoso:	
	beq $t9, 1, imparri	#imprime con orientacion arriba
	beq $t9, 2, impaba	#imprime con orientacion abajo
	beq $t9, 3, impder	#imprime con orientacion derecha
	beq $t9, 4, impizq	#imprime con orientacion izquierda

#con este metodo imprime con orientacion arriba	
imparri: 
 	li $v0, 4
 	la $a0, cord
 	syscall
 	
 	li $v0, 4
 	la $a0, fila
 	syscall 	
 	li $v0, 1
 	la $a0, ($a2)
 	syscall
 	
 	li $v0, 4
 	la $a0, col
 	syscall 	
 	li $v0, 1
 	la $a0, ($a3)
 	syscall
 	
 	li $v0, 4
	la $a0, arr
 	syscall
 	j exito # va hacia metodo que pregunta al usuario si quiere continuar
 
#con este metodo imprime con orientacion abajo	
impaba: 
	li $v0, 4
 	la $a0, cord
 	syscall
 	
 	li $v0, 4
 	la $a0, fila
 	syscall 	
 	li $v0, 1
 	la $a0,($a2)
 	syscall
 	
 	li $v0, 4
 	la $a0, col
 	syscall 	
 	li $v0, 1
 	la $a0,($a3)
 	syscall
 	
 	li $v0, 4
	la $a0, aba
 	syscall
 	j exito # va hacia metodo que pregunta al usuario si quiere continuar
 
#con este metodo imprime con orientacion derecha
impder: 
	li $v0, 4
 	la $a0, cord
 	syscall
 	
 	li $v0, 4
 	la $a0, fila
 	syscall 	
 	li $v0, 1
 	la $a0,($a2)
 	syscall
 	
 	li $v0, 4
 	la $a0, col
 	syscall 	
 	li $v0, 1
 	la $a0,($a3)
 	syscall
 	
 	li $v0, 4
	la $a0, der
 	syscall
 	j exito # va hacia metodo que pregunta al usuario si quiere continuar

#con este metodo imprime con orientacion izquierda	
impizq: 
	li $v0, 4
 	la $a0, cord
 	syscall
 	
 	li $v0, 4
 	la $a0, fila
 	syscall 	
 	li $v0, 1
 	la $a0, ($a2)
 	syscall
 	
 	li $v0, 4
 	la $a0, col
 	syscall 	
 	li $v0, 1
 	la $a0, ($a3)
 	syscall
 	
 	li $v0, 4
	la $a0, izq
 	syscall
 	j exito
 	
#este metodo imprime  un mensaje si no se encontro la palabra	
avanza:
     	li $v0, 4
 	la $a0, none
 	syscall

#este metodo pregunta al usuario si quiere seguir buscando mas palabras
exito: 	
	li $v0,4
 	la $a0,pregunta
 	syscall
 	li $v0,8
 	la $a0,resusuario
 	li $a1,3
 	syscall
 	
 	la $t1, resusuario	#llevamos la respuesta al usuario al registro t1
    	add $s3, $t1, $zero	
    	lb $t6, 0($t1)
 	
 	lb $t8, yes    		#cargamos el caracter "y"
 	beq $t6, $t8,otra 	#si el usurio escribe "y" el programa continuara...
 	j exit			# de lo contrario terminara
 					
#para terminar el programa						
exit: 	li $v0, 10		
	syscall      
        
        
        
        
        
        
        
        
        
