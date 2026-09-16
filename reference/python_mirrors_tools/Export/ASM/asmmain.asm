
        ORG     0xA300

        ld      hl,0xA307
        ld      (0xEE84),hl
        ret

LA307:  ld      a,(hl)
        inc     hl
        cp      0x47            ; 'G'
        jr      z,LA31E
        cp      0x50            ; 'P'
        jr      z,LA340
        cp      0x56            ; 'V'
        jp      z,LA441
        cp      0xC1
        jp      z,LA3E3
        jp      0x03B1

        ; Referenced from A30B, A422
        ; --- START PROC LA31E ---
LA31E:  ld      a,(hl)
        inc     hl
        cp      0x52            ; 'R'
        jr      z,LA32B
        cp      0x4C            ; 'L'
        jr      z,LA337
        jp      0x03B1

        ; Referenced from A322
LA32B:  ld      (LA51C),a
        push    hl
        ld      hl,0xC67B

        ; Referenced from A33E
LA332:  call    LA365
        pop     hl
        ret

        ; Referenced from A326
LA337:  ld      (LA51C),a
        push    hl
        ld      hl,0xC64E
        jr      LA332

        ; Referenced from A30F, A430
        ; --- START PROC LA340 ---
LA340:  ld      a,(hl)
        inc     hl
        cp      0x52            ; 'R'
        jr      z,LA34D
        cp      0x4C            ; 'L'
        jr      z,LA359
        jp      0x03B1

        ; Referenced from A344, A436
        ; --- START PROC LA34D ---
LA34D:  push    hl
        ld      hl,0xC67B
        call    LA386
        call    LA3A7
        pop     hl
        ret

        ; Referenced from A348, A43B
        ; --- START PROC LA359 ---
LA359:  push    hl
        call    LA3C5
        ld      hl,0xC64E
        call    LA386
        pop     hl
        ret

        ; Referenced from A332
        ; --- START PROC LA365 ---
LA365:  call    LA4EE
        ld      ix,0xEC10
        ld      de,0x0050
        ld      c,0x69          ; 'i'

        ; Referenced from A380
LA371:  push    hl
        ld      b,0x07

        ; Referenced from A37B
LA374:  ld      a,(hl)
        ld      (ix+0x00),a
        inc     hl
        inc     ix
        djnz    LA374
        pop     hl
        add     hl,de
        dec     c
        jr      nz,LA371
        call    LA503
        ret

        ; Referenced from A351, A360
        ; --- START PROC LA386 ---
LA386:  call    LA4EE
        ld      ix,0xEC10
        ld      de,0x0050
        ld      c,0x69          ; 'i'

        ; Referenced from A3A1
LA392:  push    hl
        ld      b,0x07

        ; Referenced from A39C
LA395:  ld      a,(ix+0x00)
        ld      (hl),a
        inc     hl
        inc     ix
        djnz    LA395
        pop     hl
        add     hl,de
        dec     c
        jr      nz,LA392
        call    LA503
        ret

        ; Referenced from A354
        ; --- START PROC LA3A7 ---
LA3A7:  call    LA4EE
        ld      de,0x0050
        ld      a,(0xFF00)
        ld      hl,0xC682
        ld      c,0x69          ; 'i'

        ; Referenced from A3BF
LA3B5:  ld      b,0x0E
        push    hl

        ; Referenced from A3BA
LA3B8:  ld      (hl),a
        inc     hl
        djnz    LA3B8
        pop     hl
        add     hl,de
        dec     c
        jr      nz,LA3B5
        call    LA503
        ret

        ; Referenced from A35A
        ; --- START PROC LA3C5 ---
LA3C5:  call    LA4EE
        ld      de,0x0050
        ld      a,(0xFF00)
        ld      hl,0xC640
        ld      c,0x69          ; 'i'

        ; Referenced from A3DD
LA3D3:  ld      b,0x0E
        push    hl

        ; Referenced from A3D8
LA3D6:  ld      (hl),a
        inc     hl
        djnz    LA3D6
        pop     hl
        add     hl,de
        dec     c
        jr      nz,LA3D3
        call    LA503
        ret

        ; Referenced from A318
LA3E3:  dec     hl
        call    0x9020
        ld      a,(hl)
        inc     hl
        cp      0x2C            ; ','
        jr      z,LA44E
        jp      0x03B1

        ; Referenced from A451
        ; --- START PROC LA3F0 ---
LA3F0:  inc     hl
        ld      de,0xEC10
        di
        ld      c,0x0A

        ; Referenced from A40F
LA3F7:  ld      b,0x50          ; 'P'

        ; Referenced from A40C
LA3F9:  out     (0x5C),a        ; '\'
        ld      a,(de)
        or      a
        jr      nz,LA413
        out     (0x5D),a        ; ']'
        ld      a,(de)
        or      a
        jr      nz,LA413
        out     (0x5E),a        ; '^'
        ld      a,(de)
        or      a
        jr      nz,LA413
        inc     de
        djnz    LA3F9
        dec     c
        jr      nz,LA3F7
        jr      LA427

        ; Referenced from A3FD, A403, A409
LA413:  out     (0x5F),a        ; '_'
        ei
        push    hl
        call    LA42C
        pop     hl
        ld      a,(LA51C)
        cp      (hl)
        ret     z

        ; Referenced from A42A
LA420:  push    hl
        ld      a,(hl)
        call    LA31E
        pop     hl
        ret

        ; Referenced from A411
LA427:  out     (0x5F),a        ; '_'
        ei
        jr      LA420

        ; Referenced from A417
        ; --- START PROC LA42C ---
LA42C:  ld      a,(LA51C)
        cp      (hl)
        jp      z,LA340
        ld      a,(hl)
        cp      0x4C            ; 'L'
        jp      z,LA34D
        cp      0x52            ; 'R'
        jp      z,LA359
        jp      0x03B1

        ; Referenced from A313
LA441:  ld      a,(hl)
        inc     hl
        cp      0x50            ; 'P'
        jr      z,LA44E
        cp      0x47            ; 'G'
        jr      z,LA497
        jp      0x0393

        ; Referenced from A3EB, A445
LA44E:  ld      a,(hl)
        cp      0x41            ; 'A'
        call    z,LA3F0
        push    hl
        call    LA4DA
        call    LA50E
        ld      ix,0x3000
        ld      de,0x0280
        ld      b,0x08

        ; Referenced from A481
LA464:  push    bc
        push    hl
        ld      c,0x0D

        ; Referenced from A479
LA468:  out     (0x5C),a        ; '\'
        call    LA489
        out     (0x5D),a        ; ']'
        call    LA489
        out     (0x5E),a        ; '^'
        call    LA489
        add     hl,de
        dec     c
        jr      nz,LA468
        pop     hl
        ld      bc,0x0050
        add     hl,bc
        pop     bc
        djnz    LA464
        call    LA514
        pop     hl
        inc     hl
        ret

        ; Referenced from A46A, A46F, A474
        ; --- START PROC LA489 ---
LA489:  push    hl
        ld      b,0x15

        ; Referenced from A493
LA48C:  ld      a,(ix+0x00)
        ld      (hl),a
        inc     hl
        inc     ix
        djnz    LA48C
        pop     hl
        ret

        ; Referenced from A449
LA497:  push    hl
        call    LA4DA
        call    LA50E
        ld      ix,0x3000
        ld      de,0x0280
        ld      b,0x08

        ; Referenced from A4C4
LA4A7:  push    bc
        push    hl
        ld      c,0x0D

        ; Referenced from A4BC
LA4AB:  out     (0x5C),a        ; '\'
        call    LA4CC
        out     (0x5D),a        ; ']'
        call    LA4CC
        out     (0x5E),a        ; '^'
        call    LA4CC
        add     hl,de
        dec     c
        jr      nz,LA4AB
        pop     hl
        ld      bc,0x0050
        add     hl,bc
        pop     bc
        djnz    LA4A7
        call    LA514
        pop     hl
        inc     hl
        ret

        ; Referenced from A4AD, A4B2, A4B7
        ; --- START PROC LA4CC ---
LA4CC:  push    hl
        ld      b,0x15

        ; Referenced from A4D6
LA4CF:  ld      a,(hl)
        ld      (ix+0x00),a
        inc     hl
        inc     ix
        djnz    LA4CF
        pop     hl
        ret

        ; Referenced from A455, A498
        ; --- START PROC LA4DA ---
LA4DA:  ld      a,(hl)
        cp      0x4C            ; 'L'
        jr      z,LA4E6
        cp      0x52            ; 'R'
        jr      z,LA4EA
        jp      0x03B1

        ; Referenced from A4DD
LA4E6:  ld      hl,0xC640
        ret

        ; Referenced from A4E1
LA4EA:  ld      hl,0xC67B
        ret

        ; Referenced from A365, A386, A3A7, A3C5
        ; --- START PROC LA4EE ---
LA4EE:  di
        out     (0x5F),a        ; '_'
        in      a,(0x32)        ; '2'
        ld      (LA506+1),a     ; reference not aligned to instruction
        or      0x40            ; '@'
        out     (0x32),a        ; '2'
        ld      a,0x97
        out     (0x35),a        ; '5'
        ld      a,0x07
        out     (0x34),a        ; '4'
        ret

        ; Referenced from A382, A3A3, A3C1, A3DF
        ; --- START PROC LA503 ---
LA503:  xor     a
        out     (0x35),a        ; '5'

        ; Referenced from A4F3
LA506:  ld      a,0x00
        out     (0x32),a        ; '2'
        out     (0x5F),a        ; '_'
        ei
        ret

        ; Referenced from A458, A49B
        ; --- START PROC LA50E ---
LA50E:  di
        ld      a,0x7B          ; '{'
        out     (0x31),a        ; '1'
        ret

        ; Referenced from A483, A4C6
        ; --- START PROC LA514 ---
LA514:  ld      a,0x79          ; 'y'
        out     (0x31),a        ; '1'
        out     (0x5F),a        ; '_'
        ei
        ret

        ; Referenced from A32B, A337, A41B, A42C
LA51C:  nop
        nop
        jr      nz,LA565
        ld      d,d
        ld      d,d
        ld      c,a
        ld      d,d
        nop
        ccf
        nop
        ld      d,a
        ld      c,b
        ld      c,c
        ld      c,h
        ld      b,l
        jr      nz,LA5A4+1      ; reference not aligned to instruction
        ld      l,c
        ld      (hl),h
        ld      l,b
        ld      l,a
        ld      (hl),l
        ld      (hl),h
        jr      nz,LA58D
        ld      b,l
        ld      c,(hl)
        ld      b,h
        nop
        ld      d,a
        ld      b,l
        ld      c,(hl)
        ld      b,h
        jr      nz,LA5B7
        ld      l,c
        ld      (hl),h
        ld      l,b
        ld      l,a
        ld      (hl),l
        ld      (hl),h
        jr      nz,LA59F
        ld      c,b
        ld      c,c
        ld      c,h
        ld      b,l
        nop
        ld      h,h
        ld      (hl),l
        ld      (hl),b
        ld      l,h
        ld      l,c
        ld      h,e
        ld      h,c
        ld      (hl),h
        ld      h,l
        jr      nz,LA5C4
        ld      h,c
        ld      h,d
        ld      h,l
        ld      l,h
        nop
        ld      (hl),l
        ld      l,(hl)
        ld      h,h
        ld      h,l
        ld      h,(hl)
        ld      l,c
        ld      l,(hl)
        ld      h,l

        ; Referenced from A51E
LA565:  ld      h,h
        jr      nz,LA5D4
        ld      h,c
        ld      h,d
        ld      h,l
        ld      l,h
        nop
        ld      b,(hl)
        ld      h,l
        ld      h,c
        ld      (hl),h
        ld      (hl),l
        ld      (hl),d
        ld      h,l
        jr      nz,LA5E4
        ld      l,a
        ld      (hl),h
        jr      nz,LA5DB
        halt
        ld      h,c
        ld      l,c
        ld      l,h
        ld      h,c
        ld      h,d
        ld      l,h
        ld      h,l
        nop
        ld      b,(hl)
        ld      c,c
        ld      b,l
        ld      c,h
        ld      b,h
        jr      nz,LA5F9
        halt
        ld      h,l
        ld      (hl),d

        ; Referenced from A534
LA58D:  ld      h,(hl)
        ld      l,h
        ld      l,a
        ld      (hl),a
        nop
        ld      c,c
        ld      l,(hl)
        ld      (hl),h
        ld      h,l
        ld      (hl),d
        ld      l,(hl)
        ld      h,c
        ld      l,h
        jr      nz,LA601
        ld      (hl),d
        ld      (hl),d
        ld      l,a

        ; Referenced from A546
LA59F:  ld      (hl),d
        nop
        ld      b,d
        ld      h,c
        ld      h,h

        ; Referenced from A52C
LA5A4:  jr      nz,LA60C
        ld      l,c
        ld      l,h
        ld      h,l
        jr      nz,LA618+1      ; reference not aligned to instruction
        ld      (hl),l
        ld      l,l
        ld      h,d
        ld      h,l
        ld      (hl),d
        nop
        ld      b,(hl)
        ld      l,c
        ld      l,h
        ld      h,l
        jr      nz,LA625

        ; Referenced from A53E
LA5B7:  ld      l,a
        ld      (hl),h
        jr      nz,LA621
        ld      l,a
        ld      (hl),l
        ld      l,(hl)
        ld      h,h
        nop
        ld      b,(hl)
        ld      l,c
        ld      l,h
        ld      h,l

        ; Referenced from A556
LA5C4:  jr      nz,LA627
        ld      l,h
        ld      (hl),d
        ld      h,l
        ld      h,c
        ld      h,h
        ld      a,c
        jr      nz,LA63D
        ld      (hl),b
        ld      h,l
        ld      l,(hl)
        nop
        ld      c,c
        ld      l,(hl)

        ; Referenced from A566
LA5D4:  ld      (hl),b
        ld      (hl),l
        ld      (hl),h
        jr      nz,LA649
        ld      h,c
        ld      (hl),e

        ; Referenced from A578
LA5DB:  ld      (hl),h
        jr      nz,LA643
        ld      l,(hl)
        ld      h,h
        nop
        ld      b,d
        ld      h,c
        ld      h,h

        ; Referenced from A574
LA5E4:  jr      nz,LA64C
        ld      l,c
        ld      l,h
        ld      h,l
        jr      nz,LA658+1      ; reference not aligned to instruction
        ld      h,c
        ld      l,l
        ld      h,l
        nop
        ld      b,h
        ld      l,c
        ld      (hl),d
        ld      h,l
        ld      h,e
        ld      (hl),h
        jr      nz,LA669+1      ; reference not aligned to instruction
        ld      (hl),h
        ld      h,c

        ; Referenced from A588
LA5F9:  ld      (hl),h
        ld      h,l
        ld      l,l
        ld      h,l
        ld      l,(hl)
        ld      (hl),h
        jr      nz,LA669+1      ; reference not aligned to instruction

        ; Referenced from A59A
LA601:  ld      l,(hl)
        jr      nz,LA669+1      ; reference not aligned to instruction
        ld      l,c
        ld      l,h
        ld      h,l
        nop
        ld      d,e
        ld      h,l
        ld      (hl),c
        ld      (hl),l

        ; Referenced from A5A4
LA60C:  ld      h,l
        ld      l,(hl)
        ld      (hl),h
        ld      l,c
        ld      h,c
        ld      l,h
        jr      nz,LA675
        ld      h,(hl)
        ld      (hl),h
        ld      h,l
        ld      (hl),d

        ; Referenced from A5A9
LA618:  jr      nz,LA669+1      ; reference not aligned to instruction
        ld      d,l
        ld      d,h
        nop
        ld      d,e
        ld      h,l
        ld      (hl),c
        ld      (hl),l

        ; Referenced from A5B9
LA621:  ld      h,l
        ld      l,(hl)
        ld      (hl),h
        ld      l,c

        ; Referenced from A5B5
LA625:  ld      h,c
        ld      l,h

        ; Referenced from A5C4
LA627:  jr      nz,LA672
        cpl
        ld      c,a
        jr      nz,LA69B+1      ; reference not aligned to instruction
        ld      l,(hl)
        ld      l,h
        ld      a,c
        nop
        ld      b,(hl)
        ld      l,c
        ld      l,h
        ld      h,l
        jr      nz,LA6A5
        ld      l,a
        ld      (hl),h
        jr      nz,LA68A
        ld      d,b
        ld      b,l

        ; Referenced from A5CC
LA63D:  ld      c,(hl)
        nop
        ld      b,(hl)
        ld      l,c
        ld      l,h
        ld      h,l

        ; Referenced from A5DC
LA643:  jr      nz,LA6BC
        ld      (hl),d
        ld      l,c
        ld      (hl),h
        ld      h,l

        ; Referenced from A5D7
LA649:  jr      nz,LA6BB
        ld      (hl),d

        ; Referenced from A5E4
LA64C:  ld      l,a
        ld      (hl),h
        ld      h,l
        ld      h,e
        ld      (hl),h
        ld      h,l
        ld      h,h
        nop
        ld      b,h
        ld      l,c
        ld      (hl),e
        ld      l,e

        ; Referenced from A5E9
LA658:  jr      nz,LA6C9
        ld      h,(hl)
        ld      h,(hl)
        ld      l,h
        ld      l,c
        ld      l,(hl)
        ld      h,l
        nop
        ld      b,h
        ld      l,c
        ld      (hl),e
        ld      l,e
        jr      nz,LA6D4+1      ; reference not aligned to instruction
        ld      l,a
        ld      (hl),h

        ; Referenced from A5F5, A5FF, A602, A618
LA669:  jr      nz,LA6D8
        ld      l,a
        ld      (hl),l
        ld      l,(hl)
        ld      (hl),h
        ld      h,l
        ld      h,h
        nop

        ; Referenced from A627
LA672:  ld      b,h
        ld      l,c
        ld      (hl),e

        ; Referenced from A612
LA675:  ld      l,e
        jr      nz,LA6C1
        cpl
        ld      c,a
        jr      nz,LA6E1
        ld      (hl),d
        ld      (hl),d
        ld      l,a
        ld      (hl),d
        nop
        ld      b,(hl)
        ld      l,c
        ld      l,h
        ld      h,l
        jr      nz,LA6E8
        ld      l,h
        ld      (hl),d
        ld      h,l

        ; Referenced from A639
LA68A:  ld      h,c
        ld      h,h
        ld      a,c
        jr      nz,LA6F4
        ld      a,b
        ld      l,c
        ld      (hl),e
        ld      (hl),h
        ld      (hl),e
        nop
        ccf
        nop
        ld      b,h
        ld      l,c
        ld      (hl),e
        ld      l,e

        ; Referenced from A62B
LA69B:  jr      nz,LA6FE
        ld      l,h
        ld      (hl),d
        ld      h,l
        ld      h,c
        ld      h,h
        ld      a,c
        jr      nz,LA711+1      ; reference not aligned to instruction

        ; Referenced from A635
LA6A5:  ld      l,a
        ld      (hl),l
        ld      l,(hl)
        ld      (hl),h
        ld      h,l
        ld      h,h
        nop
        ld      b,h
        ld      l,c
        ld      (hl),e
        ld      l,e
        jr      nz,LA717+1      ; reference not aligned to instruction
        ld      (hl),l
        ld      l,h
        ld      l,h
        nop
        ld      b,d
        ld      h,c
        ld      h,h
        jr      nz,LA71C

        ; Referenced from A649
LA6BB:  ld      l,h

        ; Referenced from A643
LA6BC:  ld      l,h
        ld      l,a
        ld      h,e
        ld      h,c
        ld      (hl),h

        ; Referenced from A676
LA6C1:  ld      l,c
        ld      l,a
        ld      l,(hl)
        jr      nz,LA737+3      ; reference not aligned to instruction
        ld      h,c
        ld      h,d
        ld      l,h

        ; Referenced from A658
LA6C9:  ld      h,l
        nop
        ld      b,d
        ld      h,c
        ld      h,h
        jr      nz,LA734
        ld      (hl),d
        ld      l,c
        halt
        ld      h,l

        ; Referenced from A665
LA6D4:  jr      nz,LA742+2      ; reference not aligned to instruction
        ld      (hl),l
        ld      l,l

        ; Referenced from A669
LA6D8:  ld      h,d
        ld      h,l
        ld      (hl),d
        nop
        ld      b,d
        ld      h,c
        ld      h,h
        jr      nz,LA755

        ; Referenced from A67A
LA6E1:  ld      (hl),d
        ld      h,c
        ld      h,e
        ld      l,e
        cpl
        ld      (hl),e
        ld      h,l

        ; Referenced from A685
LA6E8:  ld      h,e
        ld      (hl),h
        ld      l,a
        ld      (hl),d
        nop
        ld      b,h
        ld      h,l
        ld      l,h
        ld      h,l
        ld      (hl),h
        ld      h,l
        ld      h,h

        ; Referenced from A68D
LA6F4:  jr      nz,LA766+2      ; reference not aligned to instruction
        ld      h,l
        ld      h,e
        ld      l,a
        ld      (hl),d
        ld      h,h
        nop
        ld      d,d
        ld      h,l

        ; Referenced from A69B
LA6FE:  ld      l,(hl)
        ld      h,c
        ld      a,0xC3
        ld      (0xEE8C),a
        ld      hl,0xA70C
        ld      (0xEE8D),hl
        ret

