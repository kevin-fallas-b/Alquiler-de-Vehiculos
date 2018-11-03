.model small
.stack 100h
.data
  mensaje db 'N: Nuevo, E: Eliminar, B: Buscar','$'
  mensaje2 db ' para desplazar la lista','$'
  atributosAutos db 'Placa         Marca         Anno          Peso          Color', '$'
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
  pedirPeso db 'Por favor digite el peso del carro.','$'
  peso db '$$$$$$$$'
  pedirColor db 'Por favor digite el color del carro.','$'
  color db '$$$$$$$$'
  espacios db '     ','$'
  columna db 3
  carroNuevo db 100 dup('$')
  variable db 14 dup (' '), '$'



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
    call menu
    call abrirTXT
    call leerTXT
    jmp esperarTecla; metodo que se encicla
    .exit

    menu proc near

    lea dx, mensaje
    mov ah, 09h
    int 21h
    call saltoLinea
    lea dx, teclaInc
    mov ah, 09h
    int 21h
    lea dx, mensaje2
    mov ah, 09h
    int 21h
    call saltoLinea
    call msgAtributosAutos
    call saltoLinea

    ret

    menu endp

    msgAtributosAutos proc near

    call saltoLinea
    lea dx, atributosAutos
    mov ah, 09h
    int 21h
    call saltoLinea

    ret
    msgAtributosAutos endp

;segmento de codigo que manipula el txt
  abrirTXT proc near
    mov ah,3dh      ;intenta abrir el archivo txt
    lea dx,filename
    mov al,02      ;define permiso lectura y escritura
    int 21h
    mov handle,ax
    ret
  abrirTXT endp

  leerTXT proc near
  lea si, variable
  loopLeerTxt:
    mov ah,3fh
    mov bx,handle
    lea dx,fbuff
    mov cx,1     ;leer solo un btye
    int 21h
    cmp ax,0     ;revisa si leyo 0 bytes, si es 0, fin de archivo
    jz finTXT    ;si leyo 0 bytes, brincar a fin de archivo, revisar despues porque hay un error al terminar de leer el archivo sigue avanzando
    mov ah,'#'
    mov al,fbuff ;meter byte leido en al
    cmp ah,al    ;revisar si el caracter leido es un #
    je imprimirPantalla
    mov ah,'@'
    cmp ah,al    ;misma comparacion de arriba
    je loopCarros ;si es final de linea disminuye el contador
    mov  dl,fbuff ;no, load file character
    mov [si], dl ;compia el caracter a la variable variable
    inc si
    jmp loopLeerTxt  ;repite la funcion hasta que se acabe

    imprimirPantalla proc
    mov cx, 14
    lea si, variable
    loopImprimir:
    mov dl, [si]
    mov ah,2
    int 21h
    inc si
    loop loopImprimir
    lea si, variable
    mov cx, 14
    limpiarVariable:
    mov [si], ' '
    inc si
    loop limpiarVariable
    jmp LeerTxt
    imprimirPantalla endp

  leerTXT endp


  escribirAtxt proc near
  sig:
    mov ah,3fh
    mov bx,handle
    lea dx,fbuff
    mov cx,1     ;leer solo un btye
    int 21h
    cmp ax,0     ;revisa si leyo 0 bytes, si es 0, fin de archivo
    jne sig
    ;si llego aqui es que ya estoy al ginal del archivo
    ;mov al, 1        ; relative to current file position
    ;mov ah, 42h      ; service for seeking file pointer
    ;mov bx, handle
    ;mov cx, -1       ; upper half of lseek 32-bit offset (cx:dx)
    ;mov dx, -1       ; moves file pointer one byte backwards (This is important)
    ;int 21h
    lea di,carroNuevo
    mov ah, 40h          ;guarda en txt primer caracter
    mov bx, handle       ;guarda en txt primer caracter
    mov cx, 1            ;guarda en txt primer caracter
    mov dx, [di]  ; buffer that holds the new character to be written
    int 21
  guar:
    inc di
    mov ah, 40h          ; service for writing to a file
    mov bx, handle
    mov cx, 1            ; number of bytes to write
    mov dx, [di]  ; buffer that holds the new character to be written
    int 21
    cmp dx,40h
    jne guar
    ;ya escribio un arroba, terminar
    mov ah,3eh
    mov bx, handle
    ret
  escribirAtxt endp

  finTXT:
    mov contador,10
    ret
