section .text
global _start

_start:

        mov rsi, msg
        mov rdx, len
        call print
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; status = 0
        syscall

; rsi - msg buffer
; rdx - msg length
print:
        mov rdi, 1          ; fd = stdout
        mov rax, 1          ; sys_write
        syscall
        ret

section .data
msg db "Hello, world!", 10
len equ $ - msg
