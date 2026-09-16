
        ORG     0xD100

        or      a
        jp      z,LD261
        cp      0x01
        jp      z,LD423
        cp      0x02
        jp      z,LD4BD
        cp      0x03
        jp      z,LD4DD
        cp      0x04
        jp      z,LD71D
        cp      0x05
        jp      z,LD4F1
        cp      0x06
        jp      z,LD543
        cp      0x07
        jp      z,LD63A
        cp      0x08
        jp      z,LD69B
        cp      0x09
        jp      z,LD3D0
        cp      0x0A
        jp      z,LD402
        cp      0x0B
        jp      z,LD422
        ld      a,0x02
        scf
        ret

        ; Referenced from D179, D18D, D1A1, D1D1, D257, D28D, D297, D2B4, D45F, D467, D46D, D473, D479, D484, D4FF, D50A, D510, D516, D51C, D527, D56A, D572, D578, D57E, D585, D593, D5BD, D5C7, D5D5, D5F8, D60A, D641, D64A, D66F, D6A2, D6C8
        ; --- START PROC LD13F ---
LD13F:  ld      a,0x40          ; '@'
        ld      (LD7A4),a
        push    hl
        push    de
        ld      hl,0x0000
        ld      de,0x0000

        ; Referenced from D15D, D166
LD14C:  in      a,(0x90)
        push    hl
        ld      hl,0xD7A4
        and     (hl)
        pop     hl
        jr      z,LD159
        xor     a
        jr      LD16E

        ; Referenced from D154
LD159:  inc     hl
        ld      a,h
        cp      0xFF
        jr      c,LD14C
        ld      hl,0x0000
        inc     de
        ld      a,e
        cp      0x0A
        jr      c,LD14C
        ld      a,0x0D
        ld      (LD783),a
        scf

        ; Referenced from D157
LD16E:  pop     de
        pop     hl
        ret

        ; Referenced from D177, D2BC, D3DB, D48D, D4C9, D52F, D615, D677, D6D0
        ; --- START PROC LD171 ---
LD171:  in      a,(0x90)
        and     0x38            ; '8'
        cp      0x18
        jr      nz,LD171
        call    LD13F
        in      a,(0x90)
        and     0x38            ; '8'
        cp      0x18
        ret     z
        scf
        ret

        ; Referenced from D18B, D2C7, D3E6, D495, D4D1, D537, D59B, D620, D682, D6DB
        ; --- START PROC LD185 ---
LD185:  in      a,(0x90)
        and     0x38            ; '8'
        cp      0x38            ; '8'
        jr      nz,LD185
        call    LD13F
        in      a,(0x90)
        and     0x38            ; '8'
        cp      0x38            ; '8'
        ret     z
        scf
        ret

        ; Referenced from D19F, D2A5, D660, D6B9
        ; --- START PROC LD199 ---
LD199:  in      a,(0x90)
        and     0x38            ; '8'
        cp      0x08
        jr      nz,LD199
        call    LD13F
        in      a,(0x90)
        and     0x38            ; '8'
        cp      0x08
        ret     z
        scf
        ret

        ; Referenced from D25B, D2CD, D3F1, D3F8, D49A, D4D6, D53C, D5AA, D629, D630, D68A, D691, D6E3, D6EA, D776
        ; --- START PROC LD1AD ---
LD1AD:  push    hl
        ld      hl,0x0000

        ; Referenced from D1BE
LD1B1:  ld      b,0xFF

        ; Referenced from D1B8
LD1B3:  in      a,(0x90)
        or      a
        jr      z,LD1C8
        djnz    LD1B3
        inc     hl
        ld      a,0x41          ; 'A'
        cp      l
        jr      c,LD1B1
        pop     hl
        xor     a
        out     (0x91),a
        out     (0x90),a
        jr      LD1CC

        ; Referenced from D1B6
LD1C8:  pop     hl
        xor     a
        out     (0x91),a

        ; Referenced from D1C6
LD1CC:  nop
        nop
        nop
        nop
        ret

        ; Referenced from D1D9, D287, D3D5, D481, D4C6, D524, D5B7, D5E4, D5F0, D604, D655, D6AE
        ; --- START PROC LD1D1 ---
LD1D1:  call    LD13F
        jr      c,LD1DB
        xor     a
        out     (0x91),a
        djnz    LD1D1

        ; Referenced from D1D4
        ; --- START PROC LD1DB ---
