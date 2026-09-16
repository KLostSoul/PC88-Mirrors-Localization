
        .ORG     0x7B00

		xor     a
        ld      (L7F20),a
        ld      (L7F17),a
        ld      ix,0x7E59
        ld      hl,0x00C1
        push    hl
        rst     0x10
        ld      hl,0x7B23
        ld      bc,0x0006
        cpir
        ret     nz
        ld      hl,0x7B29
        add     hl,bc
        add     hl,bc
        ld      a,(hl)
        inc     hl
        ld      h,(hl)
        ld      l,a
        jp      (hl)

L7B23:  .byte 0x1f
        .byte 0x20
        .byte 0x2c
        .byte 0x2d
        .byte 0x2e
        .byte 0x2f
        .word L7DB4
        .word LRead
        .word LWrite
        .word L7DA3
        .word L7E2C
        nop
        nop
  
L7B35:  call    L7D6F
        rst     0x10
        ld      d,a
        call    0x01AA
        jp      0x0455

L7B40:  call    L7D6F
        rst     0x10
        ld      d,a
        rst     0x10
        ld      (L7E5C),a

        ; Referenced from 7DB0
        ; --- START PROC L7B49 ---
L7B49:  call    L7D14
        call    L7D4C

        ; Referenced from 7B24
L7B4F:  ld      (ix+0x08),0xFF
        ld      e,0x01
        ld      b,(ix+0x04)
        ld      hl,0x7E6B

        ; Referenced from 7B6D
L7B5B:  call    0x041B
        ld      (hl),a
        inc     hl
        call    0x042F
        ld      (hl),a
        inc     hl
        ld      (hl),e
        inc     hl
        ld      a,(L7E5C)
        ld      (hl),a
        inc     hl
        inc     e
        djnz    L7B5B
        call    L7B75
        jp      0x0455

        ; Referenced from 7B6F
        ; --- START PROC L7B75 ---
L7B75:  call    L7D91
        ret     c
        ld      a,0x01

        ; Referenced from 7BCF
L7B7B:  ld      (L7F0A),a
        push    bc
        push    de
        ld      a,(L7E59)
        or      0x0D
        call    0x02A4
        call    0x042F
        ld      b,a
        call    0x040E
        rst     0x20
        call    0x041B
        ld      d,a
        ld      a,(L7E5C)
        rst     0x20
        ld      a,(L7E5D)
        ld      e,a
        sla     e
        sla     e
        rst     0x20
        ld      a,(L7E5F)
        rst     0x20
        ld      a,(L7E61)
        rst     0x20
        ld      hl,0x7E6B

        ; Referenced from 7BB9
L7BAC:  ei
        halt
        in      a,(0xFA)
        bit     5,a
        jr      z,L7BBB
        ld      a,(hl)
        out     (0xFB),a
        inc     hl
        dec     e
        jr      nz,L7BAC

        ; Referenced from 7BB2
L7BBB:  call    0x07C6
        pop     de
        pop     bc
        call    0x0263
        ret     nc
        ld      a,(L7F0E)
        and     0x02
        scf
        ret     nz
        ld      a,(L7F0A)
        dec     a
        jr      nz,L7B7B
        scf
        ret

L7BD3:  ld      a,0x06
        ld      (L7E63),a
        rst     0x10
        ld      (L7E5C),a
        call    L7D87
        ld      a,0xFF
        ld      (L7F18),a
        call    0x06AF

        ; Referenced from 7E05
        ; --- START PROC L7BE7 ---
; ------------- PATCH - Read using standard ROM routine ------------------	        
L7BE7:  ld      a,1
        cp      c
        jp      c,0x0cc0
        call    0x0eca
        ld      a,0xff
        ld      (0x7f18),a
        call    0x0d76
        jp      0x0455
        
        nop

        ; Referenced from 7BF8
L7BFC:  ld      (L7F14),a
        ret

        ; Referenced from 7BF3
        ; --- START PROC L7C00 ---
