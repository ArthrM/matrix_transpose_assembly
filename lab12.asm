.model small
PRINT macro msg
    MOV  AH , 09
    LEA  DX , msg
    INT  21H
      endm
.stack 100h
.data
    MATRIX   DB 4 DUP (?)
             DB 4 DUP (?)
             DB 4 DUP (?)
             DB 4 DUP (?)

    MATRIX_AUX DB 4 DUP (?)
               DB 4 DUP (?)
               DB 4 DUP (?)
               DB 4 DUP (?)

    input_matrix_msg    DB 'Insira os valores da matriz [4x4]:',10,'$'
    output_matrix_msg   DB 10,10,'Matriz Inserida:'  ,10,'$'
    output_t_matrix_msg DB 10,10,'Matriz Transposta:',10,'$'
    blank DB 10,'             ','$'

.code
main proc

    MOV  AX , @DATA
    MOV  DS , AX
    PRINT input_matrix_msg
    call MATRIX_INPUT
    PRINT output_matrix_msg
    call MATRIX_OUTPUT
    PRINT output_t_matrix_msg
    call TRANSPOSE
    call MATRIX_OUTPUT

    MOV AH , 4CH
    INT 21H
main endp

MATRIX_INPUT proc

    XOR SI , SI                ;Inicializa o index SI com zero
    XOR BX , BX                ;Inicializa o index BX com zero
    MOV CL , 4 
    LINE_IN:
     PRINT blank
     MOV CH , 4
     COLUMN_IN:
        MOV AH , 01
        INT 21H                   ;Leitura de input
        SUB AL , 30H              ;Subtrai 30H do input para transformar de ASCII em número puro
        MOV MATRIX[BX][SI] , AL   ;Armazena o input na matrix
        INC SI                    ;Incrementa o index coluna
        MOV AH , 02
        MOV DL , ' '
        INT 21H
        DEC CH
         JNZ COLUMN_IN
        XOR SI , SI              ;Reseta o index coluna para continuar a leitura
        ADD BX , 4               ;Incrementa o index linha
        DEC CL
         JNZ LINE_IN

ret
MATRIX_INPUT endp

MATRIX_OUTPUT proc

    XOR SI , SI               ;Inicializa o index SI com zero
    XOR BX , BX               ;Inicializa o index BX com zero
    MOV CL , 4
    LINE_OUT:
     PRINT blank
     MOV AH , 02
     MOV CH , 4
     COLUMN_OUT:
      MOV DL , MATRIX[BX][SI]
      ADD DL , 30H
      INT 21H
      INC SI                   ;Incrementa o index coluna
      MOV AH , 02
      MOV DL , ' '
      INT 21H
      DEC CH
       JNZ COLUMN_OUT
      XOR SI , SI              ;Reseta o index coluna para continuar a impressão
      ADD BX , 4               ;Pula o index da linha para continuar a impressão
      DEC CL
       JNZ LINE_OUT
ret
MATRIX_OUTPUT endp

TRANSPOSE proc
    
    MOV CL , 4
    MOV BX , -1                ;Inicializa o index BX para posterior virar index 0
    MOV SI , -4                ;Inicializa o index SI para posterior virar index 0
    LINE_T:
     MOV CH , 4
     COLUMN_T:
      INC BX                   ;Index que percorre a matriz input inteira de 1 em 1 (DB)
      ADD SI , 4               ;Index que prepara a MATRIX_AUX para receber o elemento da matriz input no elemento correspondente transposto
      MOV AL , MATRIX[BX]      ;Move o elemento de index BX da matriz input para AL
      MOV MATRIX_AUX[SI] , AL  ;Move AL para o elemento de index SI na matriz alvo
      DEC CH
       JNZ COLUMN_T
      SUB SI , 15              ;Volta o index para continuar a transposição
      DEC CL
       JNZ LINE_T

    MOV CL , 4                 ;Processo para mandar a matriz transposta em MATRIX_AUX devolta para MATRIX para posterior impressão
    XOR BX , BX
    XOR SI , SI
    LINE_MOV:
     MOV CH , 4
     COLUMN_MOV:
     MOV AL , MATRIX_AUX[BX][SI]
     MOV MATRIX[BX][SI] , AL
     INC SI
     DEC CH
      JNZ COLUMN_MOV
     XOR SI , SI
     ADD BX , 4
     DEC CL
      JNZ LINE_MOV
ret
TRANSPOSE endp
END main