LD1DB:  ret

        ; Referenced from D20B, D226, D241, D27E, D3D0, D458, D4BD, D4F8, D563, D5AE, D63A, D69B
        ; --- START PROC LD1DC ---
LD1DC:  ld      a,0x81
        out     (0x91),a
        ld      a,0x01
        out     (0x90),a
        call    LD3C5
        in      a,(0x90)
        and     0x80
        jr      nz,LD20D
        ld      b,0xFF

        ; Referenced from D206
LD1EF:  in      a,(0x90)
        and     0x40            ; '@'
        jr      nz,LD243
        push    bc
        call    LD3C5
        call    LD3C5
        call    LD3C5
        call    LD3C5
        call    LD3C5
        pop     bc
        djnz    LD1EF
        xor     a
        out     (0x90),a
        jr      LD1DC

        ; Referenced from D1EB
LD20D:  ld      a,0x01
        out     (0x90),a
        call    LD3C5
        call    LD39A
        call    LD39A
        call    LD39A
        in      a,(0x90)
        and     0x40            ; '@'
        jr      nz,LD228
        xor     a
        out     (0x90),a
        jr      LD1DC

        ; Referenced from D221, D236
LD228:  ld      a,0xFF
        out     (0x91),a

        ; Referenced from D230
LD22C:  in      a,(0x90)
        and     0x40            ; '@'
        jr      nz,LD22C

        ; Referenced from D23C
LD232:  in      a,(0x90)
        and     0x40            ; '@'
        jr      nz,LD228
        in      a,(0x90)
        and     0x80
        jr      nz,LD232
        xor     a
        out     (0x90),a
        jr      LD1DC

        ; Referenced from D1F3
LD243:  xor     a
        out     (0x90),a
        call    LD3C5
        ld      b,0xFF

        ; Referenced from D253
LD24B:  in      a,(0x90)
        and     0x38            ; '8'
        cp      0x10
        jr      z,LD257
        djnz    LD24B
        jr      LD25B

        ; Referenced from D251
LD257:  call    LD13F
        ret

        ; Referenced from D255
LD25B:  call    LD1AD
        ld      a,0xFF
        ret

        ; Referenced from D101
LD261:  call    LD350
        ld      a,(LD782)
        or      a
        jr      z,LD26E
        call    LD38C
        ret

        ; Referenced from D268
LD26E:  ld      a,0x03
        ld      (LD783),a
        scf
        ret

        ; Referenced from D3F4, D49D, D4D9, D53F, D5A7, D62C, D68D, D6E6
        ; --- START PROC LD275 ---
LD275:  ld      a,(LD783)
        cp      0x02
        jr      z,LD27E
        xor     a
        ret

        ; Referenced from D27A
LD27E:  call    LD1DC
        ld      a,0x03
        out     (0x91),a
        ld      b,0x03
        call    LD1D1
        jp      c,LD776
        call    LD13F
        jp      c,LD776
        ld      a,0x0A
        out     (0x91),a
        call    LD13F
        jp      c,LD776
        xor     a
        out     (0x91),a
        call    LD75E
        jr      c,LD2BC
        call    LD199
        jp      c,LD776
        ld      hl,0xD790
        ld      b,0x0A

        ; Referenced from D2BA
LD2B0:  in      a,(0x91)
        ld      (hl),a
        inc     hl
        call    LD13F
        jp      c,LD776
        djnz    LD2B0

        ; Referenced from D2A3
LD2BC:  call    LD171
        jp      c,LD776
        in      a,(0x91)
        ld      (LD783),a
        call    LD185
        in      a,(0x91)
        push    af
        call    LD1AD
        pop     af
        or      a
        jr      z,LD2DB
        ld      a,0xFF
        ld      (LD783),a
        scf
        ret

        ; Referenced from D2D2
LD2DB:  ld      hl,0xD792
        ld      a,(hl)
        push    af
        ld      a,(LD799)
        and     0x0F
        ld      b,a
        pop     af
        cp      0x02
        jr      z,LD2F9
        cp      0x03
        jr      z,LD312
        cp      0x05
        jr      z,LD32D
        cp      0x06
        jr      z,LD340
        jr      LD349

        ; Referenced from D2E9
LD2F9:  ld      a,b
        cp      0x04
        jr      z,LD308
        cp      0x0B
        jr      z,LD30A
        cp      0x0D
        jr      z,LD30E
        jr      LD349

        ; Referenced from D2FC
LD308:  jr      LD34B

        ; Referenced from D300
