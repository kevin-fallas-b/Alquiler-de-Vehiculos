.model small
.stack 100h
.data
  amperson db '&','$'
  bexito db 'Borrado correctamente','$'
  iexito db 'Insertado correctamente','$'
  nInsertar db 'N: nuevo auto','$'
  nBusqueda db 'N: nueva busqueda','$'
  vMenu db 'M: volver al menu','$'
  fbuff2 db ' ','$'
  mensaje db 'N: Nuevo, B: Buscar, ','$'
  mensajeFlechas db 24,00,25,' para desplazar la lista','$'
  mensaje2 db ' para desplazar la lista','$'
  atributosAutos db 'Placa        Marca         Modelo        Peso          Color', '$'
  filename db 'vehiculo.txt',0
  teclaInc db 'Tecla incorrecta','$'
  salta db 10,13,'$'
  handle dw ?
  fbuff  db ? ;buffer del archivo text
  contador db 10
  digitePlaca db 'Digite la placa del vehiculo: ','$'
  borrar db 'B: borrar vehiculo','$'
  encontro db 'vehiculo encontrado: ','$'
  noEncontro db 'no se encontro el vehiculo', '$'
  cRetroceder db 0
  ;las variables de abajo son utilizadas a la hora de crear un carro nuevo
  pedirPlaca db 'Por favor digite la placa del carro.','$'
  placa db '$$$$$$$$'
  placa2 db '$$$$$$$$$','$'
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
  endl db 0dh,0ah

  imp_texto macro texto
	  lea dx, texto
    mov ah, 09h
	  int 21h
  endm

  pedir_datos macro valor
	 mov ah, 3fh
   mov bx, 00
   mov cx, 7
   mov dx, offset[valor]
   int 21h
  endm

.code

  .startup

    inicio proc
    call limpiarPantalla
    call menu
    call abrirTXT
    call leerTXT
    jmp esperarTecla; metodo que se encicla

    fin:
    .exit
    inicio endp

    menu proc near

    imp_texto mensaje
    imp_texto mensajeFlechas
    call saltoLinea
    call msgAtributosAutos
    call saltoLinea
    ret

    menu endp

    msgAtributosAutos proc near

    call saltoLinea
    imp_texto atributosAutos
    call saltoLinea
    ret

    msgAtributosAutos endp

;segmento de codigo que manipula el txt
  abrirTXT proc near

    mov ah, 3dh      ;intenta abrir el archivo txt
    lea dx, filename
    mov al, 02      ;define permiso lectura y escritura
    int 21h
    mov handle, ax
    ret

  abrirTXT endp

  leerTXT proc near

  lea si, variable

  loopLeerTxt:

    mov ah, 3fh
    mov bx, handle
    lea dx, fbuff
    mov cx, 1     ;leer solo un btye
    int 21h
    cmp ax, 0     ;revisa si leyo 0 bytes, si es 0, fin de archivo
    jz finTXT    ;si leyo 0 bytes, brincar a fin de archivo, revisar despues porque hay un error al terminar de leer el archivo sigue avanzando
    mov ah, '#'
    mov al, fbuff ;meter byte leido en al
    cmp ah, al    ;revisar si el caracter leido es un #
    je imprimirPantalla
    mov ah, '@'
    cmp ah, al    ;misma comparacion de arriba
    je jumpaloopCarros ;si es final de linea disminuye el contador
    mov  dl, fbuff ;no, load file character
    mov [si], dl ;compia el caracter a la variable variable
    inc si
    jmp loopLeerTxt  ;repite la funcion hasta que se acabe

    imprimirPantalla proc

    mov cx, 14
    lea si, variable

    loopImprimir:

    mov dl, [si]
    mov ah, 2
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

  finTXT:

    mov contador, 10
    ret

  jumpaloopcarros:

    jmp loopCarros
    ret

  escribirAtxt proc near

    mov bx, handle
  loopsi:

    mov ah, 3fh     ;funcion normal de lectura solo que se repite hasta que llegue al final del archivo
    mov bx, handle
    lea dx, fbuff
    mov cx, 1     ;leer solo un btye
    int 21h
    cmp ax, 0 ; si ax es = a 0 es porque llegó al final del archivo
    jne loopsi

    lea si,carroNuevo
  loopescribir:

    mov bx, handle
    mov cx, 1
    lea dx, [si]
    mov ah, 40h ;escribe en el archivo
    int 21h
    inc si
    mov ah, [si]
    cmp ah, '@'
    jne loopescribir
    mov bx, handle  ;se pone una vez mas para que escriba el @ final
    mov cx, 1       ;se pone una vez mas para que escriba el @ final
    lea dx, [si]    ;se pone una vez mas para que escriba el @ final
    mov ah, 40h      ;se pone una vez mas para que escriba el @ final
    int 21h         ;se pone una vez mas para que escriba el @ final
    mov bx, handle  ;meter un enter al final
    mov cx, 2       ;meter un enter al final
    lea dx, endl    ;hexadecimal para new line
    mov ah, 40h      ;
    int 21h         ;
    mov ah, 3eh      ; cierra el archivo
    int 21h
    ret

  escribirAtxt endp

