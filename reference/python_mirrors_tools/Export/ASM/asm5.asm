
        ORG     0x9D00

        scf
        ld      (0x2C20),a
        inc     sp
        ld      (hl),0x00
        inc     h
        jr      z,0x9CD2
        ld      e,0x84
        jr      nz,L9D44+1      ; reference not aligned to instruction
        inc     sp
        inc     l
        jr      nc,L9D30+2      ; reference not aligned to instruction
        inc     l
        inc     sp
        ld      sp,0x302C
        jr      nz,L9D39
        inc     l
        ld      c,(hl)
        ld      c,a
        scf
        inc     sp

        ; Referenced from 9D40
L9D1E:  jr      nz,L9D4C
        inc     sp
        ld      (hl),0x00
        ld      b,b
        jr      z,0x9CF8
        ld      e,0x84
        jr      nz,L9D60+1      ; reference not aligned to instruction
        inc     (hl)
        inc     l
        jr      nc,L9D4C+2      ; reference not aligned to instruction
        inc     l
        inc     sp

        ; Referenced from 9D10
L9D30:  ld      sp,0x302C
        jr      nz,L9D55
        inc     l
        ld      c,(hl)
        ld      c,a
        scf

        ; Referenced from 9D17
L9D39:  inc     (hl)
        jr      nz,L9D68
        inc     sp
        ld      (hl),0x00
        ld      e,h
        jr      z,L9D1E
        ld      e,0x84

        ; Referenced from 9D0C, 9D5C
L9D44:  jr      nz,L9D7C+1      ; reference not aligned to instruction
        dec     (hl)
        inc     l
        jr      nc,L9D68+2      ; reference not aligned to instruction
        inc     l
        inc     sp

        ; Referenced from 9D1E, 9D2C
L9D4C:  ld      (0x302C),a
        jr      nz,L9D71
        inc     l
        ld      c,(hl)
        ld      c,a
        scf

        ; Referenced from 9D33
L9D55:  dec     (hl)
        jr      nz,L9D84
        inc     sp
        scf
        nop
        ld      a,b
        jr      z,L9D44
        ld      e,0x84

        ; Referenced from 9D28
L9D60:  jr      nz,L9D98+1      ; reference not aligned to instruction
        ld      (hl),0x2C       ; ','
        jr      nc,L9D86
        inc     l
        inc     sp

        ; Referenced from 9D3A, 9D48, 9D78
L9D68:  ld      (0x302C),a
        jr      nz,L9D8D
        inc     l
        ld      c,(hl)
        ld      c,a
        scf

        ; Referenced from 9D4F
L9D71:  ld      (hl),0x20       ; ' '
        inc     l
        inc     sp
        scf
        nop
        sub     h
        jr      z,L9D68+2       ; reference not aligned to instruction
        ld      e,0x84

        ; Referenced from 9D44
L9D7C:  jr      nz,L9DB4+1      ; reference not aligned to instruction
        scf
        inc     l
        jr      nc,L9DA2
        inc     l
        inc     sp

        ; Referenced from 9D56
L9D84:  inc     sp
        inc     l

        ; Referenced from 9D64
L9D86:  jr      nc,L9DA8
        jr      nz,L9DB6
        ld      c,(hl)
        ld      c,a
        scf

        ; Referenced from 9D6B
L9D8D:  scf
        jr      nz,L9DBC

        ; Referenced from 9D94
L9D90:  inc     sp
        jr      c,L9D93

        ; Referenced from 9D91
L9D93:  or      b
        jr      z,L9D90
        ld      e,0x84

        ; Referenced from 9D60
L9D98:  jr      nz,L9DD0+1      ; reference not aligned to instruction
        jr      c,L9DC8
        jr      nc,L9DBE
        inc     l
        inc     sp
        inc     sp
        inc     l

        ; Referenced from 9D80
L9DA2:  jr      nc,L9DC4
        jr      nz,L9DD2
        ld      c,(hl)
        ld      c,a

        ; Referenced from 9D86
L9DA8:  scf
        jr      c,L9DCB
        inc     l
        inc     sp
        jr      c,L9DAF

        ; Referenced from 9DAD
L9DAF:  call    z,0x0428
        rra
        add     a,h

        ; Referenced from 9D7C
L9DB4:  jr      nz,L9DEC+1      ; reference not aligned to instruction

        ; Referenced from 9D88
L9DB6:  add     hl,sp
        inc     l
        jr      nc,L9DDA
        inc     l
        inc     sp

        ; Referenced from 9D8E
L9DBC:  inc     sp
        inc     l

        ; Referenced from 9D9C
L9DBE:  ld      sp,0x2020
        inc     l
        ld      c,(hl)
        ld      c,a

        ; Referenced from 9DA2
L9DC4:  scf
        add     hl,sp
        jr      nz,L9DF4

        ; Referenced from 9D9A
L9DC8:  inc     sp
        add     hl,sp
        nop

        ; Referenced from 9DA9
L9DCB:  ret     pe
        jr      z,L9DDC
        rra
        add     a,h

        ; Referenced from 9D98
L9DD0:  jr      nz,L9E0A

        ; Referenced from 9DA4
L9DD2:  jr      nc,L9E00
        jr      nc,L9DF6
        inc     l
        inc     sp
        inc     (hl)
        inc     l

        ; Referenced from 9DB8
L9DDA:  jr      nc,L9DFC

        ; Referenced from 9DCC