LD30A:  ld      a,0x06
        jr      LD34B

        ; Referenced from D304
LD30E:  ld      a,0x07
        jr      LD34B

        ; Referenced from D2ED
LD312:  ld      a,b
        cp      0x05
        jr      z,LD325
        cp      0x06
        jr      z,LD325
        cp      0x0C
        jr      z,LD325
        cp      0x0D
        jr      z,LD329
        jr      LD349

        ; Referenced from D315, D319, D31D
LD325:  ld      a,0x09
        jr      LD34B

        ; Referenced from D321
LD329:  ld      a,0x0B
        jr      LD34B

        ; Referenced from D2F1
LD32D:  ld      a,b
        cp      0x0B
        jr      c,LD338
        cp      0x0C
        jr      z,LD33C
        jr      LD349

        ; Referenced from D330
LD338:  ld      a,0x02
        jr      LD34B

        ; Referenced from D334
LD33C:  ld      a,0x05
        jr      LD34B

        ; Referenced from D2F5
LD340:  ld      a,b
        cp      0x01
        jr      nz,LD349
        ld      a,0x08
        jr      LD34B

        ; Referenced from D2F7, D306, D323, D336, D343
LD349:  ld      a,0xFF

        ; Referenced from D308, D30C, D310, D327, D32B, D33A, D33E, D347
LD34B:  ld      (LD783),a
        scf
        ret

        ; Referenced from D261
        ; --- START PROC LD350 ---
LD350:  in      a,(0x98)
        rla
        jr      c,LD36B

        ; Referenced from D372
LD355:  xor     a
        ld      (LD79A),a

        ; Referenced from D369
LD359:  in      a,(0x98)
        rla
        jr      c,LD384
        ld      a,(LD79A)
        inc     a
        ld      (LD79A),a
        cp      0xFF
        jr      nc,LD381
        jr      LD359

        ; Referenced from D353
LD36B:  xor     a
        ld      (LD79A),a

        ; Referenced from D37F
LD36F:  in      a,(0x98)
        rla
        jr      nc,LD355
        ld      a,(LD79A)
        inc     a
        ld      (LD79A),a
        cp      0xFF
        jr      nc,LD381
        jr      LD36F

        ; Referenced from D367, D37D
LD381:  xor     a
        jr      LD386

        ; Referenced from D35C
LD384:  ld      a,0x01

        ; Referenced from D382
LD386:  ld      (LD782),a
        out     (0x9F),a
        ret

        ; Referenced from D26A
        ; --- START PROC LD38C ---
LD38C:  xor     a
        ld      (LD784),a
        ld      (LD783),a
        ld      hl,0x0000
        ld      (LD785),hl
        ret

        ; Referenced from D214, D217, D21A
        ; --- START PROC LD39A ---
LD39A:  push    bc
        ld      b,0xFF

        ; Referenced from D3C1
LD39D:  call    LD3C4
        call    LD3C4
        call    LD3C4
        call    LD3C4
        call    LD3C4
        call    LD3C4
        call    LD3C4
        call    LD3C4
        call    LD3C4
        call    LD3C4
        call    LD3C4
        call    LD3C4
        djnz    LD39D
        pop     bc

        ; Referenced from D39D, D3A0, D3A3, D3A6, D3A9, D3AC, D3AF, D3B2, D3B5, D3B8, D3BB, D3BE
        ; --- START PROC LD3C4 ---
LD3C4:  ret

        ; Referenced from D1E4, D1F6, D1F9, D1FC, D1FF, D202, D211, D246, D409
        ; --- START PROC LD3C5 ---
LD3C5:  ld      b,0x02

        ; Referenced from D3CD
LD3C7:  call    LD3CF
        call    LD3CF
        djnz    LD3C7

        ; Referenced from D3C7, D3CA
        ; --- START PROC LD3CF ---
LD3CF:  ret

        ; Referenced from D12E
LD3D0:  call    LD1DC
        ld      b,0x06
        call    LD1D1
        jp      c,LD776
        call    LD171
        jp      c,LD776
        in      a,(0x91)
        ld      (LD783),a
        call    LD185
        jp      c,LD776
        in      a,(0x91)
        or      a
        jr      nz,LD3F8
        call    LD1AD
        call    LD275
        ret

        ; Referenced from D3EF
LD3F8:  call    LD1AD
        ld      a,0xFF
        ld      (LD783),a
        scf
        ret

        ; Referenced from D133