; ------------- PATCH START ------------------		
L7C00:  call	0x0809
		jp      0x0455
		nop
		nop
; ------------- PATCH END ------------------
        
        ret     c
        call    0x035B
        ld      a,0x01

        ; Referenced from 7C64
L7C0E:  ld      (L7F0A),a
        ld      a,(L7E63)
        push    bc
        push    de
        call    L7CDF
        ld      d,0x00
        call    L7D03
        ld      a,(L7F21)
        or      a
        jr      z,L7C37

        ; Referenced from 7C33
L7C24:  ei
        halt
        in      a,(0xFA)
        bit     5,a
        jr      z,L7C4A
        in      a,(0xFB)
        ld      (hl),a
        inc     hl
        dec     bc
        ld      a,c
        or      b
        jr      nz,L7C24
        jr      L7C4A

        ; Referenced from 7C22, 7C48
L7C37:  ei
        halt
        in      a,(0xFA)
        bit     5,a
        jr      z,L7C4A
        in      a,(0xFB)
        sub     (hl)
        or      d
        ld      d,a
        inc     hl
        dec     bc
        ld      a,c
        or      b
        jr      nz,L7C37

        ; Referenced from 7C2A, 7C35, 7C3D
L7C4A:  in      a,(0xF8)
        ei
        halt
        ld      a,d
        pop     de
        pop     bc
        push    af
        call    0x0263
        jr      c,L7C5C
        pop     af
        or      a
        ret     z
        ccf
        ret

        ; Referenced from 7C55
L7C5C:  pop     af
        call    0x0375
        ld      a,(L7F0A)
        dec     a
        jp      nz,L7C0E
        scf
        ret
		; ------------- PATCH START ------------------
L7C69:	call	0x0dc5
        call    0x0d91	
		jp      0x0455
        ; ------------- PATCH END ------------------
		
        call    L7D87
        call    0x06AF

        ; Referenced from 7E28, 7E50
        ; --- START PROC L7C78 ---
L7C78:  call    L7D14
        ld      a,(L7E5D)
        ld      (L7E5E),a
        call    L7D4C
        call    L7C8A
        jp      0x0455

        ; Referenced from 7C84
        ; --- START PROC L7C8A ---
L7C8A:  push    af
        xor     a
        ld      (L7F20),a
        pop     af
        call    L7D9A
        ret     c
        call    0x035B
        ld      a,0x01

        ; Referenced from 7CD9
L7C99:  ld      (L7F0A),a
        push    bc
        push    de
        xor     a
        ld      (L7F20),a
        ld      a,(L7E63)
        call    L7CDF
        call    L7D03

        ; Referenced from 7CBA
L7CAB:  ei
        halt
        in      a,(0xFA)
        bit     5,a
        jr      z,L7CBC
        ld      a,(hl)
        out     (0xFB),a
        inc     hl
        dec     bc
        ld      a,c
        or      b
        jr      nz,L7CAB

        ; Referenced from 7CB1
L7CBC:  xor     a
        ld      (L7F20),a
        in      a,(0xF8)
        ei
        halt
        pop     de
        pop     bc
        call    0x0263
        jr      nc,L7CDE
        ld      a,(L7F0E)
        and     0x02
        scf
        ret     nz
        call    0x0375
        ld      a,(L7F0A)
        dec     a
        jp      nz,L7C99
        scf
        ret

        ; Referenced from 7CC9
        ; --- START PROC L7CDE ---
L7CDE:  ret

        ; Referenced from 7C16, 7CA5
        ; --- START PROC L7CDF ---
L7CDF:  or      (ix+0x00)
        call    0x02A4
        call    0x040E
        rst     0x20
        call    0x041B
        rst     0x20
        call    0x042F
        rst     0x20
        ld      a,e
        rst     0x20
        ld      a,(L7E5C)
        rst     0x20
        ld      a,(L7E5E)
        rst     0x20
        ld      a,(L7E60)
        rst     0x20
        ld      a,0xFF
        rst     0x20
        ret

        ; Referenced from 7C1B, 7CA8
        ; --- START PROC L7D03 ---
