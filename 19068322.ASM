; Este programa es un creador de archivos DUMP. Hace un vaciado de un archivo txt   
; 
;        
;                         
;---------------------------------------------------------------------------------
;                      Instituto Tecnologico de Costa Rica                    
;                      
;                      Ingeneria en computacion Plan 411
;
;                      Arquitectura De Computadores
;
;                      Kirstein Gatjens
;
;                      Andrew Jose Gutierrez Castro
;
;                      Carne: 2019068322
;
;                      Grupo: 2
;---------------------------------------------------------------------------------

;*********************************************************************************
;                     Manual de Usuario
;
;    Primero en DOSBOX correr TASM 19068322.asm
;    Seguidamente ejecutar  TLINK 19068322.asm
;    Finalmente inicializar 19068322.EXE 
;    Por ejemplo: ejecutar 19068322
;
;                 A:\TDUMP>19068322.exe *nombrearchivo*.txt
;				  Hola Mundo
;				  Solo debe ejecutar el programa y dar el path            
;                 Ejemplo: 
;					      	19068322.exe archivo.txt
;				  Archivos cerrados exitosamente
;
;*********************************************************************************
;
;---------------------------------------------------------------------------------
;Partes:
;       A: Leer datos de la linea de comandos
;       B: Leer el archivo txt
;       C: Crear el vaciado y escribirlas
;		D: Contabilizar las estadisticas
;		E: Escribir las estadisticas y escribirlas
;Estado:
; A = Concluida con exito             B = Concluida con problemas especificos
; C = Concluida con problemas mayores D = Diseño del algoritmo pero no inicia
; E = No implementado
;----------------------------------------------------------------------------------
;	Partes importantes a considerar su estado:
;	+Leer datos de la linea de comandos ESTADO: A (getPath)
;	
;	+Leer el archivo txt ESTADO: A(lecturaArchivo)
;   
;	+Crear el vaciado y escribirlas ESTADO: A (escribirDUMP)
;
;	+Contabilizar las estadisticas ESTADO:A (Estadisticas)

;	+Escribir las estadisticas y escribirlas ESTADO: A (escribirStats)
;
;-----------------------------------------------------------------------------------


printENTER MACRO
    push ax
    push dx

    mov dl, 10
    mov ah, 02h
    int 21h
    mov dl, 13
    int 21h

    pop dx
    pop ax
ENDM

printBufferDUMP MACRO
	PUSH ax
	PUSH dx
	MOV ah, 09h
    lea dx, bufferDMP
    int 21h
    POP dx
    POP ax
ENDM printBufferDUMP

printBuffer macro 
	PUSH ax
	PUSH dx
	mov ah, 09h
	lea dx, buffer 
	int 21h
	POP dx
	POP ax
endm printBuffer

printBufferStats macro 
	PUSH ax
	PUSH dx
	mov ah, 09h
	lea dx, bufferStats
	int 21h
	POP dx
	POP ax
endm printBufferStats

printAcercaDe macro
	PUSH ax
	PUSH dx
	MOV ah, 09h
	lea dx, AcerdaDe
	int 21h
	POP dx
	POP ax
endm printAcercaDe

datos segment

  Rotulo db "Hola Mundo$"
  msgError db "Error$"
  msgErrorLectura db "Error en la lectura del archivo de origen$"
  msgErrorDump db "Error en crear el archivo .DMP$"
  msgCerradoExitoso db "Archivos cerrados exitosamente$"
  AcerdaDe db "Solo debe ejecutar el programa y dar el path.",10,13,7,"EJEMPLO:",10,13,7,"19068322.exe A:\Archivos\TDUMP.txt",10,13,7,'$'

  errorLectOdump db 0 ; 1 error lectura, 2 error DUMP
  ;path db "entrada.DMP",0
  pathLectura db 257 DUP(0), '$'
  largoPath db 0
  handleLectura dw ?
  pathDUMP db 256 DUP(0), '$'
  endDMP db ".dmp"
  handleDMP dw 0
  char db ?

  buffer db 512 DUP(0),0,'$'
  indiceBuffer dw 0
  bytesBufferLeidos dw 0

  bufferDMP db 64 DUP(0), '$'
  bufferStats db "Estadisticas ", 13, '$';13 DUP(0)
  contadorPosDMP dw 0

  contadorPosAscii db ?
  archivoCont db 128
  termineDeLeer db 0
  bufferHexPrint db 0,0,0,0 ,'$'

  quot dd 0; para conversion de binADec en Array
  rmdr dw 0; para conversion de binADec en Array
  dvsr dw 0
  numb dd 0  

  vectorAsciiz db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255
  vectorAscCounter dw 256 DUP(0)

