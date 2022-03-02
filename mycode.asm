.model small 
.data 
    
.code 

main proc 
    mov ah,1
    int 21h 
    
    mov ah,2
    mov dl,al 
    int 21h
    
    main endp 

end