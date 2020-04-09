;fun utilities!
memcpy:
    ;expects the stuff in the stuff
    ;destroys them tho :(
    LDY #$00
    LDA (MEMCPY_SRC),Y 
    STA (MEMCPY_DEST),Y ;copy the data
    ;subtract 1 from quant
    LDA MEMCPY_QUANT_LO
    SEC ; set carry flag
    SBC #$01 ; subtract the 1
    STA MEMCPY_QUANT_LO
    LDA MEMCPY_QUANT_HI
    SBC #$00 ;subtract nothing, but apply the carry
    STA MEMCPY_QUANT_HI ;set it
    ORA MEMCPY_QUANT_LO ;we still have A with the high value, we OR it with the low
    BEQ memcpy_end      ;if both are 0, return
    ;increase source and dest
    LDA MEMCPY_SRC_LO
    CLC ; clear carry flag
    ADC #$01 ; add the 1
    STA MEMCPY_SRC_LO
    LDA MEMCPY_SRC_HI
    ADC #$00 ;add nothing, but apply the carry
    STA MEMCPY_SRC_HI ;set it

    LDA MEMCPY_DEST_LO
    CLC ; clear carry flag
    ADC #$01 ; add the 1
    STA MEMCPY_DEST_LO
    LDA MEMCPY_DEST_HI
    ADC #$00 ;add nothing, but apply the carry
    STA MEMCPY_DEST_HI ;set it
    JMP memcpy
memcpy_end:
    RTS

memfill:
    ;expects the stuff in the stuff
    ;destroys them tho :(
    ;expects filler in A
    LDY #$00
    STA (MEMCPY_DEST),Y ;copy the data
    ;subtract 1 from quant
    PHA ;dont lose A!
    LDA MEMCPY_QUANT_LO
    SEC ; set carry flag
    SBC #$01 ; subtract the 1
    STA MEMCPY_QUANT_LO
    LDA MEMCPY_QUANT_HI
    SBC #$00 ;subtract nothing, but apply the carry
    STA MEMCPY_QUANT_HI ;set it
    ORA MEMCPY_QUANT_LO ;we still have A with the high value, we OR it with the low
    BEQ memfill_end      ;if both are 0, return

    LDA MEMCPY_DEST_LO
    CLC ; clear carry flag
    ADC #$01 ; add the 1
    STA MEMCPY_DEST_LO
    LDA MEMCPY_DEST_HI
    ADC #$00 ;add nothing, but apply the carry
    STA MEMCPY_DEST_HI ;set it
    PLA ;no mor
    JMP memfill
memfill_end:
    PLA
    RTS
    
    