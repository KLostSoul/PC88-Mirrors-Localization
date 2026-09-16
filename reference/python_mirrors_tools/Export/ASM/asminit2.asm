
        ORG     0xD800

        ld      hl,(0xF302)
        ld      (LDBD4),hl
        ld      hl,0xD822
        ld      (0xEEC6),hl
        ld      hl,0xD822
        ld      (0xEEB7),hl
        ld      hl,0xDBC8
        ld      a,0xC3
        ld      (0xED66),a
        ld      (0xED67),hl
        xor     a
        call    LDBB1
        ret

LD822:  ld      a,(hl)
        inc     hl
        cp      0x52            ; 'R'
        jp      z,LD9CD
        cp      0x50            ; 'P'
        jp      z,LD84C
        cp      0x90
        jp      z,LD974
        cp      0x43            ; 'C'
        jp      z,LD986
        cp      0x46            ; 'F'
        jp      z,LD992
        cp      0xCD
        jp      z,LDA2A
        jp      0x0393

        ; Referenced from D853, DBBA
        ; --- START PROC LD845 ---
LD845:  push    hl
        call    LDB59
        pop     hl
        inc     hl
        ret

        ; Referenced from D82B
LD84C:  ld      a,(hl)
        cp      0x54            ; 'T'
        jr      z,LD8B8
        cp      0x43            ; 'C'
        jr      z,LD845
        cp      0x58            ; 'X'
        jr      z,LD8B0
        xor     a
        ld      (LD973),a

        ; Referenced from D8B6
LD85D:  ld      a,0xFF
        ld      (LDBCE),a
        call    LDB18
        ld      (LDBD0),a
        call    LDB18
        ld      (LDBCF),a
        inc     hl
        ld      a,(hl)
        cp      0xDC
        jp      nz,LD8A8
        inc     hl
        call    LDB18
        ld      (LDBD2),a
        call    LDB18
        ld      (LDBD1),a
        inc     hl
        ld      a,(LD973)
        or      a
        call    z,LD916
        push    de
        ld      de,0xDBCF
        call    LD8F1
        ld      de,0xDBD1
        call    LD8F1
        pop     de
        ld      c,0x40          ; '@'
        call    LDAF1
        ld      a,(hl)
        cp      0x5D            ; ']'
        jr      z,LD8AE
        ld      c,0x41          ; 'A'
        call    LDB03
        ret

        ; Referenced from D872
LD8A8:  ld      c,0x41          ; 'A'
        call    LDAF1
        ret

        ; Referenced from D8A0, D8E3
LD8AE:  inc     hl
        ret

        ; Referenced from D857
LD8B0:  ld      a,0xFF
        ld      (LD973),a
        inc     hl
        jr      LD85D

        ; Referenced from D84F
LD8B8:  inc     hl
        ld      a,0xFF
        ld      (LDBCE),a
        call    LDB18
        ld      (LDBD0),a
        xor     a
        ld      (LDBCF),a
        inc     hl
        ld      a,(hl)
        cp      0xDC
        jp      nz,LD8EB
        inc     hl
        call    LDB18
        ld      (LDBD2),a
        xor     a
        ld      (LDBCF),a
        inc     hl
        ld      c,0x80
        call    LDAF1
        ld      a,(hl)
        cp      0x5D            ; ']'
        jr      z,LD8AE
        ld      c,0x81
        call    LDB03
        ret

        ; Referenced from D8CC
LD8EB:  ld      c,0x81
        call    LDAF1
        ret

        ; Referenced from D88E, D894
        ; --- START PROC LD8F1 ---
LD8F1:  push    bc
        ld      a,(de)
        call    LDB79
        ld      c,0x00
        add     a,0x18
        cp      0x3C            ; '<'
        call    nc,LD911
        call    LDB61
        ld      (de),a
        inc     de
        ld      a,(de)
        call    LDB79
        add     a,0x07
        add     a,c
        call    LDB61
        ld      (de),a
        pop     bc
        ret

        ; Referenced from D8FC
        ; --- START PROC LD911 ---
LD911:  inc     c
        or      a
        sub     0x3C            ; '<'
        ret

        ; Referenced from D887
        ; --- START PROC LD916 ---
LD916:  push    hl
        push    de
        ld      a,(LDBD0)
        ld      h,a
        ld      de,0xD945

        ; Referenced from D92C