LA70C:  ld      a,(hl)
        cp      0x47            ; 'G'
        jr      z,LA788

        ; Referenced from A6A3
LA711:  cp      0x50            ; 'P'
        jr      z,LA722
        cp      0xD3

        ; Referenced from A6B0
LA717:  jp      z,LA8B9
        cp      0xD8

        ; Referenced from A6B9
LA71C:  jp      z,LA97E
        jp      0x0393

        ; Referenced from A713
LA722:  inc     hl
        call    LA8B1
        call    LA883
        ld      a,e
        ld      (LA843),a
        ld      a,d
        ld      (LA845),a
        call    LA8B1

        ; Referenced from A6CE
LA734:  call    LA883

        ; Referenced from A6C4
LA737:  ld      (LA75A+1),de    ; reference not aligned to instruction
        push    hl
        ld      de,0xA83A
        call    LA827

        ; Referenced from A6D4
LA742:  call    LA820
        call    LA820
        ld      de,0x0050
        di
        ld      a,0x08
        out     (0x46),a        ; 'F'
        in      a,(0x47)        ; 'G'
        ld      (LA77E+1),a     ; reference not aligned to instruction

        ; Referenced from A6DF
LA755:  in      a,(0x47)        ; 'G'
        ld      (LA75D+1),a     ; reference not aligned to instruction

        ; Referenced from A737
LA75A:  ld      hl,0xC000

        ; Referenced from A757
LA75D:  ld      c,0x78          ; 'x'

        ; Referenced from A770
LA75F:  out     (0x5C),a        ; '\'
        call    LA77D
        out     (0x5D),a        ; ']'

        ; Referenced from A6F4
LA766:  call    LA77D
        out     (0x5E),a        ; '^'
        call    LA77D
        add     hl,de
        dec     c
        jr      nz,LA75F
        out     (0x5F),a        ; '_'
        ei
        ld      de,0xA84B
        call    LA82D
        pop     hl
        ret

        ; Referenced from A761, A766, A76B
        ; --- START PROC LA77D ---
LA77D:  push    hl

        ; Referenced from A752
LA77E:  ld      b,0x28          ; '('

        ; Referenced from A784
LA780:  in      a,(0x47)        ; 'G'
        ld      (hl),a
        inc     hl
        djnz    LA780
        pop     hl
        ret

        ; Referenced from A70F
LA788:  inc     hl
        call    LA8B1
        call    LA883
        ld      a,e
        ld      (LA85B),a
        ld      a,d
        ld      (LA85D),a
        ld      (LA804+1),de    ; reference not aligned to instruction
        call    LA8B1
        call    LA883
        ld      (LA7D7+1),de    ; reference not aligned to instruction
        call    LA8B1
        call    LA883
        ld      a,e
        ld      c,e
        ld      (LA80E+1),a     ; reference not aligned to instruction
        call    LA8B1
        call    LA883
        ld      a,e
        ld      b,e
        ld      (LA7DA+1),a     ; reference not aligned to instruction
        push    hl

        ; Referenced from A83C
LA7BC:  ld      de,0xA852
        call    LA827
        ld      de,0x0050
        di
        ld      a,0x08
        out     (0x46),a        ; 'F'
        ld      a,c
        out     (0x47),a        ; 'G'
        ld      a,b
        out     (0x47),a        ; 'G'

        ; Referenced from A84F
LA7D0:  ld      ix,0x0002

        ; Referenced from A854
LA7D4:  ld      de,0x0050

        ; Referenced from A7A1
LA7D7:  ld      hl,0xC000

        ; Referenced from A7B8
LA7DA:  ld      c,0x78          ; 'x'

        ; Referenced from A7ED
LA7DC:  out     (0x5C),a        ; '\'
        call    LA80D
        out     (0x5D),a        ; ']'
        call    LA80D
        out     (0x5E),a        ; '^'
        call    LA80D
        add     hl,de
        dec     c
        jr      nz,LA7DC
        out     (0x5F),a        ; '_'
        ei
        ld      de,0xA84B
        call    LA82D
        push    ix
        pop     hl
        ld      b,0x05

        ; Referenced from A801
LA7FD:  srl     h
        rr      l
        djnz    LA7FD
        inc     hl

        ; Referenced from A797
LA804:  ld      de,0x0000
        add     hl,de
        ld      (0xD000),hl
        pop     hl
        ret

        ; Referenced from A7DE, A7E3, A7E8
        ; --- START PROC LA80D ---
LA80D:  push    hl

        ; Referenced from A7AD
LA80E:  ld      b,0x28          ; '('

        ; Referenced from A816
LA810:  ld      a,(hl)
        out     (0x47),a        ; 'G'
        inc     hl
        inc     ix

        ; Referenced from A81E
LA816:  djnz    LA810
        pop     hl
        ret

LA81A:  inc     ix
        ld      e,0x1F
        jr      LA816

        ; Referenced from A742, A745
        ; --- START PROC LA820 ---
LA820:  ld      a,0x08

        ; Referenced from C553
LA822:  out     (0x46),a        ; 'F'
        in      a,(0x47)        ; 'G'
        ret

        ; Referenced from A73F, A7BF, A82B
        ; --- START PROC LA827 ---
LA827:  in      a,(0x46)        ; 'F'
        and     0x04
        jr      nz,LA827

        ; Referenced from A778, A7F5, A838
        ; --- START PROC LA82D ---
LA82D:  ld      a,(de)
        cp      0xFF
        ret     z
        out     (0x46),a        ; 'F'
        inc     de
        ld      a,(de)
        out     (0x47),a        ; 'G'
        inc     de
        jr      LA82D

LA83A:  djnz    LA83C

        ; Referenced from A83A
LA83C:  djnz    LA7BC+2         ; reference not aligned to instruction
        nop
        jr      nz,LA842
        ld      (bc),a

        ; Referenced from A83F
LA842:  ld      (bc),a

        ; Referenced from A72A
LA843:  nop
        inc     bc

        ; Referenced from A72E
LA845:  nop
        inc     b
        rst     0x38
        dec     b
        rst     0x38
        rst     0x38
        nop
        ld      bc,0x0000
        djnz    LA7D0+1         ; reference not aligned to instruction
        rst     0x38
        djnz    LA854

        ; Referenced from A852
LA854:  djnz    LA7D4+2         ; reference not aligned to instruction
        nop
        ld      h,b
        ld      bc,0x0202

        ; Referenced from A790
LA85B:  nop
        inc     bc

        ; Referenced from A794
LA85D:  nop
        inc     b
        rst     0x38
        dec     b
        rst     0x38
        rst     0x38
        push    hl
        call    LA962
        ld      b,0x78          ; 'x'
        ld      hl,0xC04F

        ; Referenced from A87C
LA86C:  push    bc
        push    hl
        ld      d,h
        ld      e,l
        inc     de
        ld      bc,0x004F
        lddr
        pop     hl
        ld      de,0x0050
        add     hl,de
        pop     bc
        djnz    LA86C
        call    LA973
        pop     hl
        ret

        ; Referenced from A726, A734, A78C, A79E, A7A8, A7B3, A982, A98C, A996
        ; --- START PROC LA883 ---
LA883:  ld      a,(hl)
        cp      0x0C
        jr      z,LA8AB
        cp      0x0F
        jr      z,LA8A4
        cp      0x1C
        jr      z,LA8AB
        cp      0x11
        jr      z,LA89D
        cp      0x1A
        jr      z,LA89D
        jr      c,LA89D
        jp      0x0393

        ; Referenced from A892, A896, A898
LA89D:  sub     0x11
        ld      d,0x00
        ld      e,a
        inc     hl
        ret

        ; Referenced from A88A
LA8A4:  inc     hl
        ld      a,(hl)
        ld      d,0x00
        ld      e,a
        inc     hl
        ret

        ; Referenced from A886, A88E
LA8AB:  inc     hl
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        inc     hl
        ret

        ; Referenced from A723, A731, A789, A79B, A7A5, A7B0, A97F, A989, A993
        ; --- START PROC LA8B1 ---
LA8B1:  ld      a,(hl)
        cp      0x2C            ; ','
        jp      nz,0x0393
        inc     hl
        ret

        ; Referenced from A717
LA8B9:  inc     hl
        inc     hl
        ld      a,(hl)
        cp      0x52            ; 'R'
        jr      z,LA8C7
        cp      0x4C            ; 'L'
        jr      z,LA8E4
        jp      0x03B1

        ; Referenced from A8BE
LA8C7:  inc     hl
        ld      a,(hl)
        cp      0x4D            ; 'M'
        jr      z,LA8D8
        push    hl
        ld      hl,0xC035
        ld      a,0x1A
        call    LA901
        pop     hl
        ret

        ; Referenced from A8CB
LA8D8:  inc     hl
        push    hl
        ld      hl,0xC040
        ld      a,0x0F
        call    LA901
        pop     hl
        ret

        ; Referenced from A8C2
LA8E4:  inc     hl
        ld      a,(hl)
        cp      0x4D            ; 'M'
        jr      z,LA8F5
        push    hl
        ld      hl,0xC01A
        ld      a,0x1A
        call    LA932
        pop     hl
        ret

        ; Referenced from A8E8
LA8F5:  inc     hl
        push    hl
        ld      hl,0xC00C
        ld      a,0x0F
        call    LA932
        pop     hl
        ret

        ; Referenced from A8D3, A8DF
        ; --- START PROC LA901 ---
LA901:  ld      (LA91E+1),a     ; reference not aligned to instruction
        ld      b,0x8D
        ld      de,0xC04E
        call    LA962

        ; Referenced from A92C
LA90C:  push    bc
        push    hl
        push    de
        push    hl
        ld      bc,0x0034
        push    bc
        lddr
        pop     bc
        pop     hl
        sbc     hl,bc
        ex      de,hl
        ld      hl,0xFF00

        ; Referenced from A901
LA91E:  ld      bc,0x001A
        ldir
        pop     hl
        ld      bc,0x0050
        add     hl,bc
        ex      de,hl
        pop     hl
        add     hl,bc
        pop     bc
        djnz    LA90C
        call    LA973
        ret

        ; Referenced from A8F0, A8FC
        ; --- START PROC LA932 ---
LA932:  ld      (LA94E+1),a     ; reference not aligned to instruction
        ld      de,0xC001
        ld      b,0x8D
        call    LA962

        ; Referenced from A95C
LA93D:  push    bc
        push    hl
        push    de
        push    de
        ld      bc,0x0034
        push    bc
        ldir
        pop     bc
        pop     hl
        add     hl,bc
        ex      de,hl
        ld      hl,0xFF00

        ; Referenced from A932
LA94E:  ld      bc,0x001A
        ldir
        pop     hl
        ld      bc,0x0050
        add     hl,bc
        ex      de,hl
        pop     hl
        add     hl,bc
        pop     bc
        djnz    LA93D
        call    LA973
        ret

        ; Referenced from A864, A909, A93A, A99E
        ; --- START PROC LA962 ---
LA962:  di
        out     (0x5F),a        ; '_'
        in      a,(0x32)        ; '2'
        ld      (LA976+1),a     ; reference not aligned to instruction
        or      0x40            ; '@'
        out     (0x32),a        ; '2'
        ld      a,0x90
        out     (0x35),a        ; '5'
        ret

        ; Referenced from A87E, A92E, A95E, A9C6
        ; --- START PROC LA973 ---
LA973:  xor     a
        out     (0x35),a        ; '5'

        ; Referenced from A967
LA976:  ld      a,0x00
        out     (0x32),a        ; '2'
        out     (0x5F),a        ; '_'
        ei
        ret

        ; Referenced from A71C
LA97E:  inc     hl
        call    LA8B1
        call    LA883
        ld      (LA9A8+1),de    ; reference not aligned to instruction
        call    LA8B1
        call    LA883
        ld      (LA9B6+1),de    ; reference not aligned to instruction
        call    LA8B1
        call    LA883
        ld      a,e
        ld      (LA9B2+1),a     ; reference not aligned to instruction
        push    hl
        call    LA962
        ld      a,(LA9B2+1)     ; reference not aligned to instruction
        ld      b,a
        ld      de,0x0050

        ; Referenced from A985
LA9A8:  ld      hl,0x0000

        ; Referenced from A9AC
LA9AB:  add     hl,de
        djnz    LA9AB
        push    hl
        add     hl,de
        ex      de,hl
        pop     hl

        ; Referenced from A99A, A9A1
LA9B2:  ld      b,0x8C

        ; Referenced from A9C4
LA9B4:  push    bc
        push    hl

        ; Referenced from A98F
LA9B6:  ld      bc,0x0050
        ldir
        pop     hl
        push    hl
        ld      de,0x0050
        sbc     hl,de
        pop     de
        pop     bc
        djnz    LA9B4
        call    LA973
        pop     hl
        ret

LA9CB:  nop
        ld      hl,(0xE656)
        push    hl
        ld      hl,(0xEAF7)
        push    hl
        call    0x44A4
        push    de
        jr      LAA04

LA9DA:  jp      nz,0x0393
        call    0x44D5
        ex      de,hl
        call    LAA26
        jr      nz,LAA4B
        ld      sp,hl
        ld      (0xEB07),hl
        ld      de,(0xE656)
        ex      de,hl
        ld      (0xEC1D),hl
        ex      de,hl
        inc     hl
        inc     hl
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        inc     hl
        ld      a,(hl)
        inc     hl
        ld      h,(hl)
        ld      l,a
        ld      (0xE656),hl
        ex      de,hl
        call    0x44A4

        ; Referenced from A9D8
LAA04:  call    0x11D3
        push    hl
        call    0x20BD
        pop     hl
        jr      z,LAA17
        ld      bc,0x00AF
        ld      b,c
        push    bc
        inc     sp
        jp      0x0996

        ; Referenced from AA0C
LAA17:  ld      hl,(0xEC1D)
        ld      (0xE656),hl
        pop     hl
        call    0x44A4
        pop     bc
        pop     bc
        jp      0x0996

        ; Referenced from A9E1
        ; --- START PROC LAA26 ---
LAA26:  ld      hl,0x0004
        add     hl,sp

        ; Referenced from AA36, AA49
LAA2A:  ld      a,(hl)
        inc     hl
        ld      bc,0x0082
        cp      c
        jr      nz,LAA38
        ld      bc,0x0012
        add     hl,bc
        jr      LAA2A

        ; Referenced from AA30
LAA38:  ld      bc,0x00AF
        cp      c
        ret     nz
        push    hl
        ld      a,(hl)
        inc     hl
        ld      h,(hl)
        ld      l,a
        rst     0x20
        pop     hl

        ; Referenced from AA7E
LAA44:  ld      bc,0x0006
        ret     z
        add     hl,bc
        jr      LAA2A

        ; Referenced from A9E4
LAA4B:  ld      de,0x001E
        jp      0x03B3

LAA51:  call    0xA0AF
        ld      a,0x80
        ld      (0xEAFB),a
        call    0x5ACA
        push    hl
        ex      de,hl
        rst     0x30
        call    0x211F
        call    0x1B9D
        ld      (0xEC21),hl
        ld      c,0x20          ; ' '
        call    0x4EC1
        pop     de
        ld      hl,0xFFC0
        add     hl,sp
        ld      sp,hl
        ex      de,hl
        ld      c,0x20          ; ' '
        dec     hl
        rst     0x10
        ld      (0xEAFD),hl
        jr      z,LAAB2
        rst     0x08

        ; Referenced from AA93
LAA7E:  jr      z,LAA44+1       ; reference not aligned to instruction
        push    de
        call    0x5ACA
        ex      (sp),hl
        ld      (hl),e
        inc     hl
        ld      (hl),d
        inc     hl
        ex      (sp),hl
        pop     de
        pop     bc
        ld      a,(hl)
        cp      0x2C            ; ','
        jr      nz,LAA95
        dec     c
        rst     0x10
        jr      LAA7E+1         ; reference not aligned to instruction

        ; Referenced from AA8F
LAA95:  rst     0x08
        add     hl,hl
        ld      (0xEAFD),hl
        ld      a,0x21          ; '!'
        sub     c
        pop     hl
        dec     a
        jr      z,LAAB2
        pop     de
        dec     a
        jr      z,LAAB2
        pop     bc
        dec     a
        jr      z,LAAB2
        push    bc
        push    hl
        ld      hl,0x0002
        add     hl,sp
        ld      b,h
        ld      c,l
        pop     hl

        ; Referenced from AA7B, AA9F, AAA3, AAA7
LAAB2:  push    hl
        ld      hl,0xAABD
        ex      (sp),hl
        push    hl
        ld      hl,(0xEC21)
        ex      (sp),hl
        ret

LAABD:  ld      hl,(0xEB07)
        ld      sp,hl
        ld      hl,(0xEAFD)
        jp      0x0996

LAAC7:  call    0x4C7D
        dec     hl
        rst     0x10
        jr      z,LAB0D

        ; Referenced from AB00
LAACE:  call    0x11D3
        push    hl
        rst     0x30
        jr      z,LAB02
        call    0x28D0
        call    0x54FC
        ld      hl,(0xEC41)
        inc     hl
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        ld      a,(de)
        cp      0x20            ; ' '
        jr      nz,LAAED
        inc     de
        ld      (hl),d
        dec     hl
        ld      (hl),e
        dec     hl
        dec     (hl)

        ; Referenced from AAE5
LAAED:  call    0x5553

        ; Referenced from AB0B
LAAF0:  pop     hl
        dec     hl
        rst     0x10
        jr      z,LAB0D
        cp      0x3B            ; ';'
        jr      z,LAAFC
        rst     0x08
        inc     l
        dec     hl

        ; Referenced from AAF7
LAAFC:  rst     0x10
        ld      a,0x2C          ; ','
        rst     0x18
        jr      LAACE

        ; Referenced from AAD3
LAB02:  ld      a,0x22          ; '"'
        rst     0x18
        call    0x5553
        ld      a,0x22          ; '"'
        rst     0x18
        jr      LAAF0

        ; Referenced from AACC, AAF3
LAB0D:  call    0x5A69
        jp      0x0F8B

        ; Referenced from AD86, ADB0, ADB6
        ; --- START PROC LAB13 ---
LAB13:  call    LAB3F
        jp      0x2424

        ; Referenced from AD95, ADA7
        ; --- START PROC LAB19 ---
LAB19:  call    LAB3F
        jp      0x241D

        ; Referenced from AB92, ABDE, AD8F, ADBF, ADEA
        ; --- START PROC LAB1F ---
LAB1F:  call    LAB3F
        jp      0x2553

        ; Referenced from AD77
        ; --- START PROC LAB25 ---
LAB25:  call    LAB3F
        jp      0x2174

        ; Referenced from ADD0
        ; --- START PROC LAB2B ---
LAB2B:  or      a
        call    0x22DD
        ld      a,(0xEC3D)
        push    af
        call    0x248C
        pop     bc
        call    LABCA
        ld      a,b
        ret     p
        cpl
        inc     a
        ret

        ; Referenced from AB13, AB19, AB1F, AB25, AB58, AB96
        ; --- START PROC LAB3F ---
LAB3F:  call    0x89C8
        ex      de,hl
        ret

        ; Referenced from AB5D, AB87, AD6E
        ; --- START PROC LAB44 ---
LAB44:  call    0x211F
        ex      de,hl
        ret

        ; Referenced from AB83
        ; --- START PROC LAB49 ---
LAB49:  ld      de,0xEC3D
        ld      b,0x08

        ; Referenced from AB52
LAB4E:  ld      a,(de)
        ld      (hl),a
        inc     de
        inc     hl
        djnz    LAB4E
        ret

        ; Referenced from AD68
        ; --- START PROC LAB55 ---
LAB55:  ld      hl,0xEC3D
        jr      LAB3F

        ; Referenced from ABEB
        ; --- START PROC LAB5A ---
LAB5A:  ld      hl,0xEC4A
        jr      LAB44

        ; Referenced from AD5A
        ; --- START PROC LAB5F ---
LAB5F:  call    0x20AB
        ld      hl,0x20AB
        ex      (sp),hl
        jp      (hl)

        ; Referenced from ADA1, ADF3
        ; --- START PROC LAB67 ---
LAB67:  ld      (0xEC52),hl
        call    LABA5
        call    LABDB
        ld      hl,(0xEC52)
        call    LAB7C
        call    LABB5
        jp      0x2553

        ; Referenced from AB73
        ; --- START PROC LAB7C ---
LAB7C:  ld      a,(hl)
        push    af
        inc     hl
        push    hl
        ld      hl,0xEC52
        call    LAB49
        pop     hl
        call    LAB44

        ; Referenced from AB9E
LAB8A:  pop     af
        dec     a
        ret     z
        push    af
        push    hl
        ld      hl,0xEC52
        call    LAB1F
        pop     hl
        call    LAB3F
        push    hl
        call    0x2424
        pop     hl
        jr      LAB8A

LABA0:  ld      hl,0xEC51
        jr      LABA8

        ; Referenced from AB6A, ABE8, AD80, ADCD, ADED
        ; --- START PROC LABA5 ---
LABA5:  ld      hl,0xEC44

        ; Referenced from ABA3
LABA8:  ld      a,0x04
        pop     de

        ; Referenced from ABB1
