#!/usr/bin/env swipl

:- initialization(main, main).

%processArgs(Args, A, S, Z, paths)
processArgs([], A, S, Z, Paths) :-
  %print(Paths),
  basename(A, S, Z, Paths).
processArgs(['--help'| _], _, _, _, _) :-
  format('Uso:  basename NOME [SUFIXO]
 ou:  basename OPÇÃO... NOME...
Mostra o NOME sem quaisquer componentes iniciais de diretório.
Se especificado, remove também o SUFIXO final.

Argumentos obrigatórios para opções longas também o são para opções curtas.
  -a, --multiple       provê suporte a múltiplos argumentos e trata cada um
                         como um NOME
  -s, --suffix=SUFIXO  remove um SUFIXO; implica em -a
  -z, --zero           termina as linhas de saída com NULO, e não nova linha
      --help     mostra esta ajuda e sai
      --version  informa a versão e sai

Exemplos:
  basename /usr/bin/sort          -> "sort"
  basename include/stdio.h .h     -> "stdio"
  basename -s .h include/stdio.h  -> "stdio"
  basename -a algo/txt1 algo/txt2 -> "txt1" seguido de "txt2"

Página de ajuda do GNU coreutils: <https://www.gnu.org/software/coreutils/>
Relate erros de tradução do basename: <https://translationproject.org/team/pt_BR.html>
Documentação completa em: <https://www.gnu.org/software/coreutils/basename>
ou disponível localmente via: info "(coreutils) basename invocation"~n').
processArgs(['--version'| _], _, _, _, _) :-
  format('basename (GNU coreutils) 8.30
Copyright (C) 2018 Free Software Foundation, Inc.
Licença GPLv3+: GNU GPL versão 3 ou posterior <https://gnu.org/licenses/gpl.html>
Este é um software livre: você é livre para alterá-lo e redistribuí-lo.
NÃO HÁ QUALQUER GARANTIA, na máxima extensão permitida em lei.

Escrito por David MacKenzie.~n').
processArgs(['-a'|T], _, S, Z, Paths) :-
  processArgs(T, 1, S, Z, Paths).
processArgs(['-s'|T], _, _, Z, Paths) :-
  nth0(0, T, Suffix, R),
  append(Paths, [Suffix], NewList),
  processArgs(R, 1, 1, Z, NewList).
processArgs(['-z'|T], A, S, _, Paths) :-
  processArgs(T, A, S, 1, Paths).
processArgs([H|T], A, S, Z, Paths) :-
  append(Paths, [H], NewList),
  processArgs(T, A, S, Z, NewList).

%basename(A, S, Z, Paths)
basename(_, 0, 0, [X]) :-
  file_base_name(X, Name),
  format('~w~n', Name).
basename(_, 0, 1, [X]) :-
  file_base_name(X, Name),
  format('~w', Name).
basename(0, 0, 0, [Path, Suffix]) :-
  file_base_name(Path, Name),
  removeSuffix(Name, Suffix, Result),
  format('~w~n', Result).
basename(0, 0, 1, [Path, Suffix]) :-
  file_base_name(Path, Name),
  removeSuffix(Name, Suffix, Result),
  format('~w', Result).
basename(1, 0, 0, [H|T]) :-
  file_base_name(H, Name),
  format('~w~n', Name),
  basename(1, 0, 0, T).
basename(1, 0, 1, [H|T]) :-
  file_base_name(H, Name),
  format('~w', Name),
  basename(1, 0, 1, T).
basename(_, 1, Z, [H|T]) :-
  basename(1, 0, Z, T).



removeSuffix(String, String, String).
removeSuffix(String, Suffix, Result) :-
  sub_string(String, Before, _, 0, Suffix),
  sub_string(String, 0, Before, _, Result).


main(Argv) :- processArgs(Argv, 0, 0, 0, []).
