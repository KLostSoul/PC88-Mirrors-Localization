        .ORG     0x0000

; Global variables
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
                
                ; New single-bank layout (physical expansion-RAM bank 0):
                ;   0x1000-0x15FF: printable ASCII 0x20-0x7F, 16 bytes each
                ;   0x2000-0x4CFF: 8x4x4 Korean component glyphs
                ; No font selector is used.  ASCII and Korean composition
                ; data are both resident in physical expansion-RAM bank 0.

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
                ; Korean composition tokens use the lead table below.  BASIC
                ; control handling remains separate from token handling.
                cp      0x80
                jr      c,_singleByteSymbol
                ld      d,a
                push    hl
                push    bc
                call    isKoreanTokenLead
                pop     bc
                pop     hl
                jr      c,_singleByteSymbol
                ld      e,(hl)
                dec     c
                ld      a,c
                cp      0x00
                jp      z,_endDraw
                inc     hl
                ld      (vStrAddr),hl
                ld      a,0xA8
                out     (0x32),a        ; '2'
                push    bc
                ; VWF code, ASCII cells, and Korean component cells all live
                ; in physical expansion-RAM bank 0.  No bank switch is needed
                ; while composing the 16x16 glyph.
                call    composeKoreanGlyph
                call    prepareKoreanBuffers
                ld      a,0x01
                ld      (vPrintSecond),a
                ld      a,0x02
                ld      (vGlyphCells),a
                jr      _copyBuffersFixed
_singleByteSymbol:
                cp      0x5c
                jp      z,_nextLine
                cp      0x0d
                jp      z,_nextLine
                ld      a,0xA8
                out     (0x32),a        ; '2'
                push    bc
                call    convertASCII_toCharAddr
_copyGlyph:
                call    copyCharToBuffer
                call    prepareASCIIBuffers
                xor     a
                ld      (vPrintSecond),a
                ld      a,0x01
                ld      (vGlyphCells),a
                jr      _copyBuffersFixed
                
                
; Fixed 8x16 ASCII / 16x16 Korean output path.
; Both glyph classes use the same 16-raster-row screen writer; Korean uses
; the second prepared buffer for its second 8-pixel half.
_copyBuffersFixed:
                ld      a,(v32IndepAccess)
                out     (0x32),a
                ld      hl,(vScreenPos)
                ld      (vScreenPos2),hl
                ld      a,(v32ExtAccess)
                out     (0x32),a
                ld      a,(vpatch5)
                out     (0x34),a
                ld      a,0x80
                out     (0x35),a

                ld      de,vPrintBuffer
                ld      b,0x10
                call    printBuffer16

                ld      a,(vPrintSecond)
                or      a
                jr      z,_prepareNextFixed
                ld      hl,(vScreenPos2)
                inc     hl
                ld      (vScreenPos),hl
                ld      de,vPrintBuffer2
                ld      b,0x10
                call    printBuffer16
                ld      hl,(vScreenPos2)
                ld      (vScreenPos),hl
                xor     a
                ld      (vPrintSecond),a

_prepareNextFixed:
                pop     bc
                ld      a,(v32IndepAccess)
                out     (0x32),a
                out     (0x5F),a
                ld      a,(vGlyphCells)
                ld      e,a
                ld      a,(vCharsLeft)
                sub     e
                jp      c,_nextLine
                jp      z,_nextLine
                ld      (vCharsLeft),a
                ld      a,(vGlyphCells)
                ld      e,a
                ld      d,0
                ld      hl,(vScreenPos)
                add     hl,de
                ld      (vScreenPos),hl
                ld      (vPrevScreenPos),hl
                xor     a
                ld      (vPrevPrint),a
                jp      _nextSymbol

                ; Referenced from 11BE
_nextLine:      ld      hl,(vStartScreenPos)
                ld      de,0x0500                              ; 16 raster rows * 0x50 bytes
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
; Reserved legacy slots.  Keep four bytes to preserve the fixed layout;
; the composite renderer does not use the former font/margin pointers.
                .byte   0x00, 0x00, 0x00, 0x00
