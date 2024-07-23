nmi:
	cpy #32 ; 4 palettes times 8 frames of delay
	bne :+
	ldy #0
:	ldx #$00 	; Set SPR-RAM address to 0
	stx $2003

	@draw_loop:	
		lda hello, x ; Get Y coordinate
		clc
		adc #$67 ; Center the text by adding 0x67 to the Y coordinate
		sta $2004 ; Send the value to the PPU-Bus
		inx
		lda hello, x ; Get the tile index
		sta $2004
		inx
		tya ; Get the frame index to calculate the palette number
		lsr a
		lsr a
		lsr a ; Change the palette each 8 frames
		sta $2004
		lda hello, x ; Get X coordinate
		clc
		adc #$6c ; Center the text
		sta $2004
		inx
		cpx #30 ; Hello contains 10 tile definitions of 3 bytes each
		bne @draw_loop
	iny
	rti

hello:
	;   posY tileI posX
  .byte 00, $48, 00
  .byte 00, $65, 10
  .byte 00, $6c, 20
  .byte 00, $6c, 30
  .byte 00, $6f, 40
  
  .byte 10, $57, 00
  .byte 10, $6f, 10
  .byte 10, $72, 20
  .byte 10, $6c, 30
  .byte 10, $64, 40