L7D03:  ld      a,(L7E5C)
        ld      c,0x00
        srl     b
        rr      c

        ; Referenced from 7D12
L7D0C:  dec     a
        ret     m
        sla     c
        rl      b
        jr      L7D0C

        ; Referenced from 7B49, 7BE7, 7C78
        ; --- START PROC L7D14 ---
L7D14:  push    bc
        push    hl
        ld      a,(L7E5C)
        ld      c,a
        ld      b,0x00
        ld      a,(L7E59)
        rlca
        rlca
        xor     0x01
        add     a,c
        ld      c,a
        ld      hl,0x7D30
        add     hl,bc
        ld      a,(hl)
        ld      (L7E5D),a
        pop     hl
        pop     bc
        ret

L7D30:  .byte     0x1a
        .byte     0x10
        .byte     0x09
        .byte     0x08
		.byte     0x02

        ; Referenced from 7BF0
        ; --- START PROC L7D35 ---
L7D35:  push    bc
        push    hl
        ld      a,(L7E5C)
        ld      c,a

        ; Referenced from 7D31
L7D3B:  ld      b,0x00
        ld      hl,0x7D48
        add     hl,bc
        ld      a,(hl)
        ld      (L7E60),a
        pop     hl
        pop     bc
        ret

L7D48:  rlca
        ld      c,0x1B
        dec     (hl)

        ; Referenced from 7B4C, 7C81
        ; --- START PROC L7D4C ---
L7D4C:  push    bc
        push    hl
        ld      a,(L7E5C)
        ld      c,a
        ld      b,0x00
        ld      hl,0x7D67
        add     hl,bc
        add     hl,bc
        ld      a,(L7E59)
        rlca
        rlca
        ld      c,a
        add     hl,bc
        ld      a,(hl)
        ld      (L7E5F),a
        pop     hl
        pop     bc
        ret

L7D67:  .byte     0x17
        .byte     0x25
        .byte     0x27
        .byte     0x33
        .byte     0x2d
        .byte     0x50
        .byte     0x64
        .byte     0x74  ; PATCH

        ; Referenced from 7B35, 7B40, 7D89
        ; --- START PROC L7D6F ---
L7D6F:  rst     0x10

        ; Referenced from 7DA6, 7DF3, 7E16, 7E46
        ; --- START PROC L7D70 ---
L7D70:  ld      c,a
        and     0x40            ; '@'
        ld      (L7E59),a
        ld      a,c
        and     0x10
        ld      (L7E5A),a
        ld      a,c
        and     0x0F
        ld      c,a
        push    af
        xor     a
        ld      (L7F20),a
        pop     af
        ret

        ; Referenced from 7BDC, 7C72
        ; --- START PROC L7D87 ---
L7D87:  rst     0x10
        ld      b,a
        call    L7D6F
        rst     0x10
        ld      d,a
        rst     0x10
        ld      e,a
        ret

        ; Referenced from 7B75
        ; --- START PROC L7D91 ---
L7D91:  ld      a,(L7E5A)
        or      a
        ret     z
        call    0x01B6
        ret

        ; Referenced from 7C05, 7C90
        ; --- START PROC L7D9A ---
L7D9A:  ld      a,(L7E5A)
        or      a
        ret     z
        call    0x01B6
        ret

L7DA3:  rst     0x10
        or      0x50            ; 'P'
        call    L7D70
;--------------- Patch - FORMAT -------------------
        call    0x0d3a          
        jp      0x0455
        nop
        nop
        nop
        nop
        ret

L7DB4:  rst     0x10
        push    af
        ld      hl,0x4000
        ld      bc,0x0400

        ; Referenced from 7DC2
L7DBC:  ld      (hl),0xFF
        inc     hl
        dec     bc
        ld      a,b
        or      c
        jr      nz,L7DBC
        ld      b,0x04
        ld      hl,0x4000
        ld      de,0x7E54

        ; Referenced from 7DD0
