.data 
sopa: .asciiz "sopa.txt"
der: .asciiz "La palabra est� hacia la derecha"
izq: .asciiz "La palabra est� hacia la izquierda"
arr: .asciiz "La palabra est� hacia la arriba"
aba: .asciiz "La palabra est� hacia la abajo"
cord: .asciiz "La palabra inicia en "
fila: .asciiz "\n fila: "
col: .asciiz "\n columna: "
none : .asciiz "\n No se encontro la palabra\n"
otra : .asciiz "\n Quieres buscar otra Palabra?\ny. ppara continuar buscando palabras\nn. para no buscar mas palabras\n"

#mensajes 
intro: .asciiz 		"\n Ingrese la palabra a buscar en la sopa de letras:\n "
palabras: .space 100 	# direcci�n de las palabras que escribir� el usuario
					
.align 2
archivo: .space 5100	# direcci�n de la url del archivo ingresada por el user
.align 2
archivolimpio: .space 5100 

.text

main: 						# Subrutina: main (Inicio del Programa)
	
	jal	importar
	jal 	leer 			# rutina principal, jump and link 
	jal	buscar
	j 	exit    

                  

importar:
	#Open file
	li $v0, 13	
	la $a0, sopa		
	li $a1, 0		
	syscall			
	move $s0, $v0		
	#  Read file
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
	li $v0, 4		#\
	la $a0, intro	# Write message
	syscall			#/
	li $v0, 8		#\
	la $a0, palabras	# \
	li $a1, 100		#  Read word to find
	syscall			# /
	jr $ra

buscar:
	la $t1,archivolimpio
	la $s1,palabras
	li $a2,1	#Filas
	li $a3,1	#Columnas
	lb $t3,0($s1)
	li $t9,0
loopsopa:	
	lb $t2,0($t1)	
	beqz $t2,avanza	
	beq $t2,$t3,arriba		
	addi $t1,$t1,1
	addi $a3,$a3,1
	bne $t2,0x0a,loopsopa
	addi $a2,$a2,1
	li $a3,1 
	j loopsopa
	
avanza:
     #mesaje fallido 
     
     	 	 
arriba:	
	move $s3,$t1	#copia sopa en s3
	move $s4,$s1	#copia palabras usuario a s4
	move $s5,$a2	#copia filas a s5
arribaloop:	
	addi $s3,$s3,-50
	addi $s4,$s4,1
	addi $s5,$s5,-1	
	lb $t4,0($s3) 	#caracter sopa
	lb $t5,0($s4)	# caracter palabra usuario
	li $t9,1
	beq $t5,0x0a,imprimirexitoso
	beq $s5,0,abajo
	beq $t4,$t5,arribaloop

abajo:
	move $s3,$t1 	#copia sopa en s3
	move $s4,$s1	#copia palabras usuario a s4
	move $s5,$a2	#copia filas a s5
abajoloop		
	addi $s3,$s3,50
	addi $s4,$s4,1
	addi $s5,$s5,1	
	lb $t4,0($s3) 	#caracter sopa
	lb $t5,0($s4)	# caracter palabra usuario
	li $t9,2
	beq $t5,0x0a,imprimirexitoso #cumple hacia abajo todo
	beq $s5,51,derecha    		#dado que no cumple pasa a la otra busqueda
	beq $t4,$t5,abajoloop
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
	beq $s6,51,izquierda         #dado que no cumple pasa a la otra busqueda
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
	beq $s6,0,avanza         #dado que no cumple pasa a la otra busqueda
	beq $t4,$t5,derechaloop
	#no encontro la palabra  
imprimirexitoso:	
	beq $t9, 1, imparri
	beq $t9, 2, impaba
	beq $t9, 3, impder
	beq $t9, 4, impizq	
imparri: 
#imprimimos s5 y a3
impaba: 
#imprimimos s5 y a3
impder: 
#imprimimos s6 y a2
impizq: 
#imprimimos s6 y a2

			
				
						
exit: 	li $v0, 10		# Constante para terminar el programa
	syscall      
        
        
        
        
        
        
        
        
        