vGlyphCells:    .byte   0x01
vKInitial:      .byte   0x00
vKMedial:       .byte   0x00
vKFinal:        .byte   0x00
vKInitialProfile: .byte 0x00
vKMedialProfile:  .byte 0x00
vKFinalProfile:   .byte 0x00
;        
; ------------------ PATCH AREA


; Decode a BASIC-string-safe two-byte token.  Both bytes are selected from
; tables that exclude BASIC/VWF control values.  Each lead selects a base-165
; block and the trail-table position supplies the value 0-164.  The result
; is the contiguous Unicode Hangul syllable index (AC00-D7A3), from which the
; initial, medial, and final indices are calculated.
isKoreanTokenLead:
                ld      a,d
                ld      hl,kTokenLeadTable
                ld      b,0x4b
                xor     a
                ld      c,a
                ld      a,d
_findKoreanTokenLead:
                cp      (hl)
                jr      z,_koreanLeadFound
                inc     hl
                inc     c
                djnz    _findKoreanTokenLead
                scf
                ret
_koreanLeadFound:
                or      a
                ret

composeKoreanGlyph:
                ld      a,d
                ld      hl,kTokenLeadTable
                ld      b,0x4b
                xor     a
                ld      c,a
                ld      a,d
_decodeKoreanTokenLead:
                cp      (hl)
                jr      z,_decodeKoreanTokenFound
                inc     hl
                inc     c
                djnz    _decodeKoreanTokenLead
                jp      _koreanBlank
_decodeKoreanTokenFound:
                ld      d,c
                ld      a,e
                ld      hl,kTokenTrailTable
                ld      b,0xA5
                ld      c,0
_findKoreanTokenTrail:
                cp      (hl)
                jr      z,_decodeTrailReady
                inc     hl
                inc     c
                djnz    _findKoreanTokenTrail
                jp      _koreanBlank
_decodeTrailReady:
                ld      hl,0
                ld      a,d
                or      a
                jr      z,_decodeLeadReady
                ld      b,a
                ld      de,165
_decodeLeadLoop:
                add     hl,de
                djnz    _decodeLeadLoop
_decodeLeadReady:
                ld      e,c
                ld      d,0
                add     hl,de

                ; Reject indices beyond the modern Hangul syllable range.
                ld      de,11172
                or      a
                sbc     hl,de
                jp      nc,_koreanBlank
                add     hl,de

                ; initial = syllable_index / 588, remainder retained in HL.
                ld      b,0
                ld      de,588
_decodeInitialLoop:
                or      a
                sbc     hl,de
                jr      c,_decodeInitialReady
                inc     b
                jr      _decodeInitialLoop
_decodeInitialReady:
                add     hl,de
                ld      a,b
                ld      (vKInitial),a

                ; medial = remainder / 28; final = remainder % 28.
                ld      b,0
                ld      de,28
_decodeMedialLoop:
                or      a
                sbc     hl,de
                jr      c,_decodeMedialReady
                inc     b
                jr      _decodeMedialLoop
_decodeMedialReady:
                add     hl,de
                ld      a,b
                ld      (vKMedial),a
                ld      a,l
                ld      (vKFinal),a

                ld      a,(vKInitial)
                cp      0x13
                jr      nc,_koreanBlank
                ld      a,(vKMedial)
                cp      0x15
                jr      nc,_koreanBlank
                ld      a,(vKFinal)
                cp      0x1c
                jr      nc,_koreanBlank

                xor     a
                ld      hl,vKanjiBuffer
                ld      b,0x20
_clearKoreanBuffer:
                ld      (hl),a
                inc     hl
                djnz    _clearKoreanBuffer

                ld      a,(vKFinal)
                or      a
                ld      hl,kInitialProfileNoFinal
                jr      z,_initialProfileReady
                ld      hl,kInitialProfileWithFinal
_initialProfileReady:
                ld      a,(vKMedial)
                ld      e,a
                ld      d,0
                add     hl,de
                ld      a,(hl)
                ld      (vKInitialProfile),a

                ld      a,(vKFinal)
                or      a
                ld      a,0x02
                jr      nz,_medialProfileBaseReady
                xor     a
