SECTION .data
  KEY        TIMES    4096 DB -1
  lenKEY 		    DD 0
  PLAIN_TEXT TIMES    4096 DB -1
  lenPLAIN_TEXT            DD 0
  MAX_LEN                  DD 4096
  INTRO1                   DB 'RC4Encryption __Enter Key__ :',10,' '
  INTRO2                   DB 'Enter Message to Encrypt : ',10
  INTRO3 	            DB 'YOUR DATA HAVE BEEN ENCRYPTED!!!',10, ' '

SECTION .bss

Key resb 4096
Message resb 4096
S 	resb 256
SECTION .text

GLOBAL _start

printFunction:
	push ebp        ;push ebp on the stack
	mov ebp,esp	;move pointer-ebp to pointer-esp
	sub esp,0x20	;allocate memory in stack for variable
	pusha


	mov eax,4 	;code of register in system
	mov ebx,1
	lea ecx,[ebp+12]
	mov edx,[ebp+8]
	int 0x80


	popa
	mov esp,ebp     ;epilog
	pop ebp		;popup  pointer
	ret		;go back
scanFunction:
	push ebp
	mov ebp,esp
	sub esp,0x20

	mov eax,3
	mov ebx,2
	mov ecx,[ebp+8]
  	xor edx,edx
	mov edx,MAX_LEN
	int 0x80

	mov esp,ebp
	pop ebp
	ret
handlePrintFunction:
	push ebp
	mov ebp,esp
	sub esp,0x20

	mov esi,[ebp+8]
	startloop:
		lodsb

		push eax
		push 1
		call printFunction

		cmp al,10
		jne startloop

	mov esp,ebp
	pop ebp
	ret

SWAP:
  push ebp
  mov ebp, esp
  sub esp,0x30

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

PRGA:
  push ebp
  mov ebp, esp
  sub esp,0x20
  	push INTRO3
  	call handlePrintFunction
  	xor ecx,ecx

  	lea eax,[ebp-4] ;i=0
  	mov ebx,0
  	mov [eax],ebx
  	lea eax,[ebp-8] ;j=0
  	mov ebx,0
  	mov [eax],ebx
   	;[ebp+8] - Sbox
  	loopPRGA:
  		mov eax,[ebp-4]
  		inc eax
  		mov ebx,256
  		xor edx,edx
  		div ebx
  		mov [ebp-4],edx ;i

  		mov eax,[ebp+8];S box
  		mov al,[eax+edx]
  		mov bl,[ebp-8];j
  		add al,bl; j=(j+S[i])
  		movzx eax,al

  		xor edx,edx
  		mov ebx,256
  		div ebx
  		mov eax,edx
  		lea edx,[ebp-8];j
  		mov [edx],al
  		;al - j

  		movzx eax,al
  		mov ebx,[ebp+8]
  		lea ebx,[ebx+eax]
  		push ebx

  		xor esi,esi
  		mov bl,[ebx]
  		movzx esi,bl

  		mov eax,[ebp-4];i
  		mov ebx,[ebp+8];sbox
  		lea ebx,[ebx+eax]
  		push ebx

  		mov bl,[ebx]
  		movzx ebx,bl
  		add esi,ebx

  		call SWAP
  		mov eax,esi
  		mov ebx,0xff
  		and eax,ebx
  		xor edx,edx
  		mov ebx,256
  		div ebx


  		mov eax,[ebp+8];sbox
  		xor ebx,ebx
  		mov bl,[eax+edx]
  		movzx ebx,bl

  		mov eax,[ebp+12];plain text
  		mov al,[eax+ecx]
  		movzx eax,al
  		xor eax,ebx

  		push eax
  		call printNumber

  		inc ecx
  		mov eax,[lenPLAIN_TEXT]
  		cmp ecx,eax
  		jne loopPRGA


  push 10
  push 1
  call printFunction
  mov esp,ebp
  pop ebp
  ret