LD91F:  ld      a,(de)
        cp      0xFF
        jr      z,LD942
        cp      h
        jr      z,LD92E
        inc     de
        inc     de
        inc     de
        inc     de
        inc     de
        jr      LD91F

        ; Referenced from D925
LD92E:  inc     de
        ld      a,(de)
        ld      (LDBD0),a
        inc     de
        ld      a,(de)
        ld      (LDBCF),a
        inc     de
        ld      a,(de)
        ld      (LDBD2),a
        inc     de
        ld      a,(de)
        ld      (LDBD1),a

        ; Referenced from D922
LD942:  pop     de
        pop     hl
        ret

LD945:  nop
        nop
        inc     bc
        ld      bc,0x1740
        rla
        add     hl,hl
        add     hl,de
        dec     d
        add     hl,de
        add     hl,de
        ld      d,0x21          ; '!'
        inc     sp
        ld      hl,0x3421
        dec     h
        inc     (hl)
        dec     h
        dec     h
        dec     (hl)
        ld      h,0x59          ; 'Y'
        daa
        daa
        nop
        jr      z,LD987+1       ; reference not aligned to instruction
        jr      z,LD997+1       ; reference not aligned to instruction
        dec     (hl)
        inc     (hl)
        ld      d,l
        add     hl,hl
        ld      (hl),0x11
        jr      c,LD9A3+2       ; reference not aligned to instruction
        ld      (0x5634),a
        ld      (hl),0x10
        rst     0x38

        ; Referenced from D85A, D883, D8B2
LD973:  rst     0x38

        ; Referenced from D830
LD974:  push    hl
        ld      a,(LDBCE)
        or      a
        jr      z,LD984
        xor     a
        ld      (LDBCE),a
        ld      a,0x02
        call    LDBB1

        ; Referenced from D979
LD984:  pop     hl
        ret

        ; Referenced from D835
LD986:  push    hl

        ; Referenced from D961
LD987:  ld      a,(LDBD3)
        set     0,a
        ld      c,a
        call    LDB03
        pop     hl
        ret

        ; Referenced from D83A
LD992:  ld      a,(hl)
        cp      0x49            ; 'I'
        jr      z,LD9A6

        ; Referenced from D963
LD997:  cp      0x4F            ; 'O'
        jr      z,LD9AA
        cp      0x4D            ; 'M'
        jr      z,LD9AE
        cp      0x50            ; 'P'
        jr      z,LD9B2

        ; Referenced from D96B
LD9A3:  jp      0x03B1

        ; Referenced from D995
LD9A6:  ld      c,0x05
        jr      LD9B6

        ; Referenced from D999
LD9AA:  ld      c,0x07
        jr      LD9B6

        ; Referenced from D99D
LD9AE:  ld      c,0x02
        jr      LD9B6

        ; Referenced from D9A1
LD9B2:  ld      c,0x00
        jr      LD9B6

        ; Referenced from D9A8, D9AC, D9B0, D9B4
LD9B6:  inc     hl
        ld      a,(hl)
        cp      0x46            ; 'F'
        jr      z,LD9C8
        cp      0x53            ; 'S'
        jr      z,LD9CA

        ; Referenced from D9CB
LD9C0:  push    hl
        ld      a,0x03
        call    LDBB1
        pop     hl
        ret

        ; Referenced from D9BA
LD9C8:  res     0,c

        ; Referenced from D9BE
LD9CA:  inc     hl
        jr      LD9C0

        ; Referenced from D826
LD9CD:  ld      a,(hl)
        cp      0x52            ; 'R'
        jr      z,LDA1F
        xor     a
        ld      (LDA29),a

        ; Referenced from DA25
LD9D6:  call    LDBA9
        call    LDB93
        push    de
        call    LDBA9
        call    LDB93
        ld      (LD9F5+1),de    ; reference not aligned to instruction
        call    LDBA9
        call    LDB93
        ld      a,e
        or      a
        call    z,LDA27
        ld      b,e
        pop     de
        push    hl

        ; Referenced from D9E3
LD9F5:  ld      hl,0x0000

        ; Referenced from DA10
LD9F8:  ld      (0xD780),hl
        push    de
        push    hl
        push    bc
        ld      hl,0x0000
        ld      a,0x06
        ld      c,0x0F
        call    LDBB1
        pop     bc
        pop     hl
        ld      de,0x0800
        add     hl,de
        pop     de
        inc     de
        djnz    LD9F8
        pop     hl
        ld      a,(LDA29)
        or      a
        ret     z
        ld      hl,0x8000
        xor     a
        out     (0x70),a        ; 'p'
        ret

        ; Referenced from D9D0