jumpaFinTXT2:

  jmp finTXT
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
  mov ah, 2
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
  je jumpaFinTXT2        ;mandar a dejar de imprimir
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
    lea dx, teclaInc
    mov ah, 09h
    int 21h
    jmp esperarTecla

  teclaIncorrecta endp

  esperarTecla:;metodo que se encicla mientras el programa esta activo

    call saltoLinea
    mov ah, 0      ;0 en ah dice que recibe la tecla estripada
    int 16h       ; int 16h es la encargada de controlar el teclado
    cmp ah, 48h    ; 48h == hexadecimal para flecha abajo, revisa si la tecla estripada == flecha arriba
    je leerAtras; si lo es, llamar funcion que lee hacia atras
    cmp ah, 50h    ; 50h == hexadecimal para flecha arriba,revisa si la tecla estripada == flecha abajo
    je leerAdelante ; si lo es, llamar funcion que lee hacia adelante
  ;  cmp ah, 30h      ;30h == hexadecimal para B,revisa si la tecla estripada == B
  ;  je jumpamoverHandle ; si lo es, llamar funcion que busca
    cmp ah, 01h      ;01h == hexadecimal para esc, revisa si la tecla estripada == esc
    je salir        ;si lo es, llamar funcion que termina programa
    cmp ah, 31h      ;31h == hexadecimal para n, resiva si la tecla estripada == n
    je ingresarCarro
    cmp ah, 30h      ;31h == hexadecimal para n, resiva si la tecla estripada == n
    je buscarCarro2
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
    mov contador, 20   ;el contador va en 20 porque ocupo retroceder las 10 que estan en pantalla, mas otras 10 que son las que voy a imrimir
    call moverHandleatras
    jmp esperartecla

  leerAtras endp

  jumpaFinTXT:

    jmp finTXT
    ret

    jumpaleerTXT:

    jmp leerTXT
    ret

    buscarCarro2:
    jmp buscarCarro

  jumpaMoverHandle:

    jmp moverHandleatras
    ret

  ingresarCarro proc near ;metodo que pide informacion sobre el carro nuevo y la guarda en variables

    call abrirTXT
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
    call limpiarPantalla
    imp_texto iexito
    call saltoLinea
    imp_texto vMenu
    call saltoLinea
    imp_texto nInsertar
    mov ah, 0      ;0 en ah dice que recibe la tecla estripada
    int 16h       ; int 16h es la encargada de controlar el teclado
    cmp ah, 31h
    je ingresarCarroJmp
    jmp inicio
    ;call leerTXT
  ingresarCarro endp