KSA:
  push ebp
  mov ebp, esp
  sub esp,0x20

	  mov edi,[ebp+8]  ; key
	  mov ebx,[ebp+12] ; BOX S
  xor ecx,ecx
  xor eax,eax
  xor edx,edx

  mov ecx,256
  loopKSA1:

  	  dec ecx
  	  mov [ebx+ecx],cl
	  cmp ecx,0
	  jnz loopKSA1

  lea eax,[ebp-4]
  xor ebx,ebx
  mov [eax],ebx
  xor esi,esi
  xor ecx,ecx
  loopKSA2:
  	 mov eax,ecx
  	 xor edx,edx
  	 mov ebx,[lenKEY]
  	 div ebx
  	 mov eax,edx
  	 mov edx,[ebp+8]
  	 mov edx,[edx+eax];KEY[i%lenKEY]
  	 mov eax,edx

  	 mov edx,[ebp+12]
  	 mov edx,[edx+ecx]
	 add eax,edx
	 mov edx,0xff
	 and eax,edx

	 mov edx,[ebp-4]
	 add eax,edx

	 xor edx,edx
	 mov ebx,256
	 div ebx
	 mov eax,edx

	 lea edx,[ebp-4]
	 mov [edx],eax

	 mov edx,[ebp+12]
	 lea edx,[edx+ecx]
	 push edx
	 mov edx,[ebp+12]
	 lea edx,[edx+eax]
	 push edx
	 call SWAP


 	 inc ecx
  	 cmp ecx,256
  	 jne loopKSA2

  mov esp,ebp
  pop ebp
  ret

RC4:
  push ebp
  mov ebp, esp
  sub esp,0x20

  mov eax,[ebp+12] ;key
  mov ebx,S 	   ;BOX

  push S
  push eax
  call KSA

  mov eax,[ebp+8];message
  push eax
  push S
  call PRGA


  mov esp,ebp
  pop ebp
  ret
storeInArray:
  push ebp
  mov ebp, esp
  sub esp,0x20
  pusha
  mov ecx,[ebp+16] ;len of string
  mov esi, [ebp+8] ;string
  mov edi,[ebp+12] ;Array wanna push

	  loopStore :
	  	lodsb
	  	cmp al,10
	  	jz next
	  	mov [edi+ecx],al

  		dec ecx
  		jnz loopStore
  next:
	  popa
	  mov esp,ebp
	  pop ebp
	  ret
endLoopPrint:
	add eax,48
	push eax
	push 1
	inc ecx
	jmp loopPrint
printNumber:
	  push ebp
	  mov ebp, esp
	  sub esp,0x30
 	  pusha
 	  	mov eax,[ebp+8]
		xor edx,edx
 	        xor ecx,ecx

	      loopDivide :
	      		  xor edx,edx
		 	  mov ebx,10
		 	  div ebx
		 	  add edx,48
		 	  push edx
		 	  push 1
	 	  	  inc ecx
	 	  	  cmp eax,10
	 	  	  jae loopDivide
			  jmp endLoopPrint

	       loopPrint:
	 	  call printFunction
	 	  pop eax
	  	  pop eax
	 	  dec ecx
	 	  cmp ecx,0
	 	  jnz loopPrint


		  push ' '
		  push 1
		  call printFunction
		  pop eax
		  pop eax
		  popa
		  mov esp,ebp
		  pop ebp
		  ret
length:
  push ebp
  mov ebp, esp
  sub esp,0x20

  mov ecx,0
  mov esi,[ebp+8];string
  	loopLength:
  		lodsb
  		inc ecx
  		cmp al,10
  		jne loopLength
  dec ecx ; remove '\n'
  mov eax,ecx
  mov esp,ebp
  pop ebp
  ret
_start:

  ;--------------INPUT-----------------------
  push INTRO1
  call handlePrintFunction

  push Key
  call scanFunction	;get input from user
  push Key
  call length
  mov eax,lenKEY
  mov [eax],ecx

  mov eax,[lenKEY]
  push eax
  mov eax,KEY
  push eax
  push Key
  call storeInArray

  push INTRO2
  call handlePrintFunction

  push Message
  call scanFunction
  push Message
  call length
  mov eax,lenPLAIN_TEXT
  mov [eax],ecx

  mov eax,[lenPLAIN_TEXT]
  push eax
  mov eax,PLAIN_TEXT
  push eax
  push Message
  call storeInArray

  ;-------------------RC4---------
  push Key
  push Message
  call RC4

  mov eax,1	; end of program
  mov ebx,0
  int 0x80

