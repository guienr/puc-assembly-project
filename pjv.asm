TITLE JOGO DA VELHA           ; Título do programa

.MODEL SMALL                  ; Define o modelo de memória como SMALL (código e dados em um único segmento de 64K)

INCLUDE mac.inc               ; Inclui a biblioteca com as macros

.STACK 100                    ; Reserva 100h para a pilha

.DATA                         ; Início da seção de dados
M DB 1, 2, 3                  ; Definição do tabuleiro 3x3 
  DB 4, 5, 6                  ; Inicialmente preenchido com números que serão substituídos por 'O' ou 'X'
  DB 7, 8, 9
MSG1 DB 13, 10, "Digite a posição que deseja colocar O: $" ; Mensagem para o Jogador 'O'
MSG2 DB 13, 10, "Digite a posição que deseja colocar X: $" ; Mensagem para o Jogador 'X' (humano)
MSG3 DB 13, 10, "Essa posição já foi ocupada $"           ; Mensagem de erro de posição ocupada
MSG4 DB 13, 10, "O jogador 'O' venceu! $"                 ; Mensagem de vitória para 'O'
MSG5 DB 13, 10, "O jogador 'X' venceu! $"                 ; Mensagem de vitória para 'X'
MSG6 DB 13, 10, "Empate! $"                              ; Mensagem de empate
MSG7 DB 13, 10, "Posição inválida $"                     ; Mensagem de erro de entrada (não é 1-9)
MSG_MODO DB 13, 10, "Modos de jogo: $"                    ; Título do menu
MSG_ESCOLHA DB 13, 10, "Escolha o modo de jogo: $"          ; Mensagem para escolha
MSG_E1 DB 13, 10, "(1) Jogador vs Jogador $"               ; Opção 1: JvJ
MSG_E2 DB 13, 10, "(2) Jogador vs Bot $"                   ; Opção 2: JvBot
MSG_BOT DB 13, 10, "Bot 'X' esta pensando... $"             ; Mensagem quando o bot está jogando
MSG_MV DB 13, 10, "Modo de jogo inválido $"               ; Mensagem para modo de jogo escolhido inválido
modo_jogo DB 0                                           ; Variável: 1=JvJ, 2=JvBot
rand_seed DW 12345                                      ; Semente inicial para o gerador pseudoaleatório (LFSR)


.CODE                          ; Início da seção de código
MAIN PROC                      ; Define a função principal
    MOV AX, @DATA              ; Carrega o endereço da seção de dados em AX
    MOV DS, AX                 ; Configura o registrador de segmento de dados DS

    ; Menu de seleção de modo
    SELECIONAR_MODO:           ; Define um rótulo para seleção de modo
    IMPRIMIR MSG_MODO          ; Função para exibir string de modo de jogo
    IMPRIMIR MSG_E1            ; Exibe opção 1    
    IMPRIMIR MSG_E2            ; Exibe opção 2    
    IMPRIMIR MSG_ESCOLHA       ; Exibe o prompt de escolha
    
    LER                        ; Função para ler um caractere
                               ; O caractere lido vai para AL
    
    CMP AL, "1"                ; Compara a entrada com o caractere '1'
    JE MODO_JVJ                ; Se igual, salta para JvJ
    
    CMP AL, "2"                ; Compara a entrada com o caractere '2'
    JE MODO_JVBOT              ; Se igual, salta para JvBot

    IMPRIMIR MSG_MV            ; Função para exibir string
                               ; "Modo de jogo inválido" 

    JMP SELECIONAR_MODO        ; Se não for '1' nem '2', repete o menu e salta incondicionamente para o rótulo
    
    MODO_JVJ:                  ; Define o rótulo para o modo jogador vs jogador
    MOV [modo_jogo], 1         ; Define o modo_jogo = 1 (Jogador vs Jogador)
    JMP INICIAR_PARTIDA        ; Vai para o jogo, salta incondicionalmente para o rótulo
    
    MODO_JVBOT:                ; Define o rótulo para o modo jogador vs bot
    MOV [modo_jogo], 2         ; Define o modo_jogo = 2 (Jogador vs Bot)

    INICIAR_PARTIDA:           ; Define o rótulo para início da partida
    ; Loop jogo principal
    MOV CX, 9                  ; Inicializa o contador de jogadas (máximo de 9 jogadas)

    JOGO:                      ; Define o rótulo do jogo
    CALL IMPRIMIRM             ; Chama a rotina para imprimir o tabuleiro
    CALL ESCOLHA               ; Chama a rotina para obter a jogada (SI = índice 0-8)

    ; Verifica se a posição em M[SI] já está ocupada
    CMP M[BX+SI], "O"          ; Compara M[BX+SI] com o caractere 'O'
    JE ERRO                    ; Se 'O', houve erro pois a posição já ocupada

    CMP M[BX+SI], "X"          ; Compara M[BX+SI] com o caractere 'X'
    JE ERRO                    ; Se 'X', houve erro pois a posição já ocupada

    JMP PREENCHER              ; Se não for 'O' nem 'X' é um número, a posição é válida

    ERRO:                      ; Define o rótulo para erros
    IMPRIMIR MSG3              ; Exibe a mensagem de erro
                               ; "Essa posição já foi ocupada"
    JMP JOGO                   ; Volta incondicionalmente para o início do turno sem decrementar CX (jogada não contada)

    PREENCHER:                 ; Define o rótulo para preencher
    CALL POS                   ; Coloca 'O' ou 'X' no tabuleiro (M[SI])
    CALL VERIFICAR_VITORIA     ; Verifica se a jogada resultou em vitória

    LOOP JOGO                  ; Decrementa CX e se CX for diferente 0, volta para JOGO

    ; Empate
    ; Se o loop terminar (CX=0) e ninguém venceu
    CALL IMPRIMIRM             ; Imprime o tabuleiro final
    IMPRIMIR MSG6              ; Exibe a mensagem de empate
                               ; "Empate!"

    FINAL:                     ; Define o rótulo para encerrar o jogo
    ; Finalização do programa                
    MOV AH, 4CH                ; Função para terminar o programa
    INT 21h