_medialProfileBaseReady:
                ld      b,a
                ld      a,(vKInitial)
                or      a
                jr      z,_medialProfileReady
                cp      0x0f
                jr      z,_medialProfileReady
                inc     b
_medialProfileReady:
                ld      a,b
                ld      (vKMedialProfile),a

                ld      a,(vKMedial)
                ld      e,a
                ld      d,0
                ld      hl,kFinalProfileByMedial
                add     hl,de
                ld      a,(hl)
                ld      (vKFinalProfile),a

                call    initialComponentAddress
                call    orComponentToKoreanBuffer
                call    medialComponentAddress
                call    orComponentToKoreanBuffer
                ld      a,(vKFinal)
                or      a
                ret     z
                call    finalComponentAddress
                jp      orComponentToKoreanBuffer

_koreanBlank:
                xor     a
                ld      hl,vKanjiBuffer
                ld      b,0x20
_clearInvalidKorean:
                ld      (hl),a
                inc     hl
                djnz    _clearInvalidKorean
                ret

; HL = initial component address.  Initial cells are 20 bytes wide in the
; reference table and the component base is 0x2000.
initialComponentAddress:
                ld      a,(vKInitialProfile)
                ld      h,0
                ld      l,a
                add     hl,hl
                add     hl,hl
                push    hl
                add     hl,hl
                add     hl,hl
                pop     de
                add     hl,de
                ld      a,(vKInitial)
                inc     a
                ld      e,a
                ld      d,0
                add     hl,de
                call    multiplyCellBy32
                ld      de,0x2000
                add     hl,de
                ret

; HL = medial component address.  Medial cells begin after 8*20 cells.
medialComponentAddress:
                ld      hl,0
                ld      a,(vKMedialProfile)
                or      a
                jr      z,_medialProfileOffsetReady
                ld      de,22
_medialProfileOffsetLoop:
                add     hl,de
                dec     a
                jr      nz,_medialProfileOffsetLoop
_medialProfileOffsetReady:
                ld      a,(vKMedial)
                inc     a
                ld      e,a
                ld      d,0
                add     hl,de
                call    multiplyCellBy32
                ld      de,0x3400
                add     hl,de
                ret

; HL = final component address.  Final cells begin after 8*20+4*22 cells.
finalComponentAddress:
                ld      hl,0
                ld      a,(vKFinalProfile)
                or      a
                jr      z,_finalProfileOffsetReady
                ld      de,28
_finalProfileOffsetLoop:
                add     hl,de
                dec     a
                jr      nz,_finalProfileOffsetLoop
_finalProfileOffsetReady:
                ld      a,(vKFinal)
                ld      e,a
                ld      d,0
                add     hl,de
                call    multiplyCellBy32
                ld      de,0x3f00
                add     hl,de
                ret

multiplyCellBy32:
                add     hl,hl
                add     hl,hl
                add     hl,hl
                add     hl,hl
                add     hl,hl
                ret

; OR one 32-byte 16x16 component into vKanjiBuffer.
orComponentToKoreanBuffer:
                ld      de,vKanjiBuffer
                ld      b,0x20
_orComponentLoop:
                ld      a,(hl)
                ld      c,a
                ld      a,(de)
                or      c
                ld      (de),a
                inc     hl
                inc     de
                djnz    _orComponentLoop
                ret

; Split interleaved 16x16 rows into the two 16-row screen buffers.
prepareKoreanBuffers:
                call    clearBuffers
                push    ix
                ld      hl,vKanjiBuffer
                ld      de,vPrintBuffer
                ld      ix,vPrintBuffer2
                ld      b,0x10
_splitKoreanRows:
                ld      a,(hl)
                ld      (de),a
                inc     hl
                inc     de
                ld      a,(hl)
                ld      (ix+0),a
                inc     hl
                inc     ix
                djnz    _splitKoreanRows
                pop     ix
                ret

; Returns address to char in DE
convertASCII_toCharAddr:
                ; ASCII uses its byte value directly as a 16-byte cell index:
                ; address = 0x1000 + ASCII code * 16.
                ld      a,e
                cp      0x20
                jr      c,_asciiBlank
                cp      0x80
                jr      nc,_asciiBlank
                jr      _asciiIndexReady
