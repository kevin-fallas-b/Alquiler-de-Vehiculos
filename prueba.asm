.model small
.stack
.data
mensaje dB 'Hola Mundo','$'
.code
inicio:
mov ax,@data
mov ds,ax
lea dx,mensaje
mov ah,09h
int 21h
mov ah,4ch
int 21h
end inicio