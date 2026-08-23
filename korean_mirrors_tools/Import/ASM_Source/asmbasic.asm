
        .ORG     0x9000

        ld      de,0x7B00
        ld      bc,0x03FE
        call    L98BD
        ld      hl,0xC000
        ld      bc,0x01FF
        call    L98C4
        nop
        nop
        ld      a,0xC3
        ld      (0xEEB6),a
        ld      hl,0x9020
        ld      (0xEEB7),hl
        ret

L9020:  ld      a,(hl)
        cp      0xCD
        jp      z,L97AF
        cp      0x87
        jp      z,L97F2
        cp      0xBF
        jp      z,L908E
        cp      0xC8
        jp      z,0x0393               ; PATCH - remove SAVE
        cp      0xC1
        jp      z,L90F2
        cp      0xBE
        jp      z,L9666
        cp      0x8A
        jp      z,L90E8
        cp      0xD5
        jp      z,0x0393               ; PATCH - remove BSAVE
        cp      0xC5
        jp      z,0x0393               ; PATCH - remove KILL
        cp      0xC3
        jp      z,L92F4
        cp      0xD3
        jp      z,L974A
        cp      0xB5
        jp      z,L9789
        cp      0x82
        jp      z,L9065
        jp      0xC110

;---------------PATCH CMD FOR --------------------
        ; Referenced from 905F
L9065:  call    L9866
        push    hl
        push    af
        nop                      
;---------------PATCH - Format disk --------------------
        ld      d,a
        ld      c,0x2C          ; ','

        ; Referenced from 907E
L906F:  call    L9894
        ld      a,d
        call    0xB337
        ld      c,0x2F          ; '/'
        call    L9894
        pop     af
        call    0xB337
        pop     hl
        ret
;---------------PATCH - Init subsystem --------------------
L9080F: push    bc
        ld      c,0x20
        call    L9894
        pop     bc
        ret
        
LIMG1:  .byte   0x00
LIMG2:  .byte   0x00
        nop
        nop
        nop
        nop
        
        ; Referenced from 902D
L908E:  inc     hl
        inc     hl

        ; Referenced from 935D
        ; --- START PROC L9090 ---
L9090:  ld      a,(hl)
        cp      0x22            ; '"'
        jr      z,L90A8
        dec     hl
        push    hl
        xor     a
        ld      (L98F1),a
        call    L90B6
        ld      a,0x01
        ld      (L98F1),a
        call    L90BB
        pop     hl
        ret

        ; Referenced from 9093
L90A8:  call    L93D9
        ld      a,(L98F1)

        ; Referenced from 9517
        ; --- START PROC L90AE ---
L90AE:  or      a
        jr      z,L90B6
        cp      0x01
        jr      z,L90BB
        ret

        ; Referenced from 909B, 90AF, 9305
        ; --- START PROC L90B6 ---
L90B6:  ld      de,0xF000
        jr      L90BE

        ; Referenced from 90A3, 90B3
        ; --- START PROC L90BB ---
L90BB:  ld      de,0xF400

        ; Referenced from 90B9
        ; --- START PROC L90BE ---
L90BE:  ld      c,0x2E          ; '.'
        push    hl
        push    de
        call    L9894
        call    setSect             ; PATCH
_cont1: ld      de,0x4000
        ld      b,0x01
        call    L982A
        ld      de,0x4000
        ld      bc,0x0400
        call    L98A7
        call    L9873
        pop     hl
        ld      bc,0x0200
        call    L98D7
        call    L987F
        pop     hl
        ret

        ; Referenced from 9041
L90E8:  call    L90F2
        ld      hl,0x8000
        xor     a
        out     (0x70),a        ; 'p'
        ret

        ; Referenced from 9037, 90E8
        ; --- START PROC L90F2 ---
L90F2:  call    L93D8
        push    hl
        ld      (L9591+1),hl    ; reference not aligned to instruction
        xor     a
        ld      (L98F1),a
        ld      de,0xF000
        push    de
        call    L954E
        ld      a,(de)
        pop     hl
        call    L987F
        cp      0xFF
        call    z,L91A7
        ld      a,c
        ld      (L94D7+1),a     ; reference not aligned to instruction
        ld      de,0x01FF
        add     hl,de
        call    getImg
        call    L9873
        call    L94CE
        call    L987F
        call    L91E2
        ld      a,(L98F8+2)     ; reference not aligned to instruction
        cp      0x01
        jr      z,L9153
        dec     a
        ld      c,a
        ld      (L9141+1),a     ; reference not aligned to instruction
        call    L94AE
        ld      hl,0x4006
        ld      (L91DA+1),hl    ; reference not aligned to instruction
        ld      hl,0x4400
        ld      ix,0x9904

        ; Referenced from 912E
L9141:  ld      c,0x01
        ld      b,0x0D

        ; Referenced from 9151
