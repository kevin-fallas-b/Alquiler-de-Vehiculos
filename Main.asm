.model small
.stack 100h
.data
  filename db 'vehiculo.txt',0
  teclaInc db 'Tecla incorrecta. D - 10 sig. A - 10 ant.','$'
  salta db 10,13,'$'
  handle dw ?
  fbuff  db ? ;buffer del archivo text
  contador db 10

.code
  .startup
    call limpiarPantalla
    call abrirTXT
    call leerTXT
    jmp esperarTecla; metodo que se encicla
    .exit


  abrirTXT proc near
    mov ah,3dh ;intenta abrir el archivo txt
    lea dx,filename
    mov al,0 ;define permiso lectura y escritura
    int 21h
    mov handle,ax
    ret
  abrirTXT endp


  leerTXT proc near
    mov ah,3fh
    mov bx,handle
    lea dx,fbuff
    mov cx,1 ;leer solo un btye
    int 21h
    cmp ax,0 ;revisa si leyo 0 bytes, si es 0, fin de archivo
    jz finTXT ; si leyo 0 bytes, brincar a fin de archivo
    mov ah,'#'
    mov al,fbuff;meter byte leido en al
    cmp ah,al ;revisar si el caracter leido es un #
    je leerTXT ; si lo es brincar a leertxt
    mov ah,'@'
    cmp ah,al ;misma comparacion de arriba
    je loopCarros ; si es final de linea disminuye el contador
    mov  dl,fbuff ;no, load file character
    mov ah,2
    int 21h
    jmp leerTXT ;repite la funcion hasta que se acabe

  leerTXT endp

  loopCarros:
  sub contador, 1  ;reduce el contador
  mov ah, contador
  mov al, 0
  cmp ah,al        ;si el contador es 0
  je finTXT        ;mandar a dejar de imprimir
  jmp leerTXT


  finTXT:
    mov contador,10
    ret


  salir: .exit

  saltoLinea proc near ;funcion super sencilla que me salta una linea en consola
  lea dx, salta
  mov ah, 09h
  int 21h
  ret
  saltoLinea endp


  teclaIncorrecta proc near ; funcion que imprime en pantalla que estripo una tecla invalida, dice las teclas validas y que intente de nuevo
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
  cmp ah,30h    ; 30h == hexadecimal para B,revisa si la tecla estripada == B
  je moverHandleatras ; si lo es, llamar funcion que busca
  cmp ah,01h    ; 01h == hexadecimal para esc, revisa si la tecla estripada == esc
  je salir ; si lo es, llamar funcion que termina programa
  call teclaIncorrecta ;si llego aqui significa que se presiono una tecla incorrecta



  limpiarPantalla proc near
  mov ax,03h ;sirve para limpiar la pantalla
  int 10h ;sirve para limpiar la pantalla
  ret
  limpiarPantalla endp

  leerAdelante proc near ; metodo que limpia la pantalla e imprime los 10 proximos carros en el txt
  call limpiarPantalla
  call leerTXT
  jmp esperarTecla
  leerAdelante endp

  leerAtras proc near ; metodo que limpia la pantalla e imprime los 10 carros anteriores en el txt
  call limpiarPantalla
  call moverHandleatras
  call leerTXT
  jmp esperartecla
  leerAtras endp


  moverHandleatras proc near ;este metodo se encarga de mover el handle dentro del txt 10 carros atras, para luego imprimir normalmente
  ;mov cx,-1 ;leer solo un btye hacia atras
  ;codigo internet
  mov al, 1        ; relative to current file position
  mov ah, 42h      ; service for seeking file pointer
  mov bx, handle
  mov cx, 0ffffh       ; upper half of lseek 32-bit offset (cx:dx)
  mov dx, 0ffffh       ; moves file pointer one byte backwards (This is important)
  int 21h
  ;fin codigo internet
  mov ah,3fh
  mov bx,handle
  lea dx,fbuff
  ;hasta aqui lo que hice es mover el handle para atras, revisar si es @, si lo es, restar contador en 1
  mov ah,'@'
  mov al,fbuff;meter byte leido en al
  cmp ah,al ;revisar si el caracter leido es un @
  jne moverHandleatras ;si no lo es, seguir leyendo hacia atras
  sub contador, 1  ;reduce el contador
  mov ah, contador
  mov al, 0
  cmp ah,al        ;si el contador es 0
  jne moverHandleatras
  mov contador,10
  ret
  moverHandleatras endp

end
