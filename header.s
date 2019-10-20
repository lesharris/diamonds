.segment "HEADER"

.byte "NES", $1a
.byte 2             ; PRG 2 * 16 = 32k
.byte 1           ; CHR 1 * 8 = 8k
.byte %00000000
.byte %00001000
.byte %00000000
.byte $00
.byte $00
.byte $00,$00,$00,$00,$00