L9145:  push    bc
        call    L9211
        pop     bc
        dec     c
        jr      z,L9153
        dec     b
        call    z,L916E
        jr      L9145

        ; Referenced from 912A, 914B
L9153:  call    L91CB
        push    bc
        call    L98A7
        ld      hl,(L98FB)
        pop     bc
        call    L91BE
        call    L98D7
        pop     hl
        ld      a,(L98F8+1)     ; reference not aligned to instruction
        cp      0x02

        ; Referenced from 95E5
L916A:  call    z,0x0000
        ret

        ; Referenced from 914E
        ; --- START PROC L916E ---
L916E:  push    bc
        call    L91CB
        ld      h,b
        ld      l,c
        ld      a,(L91DA+1)     ; reference not aligned to instruction
        or      a
        jr      z,L91A2
        ld      bc,0x37FA

        ; Referenced from 91A5
L917D:  sbc     hl,bc
        ld      (L98FD),hl
        push    bc
        call    L98A7
        ld      hl,(L98FB)
        pop     bc
        call    L91BE
        call    L98D7
        ld      (L98FB),hl
        ld      hl,0x4000
        ld      (L91DA+1),hl    ; reference not aligned to instruction
        ld      a,0xFF
        ld      (L98F8+1),a     ; reference not aligned to instruction
        pop     bc
        ld      b,0x0E
        ret

        ; Referenced from 9178
L91A2:  ld      bc,0x3800
        jr      L917D

        ; Referenced from 910B
        ; --- START PROC L91A7 ---
L91A7:  ld      de,0xF400
        push    de
        ld      a,0x01
        ld      (L98F1),a
        call    L954E
        ld      a,(de)
        call    L987F
        cp      0xFF
        jp      z,0x4DA9
        pop     hl
        ret

        ; Referenced from 915E, 918A, 9228
        ; --- START PROC L91BE ---
L91BE:  push    hl
        ld      d,b
        ld      e,c
        ld      hl,0x0002
        call    0x23AB
        ld      b,h
        ld      c,l
        pop     hl
        ret

        ; Referenced from 9153, 916F
        ; --- START PROC L91CB ---
L91CB:  ld      bc,(L98FD)
        ld      a,(L98F8+1)     ; reference not aligned to instruction
        cp      0x01
        jr      nz,L91DA
        ld      (0xEB18),bc

        ; Referenced from 9137, 9174, 9196, 91D4
L91DA:  ld      de,0x4006
        bit     0,c
        ret     z
        inc     bc
        ret

        ; Referenced from 9122
        ; --- START PROC L91E2 ---
L91E2:  push    de
        push    hl
        ld      c,0x2E          ; '.'
        call    L9894
        ex      de,hl
        ld      de,0x4000
        ld      b,0x01
        call    L982A
        ld      de,0x4000
        ld      bc,0x0006
        call    L98A7
        ld      hl,0x98F9
        ld      bc,0x0003
        call    L98D7
        ld      a,(L98F8+1)     ; reference not aligned to instruction
        cp      0x02
        call    z,L9591
        ld      a,0x00
        pop     hl
        pop     de
        ret

        ; Referenced from 9146
        ; --- START PROC L9211 ---
L9211:  call    L92B1
        ld      c,0x2E          ; '.'
        call    L9894
        ex      de,hl
        ld      b,0x01
        call    L982A
        ex      de,hl
        ld      de,0x0400
        add     hl,de
        ret

L9225:  call    L98A7
        call    L91BE
        call    L98D7
        ret
; -------------- vvvv PATCH - free space -------------------------------------
                ; Referenced from 9046
getImg: di
        push    af
        ld      a,(L98F1)
        or      a 
        jr      Z,_disk1        
        cp      0x01
        jr      Z,_disk2  
        jr      _ret
_disk1: ld      a,LIMG1&0xff
        ld      (_select+1),a
        jr      _select
_disk2: ld      a,LIMG2&0xff
        ld      (_select+1),a        
_select:ld      a,(LIMG1) 
        or      a
        jr      z,_img1
        cp      0x01
        jr      Z,_img2
        cp      0x02
        jr      Z,_img3
        jp      _ret
_img1:  ld      de,0x0000
        jr      _ret
_img2:  ld      de,0x3200
        jr      _ret
_img3:  ld      de,0x6400
_ret:   pop     af
        ei
        ret               
        
setSect:di
        push    af
        ld      a,(L98F1)
        or      a 
        jr      Z,.disk1        
        cp      0x01
        jr      Z,.disk2  
        jr      .ret
.disk1: ld      a,LIMG1&0xff
        ld      (.select+1),a
        jr      .select
.disk2: ld      a,LIMG2&0xff
        ld      (.select+1),a        
.select:ld      a,(LIMG1) 
        or      a
        jr      z,.img1
        cp      0x01
        jr      Z,.img2
        cp      0x02
        jr      Z,.img3
        jp      .ret
