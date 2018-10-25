.model small
.stack 100h
.data
  filename db 'vehiculo.txt',0
  teclaInc db 'Tecla incorrecta.\nD - 10 sig\nA - 10 ant.','$'
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

  teclaIncorrecta proc near
  lea dx,teclaInc
  mov ah, 09h
  int 21h
  jmp esperarTecla
  teclaIncorrecta endp

  esperarTecla:;metodo que se encicla mientras el programa esta activo
  mov ah,0      ;0 en ah dice que recibe la tecla estripada
  int 16h       ; int 16h es la encargada de controlar el teclado
  cmp ah,1eh    ; 1eh == hexadecimal para A, revisa si la tecla estripada == A
  je leerAtras; si lo es, llamar funcion que lee hacia atras
  cmp ah,20h    ; 20h == hexadecimal para D,revisa si la tecla estripada == D
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

  leerAdelante proc near
  call limpiarPantalla
  call leerTXT
  jmp esperarTecla
  leerAdelante endp

  leerAtras proc near
  call limpiarPantalla
  call moverHandleatras
  call leerTXT
  jmp esperartecla
  leerAtras endp


  moverHandleatras proc near
  mov ah,3fh
  mov bx,handle
  lea dx,fbuff
  mov cx,-1 ;leer solo un btye hacia atras
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