MAIN ENDP                      ; Encerra a função principal


; Procedimento para imprimir o tabuleiro na tela
IMPRIMIRM PROC                 ; Define a função de impressão do tabuleiro
    PUSH CX                    ; Salva registradores usados na pilha
    PUSH AX
    PUSH BX
    PUSH SI
    PUSH DX

    XOR BX, BX                 ; Limpa o conteúdo de BX
    MOV CH, 3                  ; CH = Contador de linhas (3)

   
    LINHA:                     ; Define o rótulo das linhas
    PULA_LINHA                 ; Caractere CR
                               ; Caractere LF
    MOV CL, 3                  ; CL = Contador de colunas (3)
    XOR SI, SI                 ; Limpa o conteúdo de SI

    COLUNA:                    ; Define o rótulo das colunas
    MOV DL, M[BX+SI]           ; Move o valor do elemento (1-9, 'O' ou 'X') para DL
    OR DL, 30h                 ; Converte o número para ASCII
    INT 21h                    ; Exibe o caractere
    ESPACO                     ; Da um espaço
    INC SI                     ; Incrementa o offset da coluna
    DEC CL                     ; Decrementa o contador de colunas
    JNZ COLUNA                 ; Repete para a próxima coluna se CL for diferente de 0

    ADD BX, 3                  ; Avança o offset para o início da próxima linha
    DEC CH                     ; Decrementa o contador de linhas
    JNZ LINHA                  ; Repete para a próxima linha se CH for diferente de 0

    POP DX                     ; Restaura os registradores salvos
    POP SI
    POP BX
    POP AX
    POP CX

    RET                        ; Retorna para a função principal
IMPRIMIRM ENDP                 ; Encerra a função de impressão do tabuleiro

; Procedimento que determina o jogador e obtém a posição.
; Saída: BX (0-3-6)
       ; SI (0-1-2)