L9DDC:  jr      nz,L9E0A
        ld      c,(hl)
        ld      c,a
        jr      c,L9E12
        jr      nz,L9E10
        inc     (hl)
        jr      nc,L9DE7

        ; Referenced from 9DE5
L9DE7:  inc     b
        add     hl,hl
        jr      L9E0A

L9DEB:  add     a,h

        ; Referenced from 9DB4
L9DEC:  jr      nz,L9E26
        ld      sp,0x302C
        jr      nz,L9E1F
        inc     sp

        ; Referenced from 9DC6
L9DF4:  inc     (hl)
        inc     l

        ; Referenced from 9DD4
L9DF6:  jr      nc,L9E18
        jr      nz,L9E26
        ld      c,(hl)
        ld      c,a

        ; Referenced from 9DDA
L9DFC:  jr      c,L9E2E+1       ; reference not aligned to instruction
        jr      nz,L9E2C

        ; Referenced from 9DD2
L9E00:  inc     (hl)
        jr      nc,L9E03

        ; Referenced from 9E01
L9E03:  jr      nz,L9E2E
        ld      (0x841F),hl
        jr      nz,L9E42

        ; Referenced from 9DD0, 9DDC, 9DE9
L9E0A:  ld      (0x302C),a
        jr      nz,L9E39+2      ; reference not aligned to instruction
        inc     sp

        ; Referenced from 9DE2
L9E10:  inc     (hl)
        inc     l

        ; Referenced from 9DE0
L9E12:  jr      nc,L9E34
        jr      nz,L9E42
        ld      c,(hl)
        ld      c,a

        ; Referenced from 9DF6
L9E18:  jr      c,L9E4A+2       ; reference not aligned to instruction
        jr      nz,L9E48
        inc     (hl)
        jr      nc,L9E1F

        ; Referenced from 9DF1, 9E1D
L9E1F:  inc     a

        ; Referenced from 9F56, 9F99, 9FF9
        ; --- START PROC L9E20 ---
L9E20:  add     hl,hl
        inc     l
        rra
        add     a,h
        jr      nz,L9E5E

        ; Referenced from 9DEC, 9DF8
L9E26:  inc     sp
        inc     l
        jr      nc,L9E4A
        inc     l
        inc     sp

        ; Referenced from 9DFE
L9E2C:  dec     (hl)
        inc     l

        ; Referenced from 9DFC, 9E03
L9E2E:  jr      nc,L9E50
        jr      nz,L9E5E
        ld      c,(hl)
        ld      c,a

        ; Referenced from 9E12
L9E34:  jr      c,L9E69
        jr      nz,L9E64
        inc     (hl)

        ; Referenced from 9E0D
L9E39:  ld      sp,0x5800
        add     hl,hl
        ld      (hl),0x1F
        add     a,h
        jr      nz,L9E7A

        ; Referenced from 9E08, 9E14
L9E42:  inc     (hl)
        inc     l
        jr      nc,L9E66
        inc     l
        inc     sp

        ; Referenced from 9E1A
L9E48:  dec     (hl)
        inc     l

        ; Referenced from 9E18, 9E28
L9E4A:  ld      sp,0x2020
        inc     l
        ld      c,(hl)
        ld      c,a

        ; Referenced from 9E2E
L9E50:  jr      c,L9E86
        jr      nz,L9E80
        inc     (hl)
        ld      (0x7400),a
        add     hl,hl
        ld      b,b
        rra
        add     a,h
        jr      nz,L9E96

        ; Referenced from 9E24, 9E30
L9E5E:  inc     (hl)
        inc     l
        ld      sp,0x2C20
        inc     sp

        ; Referenced from 9E36
L9E64:  dec     (hl)
        inc     l

        ; Referenced from 9E44
L9E66:  ld      sp,0x2020

        ; Referenced from 9E34
L9E69:  inc     l
        jr      c,L9EA0
        dec     l
        ld      sp,0x2C20
        inc     (hl)
        ld      (0x9000),a
        add     hl,hl
        ld      c,d
        rra
        add     a,h
        jr      nz,L9EB2

        ; Referenced from 9E40
L9E7A:  dec     (hl)
        inc     l
        jr      nc,L9E9E
        inc     l
        inc     sp

        ; Referenced from 9E52
L9E80:  ld      (hl),0x2C       ; ','
        jr      nc,L9EA4
        jr      nz,L9EB2

        ; Referenced from 9E50
L9E86:  ld      b,l
        ld      c,l
        ld      b,h
        jr      nz,L9EAB
        inc     l
        inc     (hl)
        inc     sp
        nop
        xor     e
        add     hl,hl
        ld      d,h
        rra
        add     a,h
        jr      nz,L9ECD+2      ; reference not aligned to instruction

        ; Referenced from 9E5C
L9E96:  add     hl,sp
        inc     l
        add     hl,sp
        add     hl,sp
        inc     l

        ; Referenced from 9EC6
L9E9B:  add     hl,sp
        add     hl,sp
        inc     l

        ; Referenced from 9E7C
L9E9E:  add     hl,sp
        add     hl,sp

        ; Referenced from 9E6A
L9EA0:  inc     l
        add     hl,sp
        add     hl,sp
        inc     l

        ; Referenced from 9E82
L9EA4:  add     hl,sp
        add     hl,sp
        inc     l
        add     hl,sp
        add     hl,sp
        nop
        or      e

        ; Referenced from 9E89