LD402:  ld      a,0x80
        out     (0x94),a
        ld      b,0x32          ; '2'

        ; Referenced from D40D
LD408:  push    bc
        call    LD3C5
        pop     bc
        djnz    LD408
        xor     a
        out     (0x94),a
        out     (0x91),a
        out     (0x90),a
        ld      (LD782),a
        ld      (LD783),a
        ld      (LD784),a
        nop
        nop
        ret

        ; Referenced from D138
LD422:  ret

        ; Referenced from D106, D441
LD423:  ld      a,c
        and     0x07
        jr      z,LD443
        cp      0x01
        jr      z,LD443
        cp      0x02
        jr      nz,LD4A1
        call    LD4A8
        or      a
        jr      nz,LD4A1
        ld      a,(LD784)
        ld      c,a
        ld      hl,(LD79B)
        ld      de,(LD79D)
        jr      LD423

        ; Referenced from D426, D42A
LD443:  ld      a,c
        ld      (LD784),a
        ld      (LD79B),hl
        ld      (LD79D),de
        and     0x07
        jr      z,LD458
        ld      a,c
        and     0xC0
        or      0x03
        ld      c,a

        ; Referenced from D450
LD458:  call    LD1DC
        ld      a,0xD9
        out     (0x91),a
        call    LD13F
        ld      a,c
        and     0x07
        out     (0x91),a
        call    LD13F
        ld      a,h
        out     (0x91),a
        call    LD13F
        ld      a,l
        out     (0x91),a
        call    LD13F
        ld      a,d
        out     (0x91),a
        call    LD13F
        ld      a,e
        out     (0x91),a
        ld      b,0x03
        call    LD1D1
        call    LD13F
        ld      a,c
        and     0xC0
        out     (0x91),a
        ret

LD48D:  call    LD171
        in      a,(0x91)
        ld      (LD783),a
        call    LD185
        in      a,(0x91)
        call    LD1AD
        call    LD275
        ret

        ; Referenced from D42E, D434
LD4A1:  scf
        ld      a,0x02
        ld      (LD783),a
        ret

        ; Referenced from D430
        ; --- START PROC LD4A8 ---
LD4A8:  push    bc
        push    hl
        push    de
        ld      a,(LD79F)
        ld      c,a
        ld      hl,(LD7A0)
        ld      de,(LD7A2)
        call    LD4F1
        pop     de
        pop     hl
        pop     bc
        ret

        ; Referenced from D10B
LD4BD:  call    LD1DC
        ld      a,0xDA
        out     (0x91),a
        ld      b,0x09
        call    LD1D1
        call    LD171
        in      a,(0x91)
        ld      (LD783),a
        call    LD185
        in      a,(0x91)
        call    LD1AD
        call    LD275
        ret

        ; Referenced from D110
LD4DD:  ld      a,c
        rla
        jr      c,LD4E9
        ld      a,c
        out     (0x98),a
        xor     a
        ld      (LD783),a
        ret

        ; Referenced from D4DF
LD4E9:  in      a,(0x98)
        ld      c,a
        xor     a
        ld      (LD783),a
        ret

        ; Referenced from D11A, D4B6
        ; --- START PROC LD4F1 ---
LD4F1:  ld      (LD7A0),hl
        ld      (LD7A2),de
        call    LD1DC
        ld      a,0xD8
        out     (0x91),a
        call    LD13F
        ld      a,c
        ld      (LD79F),a
        and     0x01
        out     (0x91),a
        call    LD13F
        ld      a,h
        out     (0x91),a
        call    LD13F
        ld      a,l
        out     (0x91),a
        call    LD13F
        ld      a,d
        out     (0x91),a
        call    LD13F
        ld      a,e
        out     (0x91),a
        ld      b,0x03
        call    LD1D1
        call    LD13F
        ld      a,c
        and     0xC0
        out     (0x91),a
        call    LD171
        in      a,(0x91)
        ld      (LD783),a
        call    LD185
        in      a,(0x91)
        call    LD1AD
        call    LD275
        ret

        ; Referenced from D11F
LD543:  push    hl
        ld      hl,0x0800
        ld      (LD785),hl
        pop     hl
        ld      a,c
        or      a
        jr      z,LD560
        push    hl
        ld      a,c
        rla
        jr      c,LD556
        jr      LD55C

        ; Referenced from D552
LD556:  ld      hl,0x0924
        ld      (LD785),hl

        ; Referenced from D554
