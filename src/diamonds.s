.include "nesdefs.inc"
.include "utils.inc"

.include "ram.s"

.segment "CODE"

.proc ResetVector
  ; Init
  sei
  cld

  ldx #0
  stx PPU_CTRL
  stx PPU_MASK
  stx APU_DMC_CTRL

  ; Set Stack Pointer
  dex   ; 0 - 1 = $FF
  txs

  ; Clear Interrupts
  bit PPU_STATUS
  bit APU_CHAN_CTRL

  ; Init APU
  lda #$40
  sta APU_FRAME
  lda #$0f
  sta APU_CHAN_CTRL

  ; PPU Warm up - VBlank 1
: bit PPU_STATUS
  bpl :-

  lda #0
  tax

ClearMemory:
  sta $0000, x
  sta $0100, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  lda #$fe
  sta oam, x
  lda #0
  inx
  bne ClearMemory

  ; PPU Warm up - VBlank 2
: bit PPU_STATUS
  bpl :-

  jsr LoadPalettes

  ppu_addr $2000
  lda #0
  ldx #32*30/4	; Only need to repeat a quarter of the time, since the loop writes 4 times.
: Repeat 4, sta PPU_DATA
  dex
  bne :-

  ldx #64
  lda #$55			; Select palette 1 (2nd palette) throughout.
:	sta PPU_DATA
  dex
  bne :-

  jsr LoadSprites

  lda #$80
  sta ball_x
  sta ball_y
  lda #$64
  sta ball_tile
  lda #0
  sta ball_attr
  sta ball_dir
  lda #2
  sta ball_yv

  lda #<tilemap
  sta data_ptr
  lda #>tilemap
  sta data_ptr + 1
  jsr LoadBackground

  ; Enable VBlank NMI
  lda #VBLANK_NMI
  sta PPU_CTRL

  ; Wait for next VBlank
  wait_for_nmi

  lda #0
  sta PPU_OAM_ADDR	; Specify the target starts at $00 in the PPU's OAM RAM.
  lda #>OAM_RAM		  ; Get upper byte (i.e. page) of source RAM for DMA operation.
  sta OAM_DMA			  ; Trigger the DMA.

  lda #0
  sta PPU_SCROLL		; Write X position first.
  sta PPU_SCROLL		; Then write Y position.

  lda #VBLANK_NMI|SPR_0|BG_0|VRAM_DOWN
  sta PPU_CTRL

  ; Enable sprites & background
  lda #SPR_ON|BG_ON
  sta PPU_MASK
.endproc

.proc Main
; Check Input
  jsr pollPlayer1

  ; 7 6 5      4     3  2    1    0
  ; A B Select Start Up Down Left Right

  lda buttonsp1
  and #%00000010
  beq checkRight

  lda ball_x
  sec
  sbc #2
  sta ball_x

checkRight:
  lda buttonsp1
  and #%00000001
  beq @inputDone

  lda ball_x
  clc
  adc #2
  sta ball_x

@inputDone:
  lda ball_dir
  bne :+
  lda ball_y
  clc
  adc ball_yv
  sta ball_y
  jmp wall_collision
: lda ball_y
  sec
  sbc ball_yv
  sta ball_y

wall_collision:
  ; Check Y
  bne :+
  sta ball_dir
  jmp checkX
: cmp #$ea
  bne checkX
  lda #1
  sta ball_dir

checkX:
  lda ball_x
  cmp #$08
  bne :+
  lda #$10
  sta ball_x
  jmp update
: cmp #$f8
  bne update
  lda #$f0
  sta ball_x

update:
  jsr UpdateBall

  wait_for_nmi
  jmp Main
.endproc

.proc UpdateBall
  lda ball_y
  sta oam
  lda ball_tile
  sta oam + 1
  lda ball_attr
  sta oam + 2
  lda ball_x
  sta oam + 3
  rts
.endproc

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

.proc pollPlayer1
  ; latch controllers
  lda #1
  sta $4016
  lda #0
  sta $4016

  ; Player 1
  ldx #8
@p1:
  lda PLAYER1_BUTTON_DATA
  lsr a
  rol buttonsp1
  dex
  bne @p1
  rts
.endproc

.proc pollPlayer2
  ; latch controllers
  lda #1
  sta $4016
  lda #0
  sta $4016

  ; Player 2
  ldx #8
@p2:
  lda PLAYER2_BUTTON_DATA
  lsr a
  rol buttonsp2
  dex
  bne @p2
  rts
.endproc

.proc VBlankVector
  php
  SAVE_AXY

  sei

  ; Decrement Counter
  dec nmi_counter

  ; DMA Copy Sprite OAM to PPU
  lda #0
  sta PPU_OAM_ADDR	; Specify the target starts at $00 in the PPU's OAM RAM.
  lda #>OAM_RAM		; Get upper byte (i.e. page) of source RAM for DMA operation.
  sta OAM_DMA			; Trigger the DMA.

  RESTORE_AXY
  plp

  cli

  rti
.endproc

.segment "PALETTE"
palette:
.byte $0f             ; Universal Background Color
.byte $30,$27,$00     ; Background Palette 0
.byte $0f,$30,$21,$01 ; Background Palette 1
.byte $0f,$26,$16,$06 ; Background Palette 2
.byte $0f,$29,$19,$09 ; Background Palette 3

.byte $0f,$00,$20,$10 ; Sprite Palette 0
.byte $0F,$02,$38,$3C ; Sprite Palette 1
.byte $0F,$1C,$15,$14 ; Sprite Palette 2
.byte $0F,$02,$38,$3C ; Sprite Palette 3

.segment "SPRITE"
       ;vert tile attr       horiz
ball:
  .byte $80, $64, %00000000, $80   ;sprite 0

.segment "ROOM"
tilemap:
  .incbin "assets/nametable.bin"

.segment "VECTORS"
    .addr VBlankVector
    .addr ResetVector
    .addr 0

.segment "FIXED"

.segment "CHR"
  .incbin "assets/diamonds.chr"   ;includes 8KB graphics file from SMB1
