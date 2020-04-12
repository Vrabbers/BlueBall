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
	LDA #$FF
	STA SPR1X
	LDA #$6F
	STA SPR1Y ;star sprite

	LDA #SURFBOARD_SPRITE_PTR
	STA SPRITE2PTR
	LDA #RED
	STA SPR2C ;surfboard

mml:  
    JSR SCNKEY
    LDA $CB    
    CMP #$40 ;no key pressed
    BEQ mml ;no key pressed, try again

    JSR level_setup
	LDA #255
	STA SPRENABLE
	LDA #$50
	STA SPR0X
	STA SPR0Y
    
game_loop: 
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