LD55C:  pop     hl
        call    LD5AE

        ; Referenced from D54D
LD560:  call    LD6F4
        call    LD1DC
        ld      a,0x08
        out     (0x91),a
        call    LD13F
        ld      a,l
        and     0x1F
        out     (0x91),a
        call    LD13F
        ld      a,d
        out     (0x91),a
        call    LD13F
        ld      a,e
        out     (0x91),a
        call    LD13F
        ld      a,0x01
        out     (0x91),a
        call    LD13F
        xor     a
        out     (0x91),a

        ; Referenced from D591
LD58B:  in      a,(0x90)
        and     0x38            ; '8'
        cp      0x18
        jr      nz,LD58B
        call    LD13F
        in      a,(0x91)
        ld      (LD783),a
        call    LD185
        in      a,(0x91)
        or      a
        jp      nz,LD630
        call    LD718
        call    LD275
        call    LD1AD
        ret

        ; Referenced from D55D
        ; --- START PROC LD5AE ---
LD5AE:  call    LD1DC
        ld      a,0x15
        out     (0x91),a
        ld      b,0x03
        call    LD1D1
        jp      c,LD776
        call    LD13F
        jp      c,LD776
        ld      a,0x0A
        out     (0x91),a
        call    LD13F
        jp      c,LD776
        xor     a
        out     (0x91),a
        call    LD76B
        jr      c,LD615
        call    LD13F
        jp      c,LD776
        in      a,(0x90)
        and     0x38            ; '8'
        jp      nz,LD776
        ld      b,0x04
        call    LD1D1
        jp      c,LD776
        ld      a,c
        rla
        jr      c,LD5F8
        ld      b,0x06
        call    LD1D1
        jp      c,LD776
        jr      LD60A

        ; Referenced from D5EC
LD5F8:  call    LD13F
        jp      c,LD776
        ld      a,0x03
        out     (0x91),a
        ld      b,0x05
        call    LD1D1
        jp      c,LD776

        ; Referenced from D5F6
LD60A:  call    LD13F
        jp      c,LD776
        ld      a,c
        and     0x0F
        out     (0x91),a

        ; Referenced from D5D3
LD615:  call    LD171
        jp      c,LD776
        in      a,(0x91)
        ld      (LD783),a
        call    LD185
        in      a,(0x91)
        or      a
        jp      nz,LD630
        call    LD1AD
        call    LD275
        ret

        ; Referenced from D5A1, D626
LD630:  call    LD1AD
        ld      a,0xFF
        ld      (LD783),a
        scf
        ret

        ; Referenced from D124
LD63A:  call    LD1DC
        ld      a,0xDE
        out     (0x91),a
        call    LD13F
        jp      c,LD776
        ld      a,c
        out     (0x91),a
        call    LD13F
        jp      c,LD776
        ld      a,h
        out     (0x91),a
        ld      b,0x07
        call    LD1D1
        jp      c,LD776
        call    LD75E
        jr      c,LD677
        call    LD199
        jp      c,LD776
        ld      hl,(LD780)
        ld      b,0x04

        ; Referenced from D675
LD66B:  in      a,(0x91)
        ld      (hl),a
        inc     hl
        call    LD13F
        jp      c,LD776
        djnz    LD66B

        ; Referenced from D65E
LD677:  call    LD171
        jp      c,LD776
        in      a,(0x91)
        ld      (LD783),a
        call    LD185
        in      a,(0x91)
        or      a
        jr      nz,LD691
        call    LD1AD
        call    LD275
        ret

        ; Referenced from D688
LD691:  call    LD1AD
        ld      a,0xFF
        ld      (LD783),a
        scf
        ret

        ; Referenced from D129
LD69B:  call    LD1DC
        ld      a,0xDD
        out     (0x91),a
        call    LD13F
        jp      c,LD776
        ld      a,0x0A
        out     (0x91),a
        ld      b,0x08
        call    LD1D1
        jp      c,LD776
        call    LD75E
        jr      c,LD6D0
        call    LD199
        jp      c,LD776
        ld      hl,(LD780)
        ld      b,0x0A

        ; Referenced from D6CE
LD6C4:  in      a,(0x91)
        ld      (hl),a
        inc     hl
        call    LD13F
        jp      c,LD776
        djnz    LD6C4

        ; Referenced from D6B7