datos endS

pila segment stack 'stack'

	dw 256 dup(?)
pila endS



codigo segment

     assume cs:codigo,ds:datos,ss:pila

estadisticas proc near
	;este procedimiento toma el buffer y le suma los codigo asciiz a
	;vectorAscCounter
	PUSH ax
	PUSH bx
	PUSH cx
	PUSH si 
	lea si, buffer
	MOV cx, bytesBufferLeidos
	MOV ax, cx

	cicloEstadisticas:
		XOR ax, ax
		XOR bx, bx
		MOV al, 2
		MOV bl, byte ptr[si]
		MUL bl
		MOV bx, ax
		INC word ptr vectorAscCounter[bx]
		INC si
	LOOP cicloEstadisticas
	POP si
	POP cx
	POP bx
	POP ax
	ret
estadisticas endp

escribirStats proc near
	PUSH ax
	PUSH bx
	PUSH cx
	PUSH dx
	PUSH di
	PUSH si
	XOR cx, cx
	XOR bx, bx
	
	JMP salirPrintEstadisticas
	cicloPrintEstadisticas:
		;este es solo para imprimir las estadisticas
		CMP word ptr vectorAscCounter[bx], 0
		JA printStats
		JMP noPrintStas
		printStats:
			XOR ax, ax
			MOV dh, 2
			MOV ax, bx
			div dh
			MOV di, ax
			MOV ah, 02h
			MOV dl, vectorAsciiz[di]
			int 21h
		noPrintStas:
			ADD bx, 2
			CMP bx, 512
			JAE salirPrintEstadisticas 
			JMP cicloPrintEstadisticas
	salirPrintEstadisticas:
	
	cicloWriteEstadisticas:
	
	CMP word ptr vectorAscCounter[bx], 0
	JA StatsWrite
	JMP noWrite
	StatsWrite:
		CALL cleanBufferStats
		lea di, bufferStats
		;limpiar el buffer de las estadisticas
		MOV ax, bx
		
		mov cl, 2 ; dividir entre 2 pues el bx va de 2 en 2 por ser word
		div cl    ;el arrayCounter el arrays Asciiz es byte osea la mitá
		MOV si, ax; bien dividido y REcalculado papá

		MOV dl, [vectorAsciiz+si]
		MOV byte ptr [di], dl
		INC di
		;Se pone la letra en Asciiz en el bufferStats
		MOV byte ptr [di], " "
		INC di
		;el espacio

		MOV al, [vectorAsciiz+si]
		XOR ah, ah
		PUSH bx 	
		MOV bx, 16
		;Aca se va a poner su numer en haexadecimal representado en Asciiz
		CALL convertirnumBaseN
		POP bx

		MOV ah, [bufferHexPrint+2]
		MOV al, [bufferHexPrint+3]
		;Se ponen los dos numero en hexadecimal en el buffer
		
		CMP ah, 0
		JNE noEsCeroEscribirStatsMSB
		ADD ah, 30h
		;Aqui solo reviso si uno de ellos es cero para ponerlo como
		;un cero Asciiz o sea 0 -> "0"
		noEsCeroEscribirStatsMSB:
			CMP al, 0
			JNE noEsCeroEscribirStatsLSB
			ADD ah, 30h
		noEsCeroEscribirStatsLSB:
			MOV byte ptr[di], ah
			INC di
			MOV byte ptr[di], al
			INC di
			MOV byte ptr [di], " "
			INC di

		MOV al, [vectorAsciiz+si]
		XOR ah, ah
		;Con este metodo pongo el valor de la letra en decimal
		;y me lo guarda en el di
		CALL printAxToDi
		
		MOV dl, " "
		MOV byte ptr[di], dl
		INC di
		;un espacio mas
		
		MOV ax, word ptr vectorAscCounter[bx]
		CALL printAxToDi
		;Aca pongo en decimal l cantidad de veces que aparecio la letra
		MOV byte ptr[di], 13
		INC di
		
		MOV cx, offset bufferStats
		SUB di, cx; Calcular cuantos bytes escribí
		MOV cx, di

		PUSH bx
		XOR ax, ax
		mov ah, 40h
		lea dx, bufferStats
		mov bx, HandleDMP
		int 21h
		JNC seEscribioBienStasDMP
		MOV errorLectOdump, 2 ; =2 error en el dmp
		POP bx
		JMP salirWriteEstadisticas
		seEscribioBienStasDMP:
		POP bx
		;y escribir los datos del buffer

	noWrite:
	
	ADD bx, 2
	CMP bx, 512
	JAE salirWriteEstadisticas
	JMP cicloWriteEstadisticas

	salirWriteEstadisticas:

	POP si
	POP di
	POP dx
	POP cx
	POP bx
	POP ax

	ret
