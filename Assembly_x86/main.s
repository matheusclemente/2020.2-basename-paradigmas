section .data
helpMsg db 'Uso:  basename NOME [SUFIXO]',0Ah,' ou:  basename OPÇÃO... NOME...',0Ah,'Mostra o NOME sem quaisquer componentes iniciais de diretório.',0Ah,'Se especificado, remove também o SUFIXO final.',0Ah,0Ah,'Argumentos obrigatórios para opções longas também o são para opções curtas.',0Ah,'    -a, --multiple       provê suporte a múltiplos argumentos e trata cada um como um NOME',0Ah,'    -s, --suffix=SUFIXO  remove um SUFIXO',59,' implica em -a',0Ah,'    -z, --zero           termina as linhas de saída com NULO, e não nova linha',0Ah,'        --help     mostra esta ajuda e sai',0Ah,'        --version  informa a versão e sai',0Ah,0Ah,'Exemplos:',0Ah,'    basename /usr/bin/sort          -> "sort"',0Ah,'    basename include/stdio.h .h     -> "stdio"',0Ah, '    basename -s .h include/stdio.h  -> "stdio"',0Ah,'    basename -a algo/txt1 algo/txt2 -> "txt1" seguido de "txt2"',0Ah,0Ah,'Página de ajuda do GNU coreutils: <https://www.gnu.org/software/coreutils/>',0Ah,'Relate erros de tradução do basename: <https://translationproject.org/team/pt_BR.html>',0Ah,'Documentação completa em: <https://www.gnu.org/software/coreutils/basename>',0Ah,'ou disponível localmente via: info "(coreutils) basename invocation"',0Ah,0
helpMsgLength equ $-helpMsg

versionMsg db 'basename (GNU coreutils) 8.30',0Ah,'Copyright (C) 2018 Free Software Foundation, Inc.',0Ah,'Licença GPLv3+: GNU GPL versão 3 ou posterior <https://gnu.org/licenses/gpl.html>',0Ah,'Este é um software livre: você é livre para alterá-lo e redistribuí-lo.',0Ah,'NÃO HÁ QUALQUER GARANTIA, na máxima extensão permitida em lei.',0Ah,0Ah,'Escrito por David MacKenzie.',0Ah,0
versionMsgLenght equ $-versionMsg

helpFlag db '--help', 0
helpLenght equ $-helpFlag

versionFlag db '--version', 0
versionLenght equ $-versionFlag

argCounter db 0

lineBreak db '',0Ah, 0

section .bss


section .text
global _start



_start:
		pop ebx ;recebe contador de argumentos
		cmp ebx, 2 ;verifica o minimo de argumentos (2)
		jl exit
		mov [argCounter], ebx - 1 ;armazena a quantidade de argumentos relevantes
		pop ebx ;remove argumento com o nome do programa
processArg:
		pop ebx ; primeiro argumento
		cmp byte [ebx], '-'
		jne basename
		call verifyHelpFlag
		call verifyVersionFlag
		mov ecx, [argCounter]
		cmp ecx, 0 ;repete o processo enquanto houverem argumentos
		mov [argCounter], ecx - 1
		jnz processArg

exit: ; Encerra o programa
		mov ebx, 0
		mov eax, 1
		int 80h

basename:
		mov edx, 0
		.incLoop:
		inc edx
		cmp byte[ebx + edx - 1], 0; verifica se a string chegou ao fim
		je .done
		cmp byte[ebx + edx], '/' ;compara cada caractere ao '/'
		jne .incLoop

		inc edx
		cmp byte [ebx + edx], 0 ;verifica se ainda há caracteres após a barra
		je .done
		add ebx, edx
		jmp basename

		.done:
		dec edx
		mov ecx, ebx
		mov ebx, 1
		mov eax, 4
		int 80h
		call printLineBreak
		jmp exit

;Subrotinas
verifyHelpFlag: ;Verifica a flag --help
		lea esi, [helpFlag]
		lea edi, [ebx]
		mov ecx, helpLenght + 1
		rep cmpsb 	;verifica igualdade das stings
		cmp ecx, 0 	;verifica se ambas as strings tem o mesmo tamanho
		jne .done

		mov edx, helpMsgLength
		mov ecx, helpMsg
		mov ebx, 1
		mov eax, 4
		int 80h 		;Imprime a mensagem de ajuda
		jmp exit
		.done:
		ret

verifyVersionFlag: ;Verifica a flag --version
		lea esi, [versionFlag]
		lea edi, [ebx]
		mov ecx, versionLenght + 1
		rep cmpsb 	; verifica igualdade das stings
		cmp ecx, 0  ;verifica se ambas as strings tem o mesmo tamanho
		jne .done

		mov edx, versionMsgLenght
		mov ecx, versionMsg
		mov ebx, 1
		mov eax, 4
		int 80h 		;Imprime a mensagem de versao
		jmp exit
		.done:
		ret

printLineBreak: ;Imprime quebra de linha
		mov edx, 3
		mov ecx, lineBreak
		mov ebx, 1
		mov eax, 4
		int 80h
		ret
