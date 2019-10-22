.include "nesdefs.inc"

.importzp data_ptr

.import oam
.import palette
.import ball

.segment "CODE"
.proc LoadPalettes
  ppu_addr $3f00

  ldx #0
LoadPalettesLoop:
  lda palette, x        ;load palette byte
  sta PPU_DATA          ;write to PPU
  inx                   ;set index to next byte
  cpx #32
  bne LoadPalettesLoop
  rts
.endproc

; Load Sprites into RAM
.proc LoadSprites
  ldy #0
LoadSpritesLoop:
  lda ball, y
  sta oam, y
  iny
  cpy #4
  bne LoadSpritesLoop
  rts
.endproc

; Loads Nametable + Attribute data (1024 bytes)
; data_ptr must be set to the address of data to load.
; Destroys a, x, y
.proc LoadBackground
  lda PPU_STATUS
  ppu_addr $2000

  ldx #4            ; Loop 4 times 256 * 4 = 1024
  ldy #0
@loop:
  lda (data_ptr), y
  sta PPU_DATA
  iny
  bne @loop
  dex
  beq @done
  inc data_ptr + 1
  jmp @loop

@done:
  rts
.endproc

.export LoadPalettes
.export LoadSprites
.export LoadBackground
