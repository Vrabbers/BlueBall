    PROCESSOR 6502
DEBUG EQU $01 ;00 for no debooge
    INCLUDE "regdefs.i"
    INCLUDE "mem.i"
    ORG    $0801 ;dec 2049
    ;this is used for autostart. it is a basic program that goes 10 SYS 2064
    .byte $0c, $08, $0a, $00, $9e, $20, $32, $30, $36, $34

    ORG $0810,0 ; fill with 0s otherwise basic goes like PIPIPIPIPIPI yeah
    
start:
;SET UP
    SEI 
    LDA #$7F
    STA $DC0D
    STA $DD0D ;disable system interrupts
	
    LDA #$00 
    STA CURRENT_LEVEL ;start at level 1

    LDA #BLACK
    STA BORDERCOLOR
    LDA #BLUE
    STA BGCOLOR0 ;border and bg colors; different c64 revisions are different

    LDA #<main_menu_scr
    LDX #>main_menu_scr
    STA MEMCPY_SRC_LO
    STX MEMCPY_SRC_HI
    LDA #<SCREEN_RAM
    LDX #>SCREEN_RAM
    STA MEMCPY_DEST_LO
    STX MEMCPY_DEST_HI
    LDA #<main_menu_size
    LDX #>main_menu_size
    STA MEMCPY_QUANT_LO
    STX MEMCPY_QUANT_HI
    JSR memcpy ;copy main menu

    LDA #<COLOR_RAM
    LDX #>COLOR_RAM
    STA MEMCPY_DEST_LO
    STX MEMCPY_DEST_HI
    LDA #<main_menu_size
    LDX #>main_menu_size
    STA MEMCPY_QUANT_LO
    STX MEMCPY_QUANT_HI
    LDA #WHITE
    JSR memfill ;fill white

    LDA #BALL_SPRITE_PTR
    STA SPRITE0PTR
	LDA #LBLUE
	STA SPR0C ;ball sprite

	LDA #STAR_SPRITE_PTR
	STA SPRITE1PTR
	LDA #YELLOW
	STA SPR1C

	LDA #SURFBOARD_SPRITE_PTR
	STA SPRITE2PTR
	LDA #RED
	STA SPR2C ;surfboard
    LDA #$05
    STA PLAYER_X_POS_HI
    STA PLAYER_Y_POS_HI
mml:  
    JSR SCNKEY
    LDA SCNKEY_OUT    
    CMP #NO_KEY
    BEQ mml ;no key pressed, try again

    JSR level_setup
	LDA #255
	STA SPRENABLE
    LDA #$30
    STA SPR0Y
    LDA #$01
    STA PLAYER_X_POS_HI
game_loop: 
    IF DEBUG
        LDA #BLUE
        STA BORDERCOLOR
    EIF
    
    JSR SCNKEY
    LDA SCNKEY_OUT
    CMP #NO_KEY
    BEQ noinput
    CMP #W_KEY
    BEQ w
    CMP #A_KEY
    BEQ a
    CMP #S_KEY
    BEQ s
    CMP #D_KEY
    BEQ d
    BNE noinput
w:
    LDA #$F9
    STA PLAYER_Y_SPEED
    LDA #$00
    STA PLAYER_X_SPEED
    BEQ doneinput
a:
    LDA #$F9
    STA PLAYER_X_SPEED
    LDA #$00
    STA PLAYER_Y_SPEED
    BEQ doneinput
s:
    LDA #$07
    STA PLAYER_Y_SPEED
    LDA #$00
    STA PLAYER_X_SPEED
    BEQ doneinput
d:
    LDA #$07
    STA PLAYER_X_SPEED
    LDA #$00
    STA PLAYER_Y_SPEED
    BEQ doneinput
noinput:
    LDA #$00
    STA PLAYER_X_SPEED
    STA PLAYER_Y_SPEED
doneinput:
    IF DEBUG
        LDA #YELLOW
        STA BORDERCOLOR
    EIF
    LDA PLAYER_X_SPEED
    BMI xminus
xplus:
    CLC
    ADC PLAYER_X_POS_LO
    STA PLAYER_X_POS_LO
    LDA #$00
    ADC PLAYER_X_POS_HI
    STA PLAYER_X_POS_HI
    JMP y
xminus:
    EOR #$FF
    STA $03
    SEC
    LDA PLAYER_X_POS_LO
    SBC $03
    STA PLAYER_X_POS_LO
    LDA PLAYER_X_POS_HI
    SBC #$00
    STA PLAYER_X_POS_HI
y:
    LDA PLAYER_Y_SPEED
    BMI yminus
yplus:
    CLC
    LDA PLAYER_Y_SPEED
    ADC PLAYER_Y_POS_LO
    STA PLAYER_Y_POS_LO
    LDA #$00
    ADC PLAYER_Y_POS_HI
    STA PLAYER_Y_POS_HI
    JMP speedfinish
yminus:
    EOR #$FF
    STA $03
    SEC
    LDA PLAYER_Y_POS_LO
    SBC $03
    STA PLAYER_Y_POS_LO
    LDA PLAYER_Y_POS_HI
    SBC #$00
    STA PLAYER_Y_POS_HI
speedfinish:
    ;routine that converts player position into c64 sprite position
    ;we will simply "floor" these values (chop off the fractional part)
    IF DEBUG
        LDA #GREEN
        STA BORDERCOLOR
    EIF
    LDA PLAYER_X_POS_LO
    LSR
    LSR 
    LSR
    LSR ;get rid of the subpixel bytes
    STA $02
    LDA PLAYER_X_POS_HI
    ASL
    ASL
    ASL
    ASL ;american sign language. funny joek
    ORA $02
    STA SPR0X
    BCS msbset
msbclear:
    LDA #$FE
    AND XMSB
    STA XMSB
    BCC msbdone
msbset: 
    LDA #$01
    ORA XMSB
    STA XMSB

msbdone:
    LDA PLAYER_Y_POS_LO
    LSR
    LSR 
    LSR
    LSR ;get rid of the subpixel bytes
    STA $02
    LDA PLAYER_Y_POS_HI
    ASL
    ASL
    ASL
    ASL ;american sign language. funny joek
    ORA $02
    STA SPR0Y

    IF DEBUG
        LDA #RED
        STA BORDERCOLOR
        LDX #0
        LDA PLAYER_X_POS_HI
        JSR print_byte
        LDA PLAYER_X_POS_LO
        JSR print_byte
        INX
        LDA PLAYER_X_SPEED
        JSR print_byte
        LDX #40
        LDA PLAYER_Y_POS_HI
        JSR print_byte
        LDA PLAYER_Y_POS_LO
        JSR print_byte
        INX
        LDA PLAYER_Y_SPEED
        JSR print_byte
        LDA #BLACK
        STA BORDERCOLOR
    EIF
backchange:
    LDA RASTER
    CMP #$F2
    BNE backchange
    LDA #BLACK
    STA BGCOLOR0 ;at this point, we're on the line just above the text, so we make the background color black

backchangeblue:
    LDA RASTER
    CMP #$FF
    BNE backchangeblue
    LDA #BLUE 
    STA BGCOLOR0 ;go back, and start the game loop again
    JMP game_loop
    
    INCLUDE "data.asm" ;include the files
    INCLUDE "utils.asm"

