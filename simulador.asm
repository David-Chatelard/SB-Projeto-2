;Trabalho 2 da disciplina de Software Basico
;Sistema Operacional: Ubuntu 20.04 64 bits 
;Aluno: David Fanchic Chatelard
;Matricula: 180138863

section .data
input_command db "Digite o nome do arquivo: ", 0
size_input_command EQU $-input_command

str_x_bytes_lidos db "A quantidade de bytes do arquivo escrito foi: "
size_str_x_bytes_lidos EQU $-str_x_bytes_lidos

TAM dd 150

teste db "cu", 0

opcode_add db "ADD", 0ah
size_opcode_add EQU $-opcode_add
opcode_sub db "SUB", 0ah
size_opcode_sub EQU $-opcode_sub
opcode_mult db "MULT", 0ah
size_opcode_mult EQU $-opcode_mult
opcode_div db "DIV", 0ah
size_opcode_div EQU $-opcode_div
opcode_jmp db "JMP", 0ah
size_opcode_jmp EQU $-opcode_jmp
opcode_jmpn db "JMPN", 0ah
size_opcode_jmpn EQU $-opcode_jmpn
opcode_jmpp db "JMPP", 0ah
size_opcode_jmpp EQU $-opcode_jmpp
opcode_jmpz db "JMPZ", 0ah
size_opcode_jmpz EQU $-opcode_jmpz
opcode_copy db "COPY", 0ah
size_opcode_copy EQU $-opcode_copy
opcode_load db "LOAD", 0ah
size_opcode_load EQU $-opcode_load
opcode_store db "STORE", 0ah
size_opcode_store EQU $-opcode_store
opcode_input db "INPUT", 0ah
size_opcode_input EQU $-opcode_input
opcode_output db "OUTPUT", 0ah
size_opcode_output EQU $-opcode_output
opcode_stop db "STOP", 0ah
size_opcode_stop EQU $-opcode_stop

section .bss
input_file_name resb 25 ;reserva 25 bytes
input_file_descriptor resd 1

output_file_name resb 25 ;reserva 25 bytes

output_file_descriptor resd 1

str_input resb 150 ;considerando que o arquivo de entrada tera no maximo 150 bytes

i resd 1 ;para botar TAM em ecx no loop
opcode_lido resb 2
index resd 1
has_dezena resd 1 ;flag para saber se o opcode tem dezena ou nao

bytes_lidos resd 1 ;int com bytes lidos do arquivo de saida
str_bytes_lidos_invertido resb 25 ;str com bytes lidos do arquivo de saida, vai ate 25 bytes
str_bytes_lidos resb 25 ;str com bytes lidos do arquivo de saida, vai ate 25 bytes

teste2 resb 2

const10 resb 16
index_inv resd 1
index_certo resd 1

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
	
	;Fazendo o nome do arquivo de saida ser o de entrada.diss
	;Pegando o nome do arquivo sem extensao
	mov dword ecx, 25 ;botando 25 no ecx para o loop, nome do arquivo so vai ate 25 caracteres
	mov dword [index], 0 ;inicia o indice em 0
output_file_name_loop:
	mov ebx, [index]			 ;bota o indice a ser lido no ebx
	mov al, byte [input_file_name+ebx] ;le o char nesse indice e salva em al

	cmp al, 2eh 				 ;verifica se o char lido foi "."
	jne salva_char_lido			 ;se nao for, salva em output_file_name e vai para a proxima iteracao do loop
	;Se foi "." significa que o que esta em output_file_name ja eh o nome do arquivo de entrada
	;Adiciona o "." no nome do arquivo de saida e termina o loop
	mov ebx, [index]
	mov byte [output_file_name+ebx], al
	jmp finish_loop_output_name

	salva_char_lido:
	mov ebx, [index]
	mov byte [output_file_name+ebx], al

	incrementa_index_output_name:
	inc dword [index]	;incrementa o indice a ser lido da string

	loop output_file_name_loop