LABAB:  ld      b,(hl)
        dec     hl
        ld      c,(hl)
        dec     hl
        push    bc
        dec     a
        jr      nz,LABAB
        ex      de,hl
        jp      (hl)

        ; Referenced from AB76, ABE5, AD98, ADD6
        ; --- START PROC LABB5 ---
LABB5:  ld      hl,0xEC4A
        jr      LABBD

LABBA:  ld      hl,0xEC3D

        ; Referenced from ABB8
LABBD:  ld      a,0x04
        pop     de

        ; Referenced from ABC6
LABC0:  pop     bc
        ld      (hl),c
        inc     hl
        ld      (hl),b
        inc     hl
        dec     a
        jr      nz,LABC0
        ex      de,hl
        jp      (hl)

        ; Referenced from AB37, AD57
        ; --- START PROC LABCA ---
LABCA:  ld      hl,(0xEC43)
        ld      a,h
        or      a
        ret     z
        ld      a,l
        rla
        sbc     a,a
        jr      nz,LABD8
        inc     a
        or      a
        ret

        ; Referenced from ABD3
LABD8:  or      a
        scf
        ret

        ; Referenced from AB6D, ABF3
        ; --- START PROC LABDB ---
LABDB:  ld      hl,0xEC3D
        jp      LAB1F

        ; Referenced from AD89, ADF6
        ; --- START PROC LABE1 ---
LABE1:  pop     hl
        ld      (0xEC52),hl
        call    LABB5
        call    LABA5
        call    LAB5A
        ld      hl,(0xEC52)
        jp      (hl)

LABF2:  add     hl,bc
        jr      LABDB

LABF5:  ret     nz
        call    po,0xD1C7
        dec     (hl)
        ld      a,h
        dec     bc
        ld      bc,0x0808
        sbc     a,e
        add     a,0x84
        ld      a,l
        ld      h,0xC5
        ld      l,h
        ld      l,0x02
        ld      b,(hl)
        dec     e
        ld      a,l
        sbc     a,b
        ld      l,e
        ld      a,(bc)
        sbc     a,l
        cp      c
        dec     hl
        cp      d
        ld      a,l
        ld      bc,0x952B
        daa
        daa
        adc     a,(hl)
        ld      h,e
        ld      a,l
        ld      l,d
        sbc     a,h
        ld      (ix+0x24),d
        ld      c,c
        sub     d
        ld      a,(hl)
        xor     b
        ex      de,hl
        sub     h
        call    z,0xCCCC
        ld      c,h
        ld      a,(hl)
        add     a,e
        sub     a
        xor     d
        xor     d
        xor     d
        xor     d
        xor     d
        ld      a,a
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        ld      a,a
        add     a,b
        inc     bc
        xor     d
        cp      l
        ld      (hl),b
        xor     e
        ld      b,d
        ld      l,0x3D          ; '='
        ld      a,e
        in      a,(0x60)        ; '`'
        sbc     a,a
        sbc     a,b
        call    nc,0x219D
        add     a,l
        jp      nc,0x734D
        ld      a,a
        inc     b
        dec     a
        dec     a
        adc     a,e
        inc     bc

        ; Referenced from ACCD
LAC55:  nop
        nop
        nop
        nop
        nop
        nop
        nop
        add     a,c
        ld      b,e
        sub     l
        ret     pe
        ld      a,d
        jr      z,LAC92
        ld      l,c
        adc     a,b
        ld      sp,0x3A65
        ld      a,h

        ; Referenced from AC90
LAC69:  or      c
        add     a,c
        ex      af,af'
        adc     a,l
        rlca
        ret     m
        ld      sp,hl
        halt
        sbc     a,0xB8
        adc     a,h
        dec     l
        ld      a,(hl)
        ld      c,l
        sbc     a,(hl)
        adc     a,0xBF
        exx
        ld      (hl),l
        add     hl,sp
        ld      a,(hl)
        dec     (hl)
        cp      e
        ld      b,c
        ld      h,b
        ld      l,e
        sub     d
        ld      h,e
        ld      a,(hl)
        ld      (LC664+2),a     ; reference not aligned to instruction
        ld      c,0x1E
        ld      c,c
        ld      (de),a
        ld      a,a
        ei
        ex      de,hl
        jr      z,LAC69

        ; Referenced from AC61
LAC92:  call    z,0x4CCC
        ld      a,a
        and     e
        add     hl,bc

        ; Referenced from AD15
LAC98:  and     a
        xor     d
        xor     d
        xor     d
        ld      hl,(0x2F80)
        nop
        nop
        nop
        nop
        nop
        nop
        add     a,d
        add     hl,bc
        jp      p,LBFCB+1       ; reference not aligned to instruction
        ld      c,d
        jp      0x4E8D

LACAE:  ld      a,l
        ld      l,e
        and     (hl)
        inc     l
        add     a,(hl)
        cp      e
        cp      h
        or      a
        add     a,b
        jp      po,LACD9
        ld      c,(hl)
        xor     a
        ld      a,c
        ld      (hl),h
        add     a,d
        ld      c,0xB8
        adc     a,(hl)
        xor     0xA6
        add     a,e
        pop     af
        add     a,h
        ld      e,d
        add     a,(hl)
        adc     a,h
        ld      b,d
        ld      a,(de)
        inc     a
        jr      z,LAC55
        inc     d
        xor     d
        inc     de
        ld      (hl),e

        ; Referenced from AD4D
LACD3:  ld      h,(hl)
        ld      l,c
        sbc     a,c
        add     a,a
        ld      l,a
        ld      d,e

        ; Referenced from ACB7
LACD9:  xor     l
        dec     sp
        ex      (sp),hl
        dec     (hl)
        inc     hl
        add     a,a
        sub     c
        jp      p,0x312D
        rst     0x20
        ld      e,l
        and     l
        add     a,(hl)
        jp      nz,0x2168
        and     d
        jp      c,0x490F
        add     a,e
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        add     a,b
        dec     d
        ld      b,h
        ld      c,(hl)
        ld      l,(hl)
        add     a,e
        ld      sp,hl
        ld      (0x007E),hl
        nop
        nop
        nop
        nop
        nop
        nop
        ld      a,a
        ld      a,e
        rst     0x08
        pop     de
        rst     0x30
        rla
        ld      (hl),d
        ld      sp,0xF180
        rla
        ld      e,h
        add     hl,hl
        dec     sp
        xor     d
        jr      c,LAC98
        ld      a,d
        rst     0x08
        pop     de
        rst     0x30
        rla
        ld      (hl),d
        ld      sp,0x007F
        nop
        nop
        nop
        nop
        nop
        add     a,b
        add     a,d
        jp      nz,0x2168
        and     d
        jp      c,0x490F
        add     a,c
        ld      l,0x9B
        ld      l,e
        pop     bc
        sub     c
        ld      a,(bc)
        ld      b,0x80
        ld      h,b
        sbc     a,0xF9
        inc     sp
        di
        inc     b
        dec     (hl)
        add     a,c
        ld      d,h
        ld      h,l
        jp      nz,0xD742
        or      e
        ld      e,l
        add     a,c
        nop
        nop
        nop
        nop
        nop
        nop
        jr      nz,LACD3
        or      d
        ld      l,d
        or      0xF4
        and     d
        jr      nc,LAD5D+2      ; reference not aligned to instruction
        ld      a,a
        call    LABCA
        call    m,LAB5F

        ; Referenced from AD54
LAD5D:  ld      a,(0xEC44)
        cp      0x81
        jr      c,LAD74
        ld      hl,0xADA4
        push    hl
        call    LAB55
        ld      hl,0xAC55
        call    LAB44
        call    0x2629

        ; Referenced from AD62
LAD74:  ld      hl,0xAD4F
        call    LAB25
        jr      c,LAD9E
        ld      hl,0xADAD
        push    hl
        call    LABA5
        ld      hl,0xAD3F
        call    LAB13
        call    LABE1
        ld      hl,0xAD3F
        call    LAB1F
        ld      hl,0xAC55
        call    LAB19
        call    LABB5
        call    0x2629

        ; Referenced from AD7A
LAD9E:  ld      hl,0xABF2
        jp      LAB67

LADA4:  ld      hl,0xAD27
        call    LAB19
        jp      0x20AB

LADAD:  ld      hl,0xAD2F
        jp      LAB13

LADB3:  ld      hl,0xAD27
        call    LAB13
        jp      LAEE4

LADBC:  ld      hl,0xAD0F
        call    LAB1F
        ld      a,(0xEC44)
        cp      0x88
        jr      nc,LAE32+2      ; reference not aligned to instruction
        cp      0x48            ; 'H'
        jr      c,LAE2E
        call    LABA5
        call    LAB2B
        ld      (0xEC45),a
        call    LABB5
        ld      a,(0xEC45)
        add     a,0x81
        jr      z,LAE32+2       ; reference not aligned to instruction
        push    af
        call    0x20AB
        call    0x2424
        ld      hl,0xACEF
        call    LAB1F
        call    LABA5
        ld      hl,0xAC3B
        call    LAB67
        call    LABE1
        call    0x2553
        ld      hl,0xAC54
        call    LC33C+2         ; reference not aligned to instruction
        ld      (0xEE8C),a
        ld      hl,0xAE0C
        ld      (0xEE8D),hl
        ret

LAE0C:  ld      a,(hl)
        cp      0x47            ; 'G'
        jr      z,LAE7B
        cp      0x50            ; 'P'
        jp      z,LAEB4
        cp      0x52            ; 'R'
        jp      z,LAE31
        cp      0x45            ; 'E'
        jp      z,LAE69
        cp      0x53            ; 'S'
        jp      z,LAFD5
        cp      0x49            ; 'I'
        jr      z,LAE48
        cp      0x4D            ; 'M'
        jp      z,LAE5B

        ; Referenced from ADCB, AE46, AE59, AE67, AE79
        ; --- START PROC LAE2E ---
LAE2E:  jp      0x0393

        ; Referenced from AE18
LAE31:  xor     a

        ; Referenced from ADC7, ADDE
LAE32:  ld      (LB204+1),a     ; reference not aligned to instruction
        inc     hl
        ld      a,(hl)
        cp      0x52            ; 'R'
        jp      z,LB04C
        cp      0x4C            ; 'L'
        jp      z,LB064
        cp      0x46            ; 'F'
        jp      z,LB020
        jr      LAE2E

        ; Referenced from AE27
LAE48:  inc     hl
        ld      a,(hl)
        cp      0x30            ; '0'
        jp      z,LB154
        cp      0x31            ; '1'
        jp      z,LB16D
        cp      0x49            ; 'I'
        jp      z,LB164
        jr      LAE2E

        ; Referenced from AE2B
LAE5B:  inc     hl
        ld      a,(hl)
        cp      0x30            ; '0'
        jp      z,LB18B
        cp      0x31            ; '1'
        jp      z,LB1B3
        jr      LAE2E

        ; Referenced from AE1D
LAE69:  xor     a
        ld      (LB204+1),a     ; reference not aligned to instruction
        inc     hl

        ; Referenced from B1E0
        ; --- START PROC LAE6E ---
LAE6E:  ld      a,(hl)
        cp      0x52            ; 'R'
        jp      z,LB0B9
        cp      0x4C            ; 'L'
        jp      z,LB0D5
        jr      LAE2E

        ; Referenced from AE0F
LAE7B:  inc     hl
        call    LAEF3
        call    LAEC5
        ld      (LB1F7),de
        call    LAEF3
        call    LAEC5
        ld      (LB1F9),de
        call    LAEF3
        call    LAEC5
        ld      (LB1FB),de
        call    LAEF3
        call    LAEC5
        ld      (LB1FD),de
        call    LAEF3
        call    LAEC5
        ld      (LB20A),de
        push    hl
        call    LAF33
        pop     hl
        ret

        ; Referenced from AE13
LAEB4:  inc     hl
        call    LAEF3
        call    LAEC5
        ld      (LB20A),de
        push    hl
        call    LAEFB
        pop     hl
        ret

        ; Referenced from AE7F, AE89, AE93, AE9D, AEA7, AEB8, AFD9, AFE3, AFED, AFF7, B001, B082
        ; --- START PROC LAEC5 ---
LAEC5:  ld      a,(hl)
        cp      0x0C
        jr      z,LAEED
        cp      0x0F
        jr      z,LAEE6
        cp      0x1C
        jr      z,LAEED
        cp      0x11
        jr      z,LAEDF
        cp      0x1A
        jr      z,LAEDF
        jr      c,LAEDF
        jp      0x0393

        ; Referenced from AED4, AED8, AEDA
LAEDF:  sub     0x11
        ld      d,0x00
        ld      e,a

        ; Referenced from ADB9
LAEE4:  inc     hl
        ret

        ; Referenced from AECC
LAEE6:  inc     hl
        ld      a,(hl)
        ld      d,0x00
        ld      e,a
        inc     hl
        ret

        ; Referenced from AEC8, AED0
LAEED:  inc     hl
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        inc     hl
        ret

        ; Referenced from AE7C, AE86, AE90, AE9A, AEA4, AEB5, AFD6, AFE0, AFEA, AFF4, AFFE, B0F0
        ; --- START PROC LAEF3 ---
LAEF3:  ld      a,(hl)
        cp      0x2C            ; ','
        jp      nz,0x0393
        inc     hl
        ret

        ; Referenced from AEC0
        ; --- START PROC LAEFB ---
LAEFB:  ld      de,(LB20A)
        di
        out     (0x5C),a        ; '\'
        ld      a,(de)
        ld      l,a
        inc     de
        ld      a,(de)
        ld      h,a
        inc     de
        ld      a,(de)
        ld      (LAF1C+1),a     ; reference not aligned to instruction
        inc     de
        ld      a,(de)
        ld      c,a
        inc     de
        ld      a,0x07
        ld      (LB20C),a
        call    LAF73
        ld      ix,0x0050

        ; Referenced from AF09, AF2D
LAF1C:  ld      b,0x50          ; 'P'
        push    hl

        ; Referenced from AF23
LAF1F:  ld      a,(de)
        ld      (hl),a
        inc     de
        inc     hl
        djnz    LAF1F
        pop     hl
        push    de
        ld      de,0x0050
        add     hl,de
        pop     de
        dec     c
        jr      nz,LAF1C
        call    LAF88
        ret

        ; Referenced from AEAF
        ; --- START PROC LAF33 ---
LAF33:  call    LAFAD
        call    LAF93
        ld      de,(LB20A)
        ld      a,b
        ld      (LAF5C+1),a     ; reference not aligned to instruction
        di
        out     (0x5C),a        ; '\'
        ld      a,l
        ld      (de),a
        inc     de
        ld      a,h
        ld      (de),a
        inc     de
        ld      a,b
        ld      (de),a
        inc     de
        ld      a,c
        ld      (de),a
        inc     de
        ld      a,0x07
        ld      (LB20C),a
        call    LAF73
        ld      iy,0x0050

        ; Referenced from AF3E, AF6D
LAF5C:  ld      b,0x50          ; 'P'
        push    hl

        ; Referenced from AF63
LAF5F:  ld      a,(hl)
        ld      (de),a
        inc     de
        inc     hl
        djnz    LAF5F
        pop     hl
        push    de
        ld      de,0x0050
        add     hl,de
        pop     de
        dec     c
        jr      nz,LAF5C
        call    LAF88
        ret

        ; Referenced from AF15, AF55, B021
        ; --- START PROC LAF73 ---
LAF73:  di
        out     (0x5F),a        ; '_'
        in      a,(0x32)        ; '2'
        ld      (LAF8B+1),a     ; reference not aligned to instruction
        or      0x40            ; '@'
        out     (0x32),a        ; '2'
        ld      a,0x97
        out     (0x35),a        ; '5'
        ld      a,0x07
        out     (0x34),a        ; '4'
        ret

        ; Referenced from AF2F, AF6F, B046
        ; --- START PROC LAF88 ---
LAF88:  xor     a
        out     (0x35),a        ; '5'

        ; Referenced from AF78
LAF8B:  ld      a,0x00
        out     (0x32),a        ; '2'
        out     (0x5F),a        ; '_'
        ei
        ret

        ; Referenced from AF36, B010
        ; --- START PROC LAF93 ---
LAF93:  push    bc
        ld      hl,(LB1F7)
        call    LAFC9
        ld      a,(LB1F9)
        inc     a
        ld      b,a
        ld      hl,0xBFB0
        ld      de,0x0050

        ; Referenced from AFA6
LAFA5:  add     hl,de
        djnz    LAFA5
        ld      b,0x00
        add     hl,bc
        pop     bc
        ret

        ; Referenced from AF33, B009
        ; --- START PROC LAFAD ---
LAFAD:  or      a
        ld      de,(LB1F7)
        ld      hl,(LB1FB)
        sbc     hl,de
        call    LAFC9
        or      a
        ld      de,(LB1F9)
        ld      hl,(LB1FD)
        sbc     hl,de
        ld      a,c
        ld      c,l
        inc     c
        ld      b,a
        ret

        ; Referenced from AF97, AFB7
        ; --- START PROC LAFC9 ---
LAFC9:  or      a
        ld      c,0x00
        ld      de,0x0008

        ; Referenced from AFD3
LAFCF:  sbc     hl,de
        ret     c
        inc     c
        jr      LAFCF

        ; Referenced from AE22
LAFD5:  inc     hl
        call    LAEF3
        call    LAEC5
        ld      (LB1F7),de
        call    LAEF3
        call    LAEC5
        ld      (LB1F9),de
        call    LAEF3
        call    LAEC5
        ld      (LB1FB),de
        call    LAEF3
        call    LAEC5
        ld      (LB1FD),de
        call    LAEF3
        call    LAEC5
        ld      (LB20C),de
        push    hl
        call    LAFAD
        ld      (LB203),bc
        call    LAF93
        ld      (LB201),hl
        dec     b
        ld      c,b
        ld      b,0x00
        add     hl,bc
        ld      (LB1FF),hl
        pop     hl
        ret

        ; Referenced from AE43
LB020:  push    hl
        call    LAF73
        ld      a,(LB204)
        ld      l,a
        ld      h,0x00
        ld      (LB039+1),hl    ; reference not aligned to instruction
        ld      hl,(LB1FF)
        ld      a,(LB203)
        ld      b,a

        ; Referenced from B044
LB034:  push    bc
        push    hl
        ld      d,h
        ld      e,l
        inc     de

        ; Referenced from B02A
LB039:  ld      bc,0x0030
        lddr
        pop     hl
        pop     bc
        ld      de,0x0050
        add     hl,de
        djnz    LB034
        call    LAF88
        pop     hl
        inc     hl
        ret

        ; Referenced from AE39
LB04C:  ld      de,0xB201
        ld      (LB093+1),de    ; reference not aligned to instruction
        ld      de,0x1ECB
        ld      (LB0A9),de
        ld      a,0x23          ; '#'
        ld      (LB0AB),a
        call    LB07C
        jr      LB08A

        ; Referenced from AE3E
LB064:  ld      de,0xB1FF
        ld      (LB093+1),de    ; reference not aligned to instruction
        ld      de,0x16CB
        ld      (LB0A9),de
        ld      a,0x2B          ; '+'
        ld      (LB0AB),a
        call    LB07C
        jr      LB08A

        ; Referenced from B05F, B077
        ; --- START PROC LB07C ---
LB07C:  inc     hl
        ld      a,(hl)
        cp      0x2C            ; ','
        ret     nz
        inc     hl
        call    LAEC5
        ld      a,e
        ld      (LB20C),a
        ret

        ; Referenced from B062, B07A
LB08A:  push    hl
        ld      a,(LB20C)
        add     a,0x5C          ; '\'
        ld      (LB0A5+1),a     ; reference not aligned to instruction

        ; Referenced from B04F, B067
LB093:  ld      hl,(LB201)
        ld      a,(LB204)
        ld      (LB0A7+1),a     ; reference not aligned to instruction
        ld      a,(LB203)
        ld      c,a
        ld      de,0x0050
        di

        ; Referenced from B0B2
LB0A4:  push    hl

        ; Referenced from B090
LB0A5:  out     (0x5E),a        ; '^'

        ; Referenced from B099
LB0A7:  ld      b,0x00

        ; Referenced from B056, B06E, B0AC
LB0A9:  rr      (hl)

        ; Referenced from B05C, B074
LB0AB:  inc     hl
        djnz    LB0A9
        or      a
        pop     hl
        add     hl,de
        dec     c
        jr      nz,LB0A4
        out     (0x5F),a        ; '_'
        ei
        pop     hl
        ret

        ; Referenced from AE71
        ; --- START PROC LB0B9 ---
LB0B9:  ld      de,0xB201
        ld      (LB10C+1),de    ; reference not aligned to instruction
        ld      de,0x1ECB
        ld      (LB11A),de
        ld      (LB132),de
        ld      a,0x23          ; '#'
        ld      (LB11C),a
        ld      (LB134),a
        jr      LB0EF

        ; Referenced from AE76
        ; --- START PROC LB0D5 ---
LB0D5:  ld      de,0xB1FF
        ld      (LB10C+1),de    ; reference not aligned to instruction
        ld      de,0x16CB
        ld      (LB11A),de
        ld      (LB132),de
        ld      a,0x2B          ; '+'
        ld      (LB11C),a
        ld      (LB134),a

        ; Referenced from B0D3
        ; --- START PROC LB0EF ---
