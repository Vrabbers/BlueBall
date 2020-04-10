	processor	6502

	include "regdefs.i"
	include "mem.i"
	org	$0801 ;dec 2049
	;this is used for autostart. it is a basic program that goes 10 SYS 2064
	.byte $0c, $08, $0a, $00, $9e, $20, $32, $30, $36, $34

	org $0810,0 ; fill with 0s otherwise basic goes like PIPIPIPIPIPI yeah
	
start:
	SEI
	LDA #$7F
	STA $DC0D
	STA $DD0D
	LDA #$00
	STA CURRENT_LEVEL
	LDA #BLACK
	STA BORDERCOLOR
	LDA #BLUE
	STA BGCOLOR0
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

	JSR memcpy

	LDA #<COLOR_RAM
	LDX #>COLOR_RAM
	STA MEMCPY_DEST_LO
	STX MEMCPY_DEST_HI

	LDA #<main_menu_size
	LDX #>main_menu_size
	STA MEMCPY_QUANT_LO
	STX MEMCPY_QUANT_HI

	LDA #WHITE
	JSR memfill

mml:  
	JSR SCNKEY
	LDA $CB	
	CMP #$40 ;no key pressed
	BEQ mml ;no key pressed, try again

	JSR level_setup

gl: 
backchange:
	LDA RASTER
	CMP #$F2
	BNE backchange
	LDA #BLACK
	STA BGCOLOR0
backchangeblue:
	LDA RASTER
	CMP #$FF
	BNE backchangeblue
	LDA #BLUE
	STA BGCOLOR0
	JMP gl

	include "utils.asm"
	include "data.asm"