	processor	6502

	include "regdefs.i"
	include "mem.i"
	org	$0801 ;dec 2049
	;this is used for autostart. it is a basic program that goes 10 SYS 2064
	.byte $0c, $08, $0a, $00, $9e, $20, $32, $30, $36, $34

	org $0810,0 ; fill with 0s otherwise basic goes like PIPIPIPIPIPI yeah
	
start:
	LDA #<main_menu_scr
	LDX #>main_menu_scr
	STA MEMCPY_SRC_LO
	STX MEMCPY_SRC_HI

	LDA #<$0400
	LDX #>$0400
	STA MEMCPY_DEST_LO
	STX MEMCPY_DEST_HI

	LDA #<main_menu_size
	LDX #>main_menu_size
	STA MEMCPY_QUANT_LO
	STX MEMCPY_QUANT_HI

	JSR memcpy

	LDA #<$D800
	LDX #>$D800
	STA MEMCPY_DEST_LO
	STX MEMCPY_DEST_HI

	LDA #<main_menu_size
	LDX #>main_menu_size
	STA MEMCPY_QUANT_LO
	STX MEMCPY_QUANT_HI

	LDA #$01
	JSR memfill

l:  
	JMP l

	include "utils.asm"
	include "data.asm"