LB0EF:  inc     hl
        call    LAEF3
        ld      a,(hl)
        sub     0x11
        add     a,0x5C          ; '\'
        ld      (LB110+1),a     ; reference not aligned to instruction
        ld      a,(LB204)
        ld      (LB118+1),a     ; reference not aligned to instruction
        ld      (LB130+1),a     ; reference not aligned to instruction
        ld      a,(LB203)
        ld      c,a
        ld      de,0x0050
        push    hl

        ; Referenced from B0BC, B0D8
LB10C:  ld      hl,(LB201)
        di

        ; Referenced from B0F8
LB110:  out     (0x5C),a        ; '\'

        ; Referenced from B146
LB112:  ld      b,0x04

        ; Referenced from B128
LB114:  push    bc

        ; Referenced from B121
LB115:  push    bc
        or      a
        push    hl

        ; Referenced from B0FE
LB118:  ld      b,0x28          ; '('

        ; Referenced from B0C3, B0DF, B11D
LB11A:  rr      (hl)

        ; Referenced from B0CD, B0E9
LB11C:  inc     hl
        djnz    LB11A
        pop     hl
        pop     bc
        djnz    LB115
        pop     bc
        dec     c
        jr      z,LB148
        add     hl,de
        djnz    LB114
        ld      b,0x01

        ; Referenced from B144
LB12C:  push    bc

        ; Referenced from B139
LB12D:  push    bc
        or      a
        push    hl

        ; Referenced from B101
LB130:  ld      b,0x28          ; '('

        ; Referenced from B0C7, B0E3, B135
LB132:  rr      (hl)

        ; Referenced from B0D0, B0EC
LB134:  inc     hl
        djnz    LB132
        pop     hl
        pop     bc
        djnz    LB12D
        pop     bc
        dec     c
        jr      z,LB148
        add     hl,de
        inc     b
        ld      a,b
        cp      0x04
        jr      nz,LB12C
        jr      LB112

        ; Referenced from B125, B13D
LB148:  out     (0x5F),a        ; '_'
        ld      a,(LB204+1)     ; reference not aligned to instruction
        or      a
        jr      nz,LB151
        ei

        ; Referenced from B14E
LB151:  pop     hl
        inc     hl
        ret

        ; Referenced from AE4C
LB154:  ld      de,0xAE6E
        ld      (LB1E0+1),de    ; reference not aligned to instruction

        ; Referenced from B16B
LB15B:  call    LB175
        ld      a,0xFF
        ld      (LB209),a
        ret

        ; Referenced from AE56
LB164:  ld      de,0xAE36
        ld      (LB1E0+1),de    ; reference not aligned to instruction
        jr      LB15B

        ; Referenced from AE51
LB16D:  ld      a,(LB209)
        or      a
        jr      nz,LB193
        inc     hl
        ret

        ; Referenced from B15B, B1B7
        ; --- START PROC LB175 ---
LB175:  push    hl
        ld      hl,(0xF304)
        ld      (LB206+1),hl    ; reference not aligned to instruction
        ld      hl,0xB1BB
        ld      (0xF304),hl
        ld      a,0x03
        out     (0xE6),a
        out     (0xE4),a
        pop     hl
        inc     hl
        ret

        ; Referenced from AE5F
LB18B:  call    LB193
        xor     a
        ld      (LB209),a
        ret

        ; Referenced from B171, B18B
        ; --- START PROC LB193 ---
LB193:  push    hl
        di
        ld      a,(0xEF0E)
        res     0,a
        ld      (0xEF0E),a
        out     (0xE6),a
        ld      hl,(LB206+1)    ; reference not aligned to instruction
        ld      (0xF304),hl
        ld      a,(0xE6C3)
        out     (0xE4),a
        ld      a,(0xEF0E)
        out     (0xE6),a
        ei
        pop     hl
        inc     hl
        ret

        ; Referenced from AE64, B28B, B291, B297, B29F, B2B2, B2D4, B2DA, B2E4, B2EA, B2F0, B2FA, B300, B306, B30C
LB1B3:  ld      a,(LB209)
        or      a
        jr      nz,LB175
        inc     hl
        ret

LB1BB:  di
        push    af
        push    hl
        push    de
        push    bc
        ld      a,(LB206)
        dec     a
        jr      nz,LB1E5
        ld      hl,(LB20E)

        ; Referenced from B1F5
LB1C9:  ld      a,(hl)
        or      a
        jr      z,LB1F2
        inc     hl
        ld      (LB20E),hl
        ld      de,0x0003
        ld      b,a
        ld      hl,0xB20D

        ; Referenced from B1D9
LB1D8:  add     hl,de
        djnz    LB1D8
        ld      a,0xFF
        ld      (LB204+1),a     ; reference not aligned to instruction

        ; Referenced from B157, B167
LB1E0:  call    LAE6E
        ld      a,0x64          ; 'd'

        ; Referenced from B1C4
LB1E5:  ld      (LB206),a
        pop     bc
        pop     de
        pop     hl
        ld      a,0x03
        out     (0xE4),a
        pop     af
        ei
        ret

        ; Referenced from B1CB
LB1F2:  ld      hl,0xB222
        jr      LB1C9

        ; Referenced from AE82, AF94, AFAE, AFDC
LB1F7:  nop
        nop

        ; Referenced from AE8C, AF9A, AFBB, AFE6
LB1F9:  nop
        nop

        ; Referenced from AE96, AFB2, AFF0
LB1FB:  djnz    LB1FD

        ; Referenced from AEA0, AFBF, AFFA, B1FB
LB1FD:  djnz    LB1FF

        ; Referenced from B01B, B02D, B1FD
LB1FF:  nop
        ret     nz

        ; Referenced from B013, B093, B10C
LB201:  nop
        ret     nz

        ; Referenced from B00C, B030, B09C, B104
LB203:  ld      d,b

        ; Referenced from AE32, AE6A, B024, B096, B0FB, B14A, B1DD
LB204:  jr      nz,LB206

        ; Referenced from B179, B19F, B1C0, B1E5, B204
LB206:  ld      bc,0x0000

        ; Referenced from B160, B16D, B18F, B1B3
LB209:  nop

        ; Referenced from AEAA, AEBB, AEFB, AF39
LB20A:  nop
        ret     po

        ; Referenced from AF12, AF52, B004, B086, B08B
LB20C:  rlca
        nop

        ; Referenced from B1C6, B1CE
LB20E:  ld      (0x52B2),hl
        inc     l
        ld      de,0x2C4C
        ld      de,0x2C52
        ld      (de),a
        ld      c,h
        inc     l
        ld      (de),a
        ld      d,d
        inc     l
        inc     de
        ld      c,h
        inc     l
        inc     de
        ld      bc,0x0101
        inc     b
        inc     b
        ld      b,0x06
        inc     bc
        inc     bc
        inc     bc
        inc     bc
        dec     b
        dec     b
        dec     b
        ld      bc,0x0401
        inc     b
        inc     b
        inc     b
        inc     b
        inc     b
        ld      (bc),a
        ld      (bc),a
        ld      (bc),a
        inc     bc
        inc     bc
        dec     b
        dec     b
        inc     b
        inc     b
        inc     b
        inc     b
        ld      b,0x06
        ld      b,0x02
        ld      (bc),a
        inc     bc
        inc     bc
        ld      bc,0x0101
        ld      bc,0x0405
        inc     b
        inc     bc
        inc     bc
        inc     bc
        inc     bc
        dec     b
        dec     b
        dec     b
        inc     bc
        inc     bc
        inc     bc
        inc     bc
        ld      (bc),a
        ld      (bc),a
        ld      (bc),a
        ld      (bc),a
        ld      b,0x03
        inc     bc
        inc     b
        inc     b
        inc     b
        inc     b
        ld      b,0x06
        ld      b,0x00
        nop
        nop
        nop
        nop

        ; Referenced from B280
LB26F:  nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        jr      nz,LB26F
        ld      d,e
        ld      a,b
        or      e
        call    LB35A

        ; Referenced from B2C0
        ; --- START PROC LB288 ---
LB288:  ld      de,0x0CF0
        call    LB1B3+2         ; reference not aligned to instruction
        ld      de,0x0D00
        call    LB1B3+2         ; reference not aligned to instruction
        ld      de,0x0500
        call    LB1B3+2         ; reference not aligned to instruction
        ld      d,0x06
        ld      b,0x1F

        ; Referenced from B2A5
LB29E:  ld      e,b
        call    LB1B3+2         ; reference not aligned to instruction
        call    LB375+1         ; reference not aligned to instruction
        djnz    LB29E
        ret

        ; Referenced from B2C3
        ; --- START PROC LB2A8 ---
LB2A8:  call    LB35A
        call    LB347
        ret

        ; Referenced from B2CA
        ; --- START PROC LB2AF ---
LB2AF:  ld      de,0x050F
        call    LB1B3+2         ; reference not aligned to instruction
        call    LB347
        ret

        ; Referenced from B2C7
        ; --- START PROC LB2B9 ---
LB2B9:  ld      de,0x0500
        ld      (LB378),de
        call    LB288
        call    LB2A8
        ret

LB2C7:  call    LB2B9
        call    LB2AF
        ret

LB2CE:  call    LB360
        ld      de,0x0600
        call    LB1B3+2         ; reference not aligned to instruction
        ld      de,0x0A0D
        call    LB1B3+2         ; reference not aligned to instruction
        ret

LB2DE:  call    LB35A
        ld      de,0x0610
        call    LB1B3+2         ; reference not aligned to instruction
        ld      de,0x0C90
        call    LB1B3+2         ; reference not aligned to instruction
        ld      de,0x0D0E
        call    LB1B3+2         ; reference not aligned to instruction
        ret

LB2F4:  call    LB35A
        ld      de,0x0501
        call    LB1B3+2         ; reference not aligned to instruction
        ld      de,0x061F
        call    LB1B3+2         ; reference not aligned to instruction
        ld      de,0x0C01
        call    LB1B3+2         ; reference not aligned to instruction
        ld      de,0x0D0A
        call    LB1B3+2         ; reference not aligned to instruction
        ret

        ; Referenced from B314
LB310:  in      a,(0xFE)
        bit     1,a
        jr      z,LB310
        ld      a,d
        out     (0xFD),a
        ld      a,0x09
        out     (0xFF),a

        ; Referenced from B321
LB31D:  in      a,(0xFE)
        bit     2,a
        jr      z,LB31D
        ld      a,e
        out     (0xFD),a
        ld      a,0x08
        out     (0xFF),a

        ; Referenced from B32E
LB32A:  in      a,(0xFE)
        bit     2,a
        jr      nz,LB32A
        ret

LB331:  push    af
        ld      a,0x0F
        out     (0xFF),a
        pop     af
        push    af

        ; Referenced from B33C
LB338:  in      a,(0xFE)
        bit     1,a
        jr      z,LB338
        ld      a,0x0E
        out     (0xFF),a
        pop     af
        out     (0xFD),a
        ld      a,0x09

        ; Referenced from B2AB, B2B5
        ; --- START PROC LB347 ---
LB347:  out     (0xFF),a

        ; Referenced from B34D
LB349:  in      a,(0xFE)
        bit     2,a
        jr      z,LB349
        ld      a,0x08
        out     (0xFF),a

        ; Referenced from B357
LB353:  in      a,(0xFE)
        bit     2,a
        jr      nz,LB353
        ret

        ; Referenced from B285, B2A8, B2DE, B2F4
        ; --- START PROC LB35A ---
LB35A:  ld      a,0x0B
        out     (0xFF),a

        ; Referenced from B362
        ; --- START PROC LB35E ---
LB35E:  in      a,(0xFE)

        ; Referenced from B2CE
        ; --- START PROC LB360 ---
LB360:  bit     0,a
        jr      z,LB35E
        ld      a,0x0A
        out     (0xFF),a
        in      a,(0xFC)
        ld      d,a
        ld      a,0x0D
        out     (0xFF),a

        ; Referenced from B373
LB36F:  in      a,(0xFE)
        bit     0,a
        jr      nz,LB36F

        ; Referenced from B2A2
LB375:  in      a,(0xFC)
        ld      e,a

        ; Referenced from B2BC
LB378:  ld      a,0x0C
        out     (0xFF),a
        ret

LB37D:  ld      a,0x0B
        out     (0xFF),a

        ; Referenced from B385
LB381:  in      a,(0xFE)
        bit     0,a
        jr      z,LB381
        ld      a,0x0A
        out     (0xFF),a
        in      a,(0xFC)
        push    af
        ld      a,0x0D
        out     (0xFF),a

        ; Referenced from B396
LB392:  in      a,(0xFE)
        bit     0,a
        jr      nz,LB392
        ld      a,0x0C
        out     (0xFF),a
        pop     af
        ret

LB39E:  nop
        nop

        ; Referenced from C4F0, C598, C774
        ; --- START PROC LB3A0 ---
LB3A0:  inc     hl

        ; Referenced from C1CE
        ; --- START PROC LB3A1 ---
LB3A1:  ld      a,(hl)
        cp      0x0C
        jr      z,LB3CC
        push    bc
        push    de
        call    0x5ACA
        ld      a,(de)
        pop     de
        pop     bc
        ret

        ; Referenced from C159, C33C, C656, C66D, C6BE, C6D5, C744, C780
        ; --- START PROC LB3AF ---
LB3AF:  inc     hl
        ld      a,(hl)
        cp      0x0C
        jr      z,LB3C6
        cp      0x2C            ; ','
        ret     z
        push    bc
        call    0x5ACA
        ld      (LB3C0+2),de    ; reference not aligned to instruction

        ; Referenced from B3BC
LB3C0:  ld      de,(0x0000)
        pop     bc
        ret

        ; Referenced from B3B3
LB3C6:  inc     hl
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        inc     hl
        ret

        ; Referenced from B3A4
        ; --- START PROC LB3CC ---
LB3CC:  inc     hl
        ld      a,(hl)
        inc     hl
        inc     hl
        ret

        ; Referenced from C164, C185
        ; --- START PROC LB3D1 ---
LB3D1:  inc     hl
        ld      a,(hl)
        inc     hl
        cp      0x0C
        ret     z
        jp      0x0393

        ; Referenced from C16C
        ; --- START PROC LB3DA ---
LB3DA:  inc     hl
        ld      a,(hl)
        cp      0x2C            ; ','
        jp      nz,0x03B1
        ret

LB3E2:  nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop

        ; Referenced from B434, B455, B467, B484, B4BB, B4C0, B4D8, B4F5, B509, B50E
LB400:  jp      LC400

LB403:  nop

        ; Referenced from B437, B4CE, B4D5
LB404:  nop
        nop

        ; Referenced from B446, B4DB, B4E1, B4ED
LB406:  nop
        nop

        ; Referenced from B4C4, B4CB
LB408:  nop
        nop

        ; Referenced from B44C, B4FA, B4FE, B502
LB40A:  nop
        nop
        nop
        nop

        ; Referenced from B42E, B48D, B53A, B58D
LB40E:  nop

        ; Referenced from B428, B47F, B4B3, B534, B57F, B5B2
LB40F:  nop

        ; Referenced from B546, B584, B5C3, B5C8, B5D8
LB410:  nop
        nop

        ; Referenced from B558, B56A, BF87, C142
LB412:  nop

        ; Referenced from C147
LB413:  nop

        ; Referenced from B549, B5CE, B5D5
LB414:  nop
        nop

        ; Referenced from B551, B5BA, B5C0, B5DE
LB416:  nop
        nop
        nop
        nop
        nop
        nop

        ; Referenced from B554, BF81, C13D
LB41C:  nop
        nop
        nop
        nop

        ; Referenced from BF8C, C14F
        ; --- START PROC LB420 ---
LB420:  jp      LB52F

LB423:  in      a,(0x32)        ; '2'
        ld      b,a
        and     0xBF
        ld      (LB40F),a
        ld      a,b
        or      0x40            ; '@'
        ld      (LB40E),a

        ; Referenced from B661
LB431:  ld      hl,0xC434
        ld      (LB400),hl
        ld      (LB404),hl
        call    LB661
        ld      hl,0xB4A5
        ld      (LB5FA+1),hl    ; reference not aligned to instruction
        ld      hl,0xB6E0
        ld      (LB406),hl
        ld      hl,0x2331
        ld      (LB40A),hl
        call    LB4FA
        call    LB4ED

        ; Referenced from B46F, B4EA
LB455:  ld      hl,(LB400+2)    ; reference not aligned to instruction
        ld      d,(hl)
        inc     hl
        ld      e,(hl)
        call    LB5FD
        dec     c
        dec     c
        ld      a,c
        cp      0x00
        jr      z,LB4C4
        push    bc
        inc     hl
        ld      (LB400+2),hl    ; reference not aligned to instruction
        ex      de,hl
        call    LB472
        pop     bc
        jp      LB455

        ; Referenced from B46B, B506
        ; --- START PROC LB472 ---
LB472:  ld      a,0xA8
        out     (0x32),a        ; '2'
        call    0x7290
        ld      de,0xB6C0
        call    0x723D
        ld      a,(LB40F)
        out     (0x32),a        ; '2'
        ld      hl,(LB400)
        ld      de,0xB6C0
        ld      b,0x0C
        di
        ld      a,(LB40E)
        out     (0x32),a        ; '2'

        ; Referenced from C178
LB492:  ld      a,0x07
        out     (0x34),a        ; '4'
        ld      a,0x80
        out     (0x35),a        ; '5'

        ; Referenced from B4B0
LB49A:  bit     0,b
        jp      nz,LB5E8
        ld      a,(de)
        ld      (hl),a
        inc     hl
        inc     de
        ld      a,(de)
        ld      (hl),a
        inc     de
        push    de
        ld      de,0x004F
        add     hl,de
        pop     de
        dec     b
        ld      a,b
        cp      0x01
        jp      nz,LB49A
        ld      a,(LB40F)
        out     (0x32),a        ; '2'
        out     (0x5F),a        ; '_'
        ei
        ld      hl,(LB400)
        inc     hl
        inc     hl
        ld      (LB400),hl
        ret

        ; Referenced from B463
LB4C4:  ld      a,(LB408)
        dec     a
        jp      z,LB5E4
        ld      (LB408),a
        ld      hl,(LB404)
        ld      de,0x03C0
        add     hl,de
        ld      (LB404),hl
        ld      (LB400),hl
        ld      hl,(LB406)
        inc     hl
        inc     hl
        inc     hl
        ld      (LB406),hl
        call    LB4FA
        call    LB4ED
        jp      LB455

        ; Referenced from B452, B4E7
        ; --- START PROC LB4ED ---
LB4ED:  ld      hl,(LB406)
        ld      c,(hl)
        inc     hl
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        ld      (LB400+2),de    ; reference not aligned to instruction
        ret

        ; Referenced from B44F, B4E4
        ; --- START PROC LB4FA ---
LB4FA:  ld      de,(LB40A)
        ld      hl,(LB40A)
        inc     de
        ld      (LB40A),de
        call    LB472
        ld      hl,(LB400)
        inc     hl
        inc     hl
        ld      (LB400),hl
        ret

        ; Referenced from B52D, B668, B675
        ; --- START PROC LB512 ---
LB512:  push    hl
        push    bc
        xor     a
        di

        ; Referenced from B520
LB516:  out     (0x5C),a        ; '\'
        ld      (hl),a
        out     (0x5D),a        ; ']'
        ld      (hl),a
        out     (0x5E),a        ; '^'
        ld      (hl),a
        inc     hl
        djnz    LB516
        out     (0x5F),a        ; '_'
        ei
        pop     bc
        pop     hl
        dec     c
        ret     z
        ld      de,0x0050
        add     hl,de
        jr      LB512

        ; Referenced from B420
        ; --- START PROC LB52F ---
LB52F:  in      a,(0x32)        ; '2'
        ld      b,a
        and     0xBF
        ld      (LB40F),a
        ld      a,b
        or      0x40            ; '@'
        ld      (LB40E),a
        ld      hl,0xB5A4
        ld      (LB5FA+1),hl    ; reference not aligned to instruction

        ; Referenced from B66B, BF6A, BF76, BF95, C15C
LB543:  ld      hl,0xED02
        ld      (LB410),hl
        ld      (LB414),hl
        nop
        nop
        nop

        ; Referenced from B5DB, B66E, C168
LB54F:  ld      a,0x26          ; '&'
        ld      (LB416),a
        ld      a,(LB41C)
        ld      c,a

        ; Referenced from B5CB, B5E1
        ; --- START PROC LB558 ---
LB558:  ld      hl,(LB412)
        ld      d,(hl)
        inc     hl
        ld      e,(hl)
        call    LB5FD
        dec     c
        dec     c
        ld      a,c
        cp      0x00
        jp      z,LB5E4
        inc     hl
        ld      (LB412),hl
        ex      de,hl
        ld      a,0xA8
        out     (0x32),a        ; '2'
        push    bc
        call    0x7290
        pop     bc
        ld      de,0xB6C0
        push    bc
        call    0x723D
        pop     bc
        ld      a,(LB40F)
        out     (0x32),a        ; '2'
        ld      hl,(LB410)
        ld      de,0xB6C0
        ld      b,0x0C
        di
        ld      a,(LB40E)
        out     (0x32),a        ; '2'

        ; Referenced from C17B
LB592:  ld      a,0x07
        out     (0x34),a        ; '4'
        ld      a,0x80
        out     (0x35),a        ; '5'

        ; Referenced from B5AF
        ; --- START PROC LB59A ---
