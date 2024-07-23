.segment "HEADER"
  .byte $4E, $45, $53, $1A  ; iNES header identifier
  .byte 2                   ; 2x 16KB PRG-ROM Banks
  .byte 1                   ; 1x  8KB CHR-ROM
  .byte $00                 ; mapper 0 (NROM)
  .byte $00                 ; System: NES

.segment "VECTORS"
  .addr nmi ; When an NMI happens (once per frame if enabled) the label nmi
  .addr reset ; When the processor first turns on or is reset, it will jump to the label reset
  .addr 0  ; External interrupt IRQ (unused)

; "nes" linker config requires a STARTUP section, even if it's empty
.segment "STARTUP"

; Main code segment for the program
.segment "CODE"

reset:
  sei		; disable IRQs
  cld		; disable decimal mode
  ldx #$40
  stx $4017	; disable APU frame IRQ
  ldx #$ff 	; Set up stack
  txs		;  .
  inx		; now X = 0
  stx $2000	; disable NMI
  stx $2001 	; disable rendering
  stx $4010 	; disable DMC IRQs

;; first wait for vblank to make sure PPU is ready
vblankwait1:
  bit $2002
  bpl vblankwait1

clear_memory:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0200, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  inx
  bne clear_memory

;; second wait for vblank, PPU is ready after this
vblankwait2:
  bit $2002
  bpl vblankwait2

main:
load_palettes:
  lda $2002
  lda #$3f
  sta $2006
  lda #$00
  sta $2006
  ldx #$00
@loop:
  lda palettes, x
  sta $2007
  inx
  cpx #32
  bne @loop

enable_rendering:
  lda #%10000000	; Enable NMI
  sta $2000
  lda #%00010000	; Enable Sprites
  sta $2001

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
		cpx #72 ; Hello contains 12 tile definitions of 6 bytes each
		bne @draw_loop
	iny
  	rti

hello:
	;   posY tileI posX
  .byte 00, $00, 00
  .byte 00, $00, 00
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

; Palettes (Background + Sprites)
palettes:
.incbin "../assets/palettes.bin"

; Character memory (8x8 tiles)
.segment "CHARS"
.incbin "../assets/ascii.chr"