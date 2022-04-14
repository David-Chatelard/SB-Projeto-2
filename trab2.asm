;Trabalho 2 Software Basico
;Aluno: Alexandre Abrahami Pinto da Cunha
;Matricula: 18/0041169
;Sistema Operacional: Ubuntu 21.10 [64 bits] 

section .data
request db "Digite o nome do arquivo: ",0
size_request EQU $-request
instr_1 db "ADD",0ah,0dh
size_instr_1 EQU $-instr_1
instr_2 db "SUB",0ah,0dh
size_instr_2 EQU $-instr_2
instr_3 db "MULT",0ah,0dh
size_instr_3 EQU $-instr_3
instr_4 db "DIV",0ah,0dh
size_instr_4 EQU $-instr_4
instr_5 db "JMP",0ah,0dh
size_instr_5 EQU $-instr_5
instr_6 db "JMPN",0ah,0dh
size_instr_6 EQU $-instr_6
instr_7 db "JMPP",0ah,0dh
size_instr_7 EQU $-instr_7
instr_8 db "JMPZ",0ah,0dh
size_instr_8 EQU $-instr_8
instr_9 db "COPY",0ah,0dh
size_instr_9 EQU $-instr_9
instr_10 db "LOAD",0ah,0dh
size_instr_10 EQU $-instr_10
instr_11 db "STORE",0ah,0dh
size_instr_11 EQU $-instr_11
instr_12 db "INPUT",0ah,0dh
size_instr_12 EQU $-instr_12
instr_13 db "OUTPUT",0ah,0dh
size_instr_13 EQU $-instr_13
instr_14 db "STOP",0ah,0dh
size_instr_14 EQU $-instr_14

i db 0
break 0

out_file_name db "gala_quente.txt",0

msg_erro db "deu errado",0dH,0ah
size_msg_erro EQU $-msg_erro

section .bss
in_file_name resb 20
fd_in resd 1
fd_out resd 1
opcode resb 2
char resb 1

section .text
global _start
_start:
	;Pedindo o nome do arquivo a ser lido pelo simulador 
	mov eax,4
	mov ebx,1
	mov ecx,request
	mov edx,size_request
	int 80h
	mov eax,3
	mov ebx,0
	mov ecx,in_file_name
	mov edx,20
	int 80h
	mov byte [ecx + eax - 1],0
	
	;Abrindo o arquivo objeto para leitura
	mov eax,5
	mov ebx,in_file_name
	mov ecx,0
	mov edx,0755o
	int 80h
	mov dword [fd_in],eax
	
	;Criando o arquivo de saida para escrita
	mov eax,8
	mov ebx,out_file_name
	mov ecx,0755o
	int 80h
	mov dword [fd_out],eax

;Tentativa de ler e escrever todos os opcodes
lpi:
	mov ecx,1
	
	cmp break,1
	je fim
	
	push in_file_name
	call ler_arquivo
	
	push out_file_name
	call escrever_arquivo
	
	loop lpi

fim:
	;Fechando o arquivo objeto
	mov eax,6
	mov ebx,dword [fd_in]
	int 80h
	
	;Fechando o arquivo de saida
	mov eax,6
	mov ebx,dword [fd_out]
	int 80h
	
	;Finalizando o codigo
	mov eax,1
	mov ebx,0
	int 80h

;Lendo os opcodes do arquivo objeto	
ler_arquivo:
	enter 0,0

;Le todos os caracteres ate encontrar um espaco em branco	
loop_op:

	inc byte [i]

	mov eax,3
	mov ebx,dword [fd_in + i]
	mov ecx,char
	mov edx,1
	int 80h
	
	cmp char,20h
	je exit
	
	mov byte [opcode + i],char
	
	loop loop_op
	
exit:
	
	mov eax,4
	mov ebx,1
	mov ecx,opcode
	mov edx,2
	int 80h
	
	leave
	ret
	
;Escrevendo no arquivo de saida
escrever_arquivo:
	enter 0,0
	cmp byte [opcode],31h
	je num_1
	cmp byte [opcode],32h
	je num_2
	cmp byte [opcode],33h
	je num_3
	cmp byte [opcode],34h
	je num_4
	cmp byte [opcode],35h
	je num_5
	cmp byte [opcode],36h
	je num_6
	cmp byte [opcode],37h
	je num_7
	cmp byte [opcode],38h
	je num_8
	cmp byte [opcode],39h
	je num_9
num_1:
	cmp byte [opcode + 1],30h
	je num_10
	cmp byte [opcode + 1],31h
	je num_11
	cmp byte [opcode + 1],32h
	je num_12
	cmp byte [opcode + 1],33h
	je num_13
	cmp byte [opcode + 1],34h
	je num_14
	
	mov eax,4
	mov ebx,dword [fd_out]
	mov ecx,instr_1
	mov edx,size_instr_1
	int 80h	
	jmp return	
num_2:
	mov eax,4
	mov ebx,dword [fd_out]
	mov ecx,instr_2
	mov edx,size_instr_2
	int 80h	
	jmp return	
num_3:
	mov eax,4
	mov ebx,dword [fd_out]
	mov ecx,instr_3
	mov edx,size_instr_3
	int 80h	
	jmp return	
num_4:
	mov eax,4
	mov ebx,dword [fd_out]
	mov ecx,instr_4
	mov edx,size_instr_4
	int 80h	
	jmp return	
num_5:
	mov eax,4
	mov ebx,dword [fd_out]
	mov ecx,instr_5
	mov edx,size_instr_5
	int 80h	
	jmp return	
num_6:
	mov eax,4
	mov ebx,dword [fd_out]
	mov ecx,instr_6
	mov edx,size_instr_6
	int 80h
	jmp return
num_7:
	mov eax,4
	mov ebx,dword [fd_out]
	mov ecx,instr_7
	mov edx,size_instr_7
	int 80h
	jmp return
num_8:
	mov eax,4
	mov ebx,dword [fd_out]
	mov ecx,instr_8
	mov edx,size_instr_8
	int 80h
	jmp return
num_9:
	mov eax,4
	mov ebx,dword [fd_out]
	mov ecx,instr_9
	mov edx,size_instr_9
	int 80h
	jmp return
num_10:
	mov eax,4
	mov ebx,dword [fd_out]
	mov ecx,instr_10
	mov edx,size_instr_10
	int 80h
	jmp return
num_11:
	mov eax,4
	mov ebx,dword [fd_out]
	mov ecx,instr_11
	mov edx,size_instr_11
	int 80h
	jmp return
num_12:
	mov eax,4
	mov ebx,dword [fd_out]
	mov ecx,instr_12
	mov edx,size_instr_12
	int 80h
	jmp return
num_13:
	mov eax,4
	mov ebx,dword [fd_out]
	mov ecx,instr_13
	mov edx,size_instr_13
	int 80h
	jmp return
num_14:
	mov eax,4
	mov ebx,dword [fd_out]
	mov ecx,instr_14
	mov edx,size_instr_14
	int 80h
	
return:
	leave
	ret
	
erro:
	mov eax,4
	mov ebx,1
	mov ecx,msg_erro
	mov edx,size_msg_erro
	int 80h
	leave
	ret