.img1:  ld      hl,0x3108
        jr      .ret        
.img2:  ld      hl,0x6308
        jr      .ret
.img3:  ld      hl,0x9508
.ret:   pop     af
        ei
        ret           
       
        nop
        nop
        nop

        ; Referenced from 9299, 92F1
L92A8:  ld      de,0x4F05
        pop     hl
        call    L9396
        pop     hl
        ret
; -------------- ^^^^ PATCH - free space -------------------------------------
        ; Referenced from 9211, 928E, 929B
        ; --- START PROC L92B1 ---
L92B1:  ld      e,(ix+0x00)
        inc     ix
        ld      d,(ix+0x00)
        inc     ix
        ret
; -------------- vvvv PATCH - free space -------------------------------------
        ; Referenced from 904B
copyFnt:di
        ld      a,0x7b
        out     (0x31),a
        ld      a,0x11
        out     (0xe2),a
        xor     a
        out     (0xe3),a
        ld      de,0x0
        ld      hl,0xA300
        ld      bc,0x2000
        ldir
        xor     a
        out     (0xe2),a
        ld      a,0x79
        out     (0x31),a
        ei
        ret
        
        
fontNumber:
        .byte   0x01
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop


        ; Referenced from 9050
L92F4:  inc     hl
        push    hl
        ld      b,0x04

        ; Referenced from 92FE
L92F8:  ld      a,(hl)
        cp      0x22            ; '"'
        jr      z,L935C
        inc     hl
        djnz    L92F8
        pop     hl
        xor     a
        ld      (L98F1),a
        call    L90B6

        ; Referenced from 9360
L9308:  push    hl
        ld      a,(L98F1)
        inc     a
        ld      b,a
        ld      hl,0xEC04
        ld      de,0x0400

        ; Referenced from 9315
L9314:  add     hl,de
        djnz    L9314
        ld      a,0x01
        ld      (0xEF87),a

        ; Referenced from 9331, 9355
L931C:  ld      de,0x9900
        push    de
        call    L9873
        ld      b,0x04

        ; Referenced from 9329
L9325:  ld      a,(hl)
        ld      (de),a
        inc     hl
        inc     de
        djnz    L9325
        call    L987F
        pop     de
        ld      a,(de)
        or      a
        jr      z,L931C
        cp      0xFF
        jr      z,L9357
        push    hl
        in      a,(0x71)        ; 'q'
        push    af
        ld      a,0xFF
        out     (0x71),a        ; 'q'
        ld      b,0x04

        ; Referenced from 9348
L9341:  ld      a,(de)
        or      a
        call    z,L9362
        rst     0x18
        inc     de
        djnz    L9341
        ld      b,0x04
        ld      a,0x20          ; ' '

        ; Referenced from 934F
L934E:  rst     0x18
        djnz    L934E
        pop     af
        out     (0x71),a        ; 'q'
        pop     hl
        jr      L931C

        ; Referenced from 9335
L9357:  call    L987F
        pop     hl
        ret

        ; Referenced from 92FB
L935C:  pop     de
        call    L9090
        jr      L9308
; -------------- ^^^^ PATCH - free space -------------------------------------
        ; Referenced from 9343
        ; --- START PROC L9362 ---
L9362:  ld      a,0x20          ; ' '
        ret

        ; Referenced from 9291
        ; --- START PROC L9365 ---
L9365:  push    hl
        push    de
        ld      de,0x4000
        ld      bc,0x0400
        call    L98BD
        ld      hl,0x98F9
        ld      bc,0x0003
        call    L98C4
        ld      bc,0x01FD
        ld      hl,(L98FB)
        call    L98C4
        ld      c,0x2D          ; '-'
        call    L9894
        pop     hl
        ld      b,0x01
        ld      de,0x4000
        call    L982A
        pop     hl
        ld      de,0x03FA
        add     hl,de
        ret

        ; Referenced from 929E, 92AC
        ; --- START PROC L9396 ---
L9396:  push    hl
        push    de
        push    hl
        ld      de,0x4000
        ld      bc,0x0400
        call    L98BD
        ld      bc,0x0200
        pop     hl
        call    L98C4
        ld      c,0x2D          ; '-'
        call    L9894
        pop     hl
        ld      b,0x01
        ld      de,0x4000
        call    L982A
        ld      a,(L98F8+2)     ; reference not aligned to instruction
        dec     a
        ld      (L98F8+2),a     ; reference not aligned to instruction
        pop     hl
        ld      de,0x0400
        add     hl,de
        ret

        ; Referenced from 9280
        ; --- START PROC L93C4 ---
L93C4:  inc     hl
        inc     hl
        inc     hl
        inc     hl
        inc     hl
        ld      de,0x0400
        ld      c,0x00

        ; Referenced from 93D1