LB59A:  bit     0,b
        jr      nz,LB5E8
        ld      a,(de)
        ld      (hl),a
        inc     hl
        inc     de
        ld      a,(de)
        ld      (hl),a

        ; Referenced from B5FA
        ; --- START PROC LB5A4 ---
LB5A4:  inc     de
        push    de
        ld      de,0x004F
        add     hl,de
        pop     de
        dec     b
        ld      a,b
        cp      0x01
        jp      nz,LB59A
        ld      a,(LB40F)
        out     (0x32),a        ; '2'
        out     (0x5F),a        ; '_'
        ei
        ld      a,(LB416)
        dec     a
        jr      z,LB5CE
        ld      (LB416),a
        ld      hl,(LB410)
        inc     hl
        inc     hl
        ld      (LB410),hl
        jp      LB558

        ; Referenced from B5BE
LB5CE:  ld      hl,(LB414)
        ld      de,0x0410
        add     hl,de
        ld      (LB414),hl
        ld      (LB410),hl
        ld      a,(LB54F+1)     ; reference not aligned to instruction
        ld      (LB416),a
        jp      LB558

        ; Referenced from B4C8, B566
        ; --- START PROC LB5E4 ---
LB5E4:  xor     a
        out     (0x35),a        ; '5'
        ret

        ; Referenced from B49C, B59C
        ; --- START PROC LB5E8 ---
LB5E8:  push    bc
        ld      a,(de)
        ld      b,a
        inc     de
        inc     de
        ld      a,(de)
        or      b
        dec     de
        ld      (hl),a
        ld      a,(de)
        ld      b,a
        inc     de
        inc     de
        ld      a,(de)
        or      b
        inc     hl
        ld      (hl),a
        pop     bc

        ; Referenced from B440, B540
LB5FA:  jp      LB5A4

        ; Referenced from B45B, B55E
        ; --- START PROC LB5FD ---
LB5FD:  ld      a,d
        cp      0x81
        jr      nc,LB604
        jr      LB60C

        ; Referenced from B600
LB604:  cp      0x9F
        jr      c,LB621
        jr      z,LB621
        jr      LB60C

        ; Referenced from B602, B60A
LB60C:  cp      0xE0
        jr      nc,LB612
        jr      LB62A

        ; Referenced from B60E
LB612:  cp      0xEF
        jr      c,LB61A
        jr      z,LB61A
        jr      LB62A

        ; Referenced from B614, B616
LB61A:  ld      b,0xE0
        sub     b
        ld      b,0x9F
        add     a,b
        inc     a

        ; Referenced from B606, B608
LB621:  ld      b,0x81
        sub     b
        ld      b,a
        add     a,b
        ld      b,0x21          ; '!'
        add     a,b
        ld      d,a

        ; Referenced from B610, B618
LB62A:  ld      a,e
        cp      0x40            ; '@'
        jr      nc,LB631
        jr      LB639

        ; Referenced from B62D
LB631:  cp      0x7E            ; '~'
        jr      c,LB64E
        jr      z,LB64E
        jr      LB639

        ; Referenced from B62F, B637
LB639:  cp      0x80
        jr      nc,LB643
        jr      z,LB643
        ld      de,0x2121
        ret

        ; Referenced from B63B, B63D
LB643:  cp      0xFC
        jr      c,LB64D
        jr      z,LB64D
        ld      de,0x2121
        ret

        ; Referenced from B645, B647
LB64D:  dec     a

        ; Referenced from B633, B635
LB64E:  cp      0x9E
        jr      c,LB659
        inc     d
        ld      b,0x9E
        sub     b
        ld      b,0x40          ; '@'
        add     a,b

        ; Referenced from B650
LB659:  ld      b,0x40          ; '@'
        sub     b
        ld      b,0x21          ; '!'
        add     a,b
        ld      e,a
        ret

        ; Referenced from B43A
        ; --- START PROC LB661 ---
LB661:  ld      hl,(LB431+1)    ; reference not aligned to instruction
        ld      b,0x10
        ld      c,0x59          ; 'Y'
        jp      LB512

LB66B:  ld      hl,(LB543+1)    ; reference not aligned to instruction
        ld      a,(LB54F+1)     ; reference not aligned to instruction
        add     a,a
        ld      b,a

        ; Referenced from BF6E, BF7C, BF92, C18F
LB673:  ld      c,0x0A
        jp      LB512

LB678:  nop
        jr      nz,LB69A+1      ; reference not aligned to instruction
        jr      nz,LB69D
        jr      nz,LB69E+1      ; reference not aligned to instruction
        jr      nz,LB6A1
        ld      c,c
        ld      c,(hl)
        ld      b,e
        jr      nz,LB6A5+1      ; reference not aligned to instruction
        jr      nz,LB6A7+1      ; reference not aligned to instruction
        jr      nz,LB6CE
        ld      b,l
        dec     c
        jr      nz,LB6AD+1      ; reference not aligned to instruction
        jr      nz,LB6AF+1      ; reference not aligned to instruction
        jr      nz,LB6B1+1      ; reference not aligned to instruction
        jr      nz,LB6B4
        ld      c,h
        ld      b,h
        jr      nz,LB6B7+1      ; reference not aligned to instruction
        jr      nz,LB6B9+1      ; reference not aligned to instruction

        ; Referenced from B679
LB69A:  jr      nz,LB6BB+1      ; reference not aligned to instruction
        ld      b,c

        ; Referenced from B67B
LB69D:  inc     l

        ; Referenced from B67D
LB69E:  jr      z,LB6E4
        ld      b,l

        ; Referenced from B67F
LB6A1:  add     hl,hl
        dec     c
        jr      nz,LB6C5

        ; Referenced from B684
LB6A5:  jr      nz,LB6C7

        ; Referenced from B686
LB6A7:  jr      nz,LB6C9
        jr      nz,LB6CB
        ld      c,a
        ld      d,d

        ; Referenced from B68C
LB6AD:  jr      nz,LB6CF

        ; Referenced from B68E
LB6AF:  jr      nz,LB6D0+1      ; reference not aligned to instruction

        ; Referenced from B690
LB6B1:  jr      nz,LB6D3
        ld      b,d

        ; Referenced from B692
LB6B4:  dec     c
        jr      nz,LB6D7

        ; Referenced from B696
LB6B7:  jr      nz,LB6D9

        ; Referenced from B698
LB6B9:  jr      nz,LB6DB

        ; Referenced from B69A
LB6BB:  jr      nz,LB6DD
        ld      b,h
        ld      b,l
        ld      b,e
        nop
        nop

        ; Referenced from B700
LB6C2:  nop
        nop
        nop

        ; Referenced from B6A3
LB6C5:  nop
        nop

        ; Referenced from B6A5
LB6C7:  nop
        nop

        ; Referenced from B6A7
LB6C9:  nop
        nop

        ; Referenced from B6A9
LB6CB:  nop
        nop
        nop

        ; Referenced from B688
LB6CE:  nop

        ; Referenced from B6AD
LB6CF:  nop

        ; Referenced from B6AF
LB6D0:  jr      nz,LB71E
        ld      b,h

        ; Referenced from B6B1
LB6D3:  jr      nz,LB6F5
        jr      nz,LB6F7

        ; Referenced from B6B5
LB6D7:  jr      nz,LB6F9

        ; Referenced from B6B7
LB6D9:  jr      z,LB721+2       ; reference not aligned to instruction

        ; Referenced from B6B9
LB6DB:  ld      c,h
        add     hl,hl

        ; Referenced from B6BB
LB6DD:  inc     l
        ld      b,c
        dec     c
        nop
        nop
        nop
        nop

        ; Referenced from B69E, B71F
LB6E4:  nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop

        ; Referenced from B6D3
LB6F5:  nop
        nop

        ; Referenced from B6D5
LB6F7:  nop
        nop

        ; Referenced from B6D7
LB6F9:  nop
        nop
        nop
        nop
        nop
        nop
        nop

        ; Referenced from B738
LB700:  djnz    LB6C2

        ; Referenced from B72C, B73E
LB702:  jr      nc,LB724

        ; Referenced from B732
LB704:  ld      e,h

        ; Referenced from B783
LB705:  ld      b,b
        ret     nz

        ; Referenced from B777, B789
LB707:  jr      nc,LB729

        ; Referenced from B77D
LB709:  ld      e,h

        ; Referenced from B7C2
LB70A:  nop
        ret     nz

        ; Referenced from B7C5, B7CB
LB70C:  jr      nc,LB72C+2      ; reference not aligned to instruction

        ; Referenced from B7D9, B7FC
LB70E:  ld      e,h

        ; Referenced from B7CF
LB70F:  ld      e,l

        ; Referenced from B81A
LB710:  nop

        ; Referenced from B81D, B824
LB711:  jp      z,0x2030

        ; Referenced from B832, B855
LB714:  ld      e,h

        ; Referenced from B828
LB715:  ld      e,l

        ; Referenced from B73B, B75D, B764, B786, B7A8, B7AF, B7E0, B803, B839, B85C, B873, B895, B8AB
LB716:  jr      nz,LB738

        ; Referenced from B741, B767, B76C, B78C, B7B2, B7B7, B7E3, B806, B83C, B85F, B876, B88A, B89F
LB718:  jr      nz,LB738+2      ; reference not aligned to instruction
        dec     sp
        jr      nz,LB767+1      ; reference not aligned to instruction
        ld      b,l

        ; Referenced from B6D0
LB71E:  ld      e,c
        jr      nz,LB6E4

        ; Referenced from B6D9
LB721:  jp      nz,LC3B7

        ; Referenced from B702
LB724:  ld      a,(de)
        cp      b
        jp      LB777

        ; Referenced from B707, BB00
LB729:  jp      LB8B6

        ; Referenced from B70C
LB72C:  ld      a,(LB702)
        ld      (LB744+1),a     ; reference not aligned to instruction
        ld      a,(LB704)
        ld      (LB74A+1),a     ; reference not aligned to instruction

        ; Referenced from B716, B718
LB738:  ld      hl,(LB700)
        ld      (LB716),hl
        ld      a,(LB702+1)     ; reference not aligned to instruction
        ld      (LB718),a

        ; Referenced from B72F, B76F
LB744:  ld      b,0x00
        ld      d,h
        ld      e,l
        inc     de

        ; Referenced from B75B
LB749:  di

        ; Referenced from B735
LB74A:  out     (0x5C),a        ; '\'
        ld      a,(de)
        bit     7,a
        jr      z,LB771
        ld      a,(hl)
        rla
        set     0,a

        ; Referenced from B775
LB755:  ld      (hl),a
        out     (0x5F),a        ; '_'
        ei
        inc     hl
        inc     de
        djnz    LB749
        ld      hl,(LB716)
        ld      de,0x0050
        add     hl,de
        ld      (LB716),hl

        ; Referenced from B71B
LB767:  ld      a,(LB718)
        dec     a
        ret     z
        ld      (LB718),a
        jr      LB744

        ; Referenced from B74F
LB771:  ld      a,(hl)
        rla
        res     0,a
        jr      LB755

        ; Referenced from B726
LB777:  ld      a,(LB707)
        ld      (LB78F+1),a     ; reference not aligned to instruction
        ld      a,(LB709)

        ; Referenced from C060, C098
LB780:  ld      (LB795+1),a     ; reference not aligned to instruction
        ld      hl,(LB705)
        ld      (LB716),hl
        ld      a,(LB707+1)     ; reference not aligned to instruction
        ld      (LB718),a

        ; Referenced from B77A, B7BA
LB78F:  ld      b,0x00
        ld      d,h
        ld      e,l
        dec     de

        ; Referenced from B7A6
LB794:  di

        ; Referenced from B780
LB795:  out     (0x5C),a        ; '\'
        ld      a,(de)
        bit     0,a
        jr      z,LB7BC
        ld      a,(hl)
        rra
        set     7,a

        ; Referenced from B7C0
LB7A0:  ld      (hl),a
        out     (0x5F),a        ; '_'
        ei
        dec     hl
        dec     de
        djnz    LB794
        ld      hl,(LB716)
        ld      de,0x0050
        add     hl,de
        ld      (LB716),hl
        ld      a,(LB718)
        dec     a
        ret     z
        ld      (LB718),a
        jr      LB78F

        ; Referenced from B79A
LB7BC:  ld      a,(hl)
        rra
        res     7,a
        jr      LB7A0

LB7C2:  ld      hl,(LB70A)
        ld      a,(LB70C)
        call    LB880
        ld      a,(LB70C+1)     ; reference not aligned to instruction
        ld      b,a
        ld      a,(LB70F)
        cp      0x00
        jr      z,LB7FC
        ld      (LB7ED+1),a     ; reference not aligned to instruction
        ld      a,(LB70E)
        ld      (LB7E8+1),a     ; reference not aligned to instruction

        ; Referenced from B7F9
LB7DF:  push    bc
        ld      (LB716),hl
        ld      (LB718),de
        di

        ; Referenced from B7DC
LB7E8:  out     (0x5C),a        ; '\'
        call    LB87A

        ; Referenced from B7D6
LB7ED:  out     (0x5E),a        ; '^'
        call    LB873
        out     (0x5F),a        ; '_'
        ei
        call    LB88A
        pop     bc
        djnz    LB7DF
        ret

        ; Referenced from B7D4
LB7FC:  ld      a,(LB70E)
        ld      (LB80B+1),a     ; reference not aligned to instruction

        ; Referenced from B817
LB802:  push    bc
        ld      (LB716),hl
        ld      (LB718),de
        di

        ; Referenced from B7FF
LB80B:  out     (0x5C),a        ; '\'
        call    LB87A
        out     (0x5F),a        ; '_'
        ei
        call    LB88A
        pop     bc
        djnz    LB802
        ret

LB81A:  ld      hl,(LB710)
        ld      a,(LB711+1)     ; reference not aligned to instruction
        call    LB880
        ex      de,hl
        ld      a,(LB711+2)     ; reference not aligned to instruction
        ld      b,a
        ld      a,(LB715)
        cp      0x00
        jr      z,LB855
        ld      (LB846+1),a     ; reference not aligned to instruction
        ld      a,(LB714)
        ld      (LB841+1),a     ; reference not aligned to instruction

        ; Referenced from B852
LB838:  push    bc
        ld      (LB716),hl
        ld      (LB718),de
        di

        ; Referenced from B835
LB841:  out     (0x5C),a        ; '\'
        call    LB87A

        ; Referenced from B82F
LB846:  out     (0x5E),a        ; '^'
        call    LB873
        out     (0x5F),a        ; '_'
        ei
        call    LB89F
        pop     bc
        djnz    LB838
        ret

        ; Referenced from B82D
LB855:  ld      a,(LB714)
        ld      (LB864+1),a     ; reference not aligned to instruction

        ; Referenced from B870
LB85B:  push    bc
        ld      (LB716),hl
        ld      (LB718),de
        di

        ; Referenced from B858
LB864:  out     (0x5C),a        ; '\'
        call    LB87A
        out     (0x5F),a        ; '_'
        ei
        call    LB89F
        pop     bc
        djnz    LB85B
        ret

        ; Referenced from B7EF, B848
        ; --- START PROC LB873 ---
LB873:  ld      hl,(LB716)
        ld      de,(LB718)

        ; Referenced from B7EA, B80D, B843, B866, B886
        ; --- START PROC LB87A ---
LB87A:  ld      bc,0x0028
        ldir
        ret

        ; Referenced from B7C8, B820
        ; --- START PROC LB880 ---
LB880:  push    hl
        ld      de,0x0050
        add     hl,de
        pop     de
        ld      (LB87A+1),a     ; reference not aligned to instruction
        ret

        ; Referenced from B7F5, B813
        ; --- START PROC LB88A ---
LB88A:  ld      de,(LB718)
        ld      h,d
        ld      l,e
        ld      de,0x0050
        add     hl,de
        ex      de,hl
        ld      hl,(LB716)
        push    de
        ld      de,0x0050
        add     hl,de
        pop     de
        ret

        ; Referenced from B84E, B86C
        ; --- START PROC LB89F ---
LB89F:  ld      de,(LB718)
        ld      h,d
        ld      l,e
        ld      de,0x0050
        sbc     hl,de
        ex      de,hl
        ld      hl,(LB716)
        push    de
        ld      de,0x0050
        sbc     hl,de
        pop     de
        ret

        ; Referenced from B729
LB8B6:  ld      hl,(LB9CE)
        ld      (LB8C6+1),hl    ; reference not aligned to instruction
        inc     hl
        inc     hl
        ld      (LB8C9+2),hl    ; reference not aligned to instruction
        ld      a,0x7B          ; '{'
        di
        out     (0x31),a        ; '1'

        ; Referenced from B8B9
LB8C6:  ld      hl,(0x0000)

        ; Referenced from B8BE
LB8C9:  ld      bc,(0x0000)
        ld      a,0x79          ; 'y'
        out     (0x31),a        ; '1'
        ei
        push    hl
        push    bc
        call    LB8E6
        pop     bc
        pop     hl
        push    bc
        dec     c
        ld      d,0x00
        ld      e,c
        call    LB8FA
        pop     bc
        call    LB8E6
        ret

        ; Referenced from B8D4, B8E2
        ; --- START PROC LB8E6 ---
LB8E6:  ld      b,c
        ld      a,0xFF

        ; Referenced from B8F7
LB8E9:  di
        out     (0x5C),a        ; '\'
        ld      (hl),a
        out     (0x5D),a        ; ']'
        ld      (hl),a
        out     (0x5E),a        ; '^'
        ld      (hl),a
        out     (0x5F),a        ; '_'
        ei
        inc     hl
        djnz    LB8E9
        ret

        ; Referenced from B8DE, B92F
        ; --- START PROC LB8FA ---
LB8FA:  push    hl
        di
        out     (0x5C),a        ; '\'
        ld      a,(hl)
        set     7,a
        ld      (hl),a
        out     (0x5D),a        ; ']'
        ld      a,(hl)
        set     7,a
        ld      (hl),a
        out     (0x5E),a        ; '^'
        ld      a,(hl)
        set     7,a
        ld      (hl),a
        out     (0x5F),a        ; '_'
        ei
        add     hl,de
        di
        out     (0x5C),a        ; '\'
        ld      a,(hl)
        set     0,a
        ld      (hl),a
        out     (0x5D),a        ; ']'
        ld      a,(hl)
        set     0,a
        ld      (hl),a
        out     (0x5E),a        ; '^'
        ld      a,(hl)
        set     0,a
        ld      (hl),a
        out     (0x5F),a        ; '_'
        ei
        pop     hl
        push    de
        ld      de,0x0050
        add     hl,de
        pop     de
        djnz    LB8FA
        ret

LB932:  nop
        ld      (bc),a
        ldir
        jr      LB962

LB938:  jr      LB94E

LB93A:  ld      ix,0xC03D
        ld      iy,0xC050
        ld      a,0x45          ; 'E'
        ld      (LB97F+1),a     ; reference not aligned to instruction
        ld      a,0x3E          ; '>'
        ld      (LB979+1),a     ; reference not aligned to instruction
        jr      LB974

        ; Referenced from B938
LB94E:  ld      ix,0xC04F
        ld      iy,0xC050
        ld      a,0x45          ; 'E'
        ld      (LB97F+1),a     ; reference not aligned to instruction
        ld      a,0x50          ; 'P'
        ld      (LB979+1),a     ; reference not aligned to instruction
        jr      LB974

        ; Referenced from B936
LB962:  ld      ix,0xC04F
        ld      iy,0xC050
        ld      a,0x65          ; 'e'
        ld      (LB97F+1),a     ; reference not aligned to instruction
        ld      a,0x50          ; 'P'
        ld      (LB979+1),a     ; reference not aligned to instruction

        ; Referenced from B94C, B960
LB974:  push    hl
        ld      de,0x00A0
        xor     a

        ; Referenced from B949, B95D, B971
LB979:  ld      h,0x3D          ; '='

        ; Referenced from B9B1
LB97B:  push    ix
        push    iy

        ; Referenced from B944, B958, B96C
LB97F:  ld      b,0x2D          ; '-'

        ; Referenced from B9A6
LB981:  di
        ld      c,0x5C          ; '\'
        out     (c),a
        ld      (ix+0x00),a
        ld      (iy+0x00),a
        inc     c
        out     (c),a
        ld      (ix+0x00),a
        ld      (iy+0x00),a
        inc     c
        out     (c),a
        ld      (ix+0x00),a
        ld      (iy+0x00),a
        inc     c
        out     (c),a
        ei
        add     ix,de
        add     iy,de
        djnz    LB981
        pop     iy
        pop     ix
        dec     ix
        inc     iy
        dec     h
        jr      nz,LB97B
        out     (0x5F),a        ; '_'
        pop     hl
        ret

LB9B7:  nop
        nop
        nop
        nop
        nop
        nop
        nop

        ; Referenced from B9FA, BA9A, BAA1, BAC5, BE8C, BE93, BEB7
LB9BE:  dec     c

        ; Referenced from B9E4, B9E9, B9F7, BA42, BA5B, BA6C, BA8A, BAED, BDD2, BDE9, BDF8, BE14, BE3B, BE52, BE61, BE7D
