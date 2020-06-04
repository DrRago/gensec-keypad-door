CSEG AT 0H
AJMP INIT
CSEG AT 100H

ORG 20H
INIT:	MOV IE, #10010010b
	MOV TMOD, #00000010b
	MOV R2, #0001H
	MOV R3, #0010H
	MOV R4, #0100H
	MOV R5, #1000H
	SETB P0.0

; -------------------------------------------------
;		     INTERRUPT
; -------------------------------------------------

ORG 0BH
CALL timer
RETI

; -------------------------------------------------
;		     LOGIC
; -------------------------------------------------
timer:	 CALL DISPLAY
         RET

; -------------------------------------------------
;		DISPLAY CONTROLLING
;
;	  Interface for display controller
; -------------------------------------------------
DISPLAY: mov P2, R2	; First block
	 clr P1.0
	 setb P1.0

	 mov P2, R3	; Second block
	 clr P1.1
  	 setb P1.1

	 mov P2, R4	; Third block
	 clr P1.2
	 setb P1.2

	 mov P2, R5	; Fourth block
	 clr P1.3
	 setb P1.3

; -------------------------------------------------
; 	      	      Database
; -------------------------------------------------
ORG 300h
DB:	 db 11000000b
	 db 11111001b, 10100100b, 10110000b
	 db 10011001b, 10010010b, 10000010b
	 db 11111000b, 10000000b, 10010000b
end