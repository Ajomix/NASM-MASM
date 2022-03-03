.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\msvcrt.lib ; Some default includes :P

printf proto C :vararg
scanf  proto C :vararg
gets proto C:vararg
fflush proto C :vararg
strlen proto C :vararg
__p__iob    PROTO C

.data
    Text        db "*************************RC4_ENCRYPTION****************************",10,"Enter your KEY: ",10,0
    TextP       db "Enter Message:",10,0
    fmt         db "%x",0
    key         db 4096 dup (?)
    max_len     dd 4096
    message     db 4096 dup (?)
    sbox        db 256 dup(?)
    stdin       dd ?
    stdout      dd ?

.code
SWAP PROC
    push ebp
    mov ebp,esp
    sub esp,32
        pusha

        mov eax,[ebp+8]
        mov al,[eax]
        mov ebx,[ebp+12]
        mov bl,[ebx]

        xchg bl,al

        mov esi,[ebp+8]
        mov edi,[ebp+12]
        mov [esi],al
        mov [edi],bl

        popa

    mov esp,ebp
    pop ebp
    ret
SWAP ENDP


;local variable
len equ DWORD PTR [ebp-4]
j   equ DWORD PTR [ebp-8]
KSA PROC
        push ebp
        mov ebp,esp
        sub esp,32
            ;[ebp+8] Key
            ;[ebp+12] Sbox
            xor ecx,ecx
            lKsa:
                mov eax,[ebp+12];Sbox
                mov BYTE PTR [eax+ecx],cl
                inc ecx
                cmp ecx,256
                jnz lKsa

            mov eax,DWORD PTR [ebp+8]
            push eax
            call strlen
            mov len,eax
            lea ebx,j
            mov BYTE PTR [ebx],0
            xor ecx,ecx

            lKsaM:

                mov eax,ecx
                xor edx,edx
                mov ebx,len
                div ebx ;i%len

                mov eax,[ebp+8];key
                xor ebx,ebx
                mov ebx,[eax+edx]

                add j,ebx

                mov eax,[ebp+12];sbox
                movzx eax,BYTE PTR [eax+ecx]
                add eax,j

                xor edx,edx
                mov ebx,256
                div ebx

                mov j,edx

                mov eax,[ebp+12];sbox
                lea ebx,[eax+edx]
                push ebx
                lea ebx,[eax+ecx]
                push ebx
                call SWAP

                inc ecx
                cmp ecx,256
                jnz lKsaM
        mov esp,ebp
        pop ebp
        ret
KSA ENDP

i equ [ebp-4]
jj equ [ebp-8]
lenMess equ [ebp-12]
PRGA PROC
    push ebp
    mov ebp,esp
    sub esp,32


        mov eax,0
        mov i,eax
        mov jj,eax

        mov eax,[ebp+12]
        push eax
        call strlen
        mov lenMess,eax
        xor eax,eax
        mov ecx,0
        loopPRGA:
            mov eax,i
            inc eax
            xor edx,edx
            mov ebx,256
            div ebx
            mov i,edx

            mov eax,[ebp+8]
            mov edx,i
            movzx eax,BYTE PTR [eax+edx];S[jj]
            add eax,jj
            mov jj,eax
            xor edx,edx
            mov ebx,256
            div ebx

            mov jj,edx
            mov eax,[ebp+8];Sbox
            lea ebx,[eax+edx]

            xor esi,esi
            movzx esi,BYTE PTR [ebx]

            push ebx ;arg1
            mov ebx,i
            lea ebx,[eax+ebx]
            push ebx ;arg2

            xor eax,eax
            movzx eax,BYTE PTR[ebx]
            add eax,esi

            call SWAP ;swap(args1,args2)

            xor edx,edx
            mov ebx,256
            div ebx

            mov eax,[ebp+8];Sbox
            movzx eax,BYTE PTR [eax+edx]

            mov ebx,[ebp+12];message
            movzx ebx,BYTE PTR [ebx+ecx]

            xor eax,ebx
            pusha
            push eax
            push offset fmt
            call printf
            pop eax
            pop eax
            popa
            inc ecx
            cmp ecx,lenMess
            jnz loopPRGA



    mov esp,ebp
    pop ebp
    ret

PRGA ENDP


RC  PROC
        push ebp
        mov ebp,esp
        sub esp,32
            push offset sbox
            push offset key
            call KSA

            push offset message
            push offset sbox
            call PRGA



        mov esp,ebp
        pop ebp
        ret
RC  ENDP

start:

    push ebp
    mov ebp,esp
    sub esp,32


        mov eax, offset Text
        push eax ; Push text to the stack
        call printf

        push offset key ; Push
        call gets

        mov eax, offset TextP
        push eax ; Push text to the stack
        call printf

        push offset message
        call gets

        push offset key
        push offset message
        call RC

    mov esp,ebp
    pop ebp
    push 0 ; Exit code 0 (Success)
    call ExitProcess
    end start