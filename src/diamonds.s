.include "nesdefs.inc"

.include "ram.s"

.segment "CODE"

.proc ResetVector
  ; Disable Interrupts
  sei
  ; Clear Decimal
  cld

  ; Init
  ldx #0
  stx PPU_CTRL
  stx PPU_MASK
  stx APU_DMC_CTRL

  ; Set Stack Pointer
  dex
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
  sta $0200, x
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
  jsr LoadBackground

  ; Enable Interuppts
  cli

  ; Enable VBlank NMI
  lda #VBLANK_NMI
  sta PPU_CTRL

  ; Wait for next VBlank
  wait_for_nmi

  lda #0
  sta PPU_OAM_ADDR	; Specify the target starts at $00 in the PPU's OAM RAM.
  lda #>OAM_RAM		; Get upper byte (i.e. page) of source RAM for DMA operation.
  sta OAM_DMA			; Trigger the DMA.

  lda #0
  sta PPU_SCROLL		; Write X position first.
  sta PPU_SCROLL		; Then write Y position.

  lda #VBLANK_NMI|SPR_0|BG_0|VRAM_DOWN
  sta PPU_CTRL

  ; Turn screen on - Activate Sprites
  lda #SPR_ON|BG_ON
  sta PPU_MASK

  wait_for_nmi

  loop:
    inc delay
    lda delay
    cmp #10
    bne @next
    lda #0
    sta delay

    inc curr_frame
    lda curr_frame
    cmp #3
    bne @next
    lda #0
    sta curr_frame

@next:
    wait_for_nmi
    jmp loop
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
  lda sprites, y
  sta $0200, y
  iny
  cpy #16
  bne LoadSpritesLoop
  rts
.endproc

.proc LoadBackground
  lda PPU_STATUS
  ppu_addr $2000

  lda #<tilemap
  sta ptr
  lda #>tilemap
  sta ptr + 1
  ldx #4
  ldy #0
@loop:
  lda (ptr), y
  sta PPU_DATA
  iny
  bne @loop
  dex
  beq @done
  inc ptr + 1
  jmp @loop

@done:
  rts
.endproc

; A - Sprite Frame
.proc UpdateSpriteFrame
  asl
  tax
  lda mario_frames, x
  sta mario_curr_frame
  lda mario_frames + 1, x
  sta mario_curr_frame + 1

  ldy #1

  lda (mario_curr_frame), y
  sta $201
  .repeat 4
    iny
  .endrep

  lda (mario_curr_frame), y
  sta $205
  .repeat 4
    iny
  .endrep

  lda (mario_curr_frame), y
  sta $209
  .repeat 4
    iny
  .endrep

  lda (mario_curr_frame), y
  sta $20D
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
  ; Disable Interuppts
  sei

  ; Decrement Counter
  dec nmi_counter

  lda curr_frame
  jsr UpdateSpriteFrame

  ; DMA Copy Sprite OAM to PPU
  lda #0
  sta PPU_OAM_ADDR	; Specify the target starts at $00 in the PPU's OAM RAM.
  lda #>OAM_RAM		; Get upper byte (i.e. page) of source RAM for DMA operation.
  sta OAM_DMA			; Trigger the DMA.

  ; Check Input
  jsr pollPlayer1

  ; 7 6 5      4     3  2    1    0
  ; A B Select Start Up Down Left Right

  lda buttonsp1
  and #%00001000
  beq checkDown

  lda $200
  sec
  sbc #1
  sta $200

  lda $204
  sec
  sbc #1
  sta $204

  lda $208
  sec
  sbc #1
  sta $208

  lda $20C
  sec
  sbc #1
  sta $20C

checkDown:
  lda buttonsp1
  and #%00000100
  beq checkLeft

  lda $200
  clc
  adc #1
  sta $200

  lda $204
  clc
  adc #1
  sta $204

  lda $208
  clc
  adc #1
  sta $208

  lda $20C
  clc
  adc #1
  sta $20C

checkLeft:
  lda buttonsp1
  and #%00000010
  beq checkRight

  lda $203
  sec
  sbc #1
  sta $203

  lda $207
  sec
  sbc #1
  sta $207

  lda $20B
  sec
  sbc #1
  sta $20B

  lda $20F
  sec
  sbc #1
  sta $20F

checkRight:
  lda buttonsp1
  and #%00000001
  beq inputDone

  lda $203
  clc
  adc #1
  sta $203

  lda $207
  clc
  adc #1
  sta $207

  lda $20B
  clc
  adc #1
  sta $20B

  lda $20F
  clc
  adc #1
  sta $20F

inputDone:

  cli     ; Enable Interupts
  rti
.endproc

.segment "PALETTE"
palette:
.byte $00             ; Universal Background Color
.byte $30,$27,$00     ; Background Palette 0
.byte $0f,$30,$21,$01 ; Background Palette 1
.byte $0f,$26,$16,$06 ; Background Palette 2
.byte $0f,$29,$19,$09 ; Background Palette 3
.byte $22,$16,$27,$18 ; Sprite Palette 0
.byte $0F,$02,$38,$3C ; Sprite Palette 1
.byte $0F,$1C,$15,$14 ; Sprite Palette 2
.byte $0F,$02,$38,$3C ; Sprite Palette 3

.segment "SPRITE"
sprites:
       ;vert tile attr horiz
mario1:
  .byte $80, $32, $00, $80   ;sprite 0
  .byte $80, $33, $00, $88   ;sprite 1
  .byte $88, $34, $00, $80   ;sprite 2
  .byte $88, $35, $00, $88   ;sprite 3

mario2:
  .byte $80, $36, $00, $80   ;sprite 0
  .byte $80, $37, $00, $88   ;sprite 1
  .byte $88, $38, $00, $80   ;sprite 2
  .byte $88, $39, $00, $88   ;sprite 3

mario3:
  .byte $80, $3A, $00, $80   ;sprite 0
  .byte $80, $37, $00, $88   ;sprite 1
  .byte $88, $3B, $00, $80   ;sprite 2
  .byte $88, $3C, $00, $88   ;sprite 3

.segment "ROOM"
tilemap:
  .incbin "assets/nametable.bin"

.segment "DATA"
mario_frames:
  .addr mario3
  .addr mario1
  .addr mario2

.segment "VECTORS"
    .addr VBlankVector
    .addr ResetVector
    .addr 0

.segment "FIXED"

.segment "CHR"
  .incbin "assets/diamonds.chr"   ;includes 8KB graphics file from SMB1