L9EAB:  add     hl,hl
        daa
        inc     hl
        ld      a,(0xE98F)
        nop

        ; Referenced from 9E78, 9E84
L9EB2:  cp      e
        add     hl,hl
        jr      z,L9ED8+1       ; reference not aligned to instruction
        ld      a,(0xE98F)
        nop
        call    z,0x2D29
        inc     hl
        adc     a,l
        jr      nz,L9ECD+2      ; reference not aligned to instruction
        ret     po
        dec     d
        ld      a,(0xE4FF)
        jr      nz,L9E9B
        jr      nz,L9EDC
        nop
        ex      de,hl
        add     hl,hl

        ; Referenced from 9E94, 9EBF
L9ECD:  ld      (0xAE23),a
        jr      nz,L9EFA
        rrca
        ld      h,b
        inc     l
        rrca
        ld      b,h
        add     hl,hl

        ; Referenced from 9EB4
L9ED8:  call    p,0x1C28
        inc     c

        ; Referenced from 9EC8
L9EDC:  ld      (bc),a
        inc     l
        rrca
        ld      e,l
        di
        rrca
        inc     d
        add     hl,hl
        inc     l
        rla
        inc     l
        ld      b,d
        ld      b,(hl)
        nop
        ld      a,(bc)
        ld      hl,(0x233C)
        xor     (hl)
        jr      nz,L9F19
        rrca
        ld      h,d
        inc     l
        rrca
        ld      b,l
        add     hl,hl
        call    p,0x1C28

        ; Referenced from 9ED0
L9EFA:  ld      a,(bc)
        ld      (bc),a
        inc     l
        rrca
        ld      e,h
        di
        rrca
        inc     d
        add     hl,hl
        inc     l
        ld      d,0x2C          ; ','
        ld      b,d
        ld      b,(hl)
        nop
        add     hl,hl
        ld      hl,(0x2346)
        xor     (hl)
        jr      nz,L9F38
        rrca
        ld      h,h
        inc     l
        rrca
        ld      b,(hl)
        add     hl,hl
        call    p,0x1C28

        ; Referenced from 9EEF
L9F19:  ex      af,af'
        ld      (bc),a
        inc     l
        rrca
        ld      e,e
        di
        rrca
        inc     d
        add     hl,hl
        inc     l
        ld      (de),a
        inc     l
        ld      b,d
        ld      b,(hl)
        nop
        ld      l,(hl)
        ld      hl,(0x2350)
        ld      b,d
        ld      c,l
        inc     h
        pop     af
        ld      (0x6282),hl
        add     a,d
        ld      h,e
        adc     a,c
        cp      c
        adc     a,d

        ; Referenced from 9F0E
L9F38:  ld      a,c
        add     a,e
        adc     a,d
        add     a,e
        ld      (hl),e
        add     a,c
        ld      a,h
        add     a,e
        ld      h,a
        add     a,c
        ld      b,b
        add     a,c
        ld      b,(hl)
        add     a,c
        ld      b,b
        add     a,d
        ld      l,(hl)
        add     a,d
        ld      l,l
        jr      nz,L9F6D
        add     a,d
        ld      l,(hl)
        add     a,d
        ld      h,l
        add     a,d
        ld      h,l
        ld      (0xFF3A),hl
        call    po,L9E20
        jr      nz,L9F65+2      ; reference not aligned to instruction
        rst     0x18
        sub     0x2C            ; ','
        inc     c
        ld      b,b
        nop
        inc     l
        jr      L9F9E

L9F64:  rst     0x38

        ; Referenced from 9F59
L9F65:  call    po,0xDB20
        jr      nz,L9FAB+1      ; reference not aligned to instruction
        ld      c,l
        inc     h
        nop

        ; Referenced from 9F4B
        ; --- START PROC L9F6D ---
L9F6D:  or      c
        ld      hl,(0x235A)
        ld      b,d
        ld      c,l
        inc     h
        pop     af
        ld      (0xB695),hl
        adc     a,(hl)
        sbc     a,d
        sub     l
        ld      e,h
        adc     a,(hl)
        and     (hl)
        add     a,e
        ld      e,b
        add     a,e
        ld      (hl),e
        add     a,c
        ld      a,h
        add     a,e
        ld      l,b
        add     a,c
        ld      b,b
        add     a,c
        ld      b,(hl)
        add     a,c
        ld      b,b
        add     a,d
        ld      d,b
        add     a,c
        ld      b,l
        add     a,d
        ld      d,c
        add     a,c
        ld      b,l
        add     a,d
        ld      d,d
        ld      (0xFF3A),hl
        call    po,L9E20
        jr      nz,L9FA8+2      ; reference not aligned to instruction

        ; Referenced from 9F62
        ; --- START PROC L9F9E ---
L9F9E:  rra
        inc     ixl
        inc     c
        ld      b,b
        nop
        inc     l
        jr      L9FE1

L9FA7:  rst     0x38

        ; Referenced from 9F9C
L9FA8:  call    po,0xDB20

        ; Referenced from 9F68
L9FAB:  jr      nz,L9FEF
        ld      c,l
        inc     h
        nop
        ld      de,0x8C2B
        inc     hl
        rst     0x38
        call    po,0xD320
        jr      nz,L9FCB
        ld      a,(0x4D42)
        inc     h
        pop     af
        ld      (0x5782),hl
        add     a,c
        ld      b,l
        add     a,d
        ld      d,c
        add     a,d
        push    bc
        sub     c
        ld      c,c
        sub     c

        ; Referenced from 9FB8