escribirStats endp

lecturaArchivo proc near
	;con un buffer de 512bytes necesito 128 ejecuciones del codigo para leer
	;
	PUSH ax
	PUSH bx
	PUSH cx
	PUSH dx

	mov handleDMP, 0
	CALL crearDUMP
    CMP handleDMP, 0
    JNE sinErrorCrearDMP
    MOV errorLectOdump, 2
    JMP errorLectura
    sinErrorCrearDMP:

	lea dx, pathLectura
	inc dx
    MOV ax, 3D00h
    int 21h    
    JNC sinErrorAbrirFichero
    MOV errorLectOdump, 1
    JMP errorLectura
    sinErrorAbrirFichero:
    MOV handleLectura, ax

    MOV al, 128
    MOV archivoCont, al ;128 * 512 = 2^16
    MOV contadorPosDMP, 0
    	cicloLectura:
	    	
		    MOV ax, 3F00h
		    MOV bx, handleLectura
		    MOV cx, 0200h ; leer todo el buffer, si lee menos de 512
		    lea dx, buffer; ya lei todo el txt.
		    int 21h
		    JNC bufferLeyoBien
		    MOV errorLectOdump, 1; =1 error de lectura
		    JMP errorLectura
		    bufferLeyoBien:
		    MOV bytesBufferLeidos, ax ; mover la cantidad de bytes que leyo
		    CMP ax, 0
		    JNE leiAlgo
		    MOV archivoCont, 1
		    JMP condicionCicloLectura
		    leiAlgo:
		    CMP ax, 512
		    JB leiTodo
		    JMP faltaLeer
		    leiTodo:
		    MOV archivoCont, 1
		    faltaLeer:

		    CALL estadisticas

		    CALL escribirDUMP
		    CMP errorLectOdump, 0
		    JE dmpEscritoConExito
		    JMP errorLectura
		    dmpEscritoConExito:

	    condicionCicloLectura:
		    DEC byte ptr[archivoCont]
		    CMP byte ptr[archivoCont], 0
		    JBE cerrarLecturaArhivo
		    JMP cicloLectura
	
    cerrarLecturaArhivo:
    	CALL escribirStats 
    	MOV ah, 3Eh
		MOV bx, handleLectura
		int 21h  
		JNC sinErrorCerrarLectura
		JMP errorLecturaMsgPrint
		sinErrorCerrarLectura:
		MOV ah, 3Eh
		MOV bx, handleDMP
		int 21h
		JNC sinErrorCerrarDMP
		JMP errorCrearDMPPrint
		sinErrorCerrarDMP:
		MOV ah, 09h
		lea dx, msgCerradoExitoso
		int 21h
		JMP finalLecturaArchivo 
	errorLectura:
		
		CMP errorLectOdump, 1
		JE errorLecturaMsgPrint
		JMP errorCrearDMPPrint
		errorLecturaMsgPrint:
	    	MOV ah, 09h
	    	lea dx, msgErrorLectura
	    	int 21h
	    	JMP finalLecturaArchivo
	    errorCrearDMPPrint:
	    	MOV ah, 09h
	    	lea dx, msgErrorDump
	    	int 21h

	finalLecturaArchivo:

    POP dx
    POP cx
    POP bx
    POP ax
	ret
lecturaArchivo endp