finish_loop_output_name:
	;Botando o .diss no nome do arquivo de saida
	inc dword [index]	;incrementa o indice a ser lido da string
	mov ebx, [index]
	mov byte [output_file_name+ebx], "d"
	inc dword [index]	;incrementa o indice a ser lido da string
	mov ebx, [index]
	mov byte [output_file_name+ebx], "i"
	inc dword [index]	;incrementa o indice a ser lido da string
	mov ebx, [index]
	mov byte [output_file_name+ebx], "s"
	inc dword [index]	;incrementa o indice a ser lido da string
	mov ebx, [index]
	mov byte [output_file_name+ebx], "s"

	;Chamada 8, criando o arquivo de saida
	mov eax, 8
	mov ebx, output_file_name
	mov ecx, 0755o
	int 80h
	
	mov dword [output_file_descriptor], eax  ;salvando o file descriptor
	
	;Funcao para ler do arquivo de entrada
	push str_input
	push dword [input_file_descriptor]
	call le_do_arquivo

	;Chamada 3, input, para ler do arquivo de entrada
	;mov eax, 3
	;mov ebx, [input_file_descriptor]
	;mov ecx, str_input
	;mov edx, TAM ;conteudo do arquivo so vai ate 150 bytes
	;int 80h

	;Print de teste-------------------------------
	;Chamada 4, print na tela para testar
	;mov eax, 4
	;mov ebx, 1
	;mov ecx, str_input
	;mov edx, TAM
	;int 80h
	;Print de teste-------------------------------

	;Loop para ler os opcodes
	mov dword [i], TAM ;salvando TAM para por no ecx
	mov dword ecx, [i] ;botando TAM no ecx para o loop
	mov dword [index], 0 ;inicia o indice em 0
	mov dword [has_dezena], 0 ;inicia a flag em 0

loop_begin:
	mov ebx, [index]			 ;bota o indice a ser lido no ebx
	mov al, byte [str_input+ebx] ;le o char nesse indice e salva em al

	cmp al, 20h 				 ;verifica se o char lido foi " "
	jne salva_opcode			 ;se nao for salva em opcode_lido e vai para a proxima iteracao do loop
	;Se foi " " significa que o que esta em opcode_lido ja eh o opcode inteiro

	push str_input
	push dword [output_file_descriptor]
	push dword [index]
	push dword [has_dezena]
	push word [opcode_lido]
	call escreve_opcode
	mov dword [index], eax

	mov dword [has_dezena], 0 	 ;volta a flag para 0 para o proximo opcode

	;botar por aqui uma condicao de parada
	cmp byte [opcode_lido], "1"
	jne not_end
	cmp byte [opcode_lido+1], "4"
	jne not_end
	jmp end_loop
not_end:
	jmp incrementa_index		 ;incrementa o indice e vai para a proxima iteracao do loop

salva_opcode:
	mov ebx, [has_dezena]
	mov byte [opcode_lido+ebx], al
	inc dword [has_dezena]

incrementa_index:
	inc dword [index]	;incrementa o indice a ser lido da string

	loop loop_begin
end_loop:
	
	;Botei essa chamada no final da funcao le_do_arquivo
	;Chamada 6, para fechar o arquivo de entrada
	;mov eax, 6
	;mov ebx, dword [input_file_descriptor]
	;int 80h

	;Chamada 6, para fechar o arquivo de saida
	mov eax, 6
	mov ebx, dword [output_file_descriptor]
	int 80h

	;Chamada 5, para abrir o arquivo de saida em leitura
	mov eax, 5
	mov ebx, output_file_name
	mov ecx, 0      ;modo de leitura
	mov edx, 0755o  ;permissoes
	int 80h

	mov dword [output_file_descriptor], eax  ;salvando o file descriptor

	;Chamada 3, input, para ler do arquivo de saida
	mov eax, 3
	mov ebx, dword [output_file_descriptor]
	mov ecx, str_input
	mov edx, TAM ;conteudo do arquivo so vai ate 150 bytes
	int 80h

	mov dword [bytes_lidos], eax

	;Convertendo o int de bytes_lidos para str, porem fica numa str invertida
	mov dword ecx, 25 ;botando 25 no ecx para o loop
	mov dword [index], 0 ;inicia o indice em 0
	mov word [const10], 10
	mov eax, 0 					 ;quociente
	mov edx, 0 					 ;resto
	mov eax, dword [bytes_lidos] ;quociente
	shr eax, 16 ;shift pra direita de 16 bits, para os 16 bits mais significativos ficaram em ax
	mov dx, ax	;passando os 16 bits mais significativos para dx
	mov eax, dword [bytes_lidos] ;quociente ;voltando os 16 bits menos significativos para ax