LDA1F:  ld      a,0xFF
        ld      (LDA29),a
        inc     hl
        jr      LD9D6

        ; Referenced from D9EF
        ; --- START PROC LDA27 ---
LDA27:  inc     e
        ret

        ; Referenced from D9D3, DA13, DA21
LDA29:  nop

        ; Referenced from D83F
LDA2A:  inc     hl
        call    LDB93
        ld      (LDA9B),de
        call    LDBA9
        call    LDB93
        xor     a
        ld      (LDAA2),a
        ld      b,d
        ld      c,e
        ld      de,0x0000
        push    hl

        ; Referenced from DA57
LDA42:  ld      (LDA9F),de
        push    de
        call    LDA5B
        ld      hl,0xDA98
        push    bc
        call    0x9020
        pop     bc
        pop     de
        inc     de
        ld      a,e
        cp      0x50            ; 'P'
        jr      nz,LDA42
        pop     hl
        ret

        ; Referenced from DA47
        ; --- START PROC LDA5B ---
LDA5B:  bit     0,e
        jr      nz,LDA88
        ld      e,0x03
        ld      hl,0x4000

        ; Referenced from DA85, DA8D
LDA64:  push    de
        push    hl
        ld      (0xD780),hl
        ld      hl,0x0000
        ld      d,b
        ld      e,c
        push    bc
        ld      a,(LDAA2)
        or      a
        jr      z,LDA8F
        ld      c,0x00

        ; Referenced from DA96
LDA77:  ld      a,0x06
        call    LDBB1
        pop     bc
        inc     bc
        pop     hl
        ld      de,0x0800
        add     hl,de
        pop     de
        dec     e
        jr      nz,LDA64
        ret

        ; Referenced from DA5D
LDA88:  ld      e,0x02
        ld      hl,0x5800
        jr      LDA64

        ; Referenced from DA73
LDA8F:  ld      c,0x0F
        ld      a,0xFF
        ld      (LDAA2),a
        jr      LDA77

LDA98:  call    0x0C20

        ; Referenced from DA2E
LDA9B:  nop
        nop
        inc     l
        inc     c

        ; Referenced from DA42
LDA9F:  nop
        nop
        nop

        ; Referenced from DA39, DA6F, DA93
LDAA2:  nop
        push    de
        push    bc
        push    bc
        ld      (0xD780),hl
        ld      hl,0x0000
        ld      (LDAEF),hl
        pop     bc
        ld      a,b
        ld      de,0x1194
        call    LDADA
        pop     bc
        ld      a,c
        ld      de,0x004B
        call    LDADA
        pop     de
        ld      a,d
        ld      e,a
        ld      d,0x00
        ld      a,0x01
        call    LDADA
        or      a
        ld      bc,0x0096
        ld      de,(LDAEF)
        sbc     hl,bc
        call    c,LDAD8
        ex      de,hl
        ret

        ; Referenced from DAD3
        ; --- START PROC LDAD8 ---
LDAD8:  dec     de
        ret

        ; Referenced from DAB4, DABC, DAC6
        ; --- START PROC LDADA ---
LDADA:  or      a
        ret     z
        ld      b,a

        ; Referenced from DAE1
LDADD:  add     hl,de
        call    c,LDAE4
        djnz    LDADD
        ret

        ; Referenced from DADE
        ; --- START PROC LDAE4 ---
LDAE4:  push    hl
        ld      hl,(LDAEF)
        inc     hl
        ld      (LDAEF),hl
        or      a
        pop     hl
        ret

        ; Referenced from DAAC, DACD, DAE5, DAE9
LDAEF:  nop
        nop

        ; Referenced from D89A, D8AA, D8DD, D8ED
        ; --- START PROC LDAF1 ---
LDAF1:  push    hl
        ld      a,c
        ld      (LDBD3),a
        ld      a,0x05
        ld      hl,(LDBCF)
        ld      de,0x0000
        call    LDBB1
        pop     hl
        ret

        ; Referenced from D8A4, D8E7, D98D
        ; --- START PROC LDB03 ---
LDB03:  push    hl
        ld      a,0x01
        ld      hl,(LDBD1)
        ld      de,0x0000
        call    LDBB1
        pop     hl
        ld      a,(hl)
        cp      0x3B            ; ';'
        jr      z,LDB16
        ret

        ; Referenced from DB13
