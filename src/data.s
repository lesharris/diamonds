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

.segment "CHR"
  .incbin "assets/diamonds.chr"   ;includes 8KB graphics file from SMB1

.export palette
.export ball
.export tilemap
