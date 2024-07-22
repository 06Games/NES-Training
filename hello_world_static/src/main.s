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
  cpx #$20
  bne @loop

enable_rendering:
  lda #%10000000	; Enable NMI
  sta $2000
  lda #%00010000	; Enable Sprites
  sta $2001

forever:
  jmp forever

nmi:
  ldx #$00 	; Set SPR-RAM address to 0
  stx $2003
@loop:	
  lda hello, x 	; Load the hello message into SPR-RAM
  sta $2004
  inx
  cpx #48 ; Hello contains 12 tile definitions of 4 bytes each
  bne @loop
  rti

hello:
	;    posY tileI Attr (flipY flipX behindBg 3x0 2xColor) posX
  .byte $00, $00,                %00000000,                $00 	; Why do I need these here?
  .byte $00, $00,                %00000000,                $00
  .byte $67, $00,                %00000001,                $6c
  .byte $67, $01,                %00000001,                $76
  .byte $67, $02,                %00000001,                $80
  .byte $67, $02,                %00000001,                $8A
  .byte $67, $03,                %00000000,                $94

  .byte $71, $04,                %00000011,                $6c
  .byte $71, $03,                %00000010,                $76
  .byte $71, $05,                %00000010,                $80
  .byte $71, $02,                %00000010,                $8A
  .byte $71, $06,                %00000010,                $94

palettes:
  ; Background Palette
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00

  ; Sprite Palette
  .byte $0f, $21, $00, $15
  .byte $0f, $27, $00, $15
  .byte $0f, $29, $00, $15
  .byte $0f, $20, $00, $15

; Character memory (8x8)
.segment "CHARS"
  .byte %11000011	; H (00)
  .byte %11000011
  .byte %11000011
  .byte %11111111
  .byte %11111111
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11111111	; E (01)
  .byte %11111111
  .byte %11000000
  .byte %11111100
  .byte %11111100
  .byte %11000000
  .byte %11111111
  .byte %11111111
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11000000	; L (02)
  .byte %11000000
  .byte %11000000
  .byte %11000000
  .byte %11000000
  .byte %11000000
  .byte %11111111
  .byte %11111111
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %01111110	; O (03)
  .byte %11100111
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte %11100111
  .byte %01111110
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11000011	; W (04)
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte %11011011
  .byte %11111111
  .byte %01100110
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11111110	; R (05)
  .byte %11111111
  .byte %11000011
  .byte %11000011
  .byte %11111110
  .byte %11111110
  .byte %11000011
  .byte %11000011
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11111100	; D (06)
  .byte %11111110
  .byte %11000111
  .byte %11000011
  .byte %11000011
  .byte %11000111
  .byte %11111110
  .byte %11111100
  .byte $00, $00, $00, $00, $00, $00, $00, $00
  