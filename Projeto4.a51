;Base Projeto 4

TempoH			EQU 0xD8		;D8EF -> 55535 FFFF->65535
TempoL			EQU 0xEF		;FFFF -> D8EF = 2710 (10ms)
Quantasx		EQU 50			;50*10ms = 500ms / 0.5s
Quantasx1s		EQU 2			;2*500ms = 1000ms = 1s
	
Nada			EQU 0
Start			EQU 1
Stop			EQU 2
Pause			EQU 3
	
PortaUnidades	EQU P1
PortaDezenas	EQU P0
	
Ponto			EQU P2.0
Iniciar			EQU P3.0
Parar			EQU P3.1
	
CSEG AT 0000H
JMP Inicio

CSEG AT 0003H					;Tratamento interrupcao externa (P3.2 vai executar InterrupcaoExt0)
JMP InterrupcaoExt0

CSEG AT 000BH					;Tratamento interrupcao0 timer (Quando Overflow)
JMP InterrupcaoTemp0

CSEG AT 0050H					;Programa Normal

Inicio:
	Mov SP, #7
	CALL Inicializacoes
	CALL PrioridadeInterrupcoes
	CALL AtivaInterrupcoes
	CALL AtivaTemporizador

Principal:
	JNB Iniciar, EstadoIniciar
	JNB Parar, EstadoParar
	JMP Principal
	
EstadoIniciar:
	MOV R1, #Start
	JMP Principal

EstadoParar:
	MOV R1, #Stop
	JMP Principal
	
	
;Rotina para fazer as inicializacoes do programa	
;////////////////////////////////////////////////////////////////////////////	

Inicializacoes:											;nada
	MOV R1, #Nada
	MOV PortaUnidades, #00000000b
	MOV PortaDezenas, #00000000b
	RET
	
PrioridadeInterrupcoes:									;nada
	MOV IP, #00000010b
	RET	
	
AtivaInterrupcoes:										;nada
	MOV IE,#10000011b
	SETB IT0
	RET
	
AtivaTemporizador:										;nada
	MOV TMOD, #00000001b			;Modo de contagem 16b
	MOV TH0, #TempoH
	MOV TL0, #TempoL
	MOV R0, #Quantasx
	MOV R6, #FimTempo0
	SETB TR0
	RET

;////////////////////////////////////////////////////////////////////////////

;CSEG AT 0003H
InterrupcaoExt0:
	MOV R1, #Pause	
	RETI
	
;CSEG AT 000BH
InterrupcaoTemp0:

	;Entra aqui cada 10ms
	MOV TL0, #TempoH
	MOV TH0, #TempoL
	
	DJNZ R6, FimTempo0
	
	;Entra aqui cada 500ms
	MOV R6, #Quantasx
	CPL Ponto
	
	DJNZ R7, FimTempo0
	
	;Entra aqui cada 1000ms
	MOV R7,#Quantasx1s
	
	CJNE R1, #Pause, TesteIniciar
	RETI
	


TesteIniciar:
	CJNE R1, #Start, TesteParar
	
	;///////////
		MOV A, PortaUnidades							
		CJNE A, #9, ContarUm							
		MOV PortaUnidades, #00000000b
		MOV A, PortaDezenas								
		CJNE A, #5, ContarZe							
		MOV PortaDezenas, #00000000b
		RETI
		
	ContarUm:
		Inc PortaUnidades											
		RETI
		
	ContarZe:
		Inc PortaDezenas
	RETI
	
TesteParar:
	CJNE R1, #Stop, FimTempo0
	MOV PortaUnidades, #00000000b
	MOV PortaDezenas, #00000000b
	RETI

FimTempo0:
RETI

END




