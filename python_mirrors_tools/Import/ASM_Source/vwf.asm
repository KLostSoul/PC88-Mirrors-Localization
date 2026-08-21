        .ORG     0x0000

; Variables
        .EQU RightMarginTable,0x0F00
; Global variables
        .EQU vFontNumber,     0x92DC
        .EQU vPrintX,         0x92DD
        .EQU vRightMargin,    0x92DF
        
        .EQU vPrevPrint,      0xB400
        .EQU vPrevLeft,       0xB401
        .EQU vGoNext,         0xB402          ; move to next print buffer
        .EQU vPrintSecond,    0xB403
        .EQU vDstAddr,        0xB404
        
        .EQU vSrcAddr,        0xB406
        
        .EQU vScreenPos2,     0xB408
        
        .EQU vPrevScreenPos,  0xB40A
        
        .EQU vPrintPos,       0xB40C
        
        .EQU v32ExtAccess,    0xB40E
        .EQU v32IndepAccess,  0xB40F
        .EQU vScreenPos,      0xB410
        
        .EQU vStrAddr,        0xB412
        
        .EQU vStartScreenPos, 0xB414
        
        .EQU vLineBreakHeight,0xB416
        .EQU vBitPattern,     0xB418
        .EQU vStarted,        0xB419
        .EQU vpatch1,         0xB41A
        .EQU vpatch5,         0xB41B
        .EQU vStrLen,         0xB41C
        .EQU vCharCount,      0xB41D
        .EQU vpatch2,         0xB41E
        .EQU vpatch3,         0xB41F

printMsg:       
                in      a,(0x32)        ; '2'
                ld      b,a
                and     0xBF
                ld      (v32IndepAccess),a
                ld      a,b
                or      0x40            ; '@'
                ld      (v32ExtAccess),a
                
                ; get font address
                ld      a,(vFontNumber)
                sla     a
                sla     a
                sla     a
                sla     a
                ld      l,0
                ld      h,a 
                ld      (vFontAddr),hl
                
                ld      hl,(vFontAddr)
                ld      de,RightMarginTable
                add     hl,de  
                ld      (vRMarginAddr),hl

                ; Referenced from 126B, BF6A, BF76, BF95, C15C
_v.prPos:       ld		A, (vPrevPrint)
            	OR		A
            	jp	    Z, _clearVars
            	ld 		HL, (vPrevScreenPos)
            	ld 		(vScreenPos), HL
            	ld 		(vStartScreenPos), HL
                jr      _printStart
_clearVars:
                ld      hl,(vPrintPos)
                ld      (vScreenPos),hl
                ld      (vStartScreenPos),hl
            	XOR		A
            	ld 		(vPrintSecond), A
            	ld 		(vPrevLeft), A
            	ld 		(vGoNext), A
            	ld 		(vStarted), A
            	ld 		(vRightMargin), A
_printStart:                
                ;ld      a,(vBitPattern)
                ;ld      (_patch2+1),a
                
                ; Referenced from 11DB, 126E, C168
_setCharCount:  ld      a,(vCharCount)          ; '&'
                ld      (vCharsLeft),a
                ld      a,(vStrLen)
                ld      c,a
                
                ; Referenced from 11CB, 11E1
                ; --- START PROC _nextSymbol ---
_nextSymbol:    ld      hl,(vStrAddr)
                ld      e,(hl)
                ld      d,0
                dec     c
                ld      a,c
                cp      0x00
                jp      z,_endDraw
                inc     hl
                ld      (vStrAddr),hl
                ld      a,e
                cp      0x0d
                jp      z,_nextLine
                call    getRightMargin
                ;ld      hl,(vPrintX)
                
                ld      a,0xA8
                out     (0x32),a        ; '2'
                push    bc
                call    convertASCII_toCharAddr
                call    copyCharToBuffer
                call    copyToBuffer
                
                
_copyBuffers:                
                ld      a,(v32IndepAccess)
                out     (0x32),a        ; '2'
                ld      hl,(vScreenPos)
                ld		(vScreenPos2), hl
                
_patch1:        ld      a,(vpatch1)
                ld		b, a
                ld		c, b
                ld      a,(v32ExtAccess)
                out     (0x32),a        ; '2'
                
                ; Referenced from C17B
                ld      a,(vpatch5)
                out     (0x34),a        ; '4'
                ld      a,0x80
                out     (0x35),a        ; '5'
                
                ld      a, (vGoNext)
                or      a
                jp 		nz, _secondSymbol
                ld 		A, (vStarted)
                or 		A
                jp 		z, _secondSymbol
                dec 	hl
                ld 		(vScreenPos), hl
                ld		(vScreenPos2), hl