escribirDUMP proc near
	PUSH ax
	PUSH bx
	PUSH cx
	PUSH dx
	PUSH di

	;en el ax viene la cantidad de bytes leidos
	;printBuffer
	;MOV cx, ax
	MOV indiceBuffer, 0
	cicloEscribirDUMP:
		
		CALL AsciiContDUMP ; aca ya queda listo el file pointer
		lea di, bufferDMP
		MOV byte ptr [di+5], " "
		MOV byte ptr [di+6], " "
		MOV byte ptr [di+7], " "

	
		ADD di, 8; di apuntando y listo para escribir los primeros 8 bytes
		
		CALL b8ytesToBufferDUMP; aca escribe en el di los 8 bytes en hexadecimal 
		
		MOV byte ptr[di], " ";en Ascii
		INC di
		MOV byte ptr[di], " "; ya se puso un espacio en blanco, solo falta 1
		INC di ;tres especios de en medio listo
		;00030 46 61 20 76 69 64 61 20    |

		CALL b8ytesToBufferDUMP; aca escribe en el di los 8 bytes en hexadecimal
		; que faltan para completar los 16
		
		DEC di
		MOV byte ptr[di], 13
		
		PUSH ax
		MOV cx, 58
		mov ah, 40h
		lea dx, bufferDMP
		mov bx, HandleDMP
		int 21h
		POP ax
		ADD contadorPosDMP, 16
		
		SUB ax, 10h
		;printENTER
		;printBufferDUMP
		CMP ax, 0
		JNG finalEscribirDUMP
		JMP cicloEscribirDUMP
	finalEscribirDUMP:
	printENTER
	MOV cx, 14
	mov ah, 40h
	lea dx, bufferStats
	mov bx, HandleDMP
	int 21h
	JNE salirEscribirDMP
	MOV errorLectOdump, 2; =2 error DMP
	JMP salirEscribirDMP
	

	salirEscribirDMP:

	POP di
	POP dx
	POP cx
	POP bx
	POP ax
	ret
escribirDUMP endp

AsciiContDUMP proc near
	PUSH ax
	PUSH bx
	PUSH cx
	PUSH dx
	PUSH di

	MOV ax, contadorPosDMP
	MOV bx, 16
	CALL convertirnumBaseN

	push ds
    pop es
    cld
	lea si, bufferHexPrint
	lea di, bufferDMP
	INC di
	MOV cx, 4
	REP MOVSB
	MOV bx, 4
  	cicloPonerCerosAscii:
  		CMP byte ptr[bufferDMP+bx], 0
  		JNE noEsCeroAsciiContDUMP
  		MOV byte ptr[bufferDMP+bx], "0"
  		noEsCeroAsciiContDUMP:
  		DEC bx
  		CMP bx, 0
  		JGE	cicloPonerCerosAscii
	
  	salirBinDecBytes:

	POP di
	POP dx
	POP cx
	POP bx
	POP ax

	ret
AsciiContDUMP endp

b8ytesToBufferDUMP proc near
	;en el di se recibe el puntero a donde dejar los 
	;8 numero hexadecimal
	PUSH ax
	PUSH bx
	PUSH cx
	PUSH dx
	PUSH si
	
	MOV cx, 8

	ciclob8ytesToBufferDUMP:
		lea si, buffer
		MOV bx, indiceBuffer
		XOR ax, ax
		MOV al, byte ptr [si+bx]
		INC indiceBuffer
		MOV bx, 16
		CALL convertirnumBaseN
	
		MOV ah, [bufferHexPrint+2]
		MOV al, [bufferHexPrint+3]
		CMP ah, 0
		JNE noEsCero8BytesMSB
		ADD ah, 30h
		noEsCero8BytesMSB:
			CMP al, 0
			JNE noEsCero8BytesLSB
			ADD ah, 30h
		noEsCero8BytesLSB:
			MOV byte ptr[di], ah
			INC di
			MOV byte ptr[di], al
			INC di
			MOV byte ptr[di], " "
			INC di
			;printENTER
			;printBufferDUMP
	LOOP ciclob8ytesToBufferDUMP
	POP si
	POP dx
	POP cx
	POP bx
	POP ax
	ret
b8ytesToBufferDUMP endp

crearDUMP proc near
	PUSH ax
	PUSH bx
	PUSH cx
	PUSH dx

	lea dx, pathDUMP
	inc dx
    mov ah, 3Ch    ; crear
    mov cx, 00h  ;  atributo de tipo de entrada de archivo  
    int 21h
    jnc crearDMPExitoso
    JMP errorCrearDMP
    crearDMPExitoso:
    	MOV handleDMP, ax
    	JMP finalCrearDUMP
    errorCrearDMP:
	    ;MOV ah, 09h
	    ;lea dx, msgError
	    ;int 21h

	finalCrearDUMP:
	POP dx
    POP cx
    POP bx
    POP ax
	ret
crearDUMP endp

printAX proc
	; imprime a la salida estándar un número que supone estar en el AX
	; supone que es un número positivo y natural en 16 bits.
	; lo imprime en decimal.  
    
    push AX
    push BX
    push CX
    push DX

    xor cx, cx
    mov bx, 10
	ciclo1PAX: xor dx, dx
	    div bx
	    push dx
	    inc cx
	    cmp ax, 0
	    jne ciclo1PAX
	    mov ah, 02h
	ciclo2PAX: pop DX
	    add dl, 30h
	    int 21h
	    loop ciclo2PAX

    pop DX
    pop CX
    pop BX
    pop AX
    ret
