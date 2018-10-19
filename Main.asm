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
  je salir
  jmp leerTXT


  finTXT: ret
  leerTXT endp

  salir: .exit

end