ESCOLHA PROC                   ; Define a função de escolha

    PUSH AX                    ; Salva AX na pilha

    MOV AX, 1                  ; Move 1 para o conteúdo de AX para a checagem de paridade
    AND AX, CX                 ; Checa se CX (contador de jogadas restantes) é ímpar (O) ou par (X)

    CMP AX, 1                  ; Compara o conteúdo de AX com 1
    JE VEZ_DO_O                ; AX = 1 significa que CX é ímpar (Jogador 'O' joga)
    JNE VEZ_DO_X               ; AX = 0 significa que CX é par (Jogador 'X' joga)

    VEZ_DO_O:                  ; Define rótulo para JOGADOR 'O' escolher
    IMPRIMIR MSG1              ; Função que exibe uma string para o jogador escolher a posição

    LER                        ; Lê a entrada do usuário para a jogada
                               ; Caractere lido em AL

    CMP AL, "0"                ; Compara com '0'
    JBE ERROI                  ; Se for menor ou igual a '0', pula para rótulo de erro

    CMP AL, "9"                ; Compara com '9'
    JA ERROI                   ; Se for maior ou igual a '9', pula para rótulo de erro

    AND AH, 00h                ; Limpa AH, AX agora contém apenas o ASCII em AL
    MOV SI, AX                 ; Move o valor ASCII para SI
    AND SI, 0Fh                ; Converte ASCII '1'-'9' para numérico 1-9

    CMP SI, 3                   ; Compara com 3
    JBE LINHA0I                 ; Se for menor ou igual a 3, pula para rótulo da linha 0

    CMP SI, 6                  ; Compara com 6
    JBE LINHA3I                 ; Se for menor ou igual a 6, pula para rótulo da linha 3

    ; Linha 6
    MOV BX, 6                  ; Move 6 para o conteúdo de BX
    DEC SI                     ; Converte numérico 1-9 para índice 0-8
    SUB SI, 6                  ; Transforma o indice certo da coluna
    JMP FIM_ESCOLHA            ; Fim da jogada

    LINHA0I:
    MOV BX, 0                  ; Move 0 para o conteúdo de BX
    DEC SI                     ; Converte numérico 1-9 para índice 0-8
    JMP FIM_ESCOLHA            ; Fim da jogada

    LINHA3I:
    MOV BX, 3                  ; Move 3 para o conteúdo de BX
    DEC SI                     ; Converte numérico 1-9 para índice 0-8
    SUB SI, 3                  ; Transforma o indice certo da coluna
    JMP FIM_ESCOLHA            ; Fim da jogada

    ERROI:                     ; Rótulo de erro do Jogador 'O'
    IMPRIMIR MSG7              ; Função que exibe uma string
                               ; "Posição inválida"
    JMP VEZ_DO_O               ; Repete a leitura

    VEZ_DO_X:                  ; Define rótulo para JOGADOR 'X' escolher
    CMP [modo_jogo], 1         ; Checa se é modo Jogador vs Jogador
    JE VEZ_DO_X_HUMANO         ; Se sim e igual a opção 1, salta para leitura humana
    JMP VEZ_DO_X_BOT           ; Se não e igual a opção 2, joga o Bot

    VEZ_DO_X_HUMANO:           ; Define rótulo para JOGADOR 'X' humano escolher
    IMPRIMIR MSG2              ; Função que exibe uma string para o jogador escolher a posição

    LER                        ; Lê a entrada do usuário para a jogada
                               ; Caractere lido em AL

    CMP AL, "0"                ; Compara com '0'
    JB ERROP                   ; Se for menor que '0', pula para rótulo de erro

    CMP AL, "9"                ; Compara com '9'
    JA ERROP                   ; Se for maior que '9', pula para rótulo de erro

    AND AH, 00h                ; Limpa AH, AX agora contém apenas o ASCII em AL
    MOV SI, AX                 ; Move o valor ASCII para SI
    AND SI, 0Fh                ; Converte ASCII '1'-'9' para numérico 1-9

    CMP AL, 3                   ; Compara com 3
    JBE LINHA0P                 ; Se for menor ou igual a 3, pula para rótulo da linha 0

    CMP AL, 6                   ; Compara com 6
    JBE LINHA3P                 ; Se for menor ou igual a 6, pula para rótulo da linha 3

    ; Linha 6
    MOV BX, 6                  ; Move 6 para o conteúdo de BX
    DEC SI                     ; Converte numérico 1-9 para índice 0-8
    SUB SI, 6                  ; Transforma o indice certo da coluna
    JMP FIM_ESCOLHA            ; Fim da jogada

    LINHA0P:
    MOV BX, 0                  ; Move 0 para o conteúdo de BX
    DEC SI                     ; Converte numérico 1-9 para índice 0-8
    JMP FIM_ESCOLHA            ; Fim da jogada

    LINHA3P:
    MOV BX, 3                  ; Move 3 para o conteúdo de BX
    DEC SI                     ; Converte numérico 1-9 para índice 0-8
    SUB SI, 3                  ; Transforma o indice certo da coluna
    JMP FIM_ESCOLHA            ; Fim da jogada

    ERROP:                     ; Rótulo de erro do Jogador 'X'
    IMPRIMIR MSG7              ; Função que exibe uma string
                               ; "Posição inválida"
    JMP VEZ_DO_X_HUMANO        ; Repete a leitura
    
    VEZ_DO_X_BOT:              ; Define rótulo para JOGADOR 'X' bot escolher
    IMPRIMIR MSG_BOT           ; Função que exibe uma string
                               ; Exibe mensagem do Bot pensando
    
    LOOP_BOT:                  ; Início do loop para encontrar posição vazia
    CALL RANDOM_1_A_9          ; Chama o gerador aleatório (DX = 1-9)
    

    AND AH, 00h                ; Limpa AH, AX agora contém apenas o ASCII em AL
    MOV SI, DX                 ; Move o valor ASCII '1'-'9' para SI
    AND SI, 0Fh                ; Converte ASCII '1'-'9' para numérico 1-9

    CMP AL, 3                  ; Compara com 3
    JBE LINHA0B                ; Se for menor ou igual a 3, pula para rótulo da linha 0

    CMP AL, 6                ; Compara com 6
    JBE LINHA3B                ; Se for menor ou igual a 6, pula para rótulo da linha 3

    ; Linha 6
    MOV BX, 6                  ; Move 6 para o conteúdo de BX
    DEC SI                     ; Converte numérico 1-9 para índice 0-8
    SUB SI, 6                  ; Transforma o indice certo da coluna
    JMP FIM_ESCOLHA            ; Fim da jogada

    LINHA0B:
    MOV BX, 0                  ; Move 0 para o conteúdo de BX
    DEC SI                     ; Converte numérico 1-9 para índice 0-8
    JMP FIM_ESCOLHA            ; Fim da jogada

    LINHA3B:
    MOV BX, 3                  ; Move 3 para o conteúdo de BX
    DEC SI                     ; Converte numérico 1-9 para índice 0-8
    SUB SI, 3                  ; Transforma o indice certo da coluna
    JMP FIM_ESCOLHA            ; Fim da jogada
    
    ; Verifica se a posição gerada está ocupada
    CMP M[BX+SI], 'O'          ; Compara com 'O'
    JE LOOP_BOT                ; Se ocupada por 'O', volta e tenta novo número
    
    CMP M[BX+SI], 'X'          ; Compara com 'X'
    JE LOOP_BOT                ; Se ocupada por 'X', volta e tenta novo número

    FIM_ESCOLHA:               ; Rótulo para o fim da escolha da posição
    
    POP AX                     ; Restaura AX
    RET                        ; Retorna para a função principal. SI contém o índice da jogada