L9FCB:  ret     p
        add     a,d
        or      l
        add     a,d
        call    nz,0x5382
        add     a,c
        ld      b,l
        add     a,d
        ld      d,l
        add     a,d
        push    bc
        sub     b
        sub     d
        ret     pe
        add     a,d
        or      l
        add     a,e
        adc     a,d
        add     a,e

        ; Referenced from 9FA5
L9FE1:  ld      e,(hl)
        add     a,c
        ld      a,h
        add     a,e
        sub     e
        add     a,d
        push    bc
        adc     a,h
        adc     a,b
        sub     d
        ret     pe
        add     a,d
        or      l
        add     a,d

        ; Referenced from 9FAB
L9FEF:  call    nz,0xBA89
        add     a,d
        or      e
        add     a,d
        and     d
        ld      (0xFF3A),hl
        call    po,L9E20
        jr      nz,LA008+2      ; reference not aligned to instruction
        inc     c

        ; Referenced from A072
L9FFF:  rst     0x30
        inc     l
        inc     c
        ld      b,b
        nop
        inc     l
        jr      LA03F+2         ; reference not aligned to instruction

LA007:  rst     0x38

        ; Referenced from 9FFC
LA008:  call    po,0xDB20
        jr      nz,LA04E+1      ; reference not aligned to instruction
        ld      c,l
        inc     h
        nop
        dec     de
        dec     hl
        sub     (hl)
        inc     hl
        adc     a,l
        jr      nz,LA025
        call    p,0x0015
        ld      l,0x2B          ; '+'
        and     b
        inc     hl
        ld      b,e
        ld      c,(hl)
        pop     af

        ; Referenced from A042
LA021:  ld      de,0x433A
        ld      c,l

        ; Referenced from A015
LA025:  pop     af
        inc     de
        ld      a,(0x5844)
        pop     af
        ld      de,0x5300
        dec     hl
        and     l
        inc     hl
        ld      e,b
        ld      sp,0xFFF1
        sub     a
        jr      z,LA044
        ld      d,(hl)
        call    nc,0x3A29
        adc     a,e
        jr      nz,LA096+1      ; reference not aligned to instruction

        ; Referenced from A005
LA03F:  ld      sp,0x14F1
        jr      nz,LA021

        ; Referenced from A036
LA044:  jr      nz,LA09E

        ; Referenced from A068
LA046:  ld      sp,0x12F1
        jr      nz,LA084+1      ; reference not aligned to instruction
        sbc     a,a
        jr      nz,LA0A6

        ; Referenced from A00B
LA04E:  ld      sp,0x11F1
        nop
        adc     a,e
        dec     hl
        and     (hl)
        inc     hl
        ld      d,(hl)
        ld      sp,0xFFF1
        sub     a

        ; Referenced from A096
LA05B:  jr      z,LA068+1       ; reference not aligned to instruction
        rst     0x38
        ex      (sp),hl
        add     hl,hl
        ld      a,(0x208B)
        ld      d,(hl)
        ld      sp,0x0FF1
        sub     (hl)

        ; Referenced from A05B
LA068:  jr      nz,LA046+1      ; reference not aligned to instruction
        jr      nz,LA0C2
        ld      sp,0x13F1
        jr      nz,LA0AB
        sbc     a,a
        jr      nz,L9FFF
        jr      nz,LA0CC
        ld      sp,0x0FF1
        ld      (0xDD20),a
        jr      nz,LA0D4
        ld      sp,0x12F1
        jr      nz,LA0BD
        sbc     a,a

        ; Referenced from A049
LA084:  jr      nz,LA0DC
        ld      sp,0x11F1
        nop
        and     b
        dec     hl
        xor     h
        ld      h,0x3A          ; ':'
        adc     a,a
        jp      (hl)

LA091:  jr      c,LA0B2+1       ; reference not aligned to instruction
        cpl
        jr      nz,LA0C8

        ; Referenced from A03D
LA096:  jr      nz,LA05B
        sbc     a,0x20          ; ' '
        cp      (hl)
        ret     nz
        cp      b

        ; Referenced from A044
LA09E:  nop
        or      b
        dec     hl
        or      (hl)
        ld      h,0x8D
        jr      nz,LA0B4

        ; Referenced from A04C
LA0A6:  ld      (hl),h
        daa
        ld      a,(0x208D)

        ; Referenced from A06F
LA0AB:  ld      c,0x5C          ; '\'
        dec     hl
        nop
        ex      (sp),hl
        dec     hl
        ret     nz

        ; Referenced from A091
LA0B2:  ld      h,0xAE

        ; Referenced from A0A4
LA0B4:  jr      z,LA0C4+1       ; reference not aligned to instruction
        ld      h,b
        di
        rrca
        djnz    LA0E7
        rrca
        ld      c,b

        ; Referenced from A081
LA0BD:  di
        ld      b,e
        ld      c,(hl)
        push    af
        rrca

        ; Referenced from A06A
LA0C2:  inc     d
        add     hl,hl

        ; Referenced from A0B4
LA0C4:  call    p,0x1C28
        ex      af,af'

        ; Referenced from A094
LA0C8:  ld      bc,0x0F2C
        ld      e,c

        ; Referenced from A074