L93CE:  inc     c
        sbc     hl,de
        jr      nc,L93CE
        ld      a,c
        ld      (L98F8+2),a     ; reference not aligned to instruction
        ret

        ; Referenced from 90F2, 922F, 9266, 92BC
        ; --- START PROC L93D8 ---
L93D8:  inc     hl

        ; Referenced from 90A8
        ; --- START PROC L93D9 ---
L93D9:  call    L9433
        ld      b,0x04
        ld      e,l
        ld      d,h

        ; Referenced from 93E6
L93E0:  ld      a,(de)
        cp      0x22            ; '"'
        jr      z,L9410
        inc     de
        djnz    L93E0
        inc     hl
        call    0x5ACA
        ld      a,(de)
        ld      b,a
        inc     de
        ld      (L93F3+2),de    ; reference not aligned to instruction

        ; Referenced from 93EF
L93F3:  ld      de,(0x0000)
        call    L94EA
        ld      a,b
        cp      0x05
        jp      nc,0x4DA0
        ld      (L98FF),a
        push    hl
        ld      hl,0x9900
        ld      b,a

        ; Referenced from 940C
L9408:  ld      a,(de)
        ld      (hl),a
        inc     de
        inc     hl
        djnz    L9408
        pop     hl
        ret

        ; Referenced from 93E3
L9410:  call    L94E9
        ex      de,hl
        ld      de,0x9900
        ld      b,0x04

        ; Referenced from 9429
L9419:  ld      a,(hl)
        cp      0x22            ; '"'
        jr      z,L942B
        cp      0x0D
        jr      z,L942B
        cp      0x20            ; ' '
        jr      z,L942B
        ld      (de),a
        inc     hl
        inc     de
        djnz    L9419

        ; Referenced from 941C, 9420, 9424
L942B:  ld      a,0x04
        sbc     a,b
        ld      (L98FF),a
        inc     hl
        ret

        ; Referenced from 93D9
        ; --- START PROC L9433 ---
L9433:  ld      de,0x9900
        xor     a
        ld      b,0x04

        ; Referenced from 943B
L9439:  ld      (de),a
        inc     de
        djnz    L9439
        ret

        ; Referenced from 9284
        ; --- START PROC L943E ---
L943E:  ld      (L9455+1),a     ; reference not aligned to instruction
        ld      (L9493+1),a     ; reference not aligned to instruction
        call    L947B
        ld      de,0x0000
        push    hl
        ld      ix,0x9904
        call    L9873

        ; Referenced from 9463
L9452:  call    L948A

        ; Referenced from 943E, 9469
L9455:  ld      a,0x00
        ld      (hl),a
        ld      (ix+0x00),e
        inc     ix
        ld      (ix+0x00),d
        inc     ix
        dec     c
        jr      nz,L9452
        inc     hl
        pop     bc
        inc     b
        inc     b
        ld      a,(L9455+1)     ; reference not aligned to instruction
        ld      d,a

        ; Referenced from 9475
L946D:  ld      a,(hl)
        cp      d
        call    z,L94A5
        inc     hl
        ld      a,h
        cp      b
        jr      nz,L946D
        call    L987F
        ret

        ; Referenced from 92D0, 9444
        ; --- START PROC L947B ---
L947B:  ld      de,0x0400
        ld      a,(L98F1)
        ld      b,a
        inc     b
        ld      hl,0xEDFF

        ; Referenced from 9487
L9486:  add     hl,de
        djnz    L9486
        ret

        ; Referenced from 9452, 9499
        ; --- START PROC L948A ---
L948A:  inc     hl
        inc     e
        ld      a,e
        cp      0x06
        call    z,L949B
        ld      a,(hl)

        ; Referenced from 9441
L9493:  cp      0x00
        ret     z
        cp      0xFF
        ret     z
        jr      L948A

        ; Referenced from 948F
        ; --- START PROC L949B ---
L949B:  inc     d
        ld      e,0x01
        ld      a,d
        cp      0x50            ; 'P'
        jp      z,L94A8
        ret

        ; Referenced from 946F
        ; --- START PROC L94A5 ---
L94A5:  ld      (hl),0xFF
        ret

        ; Referenced from 94A1
        ; --- START PROC L94A8 ---
L94A8:  call    L987F
        jp      0x03AB

        ; Referenced from 9131
        ; --- START PROC L94AE ---
L94AE:  push    hl
        ld      ix,0x9904
        call    L9873

        ; Referenced from 94C4
L94B6:  call    L94CE
        ld      (ix+0x00),e
        inc     ix
        ld      (ix+0x00),d
        inc     ix
        dec     c
        jr      nz,L94B6
        inc     hl
        pop     bc
        inc     b
        inc     b
        call    L987F
        ret

        ; Referenced from 911C, 94B6, 94DA
        ; --- START PROC L94CE ---
L94CE:  inc     hl
        inc     e
        ld      a,e
        cp      0x09                           ; PATCH - 2HD support
        call    z,L94DC
        ld      a,(hl)

        ; Referenced from 910F