_asciiBlank:
                xor     a
                ld      e,a
_asciiIndexReady:
                ld      h,0
                ld      l,e
                add     hl,hl
                add     hl,hl
                add     hl,hl
                add     hl,hl
                ld      de,0x1000
                add     hl,de
                ld      e,l
                ld      d,h
                ret
                
copyCharToBuffer:
                push    de                               
                ex      de,hl            
                ld      de,vKanjiBuffer
                ld      bc,0x10
                ldir              
                pop     de                
                ret 

prepareASCIIBuffers:
                call    clearBuffers
                ld      hl,vKanjiBuffer
                ld      de,vPrintBuffer
                ld      bc,0x0010
                ldir
                ret
                
; Print exactly 16 raster rows from a prepared screen buffer.
printBuffer16:
                ld      a,(de)
                ld      (hl),a
                inc     de
                push    de
                ld      de,0x50
                add     hl,de
                pop     de
                djnz    printBuffer16
                ret

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

; Safe lead bytes for payload high-byte indices 0x00..0x4A.  The excluded
; values cover the known BASIC string controls and the old E0-E5 token leads.
kTokenLeadTable:
                .byte 0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x8B
                .byte 0x8F,0x90,0x91,0x92,0x94,0x95,0x96,0x97,0x98,0x99
                .byte 0x9A,0x9B,0x9D,0x9E,0xA0,0xA1,0xA2,0xA3,0xA5,0xAA
                .byte 0xAB,0xAC,0xAD,0xAE,0xAF,0xB0,0xB1,0xB2,0xB3,0xB4
                .byte 0xB5,0xB6,0xB7,0xB8,0xB9,0xBA,0xBB,0xBC,0xBD,0xBE
                .byte 0xBF,0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8
                .byte 0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2
                .byte 0xD3,0xD4,0xD5,0xD6,0xD7

; Safe trail-byte alphabet.  It excludes 0x5C and every BASIC/VWF control
; value that can occur inside the old string and pagination machinery.
kTokenTrailTable:
                .byte 0x40,0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4A,0x4B
                .byte 0x4C,0x4D,0x4E,0x4F,0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57
                .byte 0x58,0x59,0x5A,0x5B,0x5D,0x5E,0x5F,0x60,0x61,0x62,0x63,0x64
                .byte 0x65,0x66,0x67,0x68,0x69,0x6A,0x6B,0x6C,0x6D,0x6E,0x6F,0x70
                .byte 0x71,0x72,0x73,0x74,0x75,0x76,0x77,0x78,0x79,0x7A,0x7B,0x7C
                .byte 0x7D,0x7E,0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x8B
                .byte 0x8F,0x90,0x91,0x92,0x94,0x95,0x96,0x97,0x98,0x99,0x9A,0x9B
                .byte 0x9D,0x9E,0xA0,0xA1,0xA2,0xA3,0xA5,0xAA,0xAB,0xAC,0xAD,0xAE
                .byte 0xAF,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0xB7,0xB8,0xB9,0xBA
                .byte 0xBB,0xBC,0xBD,0xBE,0xBF,0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6
                .byte 0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2
                .byte 0xD3,0xD4,0xD5,0xD6,0xD7,0xD8,0xD9,0xDA,0xDB,0xDC,0xDE,0xDF
                .byte 0xE6,0xE7,0xE8,0xE9,0xEA,0xEB,0xED,0xEE,0xEF,0xF0,0xF2,0xF3
                .byte 0xF4,0xF5,0xF6,0xF7,0xF8,0xF9,0xFA,0xFB,0xFC

; 8x4x4 profile lookup tables from the reference composition source.
kInitialProfileNoFinal:
                .byte 0,0,0,0,0,0,0,0,1,3,3,3,1,2,4,4,4,2,1,3,0
kInitialProfileWithFinal:
                .byte 5,5,5,5,5,5,5,5,6,7,7,7,6,6,7,7,7,6,6,7,5
kFinalProfileByMedial:
                .byte 0,2,0,2,1,2,1,2,3,0,2,1,3,3,1,2,1,3,3,1,1
                

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