LDB16:  inc     hl
        ret

        ; Referenced from D862, D868, D876, D87C, D8BE, D8D0
        ; --- START PROC LDB18 ---
LDB18:  call    LDB20
        or      a
        call    LDB61
        ret

        ; Referenced from DB18
        ; --- START PROC LDB20 ---
LDB20:  ld      e,0x00
        ld      a,(hl)
        cp      0x22            ; '"'
        jr      z,LDB2E
        cp      0x3A            ; ':'
        jr      z,LDB2E
        jp      0x03B1

        ; Referenced from DB25, DB29
LDB2E:  inc     hl
        push    hl
        inc     hl
        ld      a,(hl)
        cp      0x22            ; '"'
        jr      z,LDB4F
        cp      0x3A            ; ':'
        jr      z,LDB4F
        pop     hl
        ld      a,(hl)
        sub     0x30            ; '0'
        jp      c,0x03B1
        inc     hl
        push    hl
        ld      l,a
        ld      h,0x00
        ld      de,0x000A
        push    bc
        call    0x235A
        pop     bc
        ld      e,l

        ; Referenced from DB34, DB38
LDB4F:  pop     hl
        ld      a,(hl)
        sub     0x30            ; '0'
        jp      c,0x03B1
        add     a,e
        inc     hl
        ret

        ; Referenced from D846, DB5E
        ; --- START PROC LDB59 ---
LDB59:  ld      a,0x09
        call    0xD100
        jr      c,LDB59
        ret

        ; Referenced from D8FF, D90B, DB1C
        ; --- START PROC LDB61 ---
LDB61:  push    bc
        or      a
        jr      z,LDB70
        ld      b,a
        xor     a
        ld      c,0x0A

        ; Referenced from DB6E
LDB69:  inc     a
        dec     c
        call    z,LDB72
        djnz    LDB69

        ; Referenced from DB63
LDB70:  pop     bc
        ret

        ; Referenced from DB6B
        ; --- START PROC LDB72 ---
LDB72:  ld      c,0x0A
        and     0xF0
        add     a,0x10
        ret

        ; Referenced from D8F3, D905
        ; --- START PROC LDB79 ---
LDB79:  push    bc
        push    af
        srl     a
        srl     a
        srl     a
        srl     a
        or      a
        jr      z,LDB8C
        ld      b,a
        xor     a

        ; Referenced from DB8A
LDB88:  add     a,0x0A
        djnz    LDB88

        ; Referenced from DB84
LDB8C:  ld      b,a
        pop     af
        and     0x0F
        add     a,b
        pop     bc
        ret

        ; Referenced from D9D9, D9E0, D9EA, DA2B, DA35
        ; --- START PROC LDB93 ---
LDB93:  ld      a,(hl)
        cp      0x0C
        jr      z,LDBA3
        cp      0x0B
        jr      z,LDBA3
        cp      0x1C
        jr      z,LDBA3
        jp      0x0393

        ; Referenced from DB96, DB9A, DB9E
LDBA3:  inc     hl
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        inc     hl
        ret

        ; Referenced from D9D6, D9DD, D9E7, DA32
        ; --- START PROC LDBA9 ---
LDBA9:  ld      a,(hl)
        cp      0x2C            ; ','
        jp      nz,0x0393
        inc     hl
        ret

        ; Referenced from D81E, D981, D9C3, DA05, DA79, DAFE, DB0C, DBC1
        ; --- START PROC LDBB1 ---
LDBB1:  push    hl
        push    de
        push    bc
        push    af
        call    0xD100
        jr      nc,LDBC3
        call    LD845
        pop     af
        pop     bc
        pop     de
        pop     hl
        jr      LDBB1

        ; Referenced from DBB8
LDBC3:  pop     af
        pop     bc
        pop     de
        pop     hl
        ret

LDBC8:  ld      a,0x0E
        out     (0x53),a        ; 'S'

        ; Referenced from DBCC
LDBCC:  jr      LDBCC

        ; Referenced from D85F, D8BB, D975, D97C
LDBCE:  nop

        ; Referenced from D86B, D8C5, D8D7, D935, DAF8
LDBCF:  nop

        ; Referenced from D865, D8C1, D918, D930
LDBD0:  nop

        ; Referenced from D87F, D93F, DB06
LDBD1:  nop

        ; Referenced from D879, D8D3, D93A
LDBD2:  nop

        ; Referenced from D987, DAF3
LDBD3:  nop

        ; Referenced from D803
LDBD4:  nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