L94D7:  cp      0x43            ; 'C'
        ret     z
        jr      L94CE

        ; Referenced from 94D3
        ; --- START PROC L94DC ---
L94DC:  inc     d
        ld      e,0x01
        ld      a,d
        cp      0x9A                           ; PATCH - 2HD support
        jp      z,0x03AB
        ret

L94E6:  ld      (hl),0xFF
        ret

        ; Referenced from 9410
        ; --- START PROC L94E9 ---
L94E9:  inc     de

        ; Referenced from 93F7
        ; --- START PROC L94EA ---
L94EA:  inc     de
        ld      a,(de)
        cp      0x3A            ; ':'
        jr      nz,L950C
        dec     de
        ld      a,(de)
        cp      0x41            ; 'A'
        jr      z,L9505
        cp      0x42            ; 'B'
        jr      z,L9508
        jp      0x4DB2

        ; Referenced from 9506, 950A
L94FD:  ld      (L98F1),a
        inc     de
        inc     de
        dec     b
        dec     b
        ret

        ; Referenced from 94F4
L9505:  xor     a
        jr      L94FD

        ; Referenced from 94F8
L9508:  ld      a,0x01
        jr      L94FD

        ; Referenced from 94EE
L950C:  dec     de
        xor     a
        ld      (L98F1),a
        ret

        ; Referenced from 925F, 926A, 92CC
        ; --- START PROC L9512 ---
L9512:  push    hl
        ld      a,(L98F1)
        push    af
        call    L90AE
        pop     af
        ld      de,0x0400
        ld      b,a
        inc     b
        ld      hl,0xEC00

        ; Referenced from 9524
L9523:  add     hl,de
        djnz    L9523
        push    hl
        ex      de,hl
        ld      (L9533+1),de    ; reference not aligned to instruction
        call    L954E
        cp      0xFF
        jr      nz,L953C

        ; Referenced from 9528
L9533:  ld      de,0x0000
        ld      hl,0x98F2
        call    L9551

        ; Referenced from 9531
L953C:  ld      b,0x04

        ; Referenced from 92C3, 92EE, 9582
L953E:  ld      hl,0x9900

        ; Referenced from 9545
L9541:  ld      a,(hl)
        ld      (de),a
        inc     hl
        inc     de
        djnz    L9541
        call    L987F
        ld      a,c
        pop     de
        pop     hl
        ret

        ; Referenced from 9101, 91B0, 952C
        ; --- START PROC L954E ---
L954E:  ld      hl,0x9900

        ; Referenced from 9539
        ; --- START PROC L9551 ---
L9551:  call    L9873
        ld      c,0x00

        ; Referenced from 956A
L9556:  ld      a,(de)
        cp      (hl)
        jr      z,L956C
        cp      0xFF

        ; Referenced from 92C9, 92E8, 957C
L955C:  jp      z,L9578

        ; Referenced from 958F
L955F:  inc     c
        ld      a,c
        cp      0x7F            ; ''
        jp      nc,0x03AB
        inc     de
        inc     de
        inc     de
        inc     de
        jr      L9556

        ; Referenced from 9558
L956C:  ld      b,0x03
        push    de

        ; Referenced from 9575
L956F:  inc     de
        inc     hl
        ld      a,(de)
        cp      (hl)
        jr      nz,L958B
        djnz    L956F
        pop     de

        ; Referenced from 955C
L9578:  ret

L9579:  ld      hl,0x9578
        ld      (L955C+1),hl    ; reference not aligned to instruction
        ld      hl,0x9900
        ld      (L953E+1),hl    ; reference not aligned to instruction
        call    L987F
        jp      0x4DA9

        ; Referenced from 9573
L958B:  ld      hl,0x9900
        pop     de
        jr      L955F

        ; Referenced from 90F6, 9209
        ; --- START PROC L9591 ---
L9591:  ld      hl,0x80FE
        ld      a,(hl)
        cp      0x40            ; '@'
        jr      z,L95B1
        ld      a,(L98F8)
        or      a
        jr      z,L95ED

        ; Referenced from 95B2
L959F:  ld      de,(L98FB)
        ld      (0xB9CE),de

        ; Referenced from 9605
L95A7:  ld      a,(hl)
        cp      0x2C            ; ','
        jr      z,L95B4
        ld      de,0x961D
        jr      L95E5

        ; Referenced from 9597
L95B1:  inc     hl
        jr      L959F

        ; Referenced from 95AA
L95B4:  call    0xB3A0
        call    L96C3
        ld      (L9624+1),a     ; reference not aligned to instruction
        ld      a,(hl)
        cp      0x2C            ; ','
        jr      z,L95C7
        ld      de,0x961D
        jr      L95E5

        ; Referenced from 95C0
