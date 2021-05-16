-- comentário

import System.Environment
import Data.List

--funcao processar argumentos
-- processArgs args -a -s -z namesToBase
processArgs [] _ _ _ [] = return ()
processArgs [] a s z names = basename a s z (reverse names)
processArgs (x:xs) a s z names = do
  case x of
    "--help" -> putStrLn "Uso:  basename NOME [SUFIXO] \n\
                \ ou:  basename OPÇÃO... NOME...\n\
                \Mostra o NOME sem quaisquer componentes iniciais de diretório.\n\
                \Se especificado, remove também o SUFIXO final.\n\n\

                \Argumentos obrigatórios para opções longas também o são para opções curtas.\n\
                \  -a, --multiple       provê suporte a múltiplos argumentos e trata cada um\n\
                \                         como um NOME\n\
                \  -s, --suffix=SUFIXO  remove um SUFIXO; implica em -a\n\
                \  -z, --zero           termina as linhas de saída com NULO, e não nova linha\n\
                \      --help     mostra esta ajuda e sai\n\
                \      --version  informa a versão e sai\n\n\

                \Exemplos:\n\
                \  basename /usr/bin/sort          -> \"sort\"\n\
                \  basename include/stdio.h .h     -> \"stdio\"\n\
                \  basename -s .h include/stdio.h  -> \"stdio\"\n\
                \  basename -a algo/txt1 algo/txt2 -> \"txt1\" seguido de \"txt2\"\n\n\

                \Página de ajuda do GNU coreutils: <https://www.gnu.org/software/coreutils/>\n\
                \Relate erros de tradução do basename: <https://translationproject.org/team/pt_BR.html>\n\
                \Documentação completa em: <https://www.gnu.org/software/coreutils/basename>\n\
                \ou disponível localmente via: info \"(coreutils) basename invocation\""
    "--version" -> putStrLn "basename (GNU coreutils) 8.30\n\
                    \Copyright (C) 2018 Free Software Foundation, Inc.\n\
                    \Licença GPLv3+: GNU GPL versão 3 ou posterior <https://gnu.org/licenses/gpl.html>\n\
                    \Este é um software livre: você é livre para alterá-lo e redistribuí-lo.\n\
                    \NÃO HÁ QUALQUER GARANTIA, na máxima extensão permitida em lei.\n\n\

                    \Escrito por David MacKenzie."
    "-a" -> processArgs xs True s z names
    "--multiple" -> processArgs xs True s z names
    "-s" -> processArgs (tail xs) a True z ((head xs):names)
    "-z" -> processArgs xs a s True names
    "--zero" -> processArgs xs a s True names
    _ -> processArgs xs a s z (x:names)

--executa basenames com base nas flags
basename _ _ _ [] = return ()
basename False False False (x:xs) | xs == [] = putStrLn (basenameFunction x)
                                  | otherwise = putStrLn (removeSuffix (basenameFunction x) (head xs))
basename False False True (x:xs) | xs == [] = putStr (basenameFunction x)
                                 | otherwise = putStr (removeSuffix (basenameFunction x) (head xs))
basename True False z (x:xs) = do
  if z == True
    then putStr (basenameFunction x)
    else putStrLn (basenameFunction x)
  basename True False z xs
basename _ True z (x:xs) = basename True False z (unsuffixedArray x xs)

--retira endereço puro
basenameFunction name | head (last result) == '/' =  tail (last result)
                      | otherwise = last result
                      where result = groupBy (\a b -> b /= '/') name

--remove sufixos
removeSuffix :: String -> (String -> String)
removeSuffix name suffix = do
  let suffixLength = length suffix
  if length name <= suffixLength -- sufixo invalido
  then name
  else if take suffixLength (reverse name) /= reverse suffix -- sufixo invalido
       then name
       else reverse (drop suffixLength (reverse name))

--retorna array com sufixos removidos
unsuffixedArray _ [] = []
unsuffixedArray suffix (x:xs) = (removeSuffix x suffix) : (unsuffixedArray suffix xs)

main = do
    args <- getArgs

    processArgs args False False False []