LA0CC:  di
        ld      b,e
        ld      c,(hl)
        push    af
        rrca
        inc     d
        add     hl,hl
        inc     l

        ; Referenced from A07C
LA0D4:  jr      LA102

LA0D6:  ld      b,d
        ld      b,(hl)
        inc     l
        jp      m,0x433A

        ; Referenced from A084
LA0DC:  ld      c,(hl)
        ld      (0x43F1),a
        ld      c,(hl)
        nop

        ; Referenced from A105
LA0E2:  jp      m,0xCA2B
        ld      h,0x49          ; 'I'

        ; Referenced from A0B9
LA0E7:  inc     h
        pop     af
        rst     0x28
        ld      a,(0x208B)
        ld      c,c
        inc     h
        pop     af
        ld      (0x2022),hl
        jr      nz,LA102+2      ; reference not aligned to instruction
        jp      z,0x0026
        inc     l
        inc     l

        ; Referenced from A16E
LA0FB:  rst     0x08
        ld      h,0x8B
        jr      nz,LA149
        inc     h
        pop     af

        ; Referenced from A0D4, A0F3
LA102:  ld      (0x2238),hl
        jr      nz,LA0E2+2      ; reference not aligned to instruction
        jr      nz,LA14C+1      ; reference not aligned to instruction
        ld      e,b
        pop     af

        ; Referenced from A17E
LA10B:  ld      de,0x8B3A
        jr      nz,LA153
        ld      c,(hl)
        pop     af
        ld      de,0xDD20

        ; Referenced from A137
LA115:  jr      nz,LA125
        jp      z,0x2026
        ld      a,(0x209F)
        ld      b,e
        ld      c,(hl)
        pop     af
        ld      b,e
        ld      c,(hl)
        call    p,0x3A12

        ; Referenced from A115
LA125:  adc     a,c

        ; Referenced from A19A
LA126:  jr      nz,LA134+2      ; reference not aligned to instruction
        call    nc,0x0026
        ld      h,c
        inc     l
        ret     nc
        ld      h,0x8B
        jr      nz,LA17B
        inc     h
        pop     af

        ; Referenced from A126
LA134:  ld      (0x2232),hl

        ; Referenced from A1AA
LA137:  jr      nz,LA115+1      ; reference not aligned to instruction
        jr      nz,LA17E+1      ; reference not aligned to instruction
        ld      e,b
        pop     af
        ld      (de),a
        ld      a,(0x208B)
        ld      b,e
        ld      c,(hl)
        pop     af
        ld      b,e
        ld      c,l
        call    p,0x2012

        ; Referenced from A0FE, A16C
LA149:  jr      nz,LA159+1      ; reference not aligned to instruction

        ; Referenced from A107
LA14C:  jp      z,0x2026
        ld      a,(0x209F)
        ld      b,e

        ; Referenced from A10E
LA153:  ld      c,(hl)
        pop     af
        ld      b,e
        ld      c,(hl)
        di
        ld      (de),a

        ; Referenced from A149
LA159:  ld      a,(0x2089)
        ld      c,0xD4
        ld      h,0x00

        ; Referenced from A1C6
LA160:  adc     a,l
        inc     l
        pop     de

        ; Referenced from A185
LA163:  ld      h,0x8B
        jr      nz,LA1B0
        inc     h
        pop     af
        ld      (0x2234),hl
        jr      nz,LA149+2      ; reference not aligned to instruction
        jr      nz,LA0FB
        jr      nz,LA1B6
        ld      e,b
        pop     af
        ld      de,0xDD20

        ; Referenced from A198
LA177:  jr      nz,LA187
        djnz    LA1A0+2         ; reference not aligned to instruction

        ; Referenced from A130
LA17B:  jr      nz,LA1B7
        sbc     a,a

        ; Referenced from A139
LA17E:  jr      nz,LA10B
        jr      nz,LA1C6
        ld      e,b
        pop     af
        ld      (de),a
        jr      nz,LA163+1      ; reference not aligned to instruction

        ; Referenced from A177
LA187:  jr      nz,LA195+2      ; reference not aligned to instruction
        ret     m
        ld      hl,(0xB900)
        inc     l

        ; Referenced from A1B1
LA18E:  jp      nc,0x8B26
        jr      nz,LA1DB+1      ; reference not aligned to instruction
        inc     h
        pop     af

        ; Referenced from A187
LA195:  ld      (0x2236),hl
        jr      nz,LA177
        jr      nz,LA126+1      ; reference not aligned to instruction
        jr      nz,LA1E2
        ld      e,b
        pop     af

        ; Referenced from A179
LA1A0:  ld      de,0xDD20

        ; Referenced from A1C4
LA1A3:  jr      nz,LA1B3
        ld      a,(de)
        daa
        jr      nz,LA1E2+1      ; reference not aligned to instruction
        sbc     a,a
        jr      nz,LA137
        jr      nz,LA1F2
        ld      e,b
        pop     af

        ; Referenced from A165
LA1B0:  ld      (de),a
        jr      nz,LA18E+2      ; reference not aligned to instruction

        ; Referenced from A1A3
LA1B3:  jr      nz,LA1C1+2      ; reference not aligned to instruction
        ld      (bc),a

        ; Referenced from A170
LA1B6:  dec     hl

        ; Referenced from A17B, A227
