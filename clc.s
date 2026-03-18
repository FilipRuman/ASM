section .data
msg db "Hello, world!", 10
msg_len equ $ - msg


err db "ERR", 10
err_len equ $ - err

dbg db "DBG", 10
dbg_len equ $ - dbg

buffer_len equ 20 ;length of the string

section .bss

buffer resb buffer_len
a_num resq 1   
b_num resq 1   

section .text
global _start

_start:
        call print_msg

        ; read A variable
        call read 
        call buffer_to_int
        push rdx
        
        .loop:
        ; read operation symbol
        call read 
        xor rdx, rdx
        mov dl, [buffer]
        push rdx

        ; read B variable
        call read 
        call buffer_to_int
        
        ; do operation
        mov rsi, rdx ; b
        pop rdx ; operation
        pop rax ; a
        call do_operation 

        push rax ; save output of the operation as the A variable for next loop
        ; print output
        mov rdx, rax
        call int_to_buffer
        mov rsi, buffer
        mov rdx, rax ; digits count
        call print
        
        jmp .loop

        call quit

quit:
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; status = 0
        syscall

; dl -> operation
; rax -> a
; rsi -> b
do_operation:
        cmp dl, '+' 
        je .add
        cmp dl, '-' 
        je .sub
        cmp dl, '*' 
        je .mul
        cmp dl, '/' 
        je .div
        cmp dl, '%' 
        je .rem
        cmp dl, '=' 
        je .eq

        call print_err
        ret

        .add:
        add rax, rsi
        ret
        .sub:
        sub rax, rsi
        ret
        .mul:
        imul rax, rsi
        ret
        .div:
        xor rdx, rdx
        idiv rsi
        ret
        .rem:
        xor rdx, rdx
        idiv rsi
        mov rax, rdx
        ret
        .eq:
        mov rax, rsi
        ret


;----- Int & Asci Conversions
; digits count-> rax
; output at buffer
; input -> rdx
int_to_buffer:
        xor r8,r8 ; additional digits offset for the minus sign 
        test rdx, rdx
        jns .after_checked_sign 
                neg rdx
                mov r8, 1
                mov [buffer], '-'
        .after_checked_sign:

                mov rdi, rdx
                mov rax, rdx
                call int_digits_count ; rsi -> current digit index, starts from digits count -1
                add rsi, r8 ; offset for the minus sign 
                push rsi
                sub rsi, 1 

                mov rax, rdi; current value 

        mov rcx , 10; prepare for the division
        .to_buffer_conversion_loop:
                xor rdx, rdx ; clear rdx for division
                div rcx ; now rdx contains current digit, and rax contains rest of the digits

                add rdx, '0' ; now dl contains a asci char 
                mov [buffer + rsi], dl
                dec rsi ; move to the next digit                

                cmp rax, 0
                jne .to_buffer_conversion_loop
                pop rax ; read digit count
                ret

; input -> rax
; output -> rsi
int_digits_count:
        xor rsi, rsi 

        .loop:
                xor rdx, rdx 
                mov rcx, 10
                div rcx
                inc rsi

                cmp  rax,0
                jne .loop
                ret



; output at rdx
buffer_to_int:

        xor rdx, rdx   ; $rdx - output
        xor rsi, rsi   ; $rsi - current char index
        
        mov r8b,[buffer] 
        cmp r8b, '-' ; handle minus at the beggining 
        jne .loop
                inc rsi
        .loop:
                mov al, [buffer + rsi]; now $al contains character at the $rsi possition
        
                cmp al, 10              ; newline?
                je  .loop_end
        
                sub al, '0' ; $rax contains the char as a number 
                mul rdx, 10 ; multiply the previous value by 10 before adding a new number (because working in decimal system)
                ; needed at all?
                movzx rax, al         ; extend digit to 64-bit
                add rdx, rax          ; result += digit
                
                inc rsi 
        
                cmp rsi, buffer_len ; If read all characters, return  
                jne .loop
        .loop_end:
                cmp r8b, '-' ; handle minus at the beggining 
                jne .skip_negation
                        neg rdx
                .skip_negation:
                        ret


;----- IO -----

; output -> buffer
read: 
        ; --- read input from stdin ---
        mov rax, 0         ; sys_read
        mov rdi, 0         ; fd = stdin
        mov rsi, buffer    ; pointer to buffer
        mov rdx, buffer_len; max bytes
        syscall
        ret

print_msg:
        mov rsi, msg
        mov rdx, msg_len
        call print
        ret

print_dbg:
        mov rsi, dbg
        mov rdx, dbg_len
        call print
        ret

print_err:
        mov rsi, err
        mov rdx, err_len
        call print
        ret

print_buffer:
        mov rsi, buffer
        mov rdx, buffer_len
        call print
        ret

; rsi - msg buffer
; rdx - msg length
print:
        mov rdi, 1          ; fd = stdout
        mov rax, 1          ; sys_write
        syscall
        ret