LB9BF:  jp      z,LC000

        ; Referenced from B9EE, B9F3, BA4F, BA53, BA78, BA7C, BA97, BAA5, BAA9, BAB9, BDDD, BDE1, BE02, BE06, BE46, BE4A, BE6B, BE6F, BE89, BE97, BE9B, BEAB
LB9C2:  ld      bc,0x0202
        nop

        ; Referenced from BA2F, BAC8, BACE, BDBE, BE2A, BEBA, BEC0
LB9C6:  nop
        nop

        ; Referenced from B9FF, BAD1, BAD8, BDC4, BEDF, BEE3
LB9C8:  nop
        nop

        ; Referenced from BE1F, BF24
LB9CA:  nop

        ; Referenced from BE24, BF10
LB9CB:  nop
        nop
        nop

        ; Referenced from B8B6, B9D8, B9DC, BAE4, BECF
LB9CE:  nop
        ld      b,b
        xor     a
        in      a,(0x32)        ; '2'
        push    af
        ld      a,(0xE6C2)
        push    af
        ld      de,(LB9CE)
        ld      ix,(LB9CE)
        call    LBEF6
        ld      a,(de)
        ld      (LB9BF+1),a     ; reference not aligned to instruction
        inc     de
        ld      a,(de)
        ld      (LB9BF+2),a     ; reference not aligned to instruction
        inc     de
        ld      a,(de)
        ld      (LB9C2),a
        inc     de
        ld      a,(de)
        ld      (LB9C2+2),a     ; reference not aligned to instruction
        inc     de
        ld      hl,(LB9BF+1)    ; reference not aligned to instruction
        ld      (LB9BE),hl
        ld      a,0x5C          ; '\'
        ld      (LB9C8),a
        ld      a,(de)
        call    LBF00
        cp      0x00
        jp      z,LBDB6
        cp      0xF0
        jp      z,LBE19
        push    hl
        push    de
        ld      hl,0x0000
        ld      de,0x000F
        ld      b,a

        ; Referenced from BA1A
LBA19:  add     hl,de
        djnz    LBA19
        ex      de,hl
        ld      hl,0xBAF5
        add     hl,de
        ld      (LBA4B+1),hl    ; reference not aligned to instruction
        ld      hl,0xBC4E
        add     hl,de
        ld      (LBA74+1),hl    ; reference not aligned to instruction
        pop     de
        pop     hl
        ld      a,0x01
        ld      (LB9C6),a
        inc     de
        call    LBEF6

        ; Referenced from BA64, BA8D
LBA36:  xor     c
        ld      a,(de)
        bit     7,a
        jp      z,LBA40
        jp      LBA67

        ; Referenced from BA3A
LBA40:  ld      b,a
        inc     de
        ld      hl,(LB9BF+1)    ; reference not aligned to instruction
        ld      a,(de)
        ld      c,a
        inc     de

        ; Referenced from BA59
LBA48:  ld      a,c
        and     0xAA

        ; Referenced from BA21
LBA4B:  jp      0x0000

        ; Referenced from BB0F, BB1E, BB2C, BB3C, BB4A, BB59, BB67, BB76, BB85, BB94, BBA3, BBB2, BBC1, BBD1, BBE0, BBEF, BBFF, BC0E, BC1C, BC2C, BC3A, BC49, BC57
LBA4E:  inc     hl
        ld      a,(LB9C2)
        dec     a
        ld      (LB9C2),a
        call    z,LBA90
        djnz    LBA48
        ld      (LB9BF+1),hl    ; reference not aligned to instruction
        ld      a,d
        cp      0xFF
        jp      z,LBAE1
        jp      LBA36

        ; Referenced from BA3D
LBA67:  ld      h,0x80
        sbc     a,h
        ld      b,a
        inc     de
        ld      hl,(LB9BF+1)    ; reference not aligned to instruction

        ; Referenced from BA88
LBA6F:  ld      a,(de)
        ld      c,a
        and     0xAA
        inc     de

        ; Referenced from BA28
LBA74:  jp      0x0000

        ; Referenced from BC68, BC77, BC85, BC95, BCA3, BCB2, BCC0, BCCF, BCDE, BCED, BCFC, BD0B, BD1A, BD2A, BD39, BD48, BD58, BD67, BD75, BD85, BD93, BDA2, BDB0
LBA77:  inc     hl
        ld      a,(LB9C2)
        dec     a
        ld      (LB9C2),a
        call    z,LBA90
        ld      a,d
        cp      0xFF
        jp      z,LBAE1

        ; Referenced from C080
LBA88:  djnz    LBA6F
        ld      (LB9BF+1),hl    ; reference not aligned to instruction
        jp      LBA36

        ; Referenced from BA56, BA7F, BDE4, BE09
        ; --- START PROC LBA90 ---
LBA90:  push    de
        ld      a,(ix+0x02)
        call    LBF00
        ld      (LB9C2),a
        ld      hl,(LB9BE)
        ld      de,0x0050
        add     hl,de
        ld      (LB9BE),hl
        pop     de
        ld      a,(LB9C2+2)     ; reference not aligned to instruction
        dec     a
        ld      (LB9C2+2),a     ; reference not aligned to instruction
        call    z,LBAB3
        call    LBEF6
        ret

        ; Referenced from BAAC
        ; --- START PROC LBAB3 ---
LBAB3:  call    LBEF6
        ld      a,(ix+0x03)
        ld      (LB9C2+2),a     ; reference not aligned to instruction
        ld      h,(ix+0x01)
        ld      l,(ix+0x00)
        call    LBF00
        ld      (LB9BE),hl
        ld      a,(LB9C6)
        dec     a
        jr      z,LBADC
        ld      (LB9C6),a
        ld      a,(LB9C8)
        inc     a
        ld      (LBEFC+1),a     ; reference not aligned to instruction
        ld      (LB9C8),a
        ret

        ; Referenced from BACC
LBADC:  ld      d,0xFF
        ld      b,0x01
        ret

        ; Referenced from BA61, BA85, BDEF, BE0F, BEF3
LBAE1:  call    LBEF6
        ld      hl,(LB9CE)
        ld      (LBAEA+1),hl    ; reference not aligned to instruction

        ; Referenced from BAE7
LBAEA:  ld      hl,(0x0000)
        ld      (LB9BF+1),hl    ; reference not aligned to instruction
        call    LBF00
        pop     af
        out     (0x31),a        ; '1'
        pop     af
        out     (0x32),a        ; '2'
        out     (0x71),a        ; 'q'
        ld      a,(LC3FE+1)     ; reference not aligned to instruction
        cp      0x12
        jp      z,LB729
        ret

LBB04:  out     (0x5C),a        ; '\'
        ld      (hl),c
        out     (0x5D),a        ; ']'
        ld      (hl),0x00
        out     (0x5E),a        ; '^'
        ld      (hl),0x00
        jp      LBA4E

LBB12:  nop
        out     (0x5C),a        ; '\'
        ld      (hl),0x00
        out     (0x5D),a        ; ']'
        ld      (hl),c
        out     (0x5E),a        ; '^'
        ld      (hl),0x00
        jp      LBA4E

LBB21:  nop
        out     (0x5C),a        ; '\'
        ld      (hl),c
        out     (0x5D),a        ; ']'
        ld      (hl),c
        out     (0x5E),a        ; '^'
        ld      (hl),0x00
        jp      LBA4E

LBB2F:  nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),0x00
        out     (0x5D),a        ; ']'
        ld      (hl),0x00
        out     (0x5E),a        ; '^'
        ld      (hl),c
        jp      LBA4E

LBB3F:  nop
        out     (0x5C),a        ; '\'
        ld      (hl),c
        out     (0x5D),a        ; ']'
        ld      (hl),0x00
        out     (0x5E),a        ; '^'
        ld      (hl),c
        jp      LBA4E

LBB4D:  nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),0x00
        out     (0x5D),a        ; ']'
        ld      (hl),c
        out     (0x5E),a        ; '^'
        ld      (hl),c
        jp      LBA4E

LBB5C:  nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),c
        out     (0x5D),a        ; ']'
        ld      (hl),c
        out     (0x5E),a        ; '^'
        ld      (hl),c
        jp      LBA4E

LBB6A:  nop
        nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),c
        out     (0x5D),a        ; ']'
        ld      (hl),a
        out     (0x5E),a        ; '^'
        ld      (hl),c
        jp      LBA4E

LBB79:  nop
        nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),c
        out     (0x5D),a        ; ']'
        ld      (hl),c
        out     (0x5E),a        ; '^'
        ld      (hl),a
        jp      LBA4E

LBB88:  nop
        nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),a
        out     (0x5D),a        ; ']'
        ld      (hl),c
        out     (0x5E),a        ; '^'
        ld      (hl),c
        jp      LBA4E

LBB97:  nop
        nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),c
        out     (0x5D),a        ; ']'
        ld      (hl),a
        out     (0x5E),a        ; '^'
        ld      (hl),a
        jp      LBA4E

LBBA6:  nop
        nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),a
        out     (0x5D),a        ; ']'
        ld      (hl),a
        out     (0x5E),a        ; '^'
        ld      (hl),c
        jp      LBA4E

LBBB5:  nop
        nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),a
        out     (0x5D),a        ; ']'
        ld      (hl),c
        out     (0x5E),a        ; '^'
        ld      (hl),a
        jp      LBA4E

LBBC4:  nop
        nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),0x00
        out     (0x5D),a        ; ']'
        ld      (hl),a
        out     (0x5E),a        ; '^'
        ld      (hl),c
        jp      LBA4E

LBBD4:  nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),a
        out     (0x5D),a        ; ']'
        ld      (hl),c
        out     (0x5E),a        ; '^'
        ld      (hl),0x00
        jp      LBA4E

LBBE3:  nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),c
        out     (0x5D),a        ; ']'
        ld      (hl),0x00
        out     (0x5E),a        ; '^'
        ld      (hl),a
        jp      LBA4E

LBBF2:  nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),a
        out     (0x5D),a        ; ']'
        ld      (hl),0x00
        out     (0x5E),a        ; '^'
        ld      (hl),0x00
        jp      LBA4E

LBC02:  nop
        out     (0x5C),a        ; '\'
        ld      (hl),0x00
        out     (0x5D),a        ; ']'
        ld      (hl),a
        out     (0x5E),a        ; '^'
        ld      (hl),0x00
        jp      LBA4E

LBC11:  nop
        out     (0x5C),a        ; '\'
        ld      (hl),a
        out     (0x5D),a        ; ']'
        ld      (hl),a
        out     (0x5E),a        ; '^'
        ld      (hl),0x00
        jp      LBA4E

LBC1F:  nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),0x00
        out     (0x5D),a        ; ']'
        ld      (hl),0x00
        out     (0x5E),a        ; '^'
        ld      (hl),a
        jp      LBA4E

LBC2F:  nop
        out     (0x5C),a        ; '\'
        ld      (hl),a
        out     (0x5D),a        ; ']'
        ld      (hl),0x00
        out     (0x5E),a        ; '^'
        ld      (hl),a
        jp      LBA4E

LBC3D:  nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),0x00
        out     (0x5D),a        ; ']'
        ld      (hl),a
        out     (0x5E),a        ; '^'
        ld      (hl),a
        jp      LBA4E

LBC4C:  nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),a
        out     (0x5D),a        ; ']'
        ld      (hl),a
        out     (0x5E),a        ; '^'
        ld      (hl),a
        jp      LBA4E

LBC5A:  nop
        nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),c
        out     (0x5D),a        ; ']'
        ld      (hl),0x00
        out     (0x5E),a        ; '^'
        ld      (hl),0x00
        jp      LBA77

LBC6B:  nop
        out     (0x5C),a        ; '\'
        ld      (hl),0x00
        out     (0x5D),a        ; ']'
        ld      (hl),c
        out     (0x5E),a        ; '^'
        ld      (hl),0x00
        jp      LBA77

LBC7A:  nop
        out     (0x5C),a        ; '\'
        ld      (hl),c
        out     (0x5D),a        ; ']'
        ld      (hl),c
        out     (0x5E),a        ; '^'
        ld      (hl),0x00
        jp      LBA77

LBC88:  nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),0x00
        out     (0x5D),a        ; ']'
        ld      (hl),0x00
        out     (0x5E),a        ; '^'
        ld      (hl),c
        jp      LBA77

LBC98:  nop
        out     (0x5C),a        ; '\'
        ld      (hl),c
        out     (0x5D),a        ; ']'
        ld      (hl),0x00
        out     (0x5E),a        ; '^'
        ld      (hl),c
        jp      LBA77

LBCA6:  nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),0x00
        out     (0x5D),a        ; ']'
        ld      (hl),c
        out     (0x5E),a        ; '^'
        ld      (hl),c
        jp      LBA77

LBCB5:  nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),c
        out     (0x5D),a        ; ']'
        ld      (hl),c
        out     (0x5E),a        ; '^'
        ld      (hl),c
        jp      LBA77

LBCC3:  nop
        nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),c
        out     (0x5D),a        ; ']'
        ld      (hl),a
        out     (0x5E),a        ; '^'
        ld      (hl),c
        jp      LBA77

LBCD2:  nop
        nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),c
        out     (0x5D),a        ; ']'
        ld      (hl),c
        out     (0x5E),a        ; '^'
        ld      (hl),a
        jp      LBA77

LBCE1:  nop
        nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),a
        out     (0x5D),a        ; ']'
        ld      (hl),c
        out     (0x5E),a        ; '^'
        ld      (hl),c
        jp      LBA77

LBCF0:  nop
        nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),c
        out     (0x5D),a        ; ']'
        ld      (hl),a
        out     (0x5E),a        ; '^'
        ld      (hl),a
        jp      LBA77

LBCFF:  nop
        nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),a
        out     (0x5D),a        ; ']'
        ld      (hl),a
        out     (0x5E),a        ; '^'
        ld      (hl),c
        jp      LBA77

LBD0E:  nop
        nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),a
        out     (0x5D),a        ; ']'
        ld      (hl),c
        out     (0x5E),a        ; '^'
        ld      (hl),a
        jp      LBA77

LBD1D:  nop
        nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),0x00
        out     (0x5D),a        ; ']'
        ld      (hl),a
        out     (0x5E),a        ; '^'
        ld      (hl),c
        jp      LBA77

LBD2D:  nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),a
        out     (0x5D),a        ; ']'
        ld      (hl),c
        out     (0x5E),a        ; '^'
        ld      (hl),0x00
        jp      LBA77

LBD3C:  nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),c
        out     (0x5D),a        ; ']'
        ld      (hl),0x00
        out     (0x5E),a        ; '^'
        ld      (hl),a
        jp      LBA77

LBD4B:  nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),a
        out     (0x5D),a        ; ']'
        ld      (hl),0x00
        out     (0x5E),a        ; '^'
        ld      (hl),0x00
        jp      LBA77

LBD5B:  nop
        out     (0x5C),a        ; '\'
        ld      (hl),0x00
        out     (0x5D),a        ; ']'
        ld      (hl),a
        out     (0x5E),a        ; '^'
        ld      (hl),0x00
        jp      LBA77

LBD6A:  nop
        out     (0x5C),a        ; '\'
        ld      (hl),a
        out     (0x5D),a        ; ']'
        ld      (hl),a
        out     (0x5E),a        ; '^'
        ld      (hl),0x00
        jp      LBA77

LBD78:  nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),0x00
        out     (0x5D),a        ; ']'
        ld      (hl),0x00
        out     (0x5E),a        ; '^'
        ld      (hl),a
        jp      LBA77

LBD88:  nop
        out     (0x5C),a        ; '\'
        ld      (hl),a
        out     (0x5D),a        ; ']'
        ld      (hl),0x00
        out     (0x5E),a        ; '^'
        ld      (hl),a
        jp      LBA77

LBD96:  nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),0x00
        out     (0x5D),a        ; ']'
        ld      (hl),a
        out     (0x5E),a        ; '^'
        ld      (hl),a
        jp      LBA77

LBDA5:  nop
        nop
        out     (0x5C),a        ; '\'
        ld      (hl),a
        out     (0x5D),a        ; ']'
        ld      (hl),a
        out     (0x5E),a        ; '^'
        ld      (hl),a
        jp      LBA77

LBDB3:  nop
        nop
        nop

        ; Referenced from BA08
LBDB6:  ld      a,0x5C          ; '\'
        ld      (LBEFC+1),a     ; reference not aligned to instruction
        inc     de
        ld      a,0x03
        ld      (LB9C6),a
        call    LBEF6
        ld      a,(LB9C8)

        ; Referenced from BDF2, BE17
LBDC7:  xor     c
        ld      a,(de)
        call    LBF00
        bit     7,a
        jr      nz,LBDF4
        ld      b,a
        inc     de
        ld      hl,(LB9BF+1)    ; reference not aligned to instruction
        call    LBEF6
        ld      a,(de)
        inc     de
        ld      c,a

        ; Referenced from BDE7
LBDDB:  ld      (hl),c
        inc     hl
        ld      a,(LB9C2)
        dec     a
        ld      (LB9C2),a
        call    z,LBA90
        djnz    LBDDB
        ld      (LB9BF+1),hl    ; reference not aligned to instruction
        ld      a,d
        cp      0xFF
        jp      z,LBAE1
        jr      LBDC7

        ; Referenced from BDCE
LBDF4:  sub     0x80
        ld      b,a
        inc     de
        ld      hl,(LB9BF+1)    ; reference not aligned to instruction
        call    LBEF6

        ; Referenced from BE12
LBDFE:  ld      a,(de)
        inc     de
        ld      (hl),a
        inc     hl
        ld      a,(LB9C2)
        dec     a
        ld      (LB9C2),a
        call    z,LBA90
        ld      a,d
        cp      0xFF
        jp      z,LBAE1
        djnz    LBDFE
        ld      (LB9BF+1),hl    ; reference not aligned to instruction
        jr      LBDC7

        ; Referenced from BA0D
LBE19:  xor     a
        ld      (LBF19+1),a     ; reference not aligned to instruction
        in      a,(0x32)        ; '2'
        ld      (LB9CA),a
        or      0x40            ; '@'
        ld      (LB9CB),a
        inc     de
        ld      a,0x06
        ld      (LB9C6),a
        call    LBF0A

        ; Referenced from BE5B, BE80
LBE30:  xor     c
        ld      a,(de)
        call    LBF1F
        bit     7,a
        jr      nz,LBE5D
        ld      b,a
        inc     de
        ld      hl,(LB9BF+1)    ; reference not aligned to instruction
        call    LBF0A
        ld      a,(de)
        inc     de
        ld      c,a

        ; Referenced from BE50
LBE44:  ld      (hl),c
        inc     hl
        ld      a,(LB9C2)
        dec     a
        ld      (LB9C2),a
        call    z,LBE82
        djnz    LBE44
        ld      (LB9BF+1),hl    ; reference not aligned to instruction
        ld      a,d
        cp      0xFF
        jp      z,LBEF0
        jr      LBE30

        ; Referenced from BE37
LBE5D:  sub     0x80
        ld      b,a
        inc     de
        ld      hl,(LB9BF+1)    ; reference not aligned to instruction
        call    LBF0A

        ; Referenced from BE7B
LBE67:  ld      a,(de)
        inc     de
        ld      (hl),a
        inc     hl
        ld      a,(LB9C2)
        dec     a
        ld      (LB9C2),a
        call    z,LBE82
        ld      a,d
        cp      0xFF
        jp      z,LBEF0
        djnz    LBE67
        ld      (LB9BF+1),hl    ; reference not aligned to instruction
        jr      LBE30

        ; Referenced from BE4D, BE72
        ; --- START PROC LBE82 ---
LBE82:  push    de
        ld      a,(ix+0x02)
        call    LBF1F
        ld      (LB9C2),a
        ld      hl,(LB9BE)
        ld      de,0x0050
        add     hl,de
        ld      (LB9BE),hl
        pop     de
        ld      a,(LB9C2+2)     ; reference not aligned to instruction
        dec     a
        ld      (LB9C2+2),a     ; reference not aligned to instruction
        call    z,LBEA5
        call    LBF0A
        ret

        ; Referenced from BE9E
        ; --- START PROC LBEA5 ---
LBEA5:  call    LBF0A
        ld      a,(ix+0x03)

        ; Referenced from C00B
        ; --- START PROC LBEAB ---
LBEAB:  ld      (LB9C2+2),a     ; reference not aligned to instruction
        ld      h,(ix+0x01)
        ld      l,(ix+0x00)
        call    LBF1F
        ld      (LB9BE),hl
        ld      a,(LB9C6)
        dec     a
        jr      z,LBECA
        ld      (LB9C6),a
        cp      0x03
        jr      z,LBECF
        jr      c,LBEDF
        ret

        ; Referenced from BEBE
LBECA:  ld      d,0xFF
        ld      b,0x01
        ret

        ; Referenced from BEC5
LBECF:  ld      de,(LB9CE)
        inc     de
        inc     de
        inc     de
        inc     de
        inc     de
        ld      a,0x01
        ld      b,0x01
        jr      LBEE3

LBEDE:  ret

        ; Referenced from BEC7
LBEDF:  ld      a,(LB9C8)
        rlca

        ; Referenced from BEDC, C008
LBEE3:  ld      (LB9C8),a
        rlca
        rlca
        rlca
        rlca
        xor     0xFF
        ld      (LBF19+1),a     ; reference not aligned to instruction
        ret

        ; Referenced from BE58, BE78
