section .data
input_command db "Digite o nome do arquivo: ", 0
size_input_command EQU $-input_command

output_file_name db "saida.asm", 0

section .bss
input_file_name resb 25 ;reserva 25 bytes
input_file_descriptor resd 1

output_file_descriptor resd 1

section .text
global _start
_start:
	;Chamada 4, print na tela para pedir o nome do arquivo
	mov eax, 4
	mov ebx, 1
	mov ecx, input_command
	mov edx, size_input_command
	int 80h
	
	;Chamada 3, input, para ler o nome do arquivo
	mov eax, 3
	mov ebx, 0
	mov ecx, input_file_name
	mov edx, 25 ;nome do arquivo so vai ate 25 caracteres
	int 80h
	
	mov byte [ecx + eax - 1], 0 ;bota 0 no final da string com o nome do arquivo, para poder abrir o arquivo para leitura
	
	;Chamada 5, para abrir o arquivo no modo de leitura
	mov eax, 5
	mov ebx, input_file_name
	mov ecx, 0      ;modo de leitura
	mov edx, 0755o  ;permissoes
	int 80h
	
	mov dword [input_file_descriptor], eax  ;salvando o file descriptor
	
	;Chamada 8, criando o arquivo de saida
	mov eax, 8
	mov ebx, output_file_name
	mov ecx, 0755o
	int 80h
	
	mov dword [output_file_descriptor], eax  ;salvando o file descriptor
	
	;Ler os opcodes
	
	;Chamada , para fechar o arquivo
	mov eax, 6
	mov ebx, dword [input_file_descriptor]
	int 80h
	
	
	;Finalizando o programa
	mov eax, 1
	mov ebx, 0
	int 80h