LA1B7:  nop
        jp      nc,0xD32C
        ld      h,0x8B
        jr      nz,LA208
        inc     h
        pop     af

        ; Referenced from A1B3
LA1C1:  ld      (0x2259),hl
        jr      nz,LA1A3

        ; Referenced from A180
LA1C6:  jr      nz,LA160
        jr      nz,LA1D6
        inc     c
        ret     po
        inc     l
        inc     c
        ret

LA1CF:  nop
        nop
        nop
        dec     l
        call    nc,0xAE26

        ; Referenced from A1C8
LA1D6:  jr      z,LA1E7
        ld      h,b
        di

        ; Referenced from A240
LA1DA:  rrca

        ; Referenced from A191
LA1DB:  djnz    LA209
        rrca
        ld      c,b
        di
        ld      b,e
        ld      c,(hl)

        ; Referenced from A19C, A1A7
LA1E2:  ld      (0x0FF5),a

        ; Referenced from A24B
LA1E5:  inc     d
        add     hl,hl

        ; Referenced from A1D6
LA1E7:  call    p,0x1C28
        ex      af,af'

        ; Referenced from A20E
LA1EB:  ld      bc,0x0F2C
        ld      e,c
        di
        ld      b,e
        ld      c,(hl)

        ; Referenced from A1AC
LA1F2:  ld      (0x0FF5),a
        inc     d
        add     hl,hl
        inc     l

        ; Referenced from A26C
LA1F8:  jr      LA225+1         ; reference not aligned to instruction

        ; Referenced from A260
LA1FA:  ld      b,d
        ld      b,(hl)
        inc     l
        jp      m,0x1600
        dec     l
        sbc     a,0x26          ; '&'
        adc     a,e

        ; Referenced from A225
LA204:  jr      nz,LA24F
        inc     h
        pop     af

        ; Referenced from A1BD
LA208:  rst     0x38

        ; Referenced from A1DB
LA209:  sub     (hl)
        jr      z,LA21A+1       ; reference not aligned to instruction
        dec     c
        add     hl,hl

        ; Referenced from A275
LA20E:  jr      nz,LA1EB+2      ; reference not aligned to instruction
        jr      nz,LA220
        jp      p,0x0026
        dec     hl
        dec     l
        ret     po
        ld      h,0x8B

        ; Referenced from A20A, A281
LA21A:  jr      nz,LA265
        inc     h

        ; Referenced from A23E
LA21D:  pop     af
        rst     0x38
        sub     (hl)

        ; Referenced from A210
LA220:  jr      z,LA22D+1       ; reference not aligned to instruction
        daa
        nop
        add     hl,hl

        ; Referenced from A1F8
LA225:  jr      nz,LA204
        jr      nz,LA1B7
        nop
        dec     (hl)
        dec     l
        ret     pe

        ; Referenced from A220
LA22D:  ld      h,0x89
        jr      nz,LA23E+1      ; reference not aligned to instruction
        ret     nz
        ld      h,0x00
        ld      d,l
        dec     l
        jp      p,0x8B26
        jr      nz,LA293

        ; Referenced from A25E
LA23B:  ld      sp,0x12F1

        ; Referenced from A22F
LA23E:  jr      nz,LA21D
        jr      nz,LA1DA
        jr      nz,LA250
        ld      d,(hl)
        call    nc,0x142C
        jr      nz,LA283+1      ; reference not aligned to instruction
        sbc     a,a
        jr      nz,LA1E5
        jr      nz,LA25B

        ; Referenced from A204
LA24F:  ld      d,(hl)

        ; Referenced from A242, A273
LA250:  call    nc,0x122C
        nop
        adc     a,e
        dec     l
        call    m,0x8B26
        jr      nz,LA2B0+1      ; reference not aligned to instruction

        ; Referenced from A24D
LA25B:  ld      sp,0x13F1
        jr      nz,LA23B+2      ; reference not aligned to instruction
        jr      nz,LA1FA
        jr      nz,LA270
        rst     0x38

        ; Referenced from A21A
LA265:  ex      (sp),hl
        inc     l
        rrca
        sub     (hl)
        jr      nz,LA2A4+1      ; reference not aligned to instruction
        sbc     a,a
        jr      nz,LA1F8+1      ; reference not aligned to instruction
        jr      nz,LA2C6

        ; Referenced from A262
LA270:  ld      sp,0x12F1
        jr      nz,LA250+2      ; reference not aligned to instruction
        jr      nz,LA20E+1      ; reference not aligned to instruction
        jr      nz,LA285
        rst     0x38
        ex      (sp),hl
        inc     l
        rrca
        ld      (0x3A20),a
        sbc     a,a

        ; Referenced from A2A2
LA281:  jr      nz,LA21A+1      ; reference not aligned to instruction

        ; Referenced from A248
LA283:  jr      nz,LA291

        ; Referenced from A277
