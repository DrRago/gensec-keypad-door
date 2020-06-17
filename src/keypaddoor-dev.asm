CSEG AT 0H
AJMP INIT
CSEG AT 100H

ORG 20H
INIT:	;MOV R0, #0H
	;MOV R1, #0H
	;MOV R2, #0H
	;MOV R3, #0H
	;MOV R4, #0H
	;MOV R5, #0H
	;MOV A, #0H
	CALL CHECK_INPUT
	MOV 20H, @R1
	MOV A, R0
	CLR C
	SUBB A, #03H
	JNZ ERR
	
	CALL READ_PASSWORD
	XRL A, #10D
	JZ ERR
	CALL SHOW
	AJMP INIT

ERR:

ERR_BUSY_0:	MOV R0, #0FFH
ERR_BUSY_0_:	CALL ERR_BUSY_1
		DEC R0
		MOV A, R0
		JNZ ERR_BUSY_0_

ERR_BUSY_1:	MOV R1, #0FFH
ERR_BUSY_1_:	CALL ERR_BUSY_2
		DEC R1
		MOV A, R1
		JNZ ERR_BUSY_1_

ERR_BUSY_2:	MOV R2, #0FFH
ERR_BUSY_2_:	CALL ERR_BUSY_3
		DEC R2
		MOV A, R2
		JNZ ERR_BUSY_2_

ERR_BUSY_3:	MOV R3, #0FFH
ERR_BUSY_3_:	
		MOV R4, #0AFH
		MOV R5, #0AFH
		MOV R6, #086H
		MOV R7, #0FFH
		CALL DISPLAY
		
		DEC R3
		MOV A, R3
		JNZ ERR_BUSY_3_
		RET

; for each keypad row:
; - set row select line P0.n (for 0 <= n <= 3)
; - read P0
; - deselect
; - save the result to 1nH
READ_KEYPAD:
	CLR P0.0
	MOV A, P0
	SETB P0.0
	MOV 10H, A
	
	CLR P0.1
	MOV A, P0
	SETB P0.1
	MOV 11H, A
	
	CLR P0.2
	MOV A, P0
	SETB P0.2
	MOV 12H, A
	
	CLR P0.3
	MOV A, P0
	SETB P0.3
	MOV 13H, A
	
	RET

; translates the a keypad input byte at A into a decimal 0..9
; if this fails 10 is returned
; return value is in A
; overwrites A, Rn, DPTR
LOOKUP_KEYPAD_INPUT_DIGIT:
				MOV DPTR, #DB_KEYPAD
				MOV R0, A
				MOV R1, #0b		; for (int B = 0; ... ) -> counter
LOOKUP_KEYPAD_INPUT_DIGIT_LOOP_START:
				MOV A, R1
				MOVC A, @A+DPTR		; A = DB_KEYPAD[A]
				XRL A, R0
				JZ LOOKUP_KEYPAD_INPUT_DIGIT_LOOP_EXIT
LOOKUP_KEYPAD_INPUT_DIGIT_LOOP_CONDITION:
				CJNE R1, #9D, LOOKUP_KEYPAD_INPUT_DIGIT_LOOP_INCREMENT
				MOV A, #10D
				RET
LOOKUP_KEYPAD_INPUT_DIGIT_LOOP_INCREMENT:
				INC R1
				AJMP LOOKUP_KEYPAD_INPUT_DIGIT_LOOP_START
LOOKUP_KEYPAD_INPUT_DIGIT_LOOP_EXIT:
				MOV A, R1
				RET

LOOKUP_KEYPAD_DIGITS:
				MOV A, 10H
				CALL LOOKUP_KEYPAD_INPUT_DIGIT
				MOV 14H, A
				
				MOV A, 11H
				CALL LOOKUP_KEYPAD_INPUT_DIGIT
				MOV 15H, A
				
				MOV A, 12H
				CALL LOOKUP_KEYPAD_INPUT_DIGIT
				MOV 16H, A
				
				MOV A, 13H
				CALL LOOKUP_KEYPAD_INPUT_DIGIT
				MOV 17H, A
				RET
				
; reads the currently pressed digit key
; returns how many non-integer keys have been pressed (subtract 4 from R0)
; returns an indirect address to the pressed digit key in R1
CHECK_INPUT:     		CALL READ_KEYPAD; input is in 10H-13H
				CALL LOOKUP_KEYPAD_DIGITS

				MOV R0, #0H