L95C7:  call    0xB3AF
        ld      (L9607+1),de    ; reference not aligned to instruction
        ld      a,(hl)
        cp      0x2C            ; ','
        jr      z,L95D8

        ; Referenced from 9656, 9663
L95D3:  ld      de,0x9607
        jr      L95E5

        ; Referenced from 95D1
L95D8:  inc     hl
        ld      a,(hl)
        cp      0x11
        jr      z,L964A
        cp      0x12
        jr      z,L964E
        jp      0x0393

        ; Referenced from 95AF, 95C5, 95D6
L95E5:  ld      (L916A+1),de    ; reference not aligned to instruction
        ld      (L9646+1),hl    ; reference not aligned to instruction
        ret

        ; Referenced from 959D
L95ED:  ld      a,(L98FC)
        add     a,0x10
        ld      (L98FC),a
        ld      de,(L98FB)
        ld      (0xB9CE),de
        ld      a,(L98FD+1)     ; reference not aligned to instruction
        add     a,0x10
        ld      (L98FD+1),a     ; reference not aligned to instruction
        jr      L95A7

        ; Referenced from 95CA
L9607:  ld      de,0x0000
        ld      bc,(0xB9CE)
        ld      (L9619+2),bc    ; reference not aligned to instruction
        ld      a,(L98F6)
        cp      0x01
        jr      z,L961D

        ; Referenced from 960E
L9619:  ld      (0x0000),de

        ; Referenced from 9617
L961D:  ld      hl,(L98FB)
        inc     hl
        inc     hl
        inc     hl
        inc     hl

        ; Referenced from 95BA
L9624:  ld      a,0x00
        ld      (hl),a
        ld      a,(0xDE0E)
        or      a
        jr      z,L963A
        push    de
        push    hl
        push    bc
        call    0xDE0F
        pop     bc
        pop     hl
        pop     de
        xor     a
        ld      (0xDE0E),a

        ; Referenced from 962B
L963A:  ld      a,(L98F6)
        cp      0x00
        call    z,0xB9D0
        xor     a
        ld      (L98F6),a

        ; Referenced from 95E9
L9646:  ld      hl,0x0000
        ret

        ; Referenced from 95DC
L964A:  ld      a,0x01
        jr      L964F

        ; Referenced from 95E0
L964E:  xor     a

        ; Referenced from 964C
L964F:  ld      (L98F6),a
        inc     hl
        ld      a,(hl)
        cp      0x2C            ; ','
        jp      nz,L95D3
        inc     hl
        ld      a,(hl)
        cp      0x0C
        jp      nz,0x0393
        inc     hl
        inc     hl
        inc     hl
        jp      L95D3

        ; Referenced from 903C
L9666:  inc     hl
        ld      a,(hl)
        cp      0x40            ; '@'
        jr      z,L9687
        call    0xB3AF
        ld      a,(L98F8)
        or      a
        call    z,L968D

        ; Referenced from 968B
L9676:  ld      (0xB9CE),de
        ld      a,(hl)
        cp      0x2C            ; ','
        jr      nz,L96BD
        inc     hl
        ld      a,(hl)
        inc     hl
        cp      0x12
        jr      z,L9696
        ret

        ; Referenced from 966A
L9687:  inc     hl
        call    0xB3AF
        jr      L9676

        ; Referenced from 9673
        ; --- START PROC L968D ---
L968D:  push    hl
        ex      de,hl
        ld      de,0x1000
        add     hl,de
        ex      de,hl
        pop     hl
        ret

        ; Referenced from 9684
L9696:  ld      a,(hl)
        cp      0x2C            ; ','
        jp      nz,0x03B1
        push    de
        call    0xB3A0
        inc     de
        inc     de
        inc     de
        inc     de
        call    L96C3
        ld      (de),a
        pop     de
        ld      a,(hl)
        cp      0x2C            ; ','
        jr      nz,L96BD
        ld      de,(0xB9CE)
        ld      (L96B9+2),de    ; reference not aligned to instruction
        call    0xB3AF

        ; Referenced from 96B2
L96B9:  ld      (0x0000),de

        ; Referenced from 967D, 96AC
L96BD:  push    hl
        call    0xB9D0
        pop     hl
        ret

        ; Referenced from 95B7, 96A4
        ; --- START PROC L96C3 ---
L96C3:  cp      0xF0
        ret     z
        or      a
        ret     z
        push    de
        push    hl
        ld      c,a
        srl     a
        srl     a
        srl     a
        srl     a
        cp      0x0F
        jr      z,L96E5
        cp      0x0E
        jr      z,L96E9
        cp      0x0D
        jr      z,L96ED
        cp      0x02
        jr      c,L973D
        jr      L96F1

        ; Referenced from 96D5
L96E5:  ld      d,0x5C          ; '\'
        jr      L9705

        ; Referenced from 96D9
L96E9:  ld      d,0x5D          ; ']'
        jr      L9705

        ; Referenced from 96DD