ingresarCarroJmp:
jmp ingresarCarro

  concatenarCarroNuevo proc near;metodo muy repetitivo, no se usa macro ya que se necesitan labels

    lea si, carroNuevo
    lea di, placa
  reppp:

    mov al, [di]
    mov [si], al
    inc si
    inc di
    mov ah, [di]
    cmp ah, 0dh
    je etimar
    cmp ah, 24h
    jne reppp
  etimar:

    mov al, 23h
    mov [si], al
    inc si
    lea di, marca
  rep1:

    mov al, [di]
    mov [si], al
    inc si
    inc di
    mov ah, [di]
    cmp ah, 0dh
    je etimod
    cmp ah, 24h
    jne rep1
  etimod:

    mov al, 23h
    mov [si], al
    inc si
    lea di, modelo
  rep2:

    mov al, [di]
    mov [si], al
    inc si
    inc di
    mov ah, [di]
    cmp ah, 0dh
    je etipes
    cmp ah, 24h
    jne rep2
  etipes:

    mov al, 23h
    mov [si], al
    inc si
    lea di, peso
  rep3:

    mov al, [di]
    mov [si], al
    inc si
    inc di
    mov ah, [di]
    cmp ah, 0dh
    je eticol
    cmp ah, 24h
    jne rep3
  eticol:

    mov al, 23h
    mov [si], al
    inc si
    lea di, color
  rep4:

    mov al, [di]
    mov [si], al
    inc si
    inc di
    mov ah, [di]
    cmp ah, 0dh
    je etifin
    cmp ah, 24h
    jne rep4
  etifin:

    mov al, 40h
    mov [si], al
    inc si
    ret

  concatenarCarroNuevo endp

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
    mov ah, 3fh      ;este codigo de abajo lee un byte hacia adelante
    mov bx, handle
    lea dx, fbuff
    mov cx, 1        ;movi el handle 2 atras, ahora leo uno adelante, efectivamente leyendo la posicion anterior a la que comence
    int 21h
    cmp ax, 0        ;revisa si leyo 0 bytes, si es 0, fin de archivo
    jz segundojumpaFinTXT       ;si leyo 0 bytes, brincar a fin de archivo
    mov ah, '@'
    mov al, fbuff    ;meter byte leido en al
    cmp ah, al       ;revisar si el caracter leido es un @
    jne moverHandleatras ;si no lo es, seguir leyendo hacia atras
    sub contador, 1  ;reduce el contador
    mov ah, contador
    mov al, 0
    cmp ah, al        ;si el contador es 0
    jne moverHandleatras
    mov contador, 10
    call leerTXT
    ret

  moverHandleatras endp

  buscarCarro proc
    mov ah,3eh  ;Cierre de archivo
    int 21h
    call limpiarPantalla
    imp_texto digitePlaca
    call pedirDatosBuscar
    call buscar

  buscarCarro endp

  pedirDatosBuscar proc

    mov ah,3fh
    mov bx,00
    mov cx,9      ;cantidad de caracteres que lee
    mov dx, offset[placa2] ; placa es donde se almacena los caracteres
    int 21h

    lea si, placa2
    limpiarPlaca:   ;se debe limpiar porque el enter le genera basura
      mov al, [si]
      cmp al, 0Dh
      je limpiar
      inc si
      cmp [si],'$'
      jne limpiarPlaca
      call saltoLinea
      ret

      limpiar:

      mov [si], '$'
      inc si
      mov [si], '$'

    ret

  pedirDatosBuscar endp



  buscar proc



    lea si, placa2
    call abrirTXT
    mov bx, handle

    loopBuscar:

      mov ah, 3fh
      lea dx, fbuff
      mov cx, 1
      int 21h           ;lectura nomral de un caracter del archivo
      mov al, fbuff
      mov ah, [si]      ;solo se usa para el debug
      cmp al, [si]      ; compara si el caracter de la variable placa es igual al caracter de la placa del vehiculo en el archivo
      jne siguientePlaca ;si un caracter llega a ser diferente busca la placa del siguiente vehiculo
      cmp al, '#'        ;si el caracter leido es #, es porque coinciden las placas
      je carroEncontrado
      inc si            ; se incrementa para saber cual es el caracter siguiente
      mov ah, [si]
      cmp ah, '$'       ;si es el final de la variable placa
      je verificar      ; se debe verificar si es la misma placa o no
      jmp loopBuscar    ;si los caracteres van coicidiendo, se repite hasta que sea diferente o termine de leer los caracteres

    verificar:
      mov ah, 3fh
      lea dx, fbuff
      mov cx, 1
      int 21h        ; leer el caracter siguiente del archivo
      mov al, fbuff
      cmp al, '#'    ;si es un # las placas coinciden
      je carroEncontrado
                     ;sino busca la siguiente placa
    siguientePlaca:

      mov ah, 3fh
      lea dx, fbuff
      mov cx, 1
      int 21h          ;leer caracter a caracter
      cmp ax, 0        ;si llega al final del archivo
      je noEncontrado1  ; es que no encontró el vehiculo
      mov al, fbuff
      cmp al, 0Ah      ; si es un salto de linea el caracter leido
      jne siguientePlaca ; si no es un salto, repite hasta que haya un salto de linea
      lea si, placa2
      je loopBuscar  ;si lo encontro, es porque ya encontro la siguiente placa

      carroEncontrado:
      lea si, placa2;
      mov al, 0
      loopContarPlaca:
      mov ah,[si]
      cmp ah, '$'
      mov cRetroceder, al
      je imprimirCarroEncontrado
      inc si
      add al, 1
      jmp loopContarPlaca

      imprimirCarroEncontrado:

      devolver:

      mov ah, 42h      ; busca el puntero del archivo
      mov al, 1
      mov bx, handle
      mov cx, -1       ; upper half of lseek 32-bit offset (cx:dx)
      mov dx, -1      ; mueve el puntero 2 posiciones atras porque vamos a leer una hacia adelante
      int 21h
      mov al, cRetroceder
      cmp al, 0
      je ahoraSiImprime
      sub cRetroceder, 1
      jmp devolver

      inicioJmp:
      jmp inicio

      noEncontrado1:
      jmp noEncontrado

      ahoraSiImprime:
      call limpiarPantalla
      imp_texto encontro

      loopimprimir3:
      mov bx, handle
      mov ah, 3fh
      lea dx, fbuff2
      mov cx, 1
      int 21h
      mov al, fbuff2
      cmp al, '#'
      je quitarGato
      cmp al, '@'
      je Bborrar
      sigue1:
      imp_texto fbuff2
      jmp loopimprimir3

      nuevaBusqueda:
      jmp buscarCarro

      quitarGato:
        mov fbuff2, ' '
        jmp sigue1

      Bborrar:
      call saltoLinea
      imp_texto borrar
      call saltoLinea
      imp_texto vMenu
      call saltoLinea
      imp_texto nBusqueda
      mov ah, 0      ;0 en ah dice que recibe la tecla estripada
      int 16h       ; int 16h es la encargada de controlar el teclado
      cmp ah, 32h
      je inicioJmp
      cmp ah, 31h
      je nuevaBusqueda
      cmp ah, 30h
      je eliminar
      .exit

      noEncontrado:
      call limpiarPantalla
      imp_texto noEncontro
      call saltoLinea
      imp_texto vMenu
      call saltoLinea
      imp_texto nBusqueda
      mov ah, 0      ;0 en ah dice que recibe la tecla estripada
      int 16h       ; int 16h es la encargada de controlar el teclado
      cmp ah, 31h
      je nuevaBusqueda
      cmp ah, 42h
      jmp inicio
      .exit


  buscar endp

  eliminar:



  retrocedeUno:

  mov bx, handle
  mov ah, 42h      ; busca el puntero del archivo
  mov al, 1
  mov cx, -1       ; upper half of lseek 32-bit offset (cx:dx)
  mov dx, -1      ; mueve el puntero 2 posiciones atras porque vamos a leer una hacia adelante
  int 21h

  mov ah, 3fh
  lea dx, fbuff
  mov cx, 1
  int 21h

  mov al, fbuff
  cmp al, 0Ah
  je empiezaBorrar


  retrocedeDos:

  mov bx, handle
  mov ah, 42h      ; busca el puntero del archivo
  mov al, 1
  mov cx, -1       ; upper half of lseek 32-bit offset (cx:dx)
  mov dx, -1      ; mueve el puntero 2 posiciones atras porque vamos a leer una hacia adelante
  int 21h
  jmp retrocedeUno

 inicioJmp1:
 jmp inicio

 nuevaBusquedajmp:
 jmp buscarCarro

  empiezaBorrar:

  mov ah, 3fh
  lea dx, fbuff
  mov cx, 1
  int 21h

  mov al, fbuff
  cmp al, '@'
  je terminaBorrar

  mov bx, handle
  mov ah, 42h      ; busca el puntero del archivo
  mov al, 1
  mov cx, -1       ; upper half of lseek 32-bit offset (cx:dx)
  mov dx, -1      ; mueve el puntero 2 posiciones atras porque vamos a leer una hacia adelante
  int 21h

  mov bx, handle
  mov cx, 1
  lea dx, amperson
  mov ah,40h ;escribe en el archivo
  int 21h
  jmp empiezaBorrar

  terminaBorrar:
  call limpiarPantalla
  imp_texto bexito
  call saltoLinea
  imp_texto vMenu
  call saltoLinea
  imp_texto nBusqueda
  mov ah, 0      ;0 en ah dice que recibe la tecla estripada
  int 16h       ; int 16h es la encargada de controlar el teclado
  cmp ah, 31h
  je nuevaBusquedajmp
  cmp ah, 32h
  mov ah,3eh  ;Cierre de archivo
  int 21h
  jmp inicioJmp1

  .exit
end
