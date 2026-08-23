; Patch
        .ORG    0x9980
opna_sendReg:
        PUSH       AF
        LD         A,D
        CP         4
        JR         NC,_waitReg_FM46
_waitReg_FM13:
        IN         A,(0x44)
        RLA
        JR         C,_waitReg_FM13
        POP        AF
        OUT        (0x44),A
        RET
_waitReg_FM46:
        IN         A,(0x46)
        RLA
        JR         C,_waitReg_FM46
        POP        AF
        SUB        4
        OUT        (0x46),A
        RET
        
opna_sendReg2:
        PUSH       AF
        LD         A,D
        CP         4
        JR         NC,_waitReg_FM46_
_waitReg_FM13_:
        IN         A,(0x44)
        RLA
        JR         C,_waitReg_FM13_
        POP        AF
        OUT        (0x44),A
        RET
_waitReg_FM46_:
        IN         A,(0x46)
        RLA
        JR         C,_waitReg_FM46_
        POP        AF
        OUT        (0x46),A
        RET
                
opna_sendData:
        PUSH       AF
        LD         A,D
        CP         4
        JR         NC,_sendFM46
        POP        AF
        OUT        (0x45),A
        RET
_sendFM46:
        POP        AF
        SUB        4
        OUT        (0x47),A
        RET 
        
opna_sendData2:
        PUSH       AF
        LD         A,D
        CP         4
        JR         NC,_sendFM46_
        POP        AF
        OUT        (0x45),A
        RET
_sendFM46_:
        POP        AF
        OUT        (0x47),A
        RET 