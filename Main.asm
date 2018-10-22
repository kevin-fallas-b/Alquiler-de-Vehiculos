.model small
.stack 100h
.data
  filename db 'vehiculo.txt',0
  handle dw ?
  fbuff  db ? ;buffer del archivo text
  contador db 10

.code
  .startup
    mov ax,03h ;sirve para limpiar la pantalla
    int 10h ;sirve para limpiar la pantalla
    call abrirTXT
    call leerTXT
    ;call esperarflecha
    ;call leerTXT
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

  loopCarros:
  sub contador, 1  ;reduce el contador
  mov ah, contador
  mov al, 0
  cmp ah,al        ;si el contador es 0
  je finTXT        ;mandar a dejar de imprimir
  jmp leerTXT


  finTXT:
  mov contador,10
  call esperarflecha
  ;mov contador, ah
  ;ret
  leerTXT endp

  salir: .exit

  esperarflecha:
  mov ah,0      ;0 en ah dice que recibe la tecla estripada
  int 16h       ; int 16h es la encargada de controlar el teclado
  cmp ah,48h    ; 48h == hexadecimal para la flecha de arriba, revisa si la tecla estripada es flecha arriba
  jne esperarflecha; si no lo es, seguir esperando
  call leerTXT
  ;ret           ;si si era la flecha de arriba ret a main y seguir con procedimientos
end
