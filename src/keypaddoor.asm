CSEG AT 0H
AJMP INIT
CSEG AT 100H

; -------------------------------------------------
;		     INTERRUPT
; -------------------------------------------------

;ORG 0BH
;CALL ENTRYPOINT
;RETI

ORG 20H
INIT:	MOV IE, #10010010b
	MOV TMOD, #00000010b
	MOV R2, #0H
	MOV R3, #0H
	MOV R4, #0H
	MOV R5, #0H
	SETB P0.0


; -------------------------------------------------
;		       LOGIC
; -------------------------------------------------
;ENTRYPOINT:	 CALL DISPLAY
;		 CALL READIN
;         	 RET

; -------------------------------------------------
;		DISPLAY CONTROLLING
;
;	  Interface for display controller
; -------------------------------------------------
DISPLAY: MOV P2, R2	; First block
	 CLR P1.0
	 SETB P1.0

	 MOV P2, R3	; Second block
	 CLR P1.1
  	 SETB P1.1

	 MOV P2, R4	; Third block
	 CLR P1.2
	 SETB P1.2

	 MOV P2, R5	; Fourth block
	 CLR P1.3
	 SETB P1.3
	 RET


; -------------------------------------------------
;	      	    DATABASES
;
; -------------------------------------------------
ORG 300h
DB_DISPLAY:	  DB 11000000b
	  	  DB 11111001b, 10100100b, 10110000b
	          DB 10011001b, 10010010b, 10000010b
	          DB 11111000b, 10000000b, 10010000b
DB_KEYPAD:        DB 00010001b, 00010010b, 00010100b	; 1, 2, 3
		  DB 00100001b, 00100010b, 00100100b    ; 4, 5, 6
		  DB 01000001b, 01000010b, 01000100b    ; 7, 8, 9
		  DB 10000100b				;    0
		  
end