.model small
.stack 100h
.data
  filename db 'vehiculo.txt',0
  teclaInc db 'Tecla incorrecta. flecha arriba o flecha abajo','$'
  salta db 10,13,'$'
  handle dw ?
  fbuff  db ? ;buffer del archivo text
  contador db 10
  ;las variables de abajo son utilizadas a la hora de crear un carro nuevo
  pedirPlaca db 'Por favor digite la placa del carro.','$'
  placa db '$$$$$$$$'
  pedirMarca db 'Por favor digite la marca del carro.','$'
  marca db '$$$$$$$$'
  pedirModelo db 'Por favor digite el modelo del carro.','$'
  modelo db '$$$$$$$$'
  pedirPeso db 'Por favor digite el peso del carro','$'
  peso db '$$$$$$$$'
  pedirColor db 'Por favor digite el color del carro.','$'
  color db '$$$$$$$$'
  espacios db '     ','$'
  columna db 3



pos_cursor macro col		;UN TIPO DE "METODO" QUE RECIBE 2 PARAMETROS
	mov ah, 02h
	mov bh, 00
	mov dh, dh
	mov dl, col
	int 10h						;INTERRUPCION DE VIDEO
  endm

  imp_texto macro texto
	lea dx, texto
	mov ah, 09h
	int 21h
  endm

  pedir_datos macro valor
	mov ah,3fh
  mov bx,00
  mov cx,7
  mov dx, offset[valor]
  int 21h
  endm

.code
  .startup
    call limpiarPantalla
    call abrirTXT
    call leerTXT
    jmp esperarTecla; metodo que se encicla
    .exit

;segmento de codigo que manipula el txt
  abrirTXT proc near
    mov ah,3dh    ;intenta abrir el archivo txt
    lea dx,filename
    mov al,0      ;define permiso lectura y escritura
    int 21h
    mov handle,ax
    ret
  abrirTXT endp

  imprespacios:
  pos_cursor columna
  mov ah, 09h
  int 21h
  add columna,1
  jmp leerTXT

  leerTXT proc near
    mov ah,3fh
    mov bx,handle
    lea dx,fbuff
    mov cx,1     ;leer solo un btye
    int 21h
    cmp ax,0     ;revisa si leyo 0 bytes, si es 0, fin de archivo
    jz finTXT    ;si leyo 0 bytes, brincar a fin de archivo
    mov ah,'#'
    mov al,fbuff ;meter byte leido en al
    cmp ah,al    ;revisar si el caracter leido es un #
    je imprespacios
    mov ah,'@'
    cmp ah,al    ;misma comparacion de arriba
    je loopCarros ;si es final de linea disminuye el contador
    mov  dl,fbuff ;no, load file character
    mov ah,2
    int 21h
    jmp leerTXT  ;repite la funcion hasta que se acabe

  leerTXT endp

  escribirAtxt proc near
  ;mov ah, 40h          ; service for writing to a file
  ;  mov bx, handle
  ;  mov cx, 1            ; number of bytes to write
  ;  mov dx, offset char  ; buffer that holds the new character to be written
  ;  int 21h
  escribirAtxt endp

  finTXT:
    mov contador,10
    ret

;final del segmento de manipulacion del txt
;empieza segmento de procedimientos repetitivos
  salir: .exit

  loopCarros:
  mov columna,3
  sub contador, 1  ;reduce el contador
  mov ah, contador
  mov al, 0
  cmp ah,al        ;si el contador es 0
  je finTXT        ;mandar a dejar de imprimir
  jmp leerTXT

  saltoLinea proc near ;funcion super sencilla que me salta una linea en consola
  lea dx, salta
  mov ah, 09h
  int 21h
  ret
  saltoLinea endp

  limpiarPantalla proc near
  mov ax,03h  ;sirve para limpiar la pantalla
  int 10h     ;sirve para limpiar la pantalla
  ret
  limpiarPantalla endp

  teclaIncorrecta proc near ;funcion que imprime en pantalla que estripo una tecla invalida, dice las teclas validas y que intente de nuevo
  call saltoLinea
  lea dx,teclaInc
  mov ah, 09h
  int 21h
  jmp esperarTecla
  teclaIncorrecta endp



  esperarTecla:;metodo que se encicla mientras el programa esta activo
  call saltoLinea
  mov ah,0      ;0 en ah dice que recibe la tecla estripada
  int 16h       ; int 16h es la encargada de controlar el teclado
  cmp ah,48h    ; 48h == hexadecimal para flecha abajo, revisa si la tecla estripada == flecha arriba
  je leerAtras; si lo es, llamar funcion que lee hacia atras
  cmp ah,50h    ; 50h == hexadecimal para flecha arriba,revisa si la tecla estripada == flecha abajo
  je leerAdelante ; si lo es, llamar funcion que lee hacia adelante
  cmp ah,30h      ;30h == hexadecimal para B,revisa si la tecla estripada == B
  je jumpamoverHandle ; si lo es, llamar funcion que busca
  cmp ah,01h      ;01h == hexadecimal para esc, revisa si la tecla estripada == esc
  je salir        ;si lo es, llamar funcion que termina programa
  cmp ah,31h      ;31h == hexadecimal para n, resiva si la tecla estripada == n
  je ingresarCarro
  call teclaIncorrecta ;si llego aqui significa que se presiono una tecla incorrecta