_secondSymbol:                
                ld		a, 0x01
	            ld		(vStarted), a
	            ld      DE, vPrintBuffer
	            ld 		B, C
	            call	printBuffer
                
                ld 		a, (vPrintSecond)
	            or		a
	            jp 		z, _prepareNext
                
                ld 		hl, (vScreenPos2)
	            inc 	hl
                ld 		(vScreenPos), hl
	            ld      de, vPrintBuffer2
	            ld 		b, c
	            call	printBuffer
	            ld 		hl, (vScreenPos2)
	            ld 		(vScreenPos), hl
                
                xor     A
	            ld      (vPrintSecond), A
                
_prepareNext:    
                pop     bc  
                
                ld      a,(v32IndepAccess)
                out     (0x32),a        ; '2'
                out     (0x5F),a        ; '_'

                ld      a,(vCharsLeft)
                dec     a
                jr      z,_nextLine
                ld      (vCharsLeft),a
                ld      hl,(vScreenPos)
                inc     hl
                ld      (vScreenPos),hl
                LD 		(vPrevScreenPos), HL
                XOR 	A
                LD		(vPrevPrint), A 
                
                jp      _nextSymbol
                
                ; Referenced from 11BE
_nextLine:      ld      hl,(vStartScreenPos)
                ld      de,(vLineBreakHeight)                  ; Line break in VRAM units
                add     hl,de
                ld      (vStartScreenPos),hl
                ld      (vScreenPos),hl
                LD 		(vPrevScreenPos), HL
                ld      a,(vCharCount)     ; reference not aligned to instruction
                ld      (vCharsLeft),a
                xor     a
                ld 		(vPrintSecond), A
            	ld 		(vPrevLeft), A
            	ld 		(vGoNext), A
            	ld 		(vStarted), A
                jp      _nextSymbol
                
                ; Referenced from 10C8, 1166
                ; --- START PROC _endDraw ---
_endDraw:       xor     a
                out     (0x35),a        ; '5'
                ret

; ------------------ Variables
vCharsLeft:     .byte   0x00
vFontAddr:      .byte   0x00
                .byte   0x00
vRMarginAddr:   .byte   0x00
                .byte   0x00
;        
; ------------------ PATCH AREA


; Returns address to char in DE
convertASCII_toCharAddr:
                ld      a,e
                sub     0x20
                ld      e,a
                cp      0x0
                jr      nc,_conv_next1
                cp      0x60
                jr      c,_conv_next1
                ld      e,0x0       ; set space as default symbol
 _conv_next1:
                ld      h,0
                ld      l,e
                add     hl,hl
                add     hl,hl
                add     hl,hl
                add     hl,hl
                ld      e,l
                ld      d,h
                ld      hl,(vFontAddr)
                add     hl,de
                ex      de,hl
                ret
                
copyCharToBuffer:
                push    de                               
                ex      de,hl            
                ld      de,vKanjiBuffer
                ld      bc,0x10
                ldir              
                pop     de                
                ret 
                
getRightMargin:
                ld      hl,(vRMarginAddr)
                add     hl,de
                
                ld      a,(hl)
                ld      (vRightMargin),a
                ret  
                
; copying symbol to buffer, filling spaces
copyToBuffer:
                ld 		A, (vPrevLeft)
                CP 		0x10
                JR 		NC, _setA0
                CP 		0x8
                JR 		NC, _copy_next2
                XOR		A
                jr      _setA
_setA0:
                call    clearBuffers
                ld      hl,(vScreenPos)
                inc     hl
                ld      (vScreenPos),hl
                ld		A, 0x01
                jr      _setA
_copy_next2:	
                ld		A, 0x01
_setA:	
                ld 		(vGoNext), A

                ld 		A, (vPrevLeft)
                AND 	0x07
                ld 		C, A
                ld 		HL, vRightMargin
                add 	(HL)
                add     3
                ld 		(vPrevLeft), A
                ld 		E, 0x10
                ld 		HL, vPrintBuffer
                ld 		(vDstAddr), HL
                ld 		HL, vKanjiBuffer
                ld 		(vSrcAddr), HL
_printBufferLoop:
                ld		A, C
                ld 		D, (HL)
                AND 	0x80
                
                JR 		NZ, _copy_neg1
                LD		A, C
                CALL 	ShiftRight
                JR 		_copy_next3