L7DCC:  ld      a,(de)
        ld      (hl),a
        inc     de
        inc     hl
        djnz    L7DCC
        ld      a,0xFE
        ld      (0x4200),a
        ld      (0x438B),a
        pop     af
        ld      c,a
        ld      de,0x3108             ; PATCH - new track number
        ld      hl,0x4000
        call    L7E39
        ret

LRead:  ld      a,0x06
        ld      (L7E63),a
        ld      a,0x03
        ld      (L7E5C),a
        rst     0x10
        or      0x50            ; 'P'
        call    L7D70
        ld      a,0xFF
        ld      (L7F18),a
        rst     0x10
        ld      d,a
        rst     0x10
        ld      e,a
        rst     0x10
        ld      b,a
        rst     0x10
        ld      h,a
        rst     0x10
        ld      l,a
        call    L7BE7
        ret

LWrite: ld      a,0x05
        ld      (L7E63),a
        ld      a,0x03
        ld      (L7E5C),a
        rst     0x10
        or      0x50            ; 'P'

        ; Referenced from 7E37
L7E16:  call    L7D70
        ld      a,0xFF
        ld      (L7F18),a
        rst     0x10
        ld      d,a
        rst     0x10
        ld      e,a
        rst     0x10
        ld      b,a
        rst     0x10
        ld      h,a
        rst     0x10
        ld      l,a
        call    L7C69
        ret
        
; ------------------ PATCH -  INIT
L7E2C:  ld      a,0x0f
        out     (0xf4),a
		ld      a,0x23
		ld      c,0
		call    0x0f38
		ld      a,0x23
		ld      c,1
		call    0x0f38
		ld      a,2
		ld      (0x7f48),a
		jp      0x0455
		
		nop
		nop
		nop
		nop
		nop
		nop
        

        ; Referenced from 7DE2
        ; --- START PROC L7E39 ---
L7E39:  nop
		nop
		nop
		nop
; ------------- PATCH END ------------------
        call    L7C69
        ret

L7E54:  ld      c,c
        ld      d,b
        ld      c,h
        ld      b,h
        rst     0x38

        ; Referenced from 7B80, 7D1C, 7D59, 7D73
L7E59:  nop

        ; Referenced from 7D79, 7D91, 7D9A
L7E5A:  nop
        nop

        ; Referenced from 7B46, 7B67, 7B94, 7BD9, 7C6F, 7CF3, 7D03, 7D16, 7D37, 7D4E, 7DAD, 7DED, 7E10, 7E33, 7E40
L7E5C:  nop

        ; Referenced from 7B98, 7BEA, 7C7B, 7D2A
L7E5D:  nop

        ; Referenced from 7BED, 7C7E, 7CF7
L7E5E:  nop

        ; Referenced from 7BA1, 7D61
L7E5F:  nop

        ; Referenced from 7CFB, 7D42
L7E60:  nop

        ; Referenced from 7BA5
L7E61:  nop
        nop

        ; Referenced from 7BD5, 7C11, 7C6B, 7CA2, 7DE8, 7E0B, 7E2E, 7E3B
L7E63:  nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop

        ; Referenced from 7B7B, 7BCB, 7C0E, 7C60, 7C99, 7CD5
L7F0A:  nop
        nop
        nop
        nop

        ; Referenced from 7BC4, 7CCB
L7F0E:  nop
        nop
        nop
        nop
        nop
        nop

        ; Referenced from 7BFC
L7F14:  nop
        nop
        nop

        ; Referenced from 7B04
L7F17:  nop

        ; Referenced from 7BE1, 7DF8, 7E1B, 7E4B
L7F18:  nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop

        ; Referenced from 7B01, 7C8C, 7C9F, 7CBD, 7D82
L7F20:  nop

        ; Referenced from 7C02, 7C1E
L7F21:  nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