;final del segmento repetitivo

  leerAdelante proc near ; metodo que limpia la pantalla e imprime los 10 proximos carros en el txt
  call limpiarPantalla
  ;verificar que haya algo que pueda leer, que no este en EOF
  call jumpaleerTXT
  jmp esperarTecla
  leerAdelante endp

  leerAtras proc near ; metodo que limpia la pantalla e imprime los 10 carros anteriores en el txt
  call limpiarPantalla
  mov contador,20   ;el contador va en 20 porque ocupo retroceder las 10 que estan en pantalla, mas otras 10 que son las que voy a imrimir
  call moverHandleatras
  jmp esperartecla
  leerAtras endp

  jumpaFinTXT:
  jmp finTXT
  ret
  jumpaleerTXT:
  jmp leerTXT
  ret

  jumpaMoverHandle:
  jmp moverHandleatras
  ret

  LIMPIAR_CARACTER PROC
	;MOV BH, 00
  ;mov dh, 01
	;MOV BL, PALLEN
	;MOV placa[BX], '$'
	;RET
ENDP

  ingresarCarro proc near ;metodo que pide informacion sobre el carro nuevo y la guarda en variables
  call limpiarPantalla
  imp_texto pedirPlaca
  pedir_datos placa
  call limpiarPantalla
  imp_texto placa
  call limpiarPantalla
  imp_texto pedirMarca
  pedir_datos marca
  call limpiarPantalla
  imp_texto pedirModelo
  pedir_datos modelo
  call limpiarPantalla
  imp_texto pedirPeso
  pedir_datos peso
  call limpiarPantalla
  imp_texto pedirColor
  pedir_datos color
  call limpiarPantalla
  imp_texto placa
  call saltoLinea
  imp_texto marca
  call saltoLinea
  imp_texto modelo
  call saltoLinea
  imp_texto peso
  call saltoLinea
  imp_texto color
  ingresarCarro endp

  segundoJumpaFinTxt:
  jmp jumpaFinTXT
  ret

  moverHandleatras proc near ;metodo medio complejo, ubica el handle, lo mueve 20 lineas atras como preparacion para imprimir 10 carros
  mov al, 1
  mov ah, 42h      ; busca el puntero del archivo
  mov bx, handle
  mov cx, -1       ; upper half of lseek 32-bit offset (cx:dx)
  mov dx, -2       ; mueve el puntero 2 posiciones atras porque vamos a leer una hacia adelante
  int 21h
  mov ah,3fh      ;este codigo de abajo lee un byte hacia adelante
  mov bx,handle
  lea dx,fbuff
  mov cx,1        ;movi el handle 2 atras, ahora leo uno adelante, efectivamente leyendo la posicion anterior a la que comence
  int 21h
  cmp ax,0        ;revisa si leyo 0 bytes, si es 0, fin de archivo
  jz segundojumpaFinTXT       ;si leyo 0 bytes, brincar a fin de archivo
  mov ah,'@'
  mov al,fbuff    ;meter byte leido en al
  cmp ah,al       ;revisar si el caracter leido es un @
  jne moverHandleatras ;si no lo es, seguir leyendo hacia atras
  sub contador, 1  ;reduce el contador
  mov ah, contador
  mov al, 0
  cmp ah,al        ;si el contador es 0
  jne moverHandleatras
  mov contador,10
  call leerTXT
  ret
  moverHandleatras endp

end