ESCOLHA ENDP                   ; Encerra a função de escolha

; Procedimento que coloca 'O' ou 'X' na matriz M na posição SI
POS PROC                       ; Define a função para preencher a posição

    MOV AX, 1                  ; Checa o jogador usando CX novamente
    AND AX, CX                 ; Checa a paridade do número

    CMP AX, 1                  ; Compara AX com 1
    JE MARCAR_O                ; Se AX=1, CX é ímpar, é a vez de 'O'
    JNE MARCAR_X               ; Se AX=0, CX é par, é a vez de 'X'

    MARCAR_O:                  ; Define rótulo para marcar 'O' na posição
    MOV M[BX+SI], "O"          ; Coloca 'O' na posição [BX+SI]
    JMP FIM_POS                ; Salta incondicionalmente para o final

    MARCAR_X:                  ; Define rótulo para marcar 'X' na posição
    MOV M[BX+SI], "X"          ; Coloca 'X' na posição [BX+SI]

    FIM_POS:                   ; Rótulo para fim do preenchimento da posição
    RET                        ; Retorna para a função principal
POS ENDP                       ; Encerra a função para preencher a posição

; Procedimento que verifica todas as 8 condições de vitória.
VERIFICAR_VITORIA PROC         ; Define a função que verifica condições de vitória
    ; Se 3 posições M[a], M[b], M[c] são iguais E M[a] é 'O' ou 'X', há vitória

    ; Verifica Linha 1 (M[0+0], M[0+1], M[0+2])
    MOV AL, M[0+0]               ; Carrega o valor inicial da linha em AL
    CMP AL, M[0+1]
    JNE CONTINUAR1             ; Se M[0+0] não for igual a M[0+1], não venceu na L1
    CMP AL, M[0+2]
    JNE CONTINUAR1             ; Se M[0+0] não for igual a M[0+2], não venceu na L1
    JMP VENCEDOR               ; Se M[0+0]=M[0+1]=M[0+2], verifica se é 'O' ou 'X'

    CONTINUAR1:
    ; Verifica Linha 2 (M[3+0], M[3+1], M[3+2]) 
    MOV AL, M[3+0]               ; Carrega o valor inicial da linha em AL
    CMP AL, M[3+1]
    JNE CONTINUAR2             ; Se M[3+0] não for igual a M[3+1], não venceu na L2
    CMP AL, M[3+2]
    JNE CONTINUAR2             ; Se M[3+0] não for igual a M[3+2], não venceu na L2
    JMP VENCEDOR               ; Se M[3+0]=M[3+1]=M[3+2], verifica se é 'O' ou 'X'

    CONTINUAR2:
    ; Verifica Linha 3 (M[6+0], M[6+1], M[6+2])
    MOV AL, M[6+0]              ; Carrega o valor inicial da linha em AL
    CMP AL, M[6+1]
    JNE CONTINUAR3            ; Se M[6+0] não for igual a M[6+1], não venceu na L3
    CMP AL, M[6+2]
    JNE CONTINUAR3            ; Se M[6+0] não for igual a M[6+2], não venceu na L3
    JMP VENCEDOR              ; Se M[6+0]=M[6+1]=M[6+2], verifica se é 'O' ou 'X'

    CONTINUAR3:
    ; Verifica Coluna 1 (M[0+0], M[3+0], M[6+0])
    MOV AL, M[0+0]            ; Carrega o valor inicial da linha em AL
    CMP AL, M[3+0]
    JNE CONTINUAR4          ; Se M[0+0] não for igual a M[3+0], não venceu na C1
    CMP AL, M[6+0]
    JNE CONTINUAR4          ; Se M[0+0] não for igual a M[6+0], não venceu na C1
    JMP VENCEDOR            ; Se M[0+0]=M[3+0]=M[6+0], verifica se é 'O' ou 'X'

    CONTINUAR4:
    ; Verifica Coluna 2 (M[0+1], M[3+1], M[6+1])
    MOV AL, M[0+1]            ; Carrega o valor inicial da linha em AL
    CMP AL, M[3+1]
    JNE CONTINUAR5          ; Se M[0+1] não for igual a M3+1], não venceu na C2
    CMP AL, M[6+1]
    JNE CONTINUAR5          ; Se M[0+1] não for igual a M[6+1], não venceu na C2
    JMP VENCEDOR            ; Se M[0+1]=M[3+1]=M[6+1], verifica se é 'O' ou 'X'

    CONTINUAR5:
    ; Verifica Coluna 3 (M[0+2], M[3+2], M[6+2]) 
    MOV AL, M[0+2]           ; Carrega o valor inicial da linha em AL
    CMP AL, M[3+2]
    JNE CONTINUAR6         ; Se M[0+2] não for igual a M[3+2], não venceu na C3
    CMP AL, M[6+2]
    JNE CONTINUAR6         ; Se M[0+2] não for igual a M[6+2], não venceu na C3
    JMP VENCEDOR           ; Se M[0+2]=M[3+2]=M[6+2], verifica se é 'O' ou 'X'

    CONTINUAR6:
    ; Verifica Diagonal Principal (M[0+0], M[3+1], M[6+2]) 
    MOV AL, M[0+0]          ; Carrega o valor inicial da linha em AL
    CMP AL, M[3+1]
    JNE CONTINUAR7        ; Se M[0+0] não for igual a M[3+1], não venceu na DP
    CMP AL, M[6+2]
    JNE CONTINUAR7        ; Se M[0+0] não for igual a M[6+2], não venceu na DP
    JMP VENCEDOR          ; Se M[0+0]=M[3+1]=M[6+2], verifica se é 'O' ou 'X'

    CONTINUAR7:
    ; Verifica Diagonal Secundária (M[0+2], M[3+1], M[6+0])
    MOV AL, M[0+2]          ; Carrega o valor inicial da linha em AL
    CMP AL, M[3+1]          
    JNE FIM_VERIFICACAO   ; Se M[0+2] não for igual a M[3+1], não venceu na DS
    CMP AL, M[6+0]
    JNE FIM_VERIFICACAO   ; Se M[0+2] não for igual a M[6+0], não venceu na DS
    JMP VENCEDOR          ; Se M[0+2]=M[3+1]=M[6+0], verifica se é 'O' ou 'X'

    VENCEDOR:             ; Define rótulo para vitória
    ; Checa se o elemento em AL é 'O' ou 'X' 
    CMP AL, "O"
    JE MOSTRAR_O               ; Se 'O', mostra vitória de 'O'
    CMP AL, "X"
    JE MOSTRAR_X               ; Se 'X', mostra vitória de 'X'
    JMP FIM_VERIFICACAO        ; Não era 'O' nem 'X', então não é vitória real

    MOSTRAR_O:                 ; Define rótulo para mostrar vitória de 'O'
    IMPRIMIR MSG4              ; Função que exibe a mensagem de vitória
    CALL IMPRIMIRM             ; Imprime o tabuleiro final
    JMP FINAL                  ; Salta para o fim do programa

    MOSTRAR_X:                 ; Define rótulo para mostrar vitória de 'X'
    IMPRIMIR MSG5              ; Função que exibe a mensagem de vitória
    CALL IMPRIMIRM             ; Imprime o tabuleiro final
    JMP FINAL                  ; Salta para o fim do programa

    FIM_VERIFICACAO:           ; Rótulo para finalizar verificação
    RET                        ; Retorna para a função principal
