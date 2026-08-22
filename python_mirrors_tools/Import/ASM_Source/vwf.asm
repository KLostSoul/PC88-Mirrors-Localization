        .ORG     0x0000

; Korean 500-glyph test VWF.
; One fixed-width 8x16 font bank is resident at bank RAM 1000h..2F3Fh.
; CMD KANJI passes a whole string.  Each glyph token is E0 00h..E1 F3h.

        .EQU KoreanFontBase,     0x1000
        .EQU vPrintPos,          0xB40C
        .EQU v32ExtAccess,       0xB40E
        .EQU v32IndepAccess,     0xB40F
        .EQU vScreenPos,         0xB410
        .EQU vStrAddr,           0xB412
        .EQU vStartScreenPos,    0xB414
        .EQU vLineBreakHeight,   0xB416
        .EQU vpatch5,            0xB41B
        .EQU vStrLen,            0xB41C
        .EQU vCharCount,         0xB41D

; vStrLen is supplied by the CMD KANJI handler as (byte length + 1).
; The test token stream must be even length and at most 254 bytes
; (127 Korean glyphs) per BASIC string.
printMsg:
                in      a,(0x32)
                ld      b,a
                and     0xBF
                ld      (v32IndepAccess),a
                ld      a,b
                or      0x40
                ld      (v32ExtAccess),a

                ld      hl,(vPrintPos)
                ld      (vScreenPos),hl
                ld      (vStartScreenPos),hl
                ld      a,(vCharCount)
                ld      (k500CharsLeft),a
                ld      a,(vStrLen)
                dec     a                 ; handler supplies byte length + 1
                ld      c,a               ; remaining token bytes

k500NextToken:
                ld      a,c
                cp      0x02
                jr      c,k500End

                call    k500TokenToGlyph  ; DE = font glyph address
                dec     c
                dec     c

                ; Font bank is visible only while this access mode is active.
                ld      a,0xA8
                out     (0x32),a
                push    bc
                call    k500CopyGlyph
                pop     bc

                ld      a,(v32IndepAccess)
                out     (0x32),a
                out     (0x5F),a
                ld      hl,(vScreenPos)
                ld      a,(v32ExtAccess)
                out     (0x32),a
                ld      a,(vpatch5)
                out     (0x34),a
                ld      a,0x80
                out     (0x35),a
                ld      de,k500GlyphBuffer
                ld      b,0x10
                call    k500WriteGlyph

                ld      a,(v32IndepAccess)
                out     (0x32),a
                out     (0x5F),a
                call    k500AdvanceCell
                jr      k500NextToken

k500End:
                xor     a
                out     (0x35),a
                ret

; Read two bytes at vStrAddr, advance the pointer by two, and resolve the
; resulting token to KoreanFontBase + (glyph index * 16). Invalid tokens use
; glyph zero so unrelated legacy strings fail visibly but safely.
k500TokenToGlyph:
                ld      hl,(vStrAddr)
                ld      a,(hl)
                inc     hl
                ld      e,(hl)
                inc     hl
                ld      (vStrAddr),hl
                sub     0xE0
                jr      c,k500GlyphZero
                cp      0x02
                jr      nc,k500GlyphZero
                ld      d,a
                ld      a,d
                or      a
                jr      z,k500IndexValid
                ld      a,e
                cp      0xF4
                jr      nc,k500GlyphZero

k500IndexValid:
                ex      de,hl
                add     hl,hl
                add     hl,hl
                add     hl,hl
                add     hl,hl
                ld      de,KoreanFontBase
                add     hl,de
                ex      de,hl
                ret

k500GlyphZero:
                ld      de,KoreanFontBase
                ret

k500CopyGlyph:
                ex      de,hl
                ld      de,k500GlyphBuffer
                ld      bc,0x0010
                ldir
                ret

; DE points to 16 bitmap rows; HL is the destination VRAM address.
k500WriteGlyph:
                ld      a,(de)
                ld      (hl),a
                inc     de
                push    de
                ld      de,0x0050
                add     hl,de
                pop     de
                djnz    k500WriteGlyph
                ret

k500AdvanceCell:
                ld      hl,(vScreenPos)
                inc     hl
                ld      (vScreenPos),hl
                ld      a,(k500CharsLeft)
                dec     a
                jr      z,k500NextLine
                ld      (k500CharsLeft),a
                ret

k500NextLine:
                ld      hl,(vStartScreenPos)
                ld      de,(vLineBreakHeight)
                add     hl,de
                ld      (vStartScreenPos),hl
                ld      (vScreenPos),hl
                ld      a,(vCharCount)
                ld      (k500CharsLeft),a
                ret

k500CharsLeft: .byte   0x00
k500GlyphBuffer:
                .byte   0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
                .byte   0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