_copy_neg1:
                ld      A,C
                neg
                CALL	ShiftLeft
_copy_next3:
                ld 		HL, (vDstAddr)
                ld		(HL), D
                inc 	HL
                ld 		(vDstAddr), HL
                LD 		HL, (vSrcAddr)
		        inc 	HL
		        LD 		(vSrcAddr), HL
                dec     e
                ld      a,e
                cp      0
                jp 	    nz,_printBufferLoop
		
                ld 		A, 0x8
                sub 	C
                ld		C, A
                ld		A, (vRightMargin)
                CP		C
                JP 		NC, _copy_next4
                JP 		_ret
_copy_next4:	
                ld		A, 0x01
                ld 		(vPrintSecond), A
                ld 		E, 0x10
                ld 		HL, vPrintBuffer2
                ld 		(vDstAddr), HL
                ld 		HL, vKanjiBuffer
                ld 		(vSrcAddr), HL
_printBufferLoop2:
                ld		A, C
                ld 		D, (HL)
                AND 	0x80
                
                JR 		NZ, _neg2
                LD		A, C
                CALL	ShiftLeft
                JR 		_next5
_neg2:
                ld      A,C
                neg
                CALL	ShiftRight
_next5:
                ld 		HL, (vDstAddr)
                ld		(HL), D
                inc 	HL
                ld 		(vDstAddr), HL
                LD 		HL, (vSrcAddr)
		        inc 	HL
		        LD 		(vSrcAddr), HL
                dec     e
                ld      a,e
                cp      0
                jp 	    nz,_printBufferLoop2
_ret:
                RET

printBuffer:
_patch2:
		        ld 		A, (DE)
		        ld 		(HL), A
_print1:
		        inc 	DE
		        push 	DE
		        ld		DE, 0x50
		        add 	HL, DE
		        pop 	DE
		        dec 	B
		        ld 		A, B
		        CP 		1
		        RET     Z
		        JR 		printBuffer  

clearBuffers:
                ld      a,0
                ld      hl,vPrintBuffer
                call    _clearBuffers
                ld      hl,vPrintBuffer2
                call    _clearBuffers
                ret
_clearBuffers:
                
                ld      (hl),a
                inc     hl
                ld      (hl),a
                inc     hl
                ld      (hl),a
                inc     hl
                ld      (hl),a
                inc     hl
                ld      (hl),a
                inc     hl
                ld      (hl),a
                inc     hl
                ld      (hl),a
                inc     hl
                ld      (hl),a
                inc     hl
                ld      (hl),a
                inc     hl
                ld      (hl),a
                inc     hl
                ld      (hl),a
                inc     hl
                ld      (hl),a
                inc     hl
                ld      (hl),a
                inc     hl
                ld      (hl),a
                inc     hl
                ld      (hl),a
                inc     hl
                ld      (hl),a
                inc     hl
                ret

; 8-bit shift in A, B - shift count
ShiftRight:
                cp      0
                ret     Z
_doshiftright:
                srl     d
                dec     a
                jr ShiftRight
                
ShiftLeft:
                cp      0
                ret     Z
_doshiftleft:
                sla     d
                dec     a
                jr ShiftLeft
                

vKanjiBuffer:
                .byte 0x00 
                .byte 0x00 
                .byte 0x00 
                .byte 0x00    
                .byte 0x00 
                .byte 0x00 
                .byte 0x00 
                .byte 0x00    
                .byte 0x00 
                .byte 0x00 
                .byte 0x00 
                .byte 0x00    
                .byte 0x00 
                .byte 0x00 
                .byte 0x00 
                .byte 0x00    
vPrintBuffer:
                .byte 0x00 
                .byte 0x00 
                .byte 0x00 
                .byte 0x00    
                .byte 0x00 
                .byte 0x00 
                .byte 0x00 
                .byte 0x00    
                .byte 0x00 
                .byte 0x00 
                .byte 0x00 
                .byte 0x00    
                .byte 0x00 
                .byte 0x00 
                .byte 0x00 
                .byte 0x00    
vPrintBuffer2:
                .byte 0x00 
                .byte 0x00 
                .byte 0x00 
                .byte 0x00    
                .byte 0x00 
                .byte 0x00 
                .byte 0x00 
                .byte 0x00    
                .byte 0x00 
                .byte 0x00 
                .byte 0x00 
                .byte 0x00    
                .byte 0x00 
                .byte 0x00 
                .byte 0x00 
                .byte 0x00    
