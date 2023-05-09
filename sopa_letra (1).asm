.data 
sopa: .asciiz "sopa.txt"
der: .asciiz "\n La palabra se orienta hacia la derecha \n"
izq: .asciiz "\n La palabra se orienta hacia la izquierda \n"
arr: .asciiz "\n La palabra se orienta la arriba \n"
aba: .asciiz "\n La palabra se orienta hacia la abajo \n"
cord: .asciiz "La palabra inicia en: "
fila: .asciiz "\n fila: "
col: .asciiz "\n columna: "
resusuario: .space 3 #memoria que se utliza para respuesta usuario
yes:  .asciiz "y"	# Caracter y
palabras: .space 100 	#memoria que se utliza para letra del usuario
#mensajes 
intro: .asciiz 	"\n Ingrese la palabra a buscar en la sopa de letras:\n "
none : .asciiz 	"No se encontro la palabra\n"
pregunta: .asciiz "Quieres buscar otra Palabra?\n(y) para continuar buscando palabras\nusa CUALQUIER OTRA paterminar\n"					

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
	beq $t2,$zero,chao
	beq $t2,0x20,actind
	beq $t2,0x0d,actind
	sb $t2,0($t1)
	addi $t1,$t1,1
actind:				
	addi $v0,$v0,1									
	j p_loop
chao:
	jr $ra		
      	

leer:
	#escribe mensaje intro
	li $v0, 4		
	la $a0, intro	
	syscall		
	
	#lee la palabra a buscar por el usuario		
	li $v0, 8		
	la $a0, palabras	
	li $a1, 100		
	syscall			
	jr $ra

buscar:				# este metodo se encarga de encontrar las coincidencias de letras en la sopa de letras
	
	la $t1,archivolimpio	#sopa de letras
	la $s1,palabras		#palabra a buscar
	li $a2,1		#Filas
	li $a3,1		#Columnas
	lb $t3,0($s1)		
	li $t9,0
loopsopa:	
	lb $t2,0($t1)	
	beqz $t2,avanza	
	beq $t2,$t3,arriba	#si hay coincidencia comienza... 	
	addi $t1,$t1,1		#verificando por arriba para luego...
	addi $a3,$a3,1		#seguir con las otras direcciones.
	bne $t2,0x0a,loopsopa
	addi $a2,$a2,1
	li $a3,1 
	j loopsopa
	
	 	 
arriba:			#comprueba las coincidencias de forma vertical hacia arriba
	move $s3,$t1	#copia sopa en s3
	move $s4,$s1	#copia palabras usuario a s4
	move $s5,$a2	#copia filas a s5
arribaloop:	
	addi $s3,$s3,-51	#nos movemos en la memoria
	addi $s4,$s4,1		
	addi $s5,$s5,-1	
	lb $t4,0($s3) 		#caracter sopa
	lb $t5,0($s4)		# caracter palabra usuario
	li $t9,1
	beq $t5,0x0a,imprimirexitoso	#cumple va a imprimir
	beq $s5,0,abajo			#se va a verificar
	beq $t4,$t5,arribaloop		#se repite el ciclo

abajo:			#comprueba las coincidencias de forma vertical hacia abajo
	move $s3,$t1 	#copia sopa en s3
	move $s4,$s1	#copia palabras usuario a s4
	move $s5,$a2	#copia filas a s5
	
abajoloop:		
	addi $s3,$s3,51		#nos movemos en la memoria
	addi $s4,$s4,1
	addi $s5,$s5,1	
	lb $t4,0($s3) 		#caracter sopa
	lb $t5,0($s4)		# caracter palabra usuario
	li $t9,2
	beq $t5,0x0a,imprimirexitoso 	#cumple va a imprimir
	beq $s5,51,derecha    		#dado que no cumple pasa a la otra busqueda
	beq $t4,$t5,abajoloop		#cumple se repite el ciclo
derecha: 
	move $s3,$t1
	move $s4,$s1
	move $s6,$a3
derechaloop:
	addi $s3,$s3,1
	addi $s4,$s4,1
	addi $s6,$s6,1	
	lb $t4,0($s3) 	#caracter sopa
	lb $t5,0($s4)	# caracter palabra usuario
	li $t9,3
	beq $t5,0x0a,imprimirexitoso #cumple hacia derecha todo
	beq $t4,0x0a,izquierda       #dado que no cumple pasa a la otra busqueda
	beq $t4,$t5,derechaloop	
izquierda:
	move $s3,$t1
	move $s4,$s1
	move $s6,$a3
izquierdaloop:
	addi $s3,$s3,-1
	addi $s4,$s4,1
	addi $s6,$s6,-1	
	lb $t4,0($s3) 	#caracter sopa
	lb $t5,0($s4)	# caracter palabra usuario
	li $t9,4
	beq $t5,0x0a,imprimirexitoso #cumple hacia derecha todo
	beq $t4,0x0a,preloopsopa         #dado que no cumple pasa a la otra busqueda
	beq $t4,$t5,izquierdaloop
preloopsopa:
	addi $t1,$t1,1
	addi $a3,$a3,1	
	j loopsopa	#no encontro la palabra  
	
imprimirexitoso:	
	beq $t9, 1, imparri
	beq $t9, 2, impaba
	beq $t9, 3, impder
	beq $t9, 4, impizq	
imparri: 
#imprimimos s5 y a3
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
impaba: 
#imprimimos s5 y a3
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
impder: 
#imprimimos s6 y a2
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
 	
impizq: 
#imprimimos s6 y a2
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
avanza:
     	li $v0, 4
 	la $a0, none
 	syscall
exito: 	
	li $v0,4
 	la $a0,pregunta
 	syscall
 	li $v0,8
 	la $a0,resusuario
 	li $a1,3
 	syscall
 	
 	la $t1, resusuario	
    	add $s3, $t1, $zero
    	lb $t6, 0($t1)
 	
 	lb $t8, yes
 	beq $t6, $t8,otra 
 	j exit
 					
						
exit: 	li $v0, 10		# Constante para terminar el programa
	syscall      
        
        
        
        
        
        
        
        
        