LBEF0:  xor     a
        out     (0x35),a        ; '5'
        jp      LBAE1

        ; Referenced from B9E0, BA33, BAAF, BAB3, BAE1, BDC1, BDD5, BDFB
        ; --- START PROC LBEF6 ---
LBEF6:  di
        push    af
        ld      a,0x7B          ; '{'
        out     (0x31),a        ; '1'

        ; Referenced from BAD5, BDB8
LBEFC:  out     (0x5C),a        ; '\'
        pop     af
        ret

        ; Referenced from BA03, BA94, BAC2, BAF0, BDC9
        ; --- START PROC LBF00 ---
LBF00:  push    af
        ld      a,0x79          ; 'y'
        out     (0x31),a        ; '1'
        out     (0x5F),a        ; '_'
        pop     af
        ei
        ret

        ; Referenced from BE2D, BE3E, BE64, BEA1, BEA5
        ; --- START PROC LBF0A ---
LBF0A:  di
        push    af
        ld      a,0x7B          ; '{'
        out     (0x31),a        ; '1'
        ld      a,(LB9CB)
        out     (0x32),a        ; '2'
        ld      a,0x80
        out     (0x35),a        ; '5'

        ; Referenced from BE1A, BEEC
LBF19:  ld      a,0x00

        ; Referenced from BF68
LBF1B:  out     (0x34),a        ; '4'
        pop     af
        ret

        ; Referenced from BE32, BE86, BEB4
        ; --- START PROC LBF1F ---
LBF1F:  push    af
        ld      a,0x79          ; 'y'
        out     (0x31),a        ; '1'
        ld      a,(LB9CA)
        out     (0x32),a        ; '2'
        out     (0x5F),a        ; '_'
        pop     af
        ei
        ret

LBF2E:  nop
        nop
        nop
        nop
        nop
        adc     a,h
        ret     nz
        call    LBF6A
        ld      bc,0x4F0E
        jr      LBF55

LBF3D:  ld      a,0x51          ; 'Q'
        ld      (LC08C),a
        call    LBF6A
        ld      bc,0x4F0D
        jr      LBF55

LBF4A:  ld      a,0x52          ; 'R'
        ld      (LC08C),a
        call    LBF6A
        ld      bc,0x4F0C

        ; Referenced from BF3B, BF48
LBF55:  call    LBFAE
        push    hl
        push    bc
        ld      hl,0xC04E
        call    0x5ACA
        ld      h,d
        ld      l,e
        pop     bc
        scf
        call    0x369A
        pop     hl
        jr      LBF1B

        ; Referenced from BF35, BF42, BF4F
        ; --- START PROC LBF6A ---
LBF6A:  ld      de,(LB543+1)    ; reference not aligned to instruction
        ld      a,(LB673+1)     ; reference not aligned to instruction
        push    de
        push    af
        ld      de,0xF5CA
        ld      (LB543+1),de    ; reference not aligned to instruction
        ld      a,0x10
        ld      (LB673+1),a     ; reference not aligned to instruction
        ld      a,0x1E
        ld      (LB41C),a
        ld      de,0xC053
        ld      (LB412),de
        push    hl
        call    LB420
        pop     hl
        pop     af
        pop     de
        ld      (LB673+1),a     ; reference not aligned to instruction
        ld      (LB543+1),de    ; reference not aligned to instruction
        ret

LBF9A:  push    hl
        push    bc
        call    0x35D9
        pop     bc
        pop     hl
        ld      a,0xFF
        ld      (LC8FF),a

        ; Referenced from BFAB
LBFA6:  ld      a,(LC8FF)
        cp      0xFF
        jr      z,LBFA6
        ret

        ; Referenced from BF55
        ; --- START PROC LBFAE ---
LBFAE:  push    hl
        ld      hl,0xFFFF

        ; Referenced from BFB5
LBFB2:  dec     hl
        ld      a,h
        or      l
        jr      nz,LBFB2
        pop     hl
        ret

LBFB9:  inc     hl
        inc     hl
        push    hl
        push    hl
        ld      hl,0xC04E
        call    0x5ACA
        in      a,(0x70)        ; 'p'
        ld      c,a
        pop     hl
        ld      a,(hl)
        inc     hl
        cp      0x11

        ; Referenced from ACA7
LBFCB:  jr      z,LBFD9
        cp      0x12
        jr      z,LBFEA
        cp      0x13
        jr      z,LC001
        pop     hl
        jp      0x0393

        ; Referenced from BFCB
LBFD9:  ld      a,0x80
        out     (0x70),a        ; 'p'
        ld      hl,0x8000
        ld      b,0x7F          ; ''

        ; Referenced from BFE6
LBFE2:  ld      a,(de)
        ld      (hl),a
        inc     hl
        inc     de
        djnz    LBFE2
        jr      LBFFB

        ; Referenced from BFCF
LBFEA:  ld      a,0x80
        out     (0x70),a        ; 'p'

        ; Referenced from C06A
LBFEE:  ld      hl,0x8000
        ld      b,0x7F          ; ''

        ; Referenced from BFF7
LBFF3:  ld      a,(hl)
        ld      (de),a
        inc     hl
        inc     de
        djnz    LBFF3
        jr      LBFFB

        ; Referenced from BFE8, BFF9
LBFFB:  ld      a,c
        out     (0x70),a        ; 'p'
        pop     hl
        inc     hl

        ; Referenced from B9BF
LC000:  ret

        ; Referenced from BFD3
LC001:  ld      hl,0xC04E
        call    0x5ACA
        pop     hl
        call    LBEE3+2         ; reference not aligned to instruction
        call    LBEAB
        ld      b,0x4F          ; 'O'
        cp      0x01
        jr      z,LC01F
        cp      0x02
        jr      z,LC023
        cp      0x03
        jr      z,LC027
        jp      0x03B1

        ; Referenced from C012
LC01F:  ld      c,0x0E
        jr      LC029

        ; Referenced from C016
LC023:  ld      c,0x0D
        jr      LC029

        ; Referenced from C01A
LC027:  ld      c,0x0C

        ; Referenced from C021, C025
LC029:  push    hl
        push    de
        ex      de,hl
        xor     a
        ld      (0xEC85),a
        ld      a,0x01
        or      a
        call    0x369A
        pop     de
        in      a,(0x70)        ; 'p'
        ld      c,a
        ld      a,0x80
        out     (0x70),a        ; 'p'
        ld      hl,0x8000
        ld      b,0x7F          ; ''

        ; Referenced from C047
LC043:  ld      a,(de)
        ld      (hl),a
        inc     hl
        inc     de
        djnz    LC043
        ld      a,c
        out     (0x70),a        ; 'p'
        pop     hl
        ret

LC04E:  ld      b,c
        jr      z,LC060+2       ; reference not aligned to instruction
        add     hl,hl
        ld      b,c
        adc     a,c
        cp      l
        sub     h
        call    nc,LC982
        sub     e
        ld      l,a
        sbc     a,b
        ld      e,(hl)
        add     a,d
        or      l
        add     a,d

        ; Referenced from C04F
LC060:  call    c,LB780+2       ; reference not aligned to instruction
        add     a,d
        xor     c
        add     a,c
        jr      nz,LC0B0
        jr      nz,LC08A
        jr      nz,LBFEE
        ld      d,b
        add     a,c
        ld      a,h
        add     a,d
        ld      d,d
        add     a,d
        call    z,0x4C83
        add     a,c
        ld      a,h
        add     a,d
        ret     p
        sub     e
        call    m,0xCD97
        add     a,d
        or      l
        add     a,d
        call    nz,LBA88+1      ; reference not aligned to instruction
        add     a,d
        or      e
        add     a,d
        and     d
        add     a,d
        ld      l,l
        add     a,d

        ; Referenced from C068
LC08A:  ld      l,(hl)
        add     a,d

        ; Referenced from BF3F, BF4C
LC08C:  ld      d,b
        add     a,d
        ret

LC08F:  add     a,c
        ld      b,b
        sub     e
        ld      l,a
        sbc     a,b
        ld      e,(hl)
        add     a,d
        or      l
        add     a,d
        call    c,LB780+2       ; reference not aligned to instruction
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop

        ; Referenced from C066
LC0B0:  nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        add     a,d
        ld      h,a
        add     a,d
        adc     a,c
        add     a,d
        sub     h
        add     a,d
        add     a,b
        add     a,d
        ld      (hl),d
        add     a,d
        sub     b
        add     a,d
        add     a,c
        add     a,d
        add     a,e
        add     a,d
        add     a,l
        add     a,d
        add     a,b
        add     a,d
        ld      l,d
        add     a,d
        add     a,l
        add     a,d
        sbc     a,c
        nop
        NOP*

        ld      hl,0x8800
        di
        ld      a,0xC3
        ld      (0xECDF),a
        call    LC38F
        ld      (0xECE0),hl
        ei
        ret

LC10E:  jr      LC142+1         ; reference not aligned to instruction

LC110:  cp      0xDB
        jp      z,LC12F
        cp      0x9E
        jp      z,LC158
        cp      0xCB
        jp      z,LC1A0
        cp      0xFF
        jr      z,LC126

        ; Referenced from C12D
LC123:  jp      0x0393

        ; Referenced from C121
LC126:  inc     hl
        ld      a,(hl)
        cp      0x97
        jp      z,LC33B
        jr      LC123

        ; Referenced from C112
LC12F:  inc     hl
        inc     hl
        call    0x5ACA
        ld      a,(de)
        and     0x01
        jp      nz,0x0393
        ld      a,(de)
        inc     a
        inc     a
        ld      (LB41C),a
        inc     de
        ld      a,(de)

        ; Referenced from C10E
LC142:  ld      (LB412),a
        inc     de
        ld      a,(de)
        ld      (LB413),a
        push    hl
        ld      a,0xFE
        out     (0x71),a        ; 'q'
        call    LB420
        ld      a,0xFF
        out     (0x71),a        ; 'q'
        pop     hl
        ret

        ; Referenced from C117
LC158:  inc     hl
        call    LB3AF
        ld      (LB543+1),de    ; reference not aligned to instruction
        ld      a,(hl)
        cp      0x2C            ; ','
        ret     nz
        call    LB3D1
        ld      a,(hl)
        ld      (LB54F+1),a     ; reference not aligned to instruction
        inc     hl
        call    LB3DA

        ; Referenced from C1A4
LC16F:  inc     hl
        ld      a,(hl)
        sbc     a,0x11
        cp      0x08
        jp      nc,0x0393
        ld      (LB492+1),a     ; reference not aligned to instruction
        ld      (LB592+1),a     ; reference not aligned to instruction
        inc     hl
        ld      a,(hl)
        cp      0x2C            ; ','
        jr      z,LC185
        ret

        ; Referenced from C182
LC185:  call    LB3D1
        ld      (LC18B+2),hl    ; reference not aligned to instruction

        ; Referenced from C188
LC18B:  ld      de,(0x0000)
        ld      (LB673+1),de    ; reference not aligned to instruction
        inc     hl
        inc     hl
        ret

LC196:  push    hl
        ld      (LC19B+1),de    ; reference not aligned to instruction

        ; Referenced from C197
LC19B:  call    0x0000
        pop     hl
        ret

        ; Referenced from C11C
LC1A0:  inc     hl
        ld      a,(hl)
        cp      0xF1
        jp      z,LC16F
        cp      0x5B            ; '['
        jr      z,LC1D3
        cp      0x28            ; '('
        jr      z,LC1FC
        inc     hl
        ld      c,0x54          ; 'T'

        ; Referenced from C1CC
LC1B2:  in      a,(0x32)        ; '2'
        and     0xDF
        out     (0x32),a        ; '2'
        ld      a,(hl)
        sub     0x11
        cp      0x08
        jr      nc,LC1CE
        inc     hl

        ; Referenced from C1D1
LC1C0:  out     (c),a
        inc     c
        ld      a,c
        cp      0x5C            ; '\'
        ret     z
        ld      a,(hl)
        cp      0x2C            ; ','
        ret     nz
        inc     hl
        jr      LC1B2

        ; Referenced from C1BD
LC1CE:  call    LB3A1
        jr      LC1C0

        ; Referenced from C1A9
LC1D3:  call    LC319
        inc     hl
        ld      a,(hl)
        cp      0x58            ; 'X'
        jr      z,LC20C
        cp      0x46            ; 'F'
        jr      z,LC211
        cp      0x4D            ; 'M'
        jr      z,LC216
        cp      0x53            ; 'S'
        jr      z,LC21B
        ld      c,0x54          ; 'T'
        ld      b,0x08

        ; Referenced from C1F8
LC1EC:  call    LC280
        ld      a,(hl)
        cp      0x5D            ; ']'
        jr      z,LC1FA
        call    LC39C
        inc     c
        djnz    LC1EC

        ; Referenced from C1F2
LC1FA:  inc     hl
        ret

        ; Referenced from C1AD
LC1FC:  call    LC319
        inc     hl
        call    LC36A
        ld      a,e
        add     a,0x54          ; 'T'
        ld      c,a
        call    LC27D
        inc     hl
        ret

        ; Referenced from C1DA
LC20C:  ld      de,0x1000
        jr      LC21E

        ; Referenced from C1DE
LC211:  ld      de,0x3000
        jr      LC21E

        ; Referenced from C1E2
LC216:  ld      de,0x6000
        jr      LC21E

        ; Referenced from C1E6
LC21B:  ld      de,0xF000

        ; Referenced from C20F, C214, C219
LC21E:  ld      (LC274+1),de    ; reference not aligned to instruction
        inc     hl
        call    LC39C
        ld      (LC22C+1),hl    ; reference not aligned to instruction
        ld      b,0x08

        ; Referenced from C270
LC22B:  push    bc

        ; Referenced from C226
LC22C:  ld      hl,0x0000
        ld      c,0x54          ; 'T'
        ld      ix,0xC3A4
        ld      b,0x08

        ; Referenced from C26A
LC237:  push    bc
        call    LC36A
        ld      iy,0xC316
        call    LC2A1
        ld      e,(ix+0x00)
        inc     ix
        ld      d,(ix+0x00)
        inc     ix
        ld      iy,0xC313
        call    LC2A1
        call    LC2EE
        ld      iy,0xC313
        call    LC2CD
        call    LC283
        pop     bc
        inc     c
        ld      a,(hl)
        cp      0x5D            ; ']'
        jr      z,LC26C
        call    LC39C
        djnz    LC237

        ; Referenced from C265
LC26C:  call    LC274
        pop     bc
        djnz    LC22B
        inc     hl
        ret

        ; Referenced from C21E, C26C
        ; --- START PROC LC274 ---
LC274:  ld      bc,0x3000

        ; Referenced from C27A
LC277:  dec     bc
        ld      a,b
        or      c
        jr      nz,LC277
        ret

        ; Referenced from C207
        ; --- START PROC LC27D ---
LC27D:  call    LC39C

        ; Referenced from C1EC
        ; --- START PROC LC280 ---
LC280:  call    LC36A

        ; Referenced from C25D
        ; --- START PROC LC283 ---
LC283:  call    LC324
        ld      a,e
        and     0x3F            ; '?'
        out     (c),a
        call    LC296
        ld      a,d
        and     0x07
        set     6,a
        out     (c),a
        ret

        ; Referenced from C28B, C2A2
        ; --- START PROC LC296 ---
LC296:  or      a
        rlc     e
        rl      d
        or      a
        rlc     e
        rl      d
        ret

        ; Referenced from C23F, C250
        ; --- START PROC LC2A1 ---
LC2A1:  push    de
        call    LC296
        ld      (iy+0x00),d
        inc     iy
        pop     de
        ld      a,e
        ld      e,0x00
        or      a
        rra
        rr      e
        rra
        rr      e
        rra
        rr      e
        srl     e
        srl     e
        srl     e
        srl     e
        srl     e
        and     0x07
        ld      (iy+0x00),a
        inc     iy
        ld      (iy+0x00),e
        ret

        ; Referenced from C25A
        ; --- START PROC LC2CD ---
LC2CD:  ld      a,(iy+0x00)
        inc     iy
        ld      e,(iy+0x00)
        inc     iy
        or      a
        rrc     e
        rrc     e
        rrc     e
        or      a
        rrca
        rr      e
        rrca
        rr      e
        and     0x01
        ld      d,a
        ld      a,(iy+0x00)
        or      e
        ld      e,a
        ret

        ; Referenced from C253
        ; --- START PROC LC2EE ---
LC2EE:  push    de
        push    hl
        push    bc
        ld      b,0x03
        ld      de,0xC316
        ld      hl,0xC313

        ; Referenced from C303
LC2F9:  ld      a,(de)
        cp      (hl)
        jr      z,LC301
        jr      c,LC30E
        jr      LC309

        ; Referenced from C2FB, C30C, C311
LC301:  inc     hl
        inc     de
        djnz    LC2F9
        pop     bc
        pop     hl
        pop     de
        ret

        ; Referenced from C2FF
LC309:  ld      a,(hl)
        inc     a
        ld      (hl),a
        jr      LC301

        ; Referenced from C2FD
LC30E:  ld      a,(hl)
        dec     a
        ld      (hl),a
        jr      LC301

LC313:  nop
        nop
        nop
        nop
        nop
        nop

        ; Referenced from C1D3, C1FC
        ; --- START PROC LC319 ---
LC319:  in      a,(0x32)        ; '2'
        res     2,a
        set     3,a
        set     5,a
        out     (0x32),a        ; '2'
        ret

        ; Referenced from C283
        ; --- START PROC LC324 ---
LC324:  push    hl
        push    de
        ld      a,c
        sub     0x54            ; 'T'
        ld      hl,0xC3A4
        add     a,a
        ld      d,0x00
        ld      e,a
        add     hl,de
        ld      (LC336+2),hl    ; reference not aligned to instruction
        pop     de
        pop     hl

        ; Referenced from C331
LC336:  ld      (0x0000),de
        ret

        ; Referenced from C12A
LC33B:  inc     hl

        ; Referenced from ADFF
LC33C:  call    LB3AF
        ld      a,(hl)
        cp      0x2C            ; ','
        jp      nz,0x0393
        push    de
        inc     hl
        call    0x5ACA
        pop     bc
        push    de
        push    hl
        di
        in      a,(0x32)        ; '2'
        set     4,a
        out     (0x32),a        ; '2'
        ld      a,0x7B          ; '{'
        out     (0x31),a        ; '1'
        ld      a,(bc)
        push    af
        ld      a,0x79          ; 'y'
        out     (0x31),a        ; '1'
        in      a,(0x32)        ; '2'
        res     4,a
        out     (0x32),a        ; '2'
        pop     af
        ei
        pop     hl
        pop     de
        ld      (de),a
        ret

        ; Referenced from C200, C238, C280
        ; --- START PROC LC36A ---
LC36A:  ld      a,(hl)
        cp      0x0C
        jr      z,LC396
        cp      0x0B
        jr      z,LC396
        cp      0x0F
        jr      z,LC38F
        cp      0x1C
        jr      z,LC396
        cp      0x11
        jr      z,LC388
        cp      0x1A
        jr      z,LC388
        jr      c,LC388
        jp      0x0393

        ; Referenced from C37D, C381, C383
LC388:  sub     0x11
        ld      d,0x00
        ld      e,a
        inc     hl
        ret

        ; Referenced from C106, C375
        ; --- START PROC LC38F ---
LC38F:  inc     hl
        ld      a,(hl)
        ld      d,0x00
        ld      e,a
        inc     hl
        ret

        ; Referenced from C36D, C371, C379
        ; --- START PROC LC396 ---
LC396:  inc     hl
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        inc     hl
        ret

        ; Referenced from C1F4, C223, C267, C27D
        ; --- START PROC LC39C ---
LC39C:  ld      a,(hl)
        cp      0x2C            ; ','
        jp      nz,0x0393
        inc     hl
        ret

LC3A4:  nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        ld      b,0x00

        ; Referenced from B721
LC3B7:  nop
        inc     a
        cp      0x08
        ret     nz
        xor     a
        ret

LC3BE:  dec     a
        cp      0xFF
        ret     nz
        ld      a,0x07
        or      a
        ret

LC3C6:  inc     hl
        ld      a,(hl)
        cp      0x0C
        jr      z,LC3D5
        push    bc
        push    de
        call    0x5ACA
        ld      a,(de)
        pop     de
        pop     bc
        ret

        ; Referenced from C3CA
LC3D5:  inc     hl
        ld      a,(hl)
        inc     hl
        inc     hl
        ret

LC3DA:  nop
        ld      a,(bc)
        nop
        ldir
        ld      bc,0x000A
        ld      hl,0x2440
        push    hl
        ld      de,0x2420
        ldir
        call    0xD926
        pop     hl
        ld      bc,0x0007
        ld      de,0x2450
        ldir
        ex      de,hl
        ld      (hl),0x62       ; 'b'
        inc     hl
        ld      (hl),0x61       ; 'a'
        inc     hl

        ; Referenced from BAFB
LC3FE:  ld      (hl),0x11

        ; Referenced from B400
LC400:  di
        ld      hl,0xC41C
        ld      (0xEEA8),hl
        ld      hl,0xC632
        ld      (0xEEAB),hl
        ei
        ret

        ; Referenced from C68E
        ; --- START PROC LC40F ---
LC40F:  call    LC518
        ld      a,d
        out     (0x44),a        ; 'D'
        nop
        nop
        nop
        ld      a,e
        out     (0x45),a        ; 'E'
        ret

