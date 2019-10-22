.include "nesdefs.inc"

.importzp buttonsp1

.segment "CODE"
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

.export pollPlayer1