loop_converte_to_str:
	mov edx, 0 					 ;resto
	mov ebx, 0					 ;indice a ser escrito
	mov ebx, [index]			 ;bota o indice a ser escrito no ebx
	div word [const10]			 ;ax = dx.ax/10, dx = dx.ax%10
	add dx, 30h				 ;converte de int para char
	mov byte [str_bytes_lidos_invertido+ebx], dl ;escreve os 8 bits menos significativos do resto nesse indice de str_bytes_lidos_invertido

	cmp ax, 0					 ;verifica se o quociente eh 0
	jne continua_dividindo		 ;se nao for, ainda tem que dividir mais
	;Se for 0, o numero todo ja esta na str_bytes_lidos_invertido

	jmp termina_converte_to_str

	continua_dividindo:

	inc dword [index]	;incrementa o indice a ser escrito na string
	loop loop_converte_to_str
termina_converte_to_str:

	;Desinvertendo a str
	mov dword ecx, 25 ;botando 25 no ecx para o loop
	mov eax, dword [index]
	mov dword [index_inv], eax
	mov dword [index_certo], 0
loop_desinverte_str:
	mov ebx, dword [index_inv]		 ;bota o indice a ser lido da str invertida no ebx
	mov al, byte [str_bytes_lidos_invertido+ebx] ;le o char nesse indice e salva em al
	mov ebx, dword [index_certo]			 ;bota o indice a ser escrito na str no ebx
	mov [str_bytes_lidos+ebx], al ;escreve o char lido nesse indice

	cmp dword [index_inv], 0
	je end_loop_desinverte_str

	inc dword [index_certo]	;incrementa o indice a ser escrito na string
	dec dword [index_inv]	;decrementa o indice a ser lido da str invertida
	loop loop_desinverte_str

end_loop_desinverte_str:

	;Botando quebra de linha no final da string, mas nem precisa, pode tirar isso se quiser
	inc dword [index_certo]	;incrementa o indice a ser escrito na string
	mov ebx, dword [index_certo]			 ;bota o indice a ser escrito na str no ebx
	mov byte [str_bytes_lidos+ebx], 0ah ;escreve quebra de linha

	;Chamada 4, print na tela "A quantidade de bytes do arquivo escrito foi: "
	mov eax, 4
	mov ebx, 1
	mov ecx, str_x_bytes_lidos
	mov edx, size_str_x_bytes_lidos
	int 80h

	;Chamada 4, print na tela da quantidade de bytes do arquivo escrito
	mov eax, 4
	mov ebx, 1
	mov ecx, str_bytes_lidos
	mov edx, 25
	int 80h

	;Finalizando o programa
	mov eax, 1
	mov ebx, 0
	int 80h

le_do_arquivo:
	enter 0, 0

	;Chamada 3, input, para ler do arquivo de entrada
	mov eax, 3
	mov ebx, [ebp+8]
	mov ecx, str_input
	mov edx, TAM ;conteudo do arquivo so vai ate 150 bytes
	int 80h

	;Chamada 6, para fechar o arquivo de entrada
	mov eax, 6
	mov ebx, dword [input_file_descriptor]
	int 80h

	leave
	ret

cu:
	;Chamada 4, print na tela para testar
	mov eax, 4
	mov ebx, 1
	mov ecx, teste
	mov edx, 2
	int 80h
	ret

escreve_opcode:
	;ebp+8 == [opcode_lido]
	;ebp+10 == [has_dezena]
	;ebp+14 == [index]
	;ebp+18 == [output_file_descriptor]
	;ebp+22 == str_input
	enter 0, 0
	;Verificando se o opcode tem dezena
	cmp dword [ebp+10], 1
	je naoDezena

	cmp byte [ebp+8+1], 30h ;compara com "0"
	jne naoDezenaZero

	;Escreve o opcode "LOAD" no arquivo de saida

	;Chamada 4, escrever no arquivo de saida
	mov eax, 4
	mov ebx, [ebp+18]
	mov ecx, opcode_load
	mov edx, size_opcode_load
	int 80h

	;add dword [ebp+14], 3		;atualiza o valor do index para pular os operandos e so ler os opcodes

	push dword [ebp+22]
	push dword [ebp+14]
	call pula_operando
	mov dword [ebp+14], eax

	jmp end_func

naoDezenaZero:
	cmp byte [ebp+8+1], 31h ;compara com "1"
	jne naoDezenaUm

	;Escreve o opcode "STORE" no arquivo de saida

	;Chamada 4, escrever no arquivo de saida
	mov eax, 4
	mov ebx, [ebp+18]
	mov ecx, opcode_store
	mov edx, size_opcode_store
	int 80h

	;add dword [ebp+14], 3		;atualiza o valor do index para pular os operandos e so ler os opcodes


	push dword [ebp+22]
	push dword [ebp+14]
	call pula_operando
	mov dword [ebp+14], eax


	jmp end_func