L96ED:  ld      d,0x5E          ; '^'
        jr      L9705

        ; Referenced from 96E3
L96F1:  ld      d,0x00
        ld      hl,0x9952
        dec     a
        ld      b,a

        ; Referenced from 96FA
L96F8:  inc     hl
        inc     hl
        djnz    L96F8
        ld      a,(hl)
        ld      (0xBA4A),a
        inc     hl
        ld      a,(hl)
        ld      (0xBA72),a

        ; Referenced from 96E7, 96EB, 96EF
L9705:  ld      a,c
        and     0x0F

        ; Referenced from 9748
L9708:  push    af
        ld      hl,0xBB04
        ld      bc,0x02AF

        ; Referenced from 9718
L970F:  ld      a,(hl)
        cp      0xD3
        jr      z,L971E
        inc     hl

        ; Referenced from 9728, 972E, 9735, 973B
L9715:  dec     bc
        ld      a,b
        or      c
        jr      nz,L970F
        pop     af
        pop     hl
        pop     de
        ret

        ; Referenced from 9712
L971E:  inc     hl
        ld      a,(hl)
        cp      d
        jr      nz,L9730
        dec     bc
        inc     hl
        ld      a,(hl)
        cp      0x36            ; '6'
        jr      nz,L9715
        dec     bc
        inc     hl
        ld      (hl),0xAA
        jr      L9715

        ; Referenced from 9721
L9730:  dec     bc
        inc     hl
        ld      a,(hl)
        cp      0x36            ; '6'
        jr      nz,L9715
        dec     bc
        inc     hl
        ld      (hl),0x00
        jr      L9715

        ; Referenced from 96E1
L973D:  ld      a,0xAA
        ld      (0xBA72),a
        ld      (0xBA4A),a
        ld      d,0x00
        ld      a,c
        jr      L9708

        ; Referenced from 9055
L974A:  inc     hl
        inc     hl
        ld      a,(hl)
        inc     hl
        push    hl
        cp      0x11
        nop                ; PATCH - don't use stretched font
        nop
        ld      hl,0x9785
        call    L9763
        pop     hl
        ret

        ; Referenced from 9751
L975B:  ld      hl,0x9781
        call    L9763
        pop     hl
        ret

        ; Referenced from 9756, 975E
        ; --- START PROC L9763 ---
L9763:  ld      ix,0x9779
        ld      b,0x04

        ; Referenced from 9776
L9769:  ld      e,(ix+0x00)
        inc     ix
        ld      d,(ix+0x00)
        inc     ix
        ld      a,(hl)
        inc     hl
        ld      (de),a
        djnz    L9769
        ret

L9779:  .word   0xB41A
        .word   0xB418
        .word   0xB41B
        .word   0xB416
        .word   0x400c
        .word   0x1007
        .word   0x7811
        .word   0xb070

        ; Referenced from 905A
L9789:  call    L9845
        push    hl
        push    bc
        push    de
        ld      de,0x4000
        ld      bc,0x0400

        ; Referenced from 9784
L9795:  call    L98BD
        pop     hl
        ld      bc,0x0200
        call    L98C4
        ld      c,0x2D          ; '-'
        call    L9894
        pop     hl
        ld      b,0x01
        ld      de,0x4000
        call    L982A
        pop     hl
        ret

        ; Referenced from 9023
L97AF:  call    L9866
        call    L988D
        call    0xB3A0
        cp      0x9A            ; 'P'
        jp      nc,0x0B06
        ld      b,a
        ld      c,0x01
        ld      de,0x4000
        push    hl
        push    bc
        nop
        nop
        nop
        nop
        ld      hl,0x4000

        ; Referenced from 97F0
L97CC:  push    hl
        ld      de,0x4000
        ld      bc,0x2000
        call    L98BD
        pop     hl
        ld      bc,0x1000
        call    L98C4
        ld      c,0x2D          ; '-'
        call    L9894
        pop     hl
        ld      b,0x08
        ld      de,0x4000
        call    L982A
        pop     hl
        ret

        ; Referenced from 97C7
L97ED:  ld      hl,0x5400
        jr      L97CC

        ; Referenced from 9028
L97F2:  call    L9845
        push    hl
        push    de
        push    bc
        ld      c,0x2E          ; '.'
        call    L9894
        pop     hl
        ld      b,0x01
        ld      de,0x4000
        call    L982A
        ld      de,0x4000
        ld      bc,0x0400
        call    L98A7
        pop     hl
        ld      bc,0x0200
        call    L98D7
        ld      de,0x7F0E
        ld      bc,0x0002
        call    L98A7
        ld      hl,0xCFFD
        ld      bc,0x0001
        call    L98D7
        pop     hl
        ret

        ; Referenced from 90CD, 91EF, 921C, 938D, 93B4, 97AA, 97E8, 9803
        ; --- START PROC L982A ---