VERIFICAR_VITORIA ENDP         ; Encerra a função de verificação de vitória

; Procedimento que gera um número pseudoaleatório (0-32767) usando LFSR (Linear Feedback Shift Register)
GERAR_RANDOM PROC              ; Define a função que gera um número pseudoaleatório
    PUSH BX                    ; Salva registradores usados na pilha
    PUSH CX

    ; Começa com um número nesta faixa de valores
    MOV AX, [rand_seed]        ; Carrega a semente atual de 16 bits em AX
    
    ; Faz um deslocamento para esquerda uma vez
    SHL AX, 1                  ; Desloca todos os bits de AX para a esquerda, Bit 15 sai, Bit 0 entra 0

    ; Substitui o bit 0 pelo XOR dos bits 14 e 15 (atuais da semente)
    MOV BX, AX                 ; Copia o valor deslocado para BX
    SHR BX, 14                 ; Isola os bits 15 e 14, eles estão agora nas posições 1 e 0 de BX
    
    MOV CX, BX                 ; Copia para CX
    
    AND BX, 1                  ; Isola o Bit 14, agora na posição 0 de BX
    SHR CX, 1                  ; Desloca CX para a direita, Bit 15 vai para a posição 0
    AND CX, 1                  ; Isola o Bit 15, agora na posição 0 de CX
    
    XOR BX, CX                 ; Calcula Bit 14 XOR Bit 15
    
    OR AX, BX                  ; Define o novo Bit 0 de AX com o resultado do XOR
    
    ; Limpa o bit 15
    AND AX, 7FFFh              ; Garante que o Bit 15 seja sempre 0, limitando a faixa a 15 bits (0-32767)
    
    MOV [rand_seed], AX        ; Salva o novo número (semente)
    
    POP CX                     ; Restaura registradores
    POP BX

    RET                        ; Retorna para a função principal. AX contém o novo número aleatório
GERAR_RANDOM ENDP              ; Encerra a função que gera um número pseudoaleatório

; Procedimento que gera um número aleatório na faixa de 1 a 9
RANDOM_1_A_9 PROC              ; Define a função que gera um número aleatório na faixa de 1 a 9
    PUSH AX                    ; Salva registradores usados na pilha
    PUSH CX

    ; 1. Gera o número aleatório grande (0-32767)
    CALL GERAR_RANDOM          ; O resultado está em AX
    
    ; 2. Converte o número em AX para a faixa 1-9 usando módulo 9
    
    XOR DX, DX                 ; Zera DX 
    MOV CX, 9                  ; Move 9 para conteúdo de CX, que será o divisor
    DIV CX                     ; Divide (DX:AX) por CX (9)
    
    ; Resultado: DX = Resto (0-8)
    
    INC DX                     ; Adiciona 1 ao resto para obter o intervalo 1-9
    
    POP CX                     ; Restaura registradores
    POP AX
    RET                        ; Retorna para a função principal. O resultado (1-9) está em DX
RANDOM_1_A_9 ENDP              ; Encerra a função que gera um número aleatório na faixa de 1 a 9

END MAIN                       ; Finaliza o programa