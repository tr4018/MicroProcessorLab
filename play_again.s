#include <xc.inc>
    
extrn	LCD_Write_Message, second_line, LCD_Send_Byte_I, cursor_off 
extrn	display_clear, delay_500ms,key_control

global	play_again
    
psect	udata_acs   ; reserve data space in access ram	
pa_counter:	    ds 1    ; reserve one byte for a counter variable

psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
play_againArray:    ds 0x17 ; reserve 23 bytes for message data

psect	data    
	
    ; ******* play_againTable, data in programme memory, and its length *******
    
play_againTable:
	db	'P', 'L', 'A', 'Y', ' ', 'A', 'G', 'A', 'I', 'N', '?'
	db	'1', '.', ' ', 'Y', 'E', 'S', ' ', '2', '.', 'N', 'O', 0xa
	
					; message, plus carriage return
	play_againTable_l   EQU	 0x17	; length of data
	align	2

psect	pa_code, class=CODE	
	
    ; ****************** PLAY AGAIN MENU CODE *********************************
    
play_again: 	
	lfsr	0, play_againArray	; Load FSR0 with address in RAM
	movlw	low highword(play_againTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(play_againTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(play_againTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	play_againTable_l	; bytes to read
	movwf 	pa_counter, A		; our counter register
	
pa_loop: 	
	tblrd*+				; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0	; move data from TABLAT to (FSR0), inc FSR0	
	decfsz  pa_counter, A		; decrement counter, compare to zero
	bra	pa_loop			; keep going until finished
	
	movlw	0xB			; output message to LCD
	lfsr	2, play_againArray	; point FSR2 to table address
	call	LCD_Write_Message	
	call	second_line		; move cursor to second line
	movlw	0xC			
	addlw	0xff
	call	LCD_Write_Message	; output second line to LCD
	call	cursor_off
	movlw	0x2
	call	delay_500ms		; 1s delay
	return