LA285:  rst     0x38
        ex      (sp),hl
        inc     l
        ld      (de),a
        nop
        sub     c
        dec     l
        ld      b,0x27          ; '''
        adc     a,(hl)
        nop
        sbc     a,c

        ; Referenced from A283
LA291:  dec     l
        rrca

        ; Referenced from A239
LA293:  daa
        ld      a,(0xE98F)
        nop
        rst     0x00
        dec     l
        djnz    LA2C2+1         ; reference not aligned to instruction
        adc     a,e
        jr      nz,LA2F7
        ld      sp,0x11F1
        jr      nz,LA281

        ; Referenced from A269
LA2A4:  jr      nz,LA2B3+1      ; reference not aligned to instruction
        jp      z,0x2026
        ld      a,(0x209F)
        ld      e,b

        ; Referenced from A2D0
LA2AD:  ld      sp,0x58F1

        ; Referenced from A259
LA2B0:  ld      sp,0x12F4

        ; Referenced from A2A4
LA2B3:  ld      a,(0x208D)
        ld      c,0x7E          ; '~'
        daa
        ld      a,(0x208D)
        ld      c,0x74          ; 't'
        daa
        ld      a,(0x2089)

        ; Referenced from A29A
LA2C2:  ld      c,0xCA
        ld      h,0x00

        ; Referenced from A26E
LA2C6:  push    af
        dec     l
        ld      a,(de)
        daa
        adc     a,e
        jr      nz,LA325
        ld      sp,0x12F1
        jr      nz,LA2AD+2      ; reference not aligned to instruction
        jr      nz,LA2E1+1      ; reference not aligned to instruction
        jp      z,0x2026
        ld      a,(0x209F)
        ld      e,b
        ld      sp,0x58F1
        ld      sp,0x12F3

        ; Referenced from A2D2
LA2E1:  ld      a,(0x208D)
        ld      c,0x7E          ; '~'
        daa
        ld      a,(0x208D)
        ld      c,0x74          ; 't'
        daa
        ld      a,(0x2089)
        ld      c,0xCA
        ld      h,0x00
        daa
        ld      l,0x74          ; 't'

        ; Referenced from A29D
LA2F7:  daa
        xor     (hl)
        jr      z,LA317
        jr      z,LA2FE
        di

        ; Referenced from A2FB
LA2FE:  ld      e,b
        ld      sp,0x0FF5
        jr      nc,LA330
        rrca
        ld      c,b
        add     hl,hl
        call    p,0x1C28
        ld      e,b
        ld      bc,0x58F3
        ld      sp,0x0FF5
        jr      nc,LA33D+2      ; reference not aligned to instruction
        rrca
        ld      e,c
        add     hl,hl
        inc     l

        ; Referenced from A2F9
LA317:  jr      LA345

LA319:  ld      b,d
        ld      b,(hl)
        inc     l
        jp      m,0x583A
        ld      (0x58F1),a
        ld      sp,0x8E3A

        ; Referenced from A2CB
LA325:  nop
        ld      d,e
        ld      l,0x7E          ; '~'
        daa
        xor     (hl)
        jr      z,LA349
        jr      z,LA330
        di

        ; Referenced from A302, A32D
LA330:  ld      e,b
        ld      (0x0FF5),a
        jr      nc,LA361+1      ; reference not aligned to instruction
        rrca
        ld      c,b
        add     hl,hl
        call    p,0x1C28
        ld      e,b

        ; Referenced from A311
LA33D:  ld      bc,0x58F3
        ld      (0x0FF5),a

        ; Referenced from A364
LA343:  jr      nc,LA36F+2      ; reference not aligned to instruction

        ; Referenced from A317
LA345:  rrca
        ld      e,c
        add     hl,hl
        inc     l

        ; Referenced from A32B
LA349:  jr      LA375+2         ; reference not aligned to instruction

LA34B:  ld      b,d
        ld      b,(hl)
        inc     l
        jp      m,0x8E3A
        nop
        ld      e,e
        ld      l,0x87
        daa
        ld      a,(0xE98F)
        nop
        adc     a,c
        ld      l,0xF8
        ld      hl,(0x208B)
        ld      d,(hl)

        ; Referenced from A334
LA361:  ld      sp,0x11F1
        jr      nz,LA343
        jr      nz,LA375+1      ; reference not aligned to instruction
        jp      z,0x2026
        ld      a,(0x209F)
        ld      d,(hl)

        ; Referenced from A343, A392
LA36F:  ld      sp,0x56F1
        ld      sp,0x12F4

        ; Referenced from A349, A366
LA375:  ld      a,(0x208D)
        ld      c,0x66          ; 'f'
        dec     hl
        ld      a,(0x208D)
        ld      c,0x5C          ; '\'
        dec     hl
        ld      a,(0x2089)
        ld      c,0xCA
        ld      h,0x00
        or      a
        ld      l,0x02
        dec     hl
        adc     a,e
        jr      nz,LA3E4+1      ; reference not aligned to instruction
        ld      sp,0x13F1
        jr      nz,LA36F+2      ; reference not aligned to instruction
        jr      nz,LA3A3+1      ; reference not aligned to instruction
        jp      z,0x2026
        ld      a,(0x209F)
        ld      d,(hl)
        ld      sp,0x56F1
        ld      sp,0x12F3

        ; Referenced from A394
LA3A3:  ld      a,(0x208D)
        ld      c,0x66          ; 'f'
        dec     hl
        ld      a,(0x208D)
        ld      c,0x5C          ; '\'
        dec     hl
        ld      a,(0x2089)
        ld      c,0xCA
        ld      h,0x00
        rst     0x28
        ld      l,0x5C          ; '\'
        dec     hl
        xor     (hl)
        jr      z,LA3D9
        jr      z,LA3C0
        di

        ; Referenced from A3BD
LA3C0:  ld      d,(hl)
        ld      sp,0x0FF5
        jr      nz,LA3F2
        rrca
        ld      c,b
        di
        rrca
        inc     d
        add     hl,hl
        call    p,0x1C28
        ld      a,(0xF301)
        ld      d,(hl)
        ld      sp,0x0FF5
        jr      nz,LA404
        rrca

        ; Referenced from A3BB
LA3D9:  ld      e,c
        di
        rrca
        inc     d
        add     hl,hl
        inc     l
        jr      LA40B+2         ; reference not aligned to instruction

LA3E1:  ld      b,d
        ld      b,(hl)
        inc     l

        ; Referenced from A38D
LA3E4:  jp      m,0x563A
        ld      (0x56F1),a
        ld      sp,0x8E3A
        nop
        ld      hl,0x662F
        dec     hl

        ; Referenced from A3C4
LA3F2:  xor     (hl)
        jr      z,LA411
        jr      z,LA3F8
        di

        ; Referenced from A3F5
LA3F8:  ld      d,(hl)
        ld      (0x0FF5),a
        jr      nz,LA42A
        rrca
        ld      c,b
        di
        rrca
        inc     d
        add     hl,hl

        ; Referenced from A3D6
LA404:  call    p,0x1C28
        ld      a,(0xF301)
        ld      d,(hl)

        ; Referenced from A3DF
LA40B:  ld      (0x0FF5),a
        jr      nz,LA43C
        rrca

        ; Referenced from A3F3
LA411:  ld      e,c
        di
        rrca
        inc     d
        add     hl,hl
        inc     l
        jr      LA445

LA419:  ld      b,d
        ld      b,(hl)
        inc     l
        jp      m,0x8E3A
        nop
        nop
        nop
        cpl
        ld      d,(hl)
        ld      (0x0FF5),a
        jr      nz,LA455
        rrca

        ; Referenced from A3FC
LA42A:  ld      e,c
        di
        rrca
        inc     d
        add     hl,hl
        inc     l
        jr      LA45E

LA432:  ld      b,d
        ld      b,(hl)
        inc     l
        jp      m,0x8E3A
        nop
        nop
        nop
        inc     d

        ; Referenced from A40E
LA43C:  rrca
        ld      e,c
        di
        rrca
        inc     d
        add     hl,hl
        inc     l
        jr      LA471

        ; Referenced from A417
LA445:  ld      b,d
        ld      b,(hl)
        inc     l
        jp      m,0x8E3A
        nop
        nop
        nop
        ld      e,c
        ld      b,(hl)
        inc     l
        jp      m,0x8E3A
        nop

        ; Referenced from A427
LA455:  nop
        nop
        rrca
        ld      e,c
        di
        rrca
        inc     d
        add     hl,hl
        inc     l

        ; Referenced from A430
LA45E:  jr      LA48C

LA460:  ld      b,d
        ld      b,(hl)
        inc     l
        jp      m,0x8E3A
        nop
        nop
        nop
        ld      d,(hl)
        rrca
        inc     d
        add     hl,hl
        inc     l
        jr      LA49C

LA470:  ld      b,d

        ; Referenced from A443
LA471:  ld      b,(hl)
        inc     l
        jp      m,0x8E3A
        nop
        nop
        nop
        dec     hl
        jp      m,0x8E3A
        nop
        nop
        nop
        di
        di
        rrca
        inc     d
        add     hl,hl
        call    p,0x1C28
        ld      a,(0xF301)
        ld      d,(hl)

        ; Referenced from A45E
LA48C:  ld      (0x0FF5),a
        jr      nz,LA4BD
        rrca
        ld      e,c
        di
        rrca
        inc     d
        add     hl,hl
        inc     l
        jr      LA4C6

LA49A:  ld      b,d
        ld      b,(hl)

        ; Referenced from A46E
LA49C:  inc     l
        jp      m,0x8E3A
        nop
        nop
        nop
        ld      d,(hl)
        rrca
        inc     d
        add     hl,hl
        call    p,0x1C28
        ld      a,(0xF301)
        ld      d,(hl)
        ld      (0x0FF5),a
        jr      nz,LA4DF
        rrca
        ld      e,c
        di
        rrca
        inc     d
        add     hl,hl
        inc     l
        jr      LA4E8

LA4BC:  ld      b,d

        ; Referenced from A48F
LA4BD:  ld      b,(hl)
        inc     l
        jp      m,0x8E3A
        nop
        nop
        nop
        ld      d,(hl)

        ; Referenced from A498
LA4C6:  rrca
        inc     d
        add     hl,hl
        call    p,0x1C28
        ld      a,(0xF301)
        ld      d,(hl)
        ld      (0x0FF5),a
        jr      nz,LA4FF+2      ; reference not aligned to instruction
        rrca
        ld      e,c
        di
        rrca
        inc     d
        add     hl,hl
        inc     l
        jr      0xA50A

LA4DE:  ld      b,d

        ; Referenced from A4B1
LA4DF:  ld      b,(hl)
        inc     l
        jp      m,0x8E3A
        nop
        nop
        nop
        inc     e

        ; Referenced from A4BA
LA4E8:  inc     l
        rrca
        ld      c,b
        di
        rrca
        inc     d
        add     hl,hl
        call    p,0x1C28
        ld      a,(0xF301)
        ld      d,(hl)
        ld      (0x0FF5),a
        jr      nz,0xA527
        rrca
        ld      e,c
        di
        rrca

        ; Referenced from A4D3
LA4FF:  inc     d
