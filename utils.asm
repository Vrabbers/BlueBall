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
    
level_setup:
    ;expects the level no in CURRENT_LEVEL($08)
    ;destroys the memcpy pointers tho
    LDA CURRENT_LEVEL
    ASL  ;not american sign language, multiplies index by 2 because the level pointers are of course words
    TAX ;not theft
    LDA level_table,X;get the lo byte
    STA MEMCPY_SRC_LO
    INX ;もう一回
    LDA level_table,X ;ハイバイト
    STA MEMCPY_SRC_HI

    LDA #<level_size
    LDX #>level_size
    STA MEMCPY_QUANT_LO
    STX MEMCPY_QUANT_HI

    LDA #<SCREEN_RAM
    LDX #>SCREEN_RAM
    STA MEMCPY_DEST_LO
    STX MEMCPY_DEST_HI

    LDA #<COLOR_RAM
    LDX #>COLOR_RAM
    STA LEVELSET_COLOR_LO
    STX LEVELSET_COLOR_HI ;set up screen registers

level_setup_loop: 
    LDY #$00 ;make sure our Y isnt like poop
    LDA (MEMCPY_SRC),Y 
    TAX
    LDA tile_scrcode_table,X ;getscrcode for the level
    STA (MEMCPY_DEST),Y
    LDA tile_property_table,X;get color
    LSR 
    LSR 
    LSR 
    LSR  ;goodbye property data!
    STA (LEVELSET_COLOR),Y

    LDA MEMCPY_QUANT_LO
    SEC ; set carry flag
    SBC #$01 ; subtract the 1
    STA MEMCPY_QUANT_LO
    LDA MEMCPY_QUANT_HI
    SBC #$00 ;subtract nothing, but apply the carry
    STA MEMCPY_QUANT_HI ;set it
    ORA MEMCPY_QUANT_LO ;we still have A with the high value, we OR it with the low
    BEQ level_string      ;if both are 0, return
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

    LDA LEVELSET_COLOR_LO
    CLC ; clear carry flag
    ADC #$01 ; add the 1
    STA LEVELSET_COLOR_LO
    LDA LEVELSET_COLOR_HI
    ADC #$00 ;add nothing, but apply the carry
    STA LEVELSET_COLOR_HI ;set it

    JMP level_setup_loop

level_string:
    LDX #$00
    LDA #$20
level_string_clear_loop:
    STA SCREEN_LAST_ROW,X
    INX
    CPX #ROW_SIZE
    BNE level_string_clear_loop
    ;text at the bottom
    CLC
    LDX #24
    LDY #0
    JSR PLOT ;cursor positiion
    
    LDA CURRENT_LEVEL
    ASL  ;not american sign language, multiplies index by 2 because the level pointers are of course words
    TAX ;not theft
    LDA level_message_table,X;get the lo byte
    STA MEMCPY_SRC_LO
    INX ;もう一回
    LDA level_message_table,X ;ハイバイト
    STA MEMCPY_SRC_HI

    LDY #$00
level_string_loop:
    LDA (MEMCPY_SRC),Y
    BEQ level_setup_end ;if it is $00, end
    JSR CHROUT
    INY
    JMP level_string_loop
level_setup_end:
    RTS



    