LD6D0:  call    LD171
        jp      c,LD776
        in      a,(0x91)
        ld      (LD783),a
        call    LD185
        in      a,(0x91)
        or      a
        jr      nz,LD6EA
        call    LD1AD
        call    LD275
        ret

        ; Referenced from D6E1
LD6EA:  call    LD1AD
        ld      a,0xFF
        ld      (LD783),a
        scf
        ret

        ; Referenced from D560
        ; --- START PROC LD6F4 ---
LD6F4:  push    hl
        push    de
        ld      a,(LD780)
        out     (0x62),a        ; 'b'
        ld      a,(LD781)
        out     (0x62),a        ; 'b'
        ld      hl,(LD785)
        ld      a,l
        out     (0x63),a        ; 'c'
        ld      a,h
        res     7,a
        set     6,a
        out     (0x63),a        ; 'c'
        ld      a,0xAE
        out     (0x68),a        ; 'h'
        ld      a,0x41          ; 'A'
        out     (0x9F),a
        pop     de
        pop     hl
        ret

        ; Referenced from D5A4
        ; --- START PROC LD718 ---
LD718:  ld      a,0x01
        out     (0x9F),a
        ret

        ; Referenced from D115
LD71D:  di
        ld      hl,(LD780)

        ; Referenced from D725
LD721:  in      a,(0x93)
        and     0x80
        jr      nz,LD721

        ; Referenced from D72B
LD727:  in      a,(0x93)
        and     0x80
        jr      z,LD727
        ld      a,0x01
        out     (0x97),a
        ld      b,0x60          ; '`'

        ; Referenced from D737, D756
LD733:  in      a,(0x96)
        and     0x80
        jr      nz,LD733

        ; Referenced from D73D
LD739:  in      a,(0x96)
        and     0x80
        jr      z,LD739
        in      a,(0x96)
        and     0x01
        jr      z,LD752
        ld      a,0x0A
        ld      (LD783),a

        ; Referenced from D75C
LD74A:  in      a,(0x97)
        and     0xFE
        out     (0x97),a
        ei
        ret

        ; Referenced from D743
LD752:  in      a,(0x92)
        ld      (hl),a
        inc     hl
        djnz    LD733
        xor     a
        ld      (LD783),a
        jr      LD74A

        ; Referenced from D2A0, D65B, D6B4, D767
        ; --- START PROC LD75E ---
LD75E:  in      a,(0x90)
        and     0x38            ; '8'
        cp      0x08
        ret     z
        cp      0x18
        jr      nz,LD75E
        scf
        ret

        ; Referenced from D5D0, D772
        ; --- START PROC LD76B ---
LD76B:  in      a,(0x90)
        and     0x38            ; '8'
        ret     z
        cp      0x18
        jr      nz,LD76B
        scf
        ret

        ; Referenced from D28A, D290, D29A, D2A8, D2B7, D2BF, D3D8, D3DE, D3E9, D5BA, D5C0, D5CA, D5D8, D5DF, D5E7, D5F3, D5FB, D607, D60D, D618, D644, D64D, D658, D663, D672, D67A, D6A5, D6B1, D6BC, D6CB, D6D3
        ; --- START PROC LD776 ---
LD776:  call    LD1AD
        ld      a,0x0D
        ld      (LD783),a
        scf
        ret

        ; Referenced from D666, D6BF, D6F6, D71E
LD780:  and     (hl)

        ; Referenced from D6FB
LD781:  rst     0x10

        ; Referenced from D264, D386, D416
LD782:  nop

        ; Referenced from D16A, D270, D275, D2C4, D2D6, D34B, D390, D3E3, D3FD, D419, D492, D4A4, D4CE, D4E5, D4ED, D534, D598, D61D, D635, D67F, D696, D6D8, D6EF, D747, D759, D77B
LD783:  nop

        ; Referenced from D38D, D41C, D436, D444
LD784:  nop

        ; Referenced from D396, D547, D559, D700
LD785:  nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop

        ; Referenced from D2E0
LD799:  nop

        ; Referenced from D356, D35E, D362, D36C, D374, D378
LD79A:  nop

        ; Referenced from D43A, D447
LD79B:  nop
        nop

        ; Referenced from D43D, D44A
LD79D:  nop
        nop

        ; Referenced from D4AB, D503
LD79F:  nop

        ; Referenced from D4AF, D4F1
LD7A0:  nop
        nop

        ; Referenced from D4B2, D4F4
LD7A2:  nop
        nop

        ; Referenced from D141
LD7A4:  nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
