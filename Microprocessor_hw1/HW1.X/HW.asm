LIST p=18f4520		
#include<p18f4520.inc>		
; CONFIG1H
  CONFIG  OSC = INTIO67              ; Oscillator Selection bits (Internal oscillator block, port function on RA6 and RA7)
; CONFIG2H
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))

    org 	0x00	
    vector equ 0x01
  
    Start:
	    MOVLW upper array					;set table pointer
	    MOVWF TBLPTRU
	    MOVLW high array 
	    MOVWF TBLPTRH
	    MOVLW low array 
	    MOVWF TBLPTRL
    INITIAL:
        MOVLW D'21'						;user could change distance in decimal
	 MOVWF vector						;let distance put into vector
	 CLRF LATA							;LATA as degree
	 TBLRD*+							;find the first table number
    MAIN: 
	    MOVFF TABLAT,WREG
	    INCF LATA							;add degree
	    CPFSEQ vector						;if vector the same as table number go to finish else go to next
	    GOTO NEXT
	    GOTO FINISH
    NEXT: 
	    CPFSGT vector						;if vector larger than table number,and then go to find next table number
	    GOTO Large						;find the larger table num than vector,and so we should do check which is closer between last round and this round
	    MOVFF WREG,LATB						;store this time's num in order to compare which is closer to vector in the following
	    TBLRD*+							;next table num
	    GOTO MAIN							;next round
   Large:
	    MOVFF WREG,LATC
	    MOVFF vector,WREG					;this round number
	    SUBWF LATC						;f(Larger table num)-W(vector) store into LATC
	    
	    MOVFF WREG,LATD
	    MOVFF LATB,WREG
	    MOVFF LATD,LATB						;last round number
	    SUBWF LATB,0						;f(vetor)-W(Less table num) store into W
	    
	    CPFSLT LATC						;compare which is close to vector
	    DECF LATA							;if last round is less,and then minus degree once 
	    GOTO FINISH						;else go to finish
   FINISH:
	    MOVLW 0x00
	    CPFSEQ LATA						;check if the first one is close to zero,and we should add degree once
	    GOTO OVER
	    INCF LATA
   OVER:
	    MOVFF LATA,0x02						;load angle to 0x02 and end program
	    GOTO PEND
	
	    
    array:  
	    db 0x04,0x09,0x0D,0x12,0x16,0x1B,0x1F,0x24,0x28,0x2C	;SET TABLE 1~10 degree
    	    db 0x31,0x35,0x3A,0x3E,0x42,0x47,0x4B,0x4F,0x53,0x58	;SET TABLE 11~20 degree
    	    db 0x5C,0x60,0x64,0x68,0x6C,0x70,0x74,0x78,0x7C,0x80	;SET TABLE 21~30 degree
	    db 0x84,0x88,0x8B,0x8F,0x93,0x96,0x9A,0x9E,0xA1,0xA5	;SET TABLE 31~40 degree
	    db 0xA8,0xAB,0xAF,0xB2,0xB5,0xB8,0xBB,0xBE,0xC1,0xC4	;SET TABLE 41~50 degree
	    db 0xC7,0xCA,0xCC,0xCF,0xD2,0xD4,0xD7,0xD9,0xDB,0xDE	;SET TABLE 51~60 degree
	    db 0xE0,0xE2,0xE4,0xE6,0xE8,0xEA,0xEC,0xED,0xEF,0xF1	;SET TABLE 61~70 degree
	    db 0xF2,0xF3,0xF5,0xF6,0xF7,0xF8,0xF9,0xFA,0xFB,0xFC	;SET TABLE 71~80 degree
	    db 0xFD,0xFE,0xFE,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF		;SET TABLE 81~90 degree
   PEND:
END