L982A:  ld      a,(L98F1)
        call    0xB337
        ld      a,h
        call    0xB337
        ld      a,l
        call    0xB337
        ld      a,b
        call    0xB337
        ld      a,d
        call    0xB337
        ld      a,e
        call    0xB337
        ret

        ; Referenced from 9789, 97F2
        ; --- START PROC L9845 ---
L9845:  call    L9866
        call    L988D
        call    0xB3A0
        cp      0x9A            ; PATCH: 2HD disk
        jp      nc,0x0B06
        ld      b,a
        call    L988D
        call    0xB3A0
        or      a
        jp      z,0x0B06
        ld      c,a
        call    L988D
        call    0xB3AF
        ret

        ; Referenced from 9065, 97AF, 9845
        ; --- START PROC L9866 ---
L9866:  inc     hl
        call    0xB3A0
        cp      0x02
        jp      nc,0x4DB2
        ld      (L98F1),a
        ret

        ; Referenced from 90D9, 9119, 92D3, 9320, 944F, 94B3, 9551, 98C4
        ; --- START PROC L9873 ---
L9873:  di
        in      a,(0x32)        ; '2'
        set     4,a
        out     (0x32),a        ; '2'
        ld      a,0x7B          ; '{'
        out     (0x31),a        ; '1'
        ret

        ; Referenced from 90E3, 9106, 911F, 91B4, 932B, 9357, 9477, 94A8, 94CA, 9547, 9585, 98D3
        ; --- START PROC L987F ---
L987F:  push    af
        in      a,(0x32)        ; '2'
        res     4,a
        out     (0x32),a        ; '2'
        ld      a,0x79          ; 'y'
        out     (0x31),a        ; '1'
        ei
        pop     af
        ret

        ; Referenced from 97B2, 9848, 9854, 985F
        ; --- START PROC L988D ---
L988D:  ld      a,(hl)
        cp      0x2C            ; ','
        jp      nz,0x03B1
        ret

        ; Referenced from 906F, 9082, 90C2, 91E6, 9216, 9384, 93AB, 97A1, 97DF, 97FA
        ; --- START PROC L9894 ---
L9894:  ld      a,0x0D
        call    0xB331
        ld      a,0x7B          ; '{'
        call    0xB337
        xor     a
        call    0xB337
        ld      a,c
        call    0xB337
        ret

        ; Referenced from 90D6, 9157, 9183, 91F8, 9225, 980C, 981C
        ; --- START PROC L98A7 ---
L98A7:  ld      a,0x15
        call    0xB331

        ; Referenced from 98C2
        ; --- START PROC L98AC ---
L98AC:  ld      a,d
        call    0xB337
        ld      a,e
        call    0xB337
        ld      a,b
        call    0xB337
        ld      a,c
        call    0xB337
        ret

        ; Referenced from 9006, 936D, 939F, 9795, 97D3
        ; --- START PROC L98BD ---
L98BD:  ld      a,0x16
        call    0xB331
        jr      L98AC

        ; Referenced from 900F, 9376, 937F, 93A6, 979C, 97DA
        ; --- START PROC L98C4 ---
L98C4:  call    L9873

        ; Referenced from 98D1
L98C7:  ld      d,(hl)
        inc     hl
        ld      e,(hl)
        inc     hl
        call    0xB310
        dec     bc
        ld      a,b
        or      c
        jr      nz,L98C7
        call    L987F
        ret

        ; Referenced from 90E0, 9161, 918D, 9201, 922B, 9813, 9825, 98E1
        ; --- START PROC L98D7 ---
L98D7:  call    0xB35A
        ld      (hl),d
        inc     hl
        ld      (hl),e
        inc     hl
        dec     bc
        ld      a,b
        or      c
        jr      nz,L98D7
        ret

        ; Referenced from 98EB
L98E4:  ld      a,(hl)
        or      a
        ret     z
        call    0x3E0D
        inc     hl
        jr      L98E4

L98ED:  nop
        nop
        nop
        nop

        ; Referenced from 9098, 90A0, 90AB, 90FA, 91AD, 9302, 9309, 947E, 94FD, 950E, 9513, 982A, 986F
L98F1:  nop
        nop
        nop
        nop
        nop

        ; Referenced from 9612, 963A, 9643, 964F
L98F6:  nop
        nop

        ; Referenced from 9125, 9165, 919B, 91CF, 9204, 925C, 9271, 9294, 92A1, 93B7, 93BB, 93D4, 9599, 966F
L98F8:  ld      bc,0x0103

        ; Referenced from 915A, 9186, 9190, 9238, 9277, 9287, 937C, 959F, 95F5, 961D
L98FB:  nop

        ; Referenced from 95ED, 95F2
L98FC:  ret     po

        ; Referenced from 917F, 91CB, 9259, 927D, 95FD, 9602
L98FD:  ld      b,0x01

        ; Referenced from 9400, 942E
L98FF:  inc     b
        
        