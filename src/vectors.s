.include "nesdefs.inc"
.include "utils.inc"

.importzp data_ptr
.importzp nmi_counter
.importzp ball_x
.importzp ball_y
.importzp ball_tile
.importzp ball_attr
.importzp ball_dir
.importzp ball_yv

.import oam

.import Main
.import LoadPalettes
.import LoadSprites
.import LoadBackground

.import tilemap

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
  ldx #32*30/4           ; Only need to repeat a quarter of the time, since the loop writes 4 times.
: Repeat 4, sta PPU_DATA
  dex
  bne :-

  ldx #64
  lda #$55               ; Select palette 1 (2nd palette) throughout.
:  sta PPU_DATA
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
  sta PPU_OAM_ADDR  ; Specify the target starts at $00 in the PPU's OAM RAM.
  lda #>OAM_RAM      ; Get upper byte (i.e. page) of source RAM for DMA operation.
  sta OAM_DMA        ; Trigger the DMA.

  lda #0
  sta PPU_SCROLL    ; Write X position first.
  sta PPU_SCROLL    ; Then write Y position.

  lda #VBLANK_NMI|SPR_0|BG_0|VRAM_DOWN
  sta PPU_CTRL

  ; Enable sprites & background
  lda #SPR_ON|BG_ON
  sta PPU_MASK

  jmp Main
.endproc

.proc VBlankVector
  php
  SAVE_AXY

  sei

  ; Decrement Counter
  dec nmi_counter

  ; DMA Copy Sprite OAM to PPU
  lda #0
  sta PPU_OAM_ADDR  ; Specify the target starts at $00 in the PPU's OAM RAM.
  lda #>OAM_RAM    ; Get upper byte (i.e. page) of source RAM for DMA operation.
  sta OAM_DMA      ; Trigger the DMA.

  RESTORE_AXY
  plp

  cli

  rti
.endproc

.proc IRQVector
    rti
.endproc

.segment "VECTORS"
.addr VBlankVector
.addr ResetVector
.addr IRQVector