LC41C:  ld      a,(hl)
        inc     hl
        cp      0x58            ; 'X'
        jr      z,LC446
        cp      0x50            ; 'P'
        jr      z,LC489
        cp      0x43            ; 'C'
        jr      z,LC485
        cp      0x46            ; 'F'
        jp      z,LC4EA
        cp      0x54            ; 'T'
        jp      z,LC4F0
        cp      0x56            ; 'V'
        jp      z,LC4FA
        cp      0x4C            ; 'L'
        jp      z,LC550
        cp      0x4B            ; 'K'
        jp      z,LC598
        jp      0x0393

        ; Referenced from C420, C557
        ; --- START PROC LC446 ---
LC446:  ld      de,0x2900
        call    LC500
        ld      bc,0x1000

        ; Referenced from C458
LC44F:  ld      de,0x2700
        call    LC50D
        dec     bc
        ld      a,b
        or      c
        jr      nz,LC44F
        ld      de,0x0A10
        call    LC500
        ld      de,0x2800
        call    LC500
        ld      de,0x2801
        call    LC500
        ld      de,0x2802
        call    LC500
        ld      de,0x0800
        call    LC500
        ld      de,0x0900
        call    LC500
        ld      de,0x2903
        call    LC500
        ret

        ; Referenced from C428
LC485:  ld      a,0xFF
        jr      LC48A

        ; Referenced from C424
LC489:  xor     a

        ; Referenced from C487
LC48A:  push    af
        push    hl
        ld      d,0x18
        ld      e,0xFF
        ld      b,0x06

        ; Referenced from C496
LC492:  call    LC500
        inc     d
        djnz    LC492
        ld      hl,0xCFFA
        ld      d,0x11
        ld      e,(hl)
        call    LC500
        ld      d,0x0B
        call    LC71D
        inc     hl
        ld      e,(hl)
        ld      a,(hl)
        ld      (LC7EE),a
        inc     hl
        ld      b,0x03
        ld      d,0xB6

        ; Referenced from C4B7
LC4B1:  ld      e,(hl)
        call    LC500
        inc     hl
        dec     d
        djnz    LC4B1
        ld      e,(hl)
        ld      d,0x22          ; '"'
        call    LC500
        pop     hl
        pop     af
        or      a
        call    z,LC51E
        ld      de,0x0718
        call    LC500
        ld      de,0x0A10
        call    LC500
        ld      de,0x0B0F
        call    LC500
        ld      de,0x1008
        call    LC71D
        ld      de,0x1080
        call    LC71D
        ld      de,0x273F
        call    LC50D
        ret

        ; Referenced from C42C
LC4EA:  ld      a,0x01
        ld      (LC900),a
        ret

        ; Referenced from C431
LC4F0:  call    LB3A0
        ld      e,a
        ld      d,0x26          ; '&'
        call    LC50D
        ret

        ; Referenced from C436
LC4FA:  push    hl
        call    LC94D
        pop     hl
        ret

        ; Referenced from C449, C45D, C463, C469, C46F, C475, C47B, C481, C492, C49E, C4B2, C4BC, C4C8, C4CE, C4D4, C533, C539, C53F, C545, C54B
        ; --- START PROC LC500 ---
LC500:  call    LC518
        ld      a,d
        out     (0x44),a        ; 'D'
        nop
        nop
        nop
        ld      a,e
        out     (0x45),a        ; 'E'
        ret

        ; Referenced from C452, C4E6, C4F6
        ; --- START PROC LC50D ---
LC50D:  call    LC518
        ld      a,d
        out     (0x44),a        ; 'D'
        nop
        ld      a,e
        out     (0x45),a        ; 'E'
        ret

        ; Referenced from C40F, C500, C50D, C51B
        ; --- START PROC LC518 ---
LC518:  in      a,(0x44)        ; 'D'
        rla
        jr      c,LC518
        ret

        ; Referenced from C4C2
        ; --- START PROC LC51E ---
LC51E:  push    hl
        ld      hl,0xC7D2
        ld      de,0xC900
        ld      bc,0x0025
        ldir
        ld      hl,0xC950
        ld      (0xF308),hl
        ld      de,0x0718
        call    LC500
        ld      de,0x0500
        call    LC500
        ld      de,0x0A10
        call    LC500
        ld      de,0x0B0F
        call    LC500
        ld      de,0x0C00
        call    LC500
        pop     hl
        ret

        ; Referenced from C43B
LC550:  dec     hl
        ld      a,0xC1
        call    LA822+1         ; reference not aligned to instruction
        push    hl
        call    LC446
        ld      hl,0x5000
        ld      de,0xCFF8
        ld      a,0x7B          ; '{'
        di
        out     (0x31),a        ; '1'
        ld      b,0x08

        ; Referenced from C56B
LC567:  ld      a,(hl)
        ld      (de),a
        inc     de
        inc     hl
        djnz    LC567
        call    LC58F
        ld      de,0xD300
        call    LC58F
        ld      de,0xD600
        call    LC58F
        ld      de,0xD900
        call    LC58F
        ld      de,0xDC00
        call    LC58F
        ld      a,0x79          ; 'y'
        out     (0x31),a        ; '1'
        ei
        pop     hl
        ret

        ; Referenced from C56D, C573, C579, C57F, C585, C595
        ; --- START PROC LC58F ---
LC58F:  ld      a,(hl)
        ld      (de),a
        inc     hl
        inc     de
        cp      0xFD
        jr      nz,LC58F
        ret

        ; Referenced from C440
LC598:  call    LB3A0
        cp      0x18
        jp      nc,0x0B06
        or      a
        jp      z,0x0B06
        ld      c,a
        inc     hl
        ld      a,(hl)
        cp      0xF3
        jr      z,LC5B2
        cp      0xF4
        jr      z,LC5BB
        jp      0x03B1

        ; Referenced from C5A9
LC5B2:  ld      de,0xC606
        ld      (LC5FF+1),de    ; reference not aligned to instruction
        jr      LC5C2

        ; Referenced from C5AD
LC5BB:  ld      de,0xC619
        ld      (LC5FF+1),de    ; reference not aligned to instruction

        ; Referenced from C5B9
LC5C2:  push    hl
        ld      hl,0xD000
        call    LC5DE
        ld      hl,0xD300
        call    LC5DE
        ld      hl,0xD600
        call    LC5DE
        ld      hl,0xD900
        call    LC5DE
        pop     hl
        inc     hl
        ret

        ; Referenced from C5C6, C5CC, C5D2, C5D8, C5EF
        ; --- START PROC LC5DE ---
LC5DE:  ld      a,(hl)
        cp      0xFF
        call    z,LC5F6
        cp      0x02
        jr      z,LC5F1
        cp      0xFD
        ret     z
        cp      0xFE
        ret     z

        ; Referenced from C5F4, C604
        ; --- START PROC LC5EE ---
LC5EE:  inc     hl
        jr      LC5DE

        ; Referenced from C5E6
LC5F1:  inc     hl
        inc     hl
        inc     hl
        jr      LC5EE

        ; Referenced from C5E1
        ; --- START PROC LC5F6 ---
LC5F6:  inc     hl
        ld      a,(hl)
        push    af
        and     0xF0
        ld      d,a
        pop     af
        and     0x0F

        ; Referenced from C5B5, C5BE
LC5FF:  call    LC606
        inc     hl
        inc     hl
        jr      LC5EE

        ; Referenced from C5FF
        ; --- START PROC LC606 ---
LC606:  ld      b,c

        ; Referenced from C60D
LC607:  inc     a
        cp      0x0D
        call    z,LC612
        djnz    LC607
        add     a,d
        ld      (hl),a
        ret

        ; Referenced from C60A
        ; --- START PROC LC612 ---
LC612:  ld      a,d
        add     a,0x10
        ld      d,a
        ld      a,0x01
        ret

LC619:  ld      b,c

        ; Referenced from C61F
LC61A:  dec     a
        or      a
        call    z,LC624
        djnz    LC61A
        add     a,d
        ld      (hl),a
        ret

        ; Referenced from C61C
        ; --- START PROC LC624 ---
LC624:  ld      a,d
        sub     0x10
        or      a
        call    z,LC62F
        ld      d,a
        ld      a,0x0C
        ret

        ; Referenced from C628
        ; --- START PROC LC62F ---
LC62F:  ld      a,0x10
        ret

LC632:  ld      a,(hl)
        cp      0x58            ; 'X'
        jp      z,LC693
        cp      0x50            ; 'P'
        jp      z,LC64F
        cp      0x4C            ; 'L'
        jp      z,LC6B1+1       ; reference not aligned to instruction
        cp      0x53            ; 'S'
        jp      z,LC743
        cp      0x56            ; 'V'
        jp      z,LC77F
        jp      0x4DC1

        ; Referenced from C63A
LC64F:  inc     hl

        ; Referenced from C698
        ; --- START PROC LC650 ---
LC650:  call    LC724
        call    LC796
        call    LB3AF
        call    LC73F
        ld      a,e
        ld      (LC7A6),a
        ld      a,d
        ld      (LC7A8),a

        ; Referenced from AC86
LC664:  call    LC796
        call    LC724
        call    LC796
        call    LB3AF
        call    LC73F
        ld      a,e
        ld      (LC7B4),a
        ld      (LC7AA),a
        ld      a,d
        ld      (LC7B6),a
        ld      (LC7AC),a
        call    LC69C
        di
        ld      de,0xC79D
        call    LC789
        ld      de,0x2903
        call    LC40F
        ei
        ret

        ; Referenced from C635
LC693:  inc     hl
        push    hl
        ld      hl,0xC6A5
        call    LC650
        pop     hl

        ; Referenced from C681, C6E4
        ; --- START PROC LC69C ---
LC69C:  di
        ld      de,0xC7BA
        call    LC789
        ei
        ret

LC6A5:  inc     l
        ld      (de),a
        inc     l
        inc     c
        nop
        nop
        inc     l
        ld      (de),a
        inc     l
        inc     c
        rst     0x38
        rrca

        ; Referenced from C63F
LC6B1:  ld      a,(0xCD23)
        xor     a
        or      e
        ld      (LC6EC+1),de    ; reference not aligned to instruction
        push    de
        call    LC796
        call    LB3AF
        ld      b,h
        ld      c,l
        ex      de,hl
        pop     de
        sbc     hl,de
        ld      (LC6EF+1),hl    ; reference not aligned to instruction
        ld      h,b
        ld      l,c
        call    LC796
        call    LC724
        call    LC796
        call    LB3AF
        call    LC73F
        ld      a,e
        ld      (LC7CA),a
        ld      a,d
        ld      (LC7CC),a
        push    hl
        call    LC69C
        di
        ld      a,0x7B          ; '{'
        out     (0x31),a        ; '1'

        ; Referenced from C6B6
LC6EC:  ld      hl,0x1000

        ; Referenced from C6C7
LC6EF:  ld      bc,0x6FFF
        ld      de,0xC7C1
        call    LC789

        ; Referenced from C70E
LC6F8:  ld      d,0x08
        ld      e,(hl)
        call    LC71D
        inc     hl
        dec     bc

        ; Referenced from C704
LC700:  in      a,(0x46)        ; 'F'
        bit     3,a
        jr      z,LC700
        ld      de,0x1080
        call    LC71D
        ld      a,b
        or      c
        jr      nz,LC6F8
        ld      de,0x0001
        call    LC71D
        ld      a,0x79          ; 'y'
        out     (0x31),a        ; '1'
        ei
        pop     hl
        ret

        ; Referenced from C4A3, C4DA, C4E0, C6FB, C709, C713, C785
        ; --- START PROC LC71D ---
LC71D:  ld      a,d

        ; Referenced from C751, C757
        ; --- START PROC LC71E ---
LC71E:  out     (0x46),a        ; 'F'
        ld      a,e

        ; Referenced from C79F
LC721:  out     (0x47),a        ; 'G'
        ret

        ; Referenced from C650, C667, C6CF
        ; --- START PROC LC724 ---
LC724:  inc     hl
        ld      a,(hl)
        cp      0x10
        jp      c,0x03B1
        cp      0x19
        jp      nc,0x03B1
        sub     0x11
        sla     a
        sla     a
        sla     a
        sla     a
        sla     a
        ld      b,a
        inc     hl
        ret

        ; Referenced from C659, C670, C6D8
        ; --- START PROC LC73F ---
LC73F:  ld      a,d

        ; Referenced from C7BE
LC740:  or      b
        ld      d,a
        ret

        ; Referenced from C644
LC743:  inc     hl

        ; Referenced from C7C3
LC744:  call    LB3AF
        ld      a,e
        ld      (LC7AE),a
        ld      a,d
        ld      (LC7B0),a
        ld      a,0x09
        call    LC71E
        ld      e,d
        ld      a,0x0A
        call    LC71E
        call    LC796
        inc     hl
        ld      a,(hl)
        inc     hl
        cp      0x11
        jr      z,LC76B
        cp      0x12
        jr      z,LC77B
        jp      0x03B1

        ; Referenced from C762
LC76B:  ld      a,0xA0

        ; Referenced from C77D
LC76D:  ld      (LC7B8),a
        ld      a,(hl)
        cp      0x2C            ; ','
        ret     nz
        call    LB3A0
        ld      (LC7B2),a
        ret

        ; Referenced from C766
LC77B:  ld      a,0xB0
        jr      LC76D

        ; Referenced from C649
LC77F:  inc     hl
        call    LB3AF
        ld      d,0x0B
        call    LC71D
        ret

        ; Referenced from C688, C6A0, C6F5, C794
        ; --- START PROC LC789 ---
LC789:  ld      a,(de)
        cp      0xFF
        ret     z
        out     (0x46),a        ; 'F'
        inc     de
        ld      a,(de)
        out     (0x47),a        ; 'G'
        inc     de
        jr      LC789

        ; Referenced from C653, C664, C66A, C6BB, C6CC, C6D2, C75A
        ; --- START PROC LC796 ---
LC796:  ld      a,(hl)
        cp      0x2C            ; ','
        jp      nz,0x03B1
        ret

LC79D:  djnz    LC7A7
        djnz    LC721
        nop
        jr      nz,LC7A5
        ret     nz

        ; Referenced from C7A2
LC7A5:  ld      (bc),a

        ; Referenced from C65D
LC7A6:  nop

        ; Referenced from C79D
LC7A7:  inc     bc

        ; Referenced from C661
LC7A8:  nop
        inc     b

        ; Referenced from C677
LC7AA:  rst     0x38
        dec     b

        ; Referenced from C67E
LC7AC:  ld      a,a
        add     hl,bc

        ; Referenced from C748
LC7AE:  ld      a,(bc)

        ; Referenced from C74C
LC7B0:  inc     h
        dec     bc

        ; Referenced from C777
LC7B2:  rst     0x38
        inc     c

        ; Referenced from C674
LC7B4:  rst     0x38
        dec     c

        ; Referenced from C67B
LC7B6:  ld      a,a
        nop

        ; Referenced from C76D
LC7B8:  and     b
        rst     0x38
        nop
        ld      bc,0x0000
        djnz    LC740
        rst     0x38
        djnz    LC7C3

        ; Referenced from C7C1
LC7C3:  djnz    LC744+1         ; reference not aligned to instruction
        nop
        ld      h,b
        ld      bc,0x0200

        ; Referenced from C6DC
LC7CA:  nop
        inc     bc

        ; Referenced from C6E0
LC7CC:  nop
        inc     b
        rst     0x38
        dec     b
        ccf
        rst     0x38
        nop
        nop
        nop
        nop
        ret     nc
        nop
        out     (0x00),a
        sub     0x00
        exx
        nop
        call    c,0x0101
        ld      bc,0x0101
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop

        ; Referenced from C4A9
LC7EE:  inc     c
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop

        ; Referenced from BFA3, BFA6
LC8FF:  nop

        ; Referenced from C4EC
LC900:  ld      a,0xC3
        ld      (0xEEA7),a
        ld      hl,0xC90C
        ld      (0xEEA8),hl
        ret

LC90C:  ld      a,(hl)
        inc     hl
        cp      0x50            ; 'P'
        jr      z,LC924
        cp      0x58            ; 'X'
        jp      z,LC9AE
        cp      0x45            ; 'E'
        jp      z,LC9C1
        cp      0x56            ; 'V'
        jp      z,LC9EC
        jp      0x03B1

        ; Referenced from C910
LC924:  call    LCA47
        call    LCA19
        push    de
        call    LCA47
        call    LCA19
        ld      (LC9AC),de
        pop     de
        call    LC93A
        ret

        ; Referenced from C936
        ; --- START PROC LC93A ---
LC93A:  push    hl
        push    de
        ld      b,e
        inc     b
        ld      hl,0xF7E0
        ld      de,0x0020

        ; Referenced from C945
LC944:  add     hl,de
        djnz    LC944
        pop     de
        di
        in      a,(0x32)        ; '2'
        set     4,a

        ; Referenced from C4FB
        ; --- START PROC LC94D ---
LC94D:  out     (0x32),a        ; '2'
        ld      a,0x28          ; '('
        call    LCA0C
        xor     a
        add     a,d
        call    LCA16
        push    hl
        inc     hl
        ld      a,0x30          ; '0'

        ; Referenced from C96C, C96E
LC95D:  push    af
        add     a,d
        call    LCA0C
        ld      a,(hl)
        call    LCA16
        inc     hl
        pop     af
        add     a,0x04
        cp      0xA0
        jr      c,LC95D
        jr      z,LC95D
        pop     hl
        ld      a,0xB0
        add     a,d
        call    LCA0C
        ld      a,(hl)
        call    LCA16
        ld      a,0x2D          ; '-'
        call    LCA0C
        ld      a,0xA4

        ; Referenced from C056
        ; --- START PROC LC982 ---
LC982:  add     a,d
        call    LCA0C
        ld      a,(LC9AC)
        call    LCA16
        ld      a,0xA0
        add     a,d
        call    LCA0C
        ld      a,(LC9AD)
        call    LCA16
        ld      a,0x28          ; '('
        call    LCA0C
        ld      a,0xF0
        add     a,d
        call    LCA16
        in      a,(0x32)        ; '2'
        res     4,a
        out     (0x32),a        ; '2'
        ei
        pop     hl
        ret

        ; Referenced from C931, C986
LC9AC:  nop

        ; Referenced from C992
LC9AD:  nop

        ; Referenced from C914
LC9AE:  push    hl
        xor     a

        ; Referenced from C9BD
LC9B0:  push    af
        ld      a,0x28          ; '('
        call    LCA0C
        pop     af
        call    LCA16
        inc     a
        cp      0x03
        jr      nz,LC9B0
        pop     hl
        ret

        ; Referenced from C919
LC9C1:  call    LCA47
        call    LCA19
        ld      a,e
        and     0x07
        set     3,a
        push    af
        ld      a,0x22          ; '"'
        call    LCA0C
        pop     af
        call    LCA16
        ld      b,0x03
        ld      c,0xB4

        ; Referenced from C9E9
LC9DA:  ld      a,c
        call    LCA0C
        call    LCA47
        call    LCA19
        ld      a,e
        call    LCA16
        inc     c
        djnz    LC9DA
        ret

        ; Referenced from C91E
LC9EC:  call    LCA47
        call    LCA19
        push    hl
        ex      de,hl
        di
        in      a,(0x32)        ; '2'
        set     4,a
        out     (0x32),a        ; '2'
        ld      bc,0x0400
        ld      de,0xF800
        ldir
        in      a,(0x32)        ; '2'
        res     4,a
        out     (0x32),a        ; '2'
        ei
        pop     hl
        ret

        ; Referenced from C951, C95F, C974, C97D, C983, C98F, C99A, C9B3, C9CF, C9DB
        ; --- START PROC LCA0C ---
LCA0C:  push    af

        ; Referenced from CA10
LCA0D:  in      a,(0x44)        ; 'D'
        rla
        jr      c,LCA0D
        pop     af
        out     (0x44),a        ; 'D'
        ret

        ; Referenced from C956, C963, C978, C989, C995, C9A0, C9B7, C9D3, C9E5
        ; --- START PROC LCA16 ---
LCA16:  out     (0x45),a        ; 'E'
        ret

        ; Referenced from C927, C92E, C9C4, C9E1, C9EF
        ; --- START PROC LCA19 ---
LCA19:  ld      a,(hl)
        cp      0x0C
        jr      z,LCA41
        cp      0x0F
        jr      z,LCA3A
        cp      0x1C
        jr      z,LCA41
        cp      0x11
        jr      z,LCA33
        cp      0x1A
        jr      z,LCA33
        jr      c,LCA33
        jp      0x0393

        ; Referenced from CA28, CA2C, CA2E
LCA33:  sub     0x11
        ld      d,0x00
        ld      e,a
        inc     hl
        ret

        ; Referenced from CA20
LCA3A:  inc     hl
        ld      a,(hl)
        ld      d,0x00
        ld      e,a
        inc     hl
        ret

        ; Referenced from CA1C, CA24
LCA41:  inc     hl
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        inc     hl
        ret

        ; Referenced from C924, C92B, C9C1, C9DE, C9EC
        ; --- START PROC LCA47 ---
LCA47:  ld      a,(hl)
        cp      0x2C            ; ','
        jp      nz,0x0393
        inc     hl
        ret

LCA4F:  nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        rst     0x38
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