naoDezenaUm:
	cmp byte [ebp+8+1], 32h ;compara com "2"
	jne naoDezenaDois

	;Escreve o opcode "INPUT" no arquivo de saida

	;Chamada 4, escrever no arquivo de saida
	mov eax, 4
	mov ebx, [ebp+18]
	mov ecx, opcode_input
	mov edx, size_opcode_input
	int 80h

	;add dword [ebp+14], 3		;atualiza o valor do index para pular os operandos e so ler os opcodes


	push dword [ebp+22]
	push dword [ebp+14]
	call pula_operando
	mov dword [ebp+14], eax


	jmp end_func

naoDezenaDois:
	cmp byte [ebp+8+1], 33h ;compara com "3"
	jne naoDezenaTres

	;Escreve o opcode "OUTPUT" no arquivo de saida

	;Chamada 4, escrever no arquivo de saida
	mov eax, 4
	mov ebx, [ebp+18]
	mov ecx, opcode_output
	mov edx, size_opcode_output
	int 80h

	;add dword [ebp+14], 3		;atualiza o valor do index para pular os operandos e so ler os opcodes


	push dword [ebp+22]
	push dword [ebp+14]
	call pula_operando
	mov dword [ebp+14], eax


	jmp end_func

naoDezenaTres:
	;Se tiver dezena depois tem que ser "0", "1", "2", "3" ou "4", entao nem precisa comparar com "4", pois eh a ultima opcao
	cmp byte [ebp+8+1], 34h ;compara com "4"
	jne naoDezena

	;Escreve o opcode "STOP" no arquivo de saida

	;Chamada 4, escrever no arquivo de saida
	mov eax, 4
	mov ebx, [ebp+18]
	mov ecx, opcode_stop
	mov edx, size_opcode_stop
	int 80h

	jmp end_func

naoDezena:
	;Fazer as verificacoes para os opcodes unitarios
	cmp byte [ebp+8], 31h ;compara com "1"
	jne naoUm
	
	;Escreve o opcode "ADD" no arquivo de saida

	;Chamada 4, escrever no arquivo de saida
	mov eax, 4
	mov ebx, [ebp+18]
	mov ecx, opcode_add
	mov edx, size_opcode_add
	int 80h

	;add dword [ebp+14], 3		;atualiza o valor do index para pular os operandos e so ler os opcodes


	push dword [ebp+22]
	push dword [ebp+14]
	call pula_operando
	mov dword [ebp+14], eax


	jmp end_func

naoUm:
	cmp byte [ebp+8], 32h ;compara com "2"
	jne naoDois
	
	;Escreve o opcode "SUB" no arquivo de saida

	;Chamada 4, escrever no arquivo de saida
	mov eax, 4
	mov ebx, [ebp+18]
	mov ecx, opcode_sub
	mov edx, size_opcode_sub
	int 80h

	;add dword [ebp+14], 3		;atualiza o valor do index para pular os operandos e so ler os opcodes


	push dword [ebp+22]
	push dword [ebp+14]
	call pula_operando
	mov dword [ebp+14], eax


	jmp end_func

naoDois:
	cmp byte [ebp+8], 33h ;compara com "3"
	jne naoTres
	
	;Escreve o opcode "MULT" no arquivo de saida

	;Chamada 4, escrever no arquivo de saida
	mov eax, 4
	mov ebx, [ebp+18]
	mov ecx, opcode_mult
	mov edx, size_opcode_mult
	int 80h

	;add dword [ebp+14], 3		;atualiza o valor do index para pular os operandos e so ler os opcodes


	push dword [ebp+22]
	push dword [ebp+14]
	call pula_operando
	mov dword [ebp+14], eax


	jmp end_func

naoTres:
	cmp byte [ebp+8], 34h ;compara com "4"
	jne naoQuatro
	
	;Escreve o opcode "DIV" no arquivo de saida

	;Chamada 4, escrever no arquivo de saida
	mov eax, 4
	mov ebx, [ebp+18]
	mov ecx, opcode_div
	mov edx, size_opcode_div
	int 80h

	;add dword [ebp+14], 3		;atualiza o valor do index para pular os operandos e so ler os opcodes


	push dword [ebp+22]
	push dword [ebp+14]
	call pula_operando
	mov dword [ebp+14], eax


	jmp end_func

