.include "nesdefs.inc"
.include "ram.s"

.importzp buttonsp1
.importzp ball_x
.importzp ball_y
.importzp ball_yv
.importzp ball_dir
.importzp ball_tile
.importzp ball_attr

.import pollPlayer1

.segment "CODE"

.proc Main
; Check Input
  jsr pollPlayer1

  ; 7 6 5      4     3  2    1    0
  ; A B Select Start Up Down Left Right

  lda buttonsp1
  and #bLEFT|bB
  beq checkRight

  lda ball_x
  sec
  sbc #2
  sta ball_x

checkRight:
  lda buttonsp1
  and #bRIGHT|bA
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
  cmp #$08
  bne :+
  lda #0
  sta ball_dir
  jmp checkX
: cmp #$e2
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

.export Main