;c
;final del segmento de manipulacion del txt
;empieza segmento de procedimientos repetitivos
  salir: .exit
  loopCarros:
  mov cx, 14
  lea si, variable
  loopImprimir2:
  mov dl, [si]
  mov ah,2
  int 21h
  inc si
  loop loopImprimir2
  lea si, variable
  mov cx, 14
  limpiarVariable2:
  mov [si], ' '
  inc si
  loop limpiarVariable2
  sub contador, 1  ;reduce el contador
  mov ah, contador
  mov al, 0
  cmp ah,al        ;si el contador es 0
  je finTXT        ;mandar a dejar de imprimir
  jmp LeerTxt

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

  saltos:
  jmp salir

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
    call menu
    ;verificar que haya algo que pueda leer, que no este en EOF
    call jumpaleerTXT
    jmp esperarTecla
  leerAdelante endp

  leerAtras proc near ; metodo que limpia la pantalla e imprime los 10 carros anteriores en el txt
    call limpiarPantalla
    call menu
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

  ingresarCarro proc near ;metodo que pide informacion sobre el carro nuevo y la guarda en variables
    call limpiarPantalla
    imp_texto pedirPlaca
    call saltoLinea
    pedir_datos placa
    call limpiarPantalla
    imp_texto pedirMarca
    call saltoLinea
    pedir_datos marca
    call limpiarPantalla
    imp_texto pedirModelo
    call saltoLinea
    pedir_datos modelo
    call limpiarPantalla
    imp_texto pedirPeso
    call saltoLinea
    pedir_datos peso
    call limpiarPantalla
    imp_texto pedirColor
    call saltoLinea
    pedir_datos color
    call limpiarPantalla
    call concatenarCarroNuevo
    call escribirAtxt

  ingresarCarro endp

  concatenarCarroNuevo proc near;metodo muy repetitivo, no se usa macro ya que se necesitan labels
    lea si, carroNuevo
    lea di, placa
  reppp:
    mov al,[di]
    mov [si],al
    inc si
    inc di
    mov ah,[di]
    cmp ah,0dh
    je etimar
    cmp ah,24h
    jne reppp
  etimar:
    mov al,23h
    mov [si],al
    inc si
    lea di, marca
  rep1:
    mov al,[di]
    mov [si],al
    inc si
    inc di
    mov ah,[di]
    cmp ah,0dh
    je etimod
    cmp ah,24h
    jne rep1
  etimod:
    mov al,23h
    mov [si],al
    inc si
    lea di,modelo
  rep2:
    mov al,[di]
    mov [si],al
    inc si
    inc di
    mov ah,[di]
    cmp ah,0dh
    je etipes
    cmp ah,24h
    jne rep2
  etipes:
    mov al,23h
    mov [si],al
    inc si
    lea di, peso
  rep3:
    mov al,[di]
    mov [si],al
    inc si
    inc di
    mov ah,[di]
    cmp ah,0dh
    je eticol
    cmp ah,24h
    jne rep3
  eticol:
    mov al,23h
    mov [si],al
    inc si
    lea di,color
  rep4:
    mov al,[di]
    mov [si],al
    inc si
    inc di
    mov ah,[di]
    cmp ah,0dh
    je etifin
    cmp ah,24h
    jne rep4
  etifin:
    mov al,40h
    mov [si],al
    inc si
    imp_texto carroNuevo
    ret
  concatenarCarroNuevo ENDP

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