naoQuatro:
	cmp byte [ebp+8], 35h ;compara com "5"
	jne naoCinco
	
	;Escreve o opcode "JMP" no arquivo de saida

	;Chamada 4, escrever no arquivo de saida
	mov eax, 4
	mov ebx, [ebp+18]
	mov ecx, opcode_jmp
	mov edx, size_opcode_jmp
	int 80h

	;add dword [ebp+14], 3		;atualiza o valor do index para pular os operandos e so ler os opcodes


	push dword [ebp+22]
	push dword [ebp+14]
	call pula_operando
	mov dword [ebp+14], eax


	jmp end_func

naoCinco:
	cmp byte [ebp+8], 36h ;compara com "6"
	jne naoSeis
	
	;Escreve o opcode "JMPN" no arquivo de saida

	;Chamada 4, escrever no arquivo de saida
	mov eax, 4
	mov ebx, [ebp+18]
	mov ecx, opcode_jmpn
	mov edx, size_opcode_jmpn
	int 80h

	;add dword [ebp+14], 3		;atualiza o valor do index para pular os operandos e so ler os opcodes


	push dword [ebp+22]
	push dword [ebp+14]
	call pula_operando
	mov dword [ebp+14], eax


	jmp end_func

naoSeis:
	cmp byte [ebp+8], 37h ;compara com "7"
	jne naoSete
	
	;Escreve o opcode "JMPP" no arquivo de saida

	;Chamada 4, escrever no arquivo de saida
	mov eax, 4
	mov ebx, [ebp+18]
	mov ecx, opcode_jmpp
	mov edx, size_opcode_jmpp
	int 80h

	;add dword [ebp+14], 3		;atualiza o valor do index para pular os operandos e so ler os opcodes


	push dword [ebp+22]
	push dword [ebp+14]
	call pula_operando
	mov dword [ebp+14], eax


	jmp end_func

naoSete:
	cmp byte [ebp+8], 38h ;compara com "8"
	jne naoOito
	
	;Escreve o opcode "JMPZ" no arquivo de saida

	;Chamada 4, escrever no arquivo de saida
	mov eax, 4
	mov ebx, [ebp+18]
	mov ecx, opcode_jmpz
	mov edx, size_opcode_jmpz
	int 80h

	;add dword [ebp+14], 3		;atualiza o valor do index para pular os operandos e so ler os opcodes


	push dword [ebp+22]
	push dword [ebp+14]
	call pula_operando
	mov dword [ebp+14], eax


	jmp end_func

naoOito:
	;Se nao tiver dezena tem que ser "0", "1", ..., "9", entao nem precisa comparar com "9", pois eh a ultima opcao
	cmp byte [ebp+8], 39h ;compara com "9"
	jne end_func
	
	;Escreve o opcode "COPY" no arquivo de saida

	;Chamada 4, escrever no arquivo de saida
	mov eax, 4
	mov ebx, [ebp+18]
	mov ecx, opcode_copy
	mov edx, size_opcode_copy
	int 80h

	;add dword [ebp+14], 6		;atualiza o valor do index para pular os operandos e so ler os opcodes


	push dword [ebp+22]
	push dword [ebp+14]
	call pula_operando
	mov dword [ebp+14], eax

	push dword [ebp+22]
	push dword [ebp+14]
	call pula_operando
	mov dword [ebp+14], eax


	jmp end_func

end_func:
	mov eax, dword [ebp+14]
	leave
	ret

pula_operando:
	;ebp+8 == [index]
	;ebp+12 == str_input
	enter 0, 0

	mov eax, dword [ebp+12]
	inc dword [ebp+8]	;incrementa o indice a ser lido da string
	mov dword ecx, 6 ;botando 6 no ecx para o loop
loop_start:
	mov ebx, [ebp+8]			 ;bota o indice a ser lido no ebx
	mov al, byte [str_input+ebx]    ;le o char nesse indice e salva em al
	mov byte [teste2], al
	mov byte [teste2+1], 0ah

	;Print de teste-------------------------------
	push eax
	push ebx
	push ecx

	;Chamada 4, print na tela para testar
	;mov eax, 4
	;mov ebx, 1
	;mov ecx, teste2
	;mov edx, 8
	;int 80h

	pop ecx
	pop ebx
	pop eax
	;Print de teste-------------------------------

	cmp al, 20h 				 ;verifica se o char lido foi " "
	jne aumenta_index			 ;se nao for, incrementa o index e vai pra proxima iteracao
	;Se foi " " significa que ja passou do operando
	jmp finish_loop_func

aumenta_index:
	inc dword [ebp+8]	;incrementa o indice a ser lido da string

	loop loop_start

finish_loop_func:
	mov eax, dword [ebp+8]
	leave
	ret