printAX endP

printAxToDi proc near
	push AX
    push BX
    push CX
    push DX

    xor cx, cx
    mov bx, 10
	ciclo1PAXtDI: xor dx, dx
	    div bx
	    push dx
	    inc cx
	    cmp ax, 0
	    jne ciclo1PAXtDI
	    ;mov ah, 02h
	ciclo2PAXtDI: pop DX
	    add dl, 30h
	    mov byte ptr[di], dl
	    INC di
	    
	    loop ciclo2PAXtDI

    pop DX
    pop CX
    pop BX
    pop AX

	ret
printAxToDi endp

convertirnumBaseN proc near
  ;recibe en el ax el numero a convertir
  ;en el bx la base a convertir 
  ;la salida se da en el si
  ;el buffer es de 4bytes

  push ax            
  push bx
  push cx
  push dx
  PUSH si
  lea si, bufferHexPrint
  CALL CleanSi4
  ADD si, 4
  convert:
    xor dx, dx         
    div bx             
    add dl, '0'        
    cmp dl, '9'       
    jbe store         
    add dl, 'A'-'0'-10 
  store:
    dec si             
    mov [si], dl       
    and ax, ax        
    jnz convert

  ;lea si, bufferHexPrint
  ;MOV ah, 02h
  ;MOV cx, 4
  ;cicloPrintHex:
	  ;CMP byte ptr [si], 0
	  ;JE seguirCicloPrintHex
	  ;MOV dl, [si]
	  ;int 21h
	  ;seguirCicloPrintHex:
	  ;INC si
	  ;LOOP cicloPrintHex
  POP si       
  pop dx
  pop cx            
  pop bx
  pop ax

  ret
convertirnumBaseN endp

CleanSi4 proc near
  PUSH si
  PUSH cx
  MOV cx, 4
  cicloCleanSi4:
    MOV byte ptr [si], 0
    INC si
    LOOP cicloCleanSi4

  POP cx
  POP si
  ret
CleanSi4 endp

cleanBufferStats proc near
	PUSH cx
	PUSH si

	lea si, bufferStats
	MOV cx, 14
	cicloBufferStats:
		MOV byte ptr[si], ""
		INC si
	LOOP cicloBufferStats
	POP si
	POP cx
	ret
cleanBufferStats endp

pressEnterContinueEco proc near
	PUSH ax
	XOR ax, ax
	MOV ah, 01h
	noPressEnter:
	int 21h
	CMP al, 13
	JNE noPressEnter

	POP ax	
	ret
pressEnterContinueEco endp

getPath proc near
	PUSH ax
	PUSH cx
	PUSH dx
	PUSH di
	PUSH si

	MOV si, 80h
	mov cl, byte ptr es:[si]
	xor ch, ch
	mov largoPath, cl
	inc si

	lea di, pathLectura

	cicloGetPath:
		mov dl, byte ptr es:[si]
		mov byte ptr [di], dl   	
		INC si
		INC di 
	loop cicloGetPath
	
	CALL makeDMPPath
	POP si
	POP di
	POP dx
	POP cx
	POP ax
	ret
getPath endp

makeDMPPath proc near
	PUSH ax
	PUSH cx
	PUSH dx
	PUSH di
	PUSH si
	
	PUSH ds
	PUSH es 
		push ds
	    pop es
	    cld
		lea si, pathLectura
		lea di, pathDUMP
		XOR ch, ch
		MOV cl, largoPath
		SUB cx, 4
		REP MOVSB
	POP es 
	POP ds
	
	PUSH ds
	PUSH es
		push ds
	    pop es
	    cld
		lea si, endDMP
		lea di, pathDUMP
		XOR ah, ah
		MOV al, largoPath
		ADD di, ax
		SUB di, 4
		MOV cx, 4
		REP MOVSB
	POP es 
	POP ds

	POP si
	POP di
	POP dx
	POP cx
	POP ax
	ret
makeDMPPath endp

	main:

	holaMundo:
		mov ax, pila
		mov ss, ax

		mov ax, datos
		mov ds, ax
		CALL getPath

		;CALL pressEnterContinueEco

		mov ah, 09h
		lea dx, rotulo 
		int 21h
		CALL pressEnterContinueEco
		printAcercaDe

		CALL pressEnterContinueEco
	
	CALL lecturaArchivo	
	
    salidaMain:
		MOV ax, 4C00h
		int 21h 

codigo ends

end main