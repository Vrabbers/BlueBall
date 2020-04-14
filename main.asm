    PROCESSOR 6502

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
    LDA #WHITE
    STA BORDERCOLOR

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
    JMP doneinput
a:
    LDA #$F9
    STA PLAYER_X_SPEED
    LDA #$00
    STA PLAYER_Y_SPEED
    JMP doneinput
s:
    LDA #$07
    STA PLAYER_Y_SPEED
    LDA #$00
    STA PLAYER_X_SPEED
    JMP doneinput
d:
    LDA #$07
    STA PLAYER_X_SPEED
    LDA #$00
    STA PLAYER_Y_SPEED
    JMP doneinput
noinput:
    LDA #$00
    STA PLAYER_X_SPEED
    STA PLAYER_Y_SPEED
doneinput:

    LDA #%10000000
    STA $02 ;we will need this for later
    LDA PLAYER_X_SPEED
    BIT $02 ;;ones compliment!!! stinky stinky but who cares
    BNE xminus
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
    BIT $02
    BNE yminus
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

    LDA PLAYER_X_POS_LO
    LSR
    LSR 
    LSR
    LSR ;get rid of the subpixel bytes
    STA $02
    LDX #$00 ;we use this for writing the MSB
    LDA PLAYER_X_POS_HI
    ASL
    ASL
    ASL
    ASL ;american sign language. funny joek
    BCC msbsetdone
    ;msb is set
    INX ;make our X 1 (takes the same time as LDX #$01 and is 1 byte)
msbsetdone:    
    ORA $02
    STA SPR0X
    TXA ;GIB ME X
    ORA XMSB
    STA XMSB

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
    LDA #BLACK
    STA BORDERCOLOR
    LDA PLAYER_X_POS_HI
    STA SCREEN_RAM
    LDA PLAYER_X_POS_LO
    STA SCREEN_RAM + 1
    LDA PLAYER_X_SPEED 
    STA SCREEN_RAM + 3
    LDA PLAYER_Y_POS_HI
    STA SCREEN_RAM + 40
    LDA PLAYER_Y_POS_LO
    STA SCREEN_RAM + 41
    LDA PLAYER_Y_SPEED 
    STA SCREEN_RAM + 43
    LDA SCNKEY_OUT
    STA SCREEN_RAM + 80
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
    
    INCLUDE "utils.asm"
    INCLUDE "data.asm" ;include the files