CHECK_INPUT_ROW_1:		MOV A, 14H
				XRL A, #10D
				JNZ CHECK_INPUT_ROW_2_
				CALL CHECK_INPUT_10D_FOUND
				AJMP CHECK_INPUT_ROW_2

CHECK_INPUT_ROW_2_:		MOV R1, #14H
CHECK_INPUT_ROW_2:		MOV A, 15H
				XRL A, #10D
				JNZ CHECK_INPUT_ROW_3_
				CALL CHECK_INPUT_10D_FOUND
				AJMP CHECK_INPUT_ROW_3

CHECK_INPUT_ROW_3_:		MOV R1, #15H
CHECK_INPUT_ROW_3:		MOV A, 16H
				XRL A, #10D
				JNZ CHECK_INPUT_ROW_4_
				CALL CHECK_INPUT_10D_FOUND
				AJMP CHECK_INPUT_ROW_4

CHECK_INPUT_ROW_4_:		MOV R1, #16H
CHECK_INPUT_ROW_4:		MOV A, 17H
				XRL A, #10D
				JNZ CHECK_INPUT_TEST_10D_
				CALL CHECK_INPUT_10D_FOUND
				AJMP CHECK_INPUT_TEST_10D
				

CHECK_INPUT_TEST_10D_:		MOV R1, #17H
CHECK_INPUT_TEST_10D:		MOV A, R0
				JZ CHECK_INPUT_ERROR
				DEC A
				JZ CHECK_INPUT_ERROR
				DEC A
				JZ CHECK_INPUT_ERROR
				DEC A
				JZ CHECK_INPUT_EXIT
				DEC A
				JZ CHECK_INPUT_ERROR
				
CHECK_INPUT_ERROR:		RET
CHECK_INPUT_10D_FOUND:		INC R0
CHECK_INPUT_EXIT:		RET

; read for input digits
; returns #10D on invalid input
READ_PASSWORD:		
			CALL CHECK_INPUT
			MOV 20H, @R1
			MOV A, R0
			CLR C
			SUBB A, #03H
			JZ READ_PASSWORD_DIGIT_2
			AJMP READ_PASSWORD_ERROR
			
READ_PASSWORD_DIGIT_2:	
			CALL CHECK_INPUT
			MOV 21H, @R1
			MOV A, R0
			CLR C
			SUBB A, #03H
			JZ READ_PASSWORD_DIGIT_3
			AJMP READ_PASSWORD_ERROR
			
READ_PASSWORD_DIGIT_3:	
			CALL CHECK_INPUT
			MOV 22H, @R1
			MOV A, R0
			CLR C
			SUBB A, #03H
			JZ READ_PASSWORD_DIGIT_4
			AJMP READ_PASSWORD_ERROR
			
READ_PASSWORD_DIGIT_4:	
			CALL CHECK_INPUT
			MOV 23H, @R1
			MOV A, R0
			CLR C
			SUBB A, #03H
			JZ READ_PASSWORD_EXIT
			AJMP READ_PASSWORD_ERROR
			
READ_PASSWORD_ERROR:	MOV A, #10H
READ_PASSWORD_EXIT:	RET
			
			
LOOKUP_DISPLAY:
	MOV DPTR, #DB_DISPLAY
	
	MOV A, 20H
	MOVC A,@A+DPTR
	MOV R7, A
	
	MOV A, 21H
	MOVC A, @A+DPTR
	MOV R6, A
	
	MOV A, 22H
	MOVC A, @A+DPTR
	MOV R5, A
	
	MOV A, 23H
	MOVC A, @A+DPTR
	MOV R4, A

	RET
	
SHOW:
	CALL LOOKUP_DISPLAY
	CALL DISPLAY
	RET

DISPLAY:
	MOV P2, R4
	CLR P1.0
	SETB P1.0
	
	MOV P2, R5
	CLR P1.1
	SETB P1.1
	
	MOV P2, R6
	CLR P1.2
	SETB P1.2
	
	MOV P2, R7
	CLR P1.3
	SETB P1.3
	
	RET	

ORG 300H
DB_DISPLAY:	  DB 11000000B
	  	  DB 11111001B, 10100100B, 10110000B
	          DB 10011001B, 10010010B, 10000010B
	          DB 11111000B, 10000000B, 10010000B
DB_KEYPAD:        DB 11010111B				;    0
		  DB 11101110B, 11011110B, 10111110B	; 1, 2, 3
		  DB 11101101B, 11011101B, 10111101B    ; 4, 5, 6
		  DB 11101011B, 11011011B, 10111011B    ; 7, 8, 9
DB_PW:		  DB 4D, 7D, 1D, 1D
END


