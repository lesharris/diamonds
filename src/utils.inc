.macro SAVE_AXY
  pha
  txa
  pha
  tya
  pha
.endmacro

.macro RESTORE_AXY
  pla
  tay
  pla
  tax
  pla
.endmacro

.macro SAVE_XY
  tya
  pha
  txa
  pha
.endmacro

.macro RESTORE_XY
  pla
  tax
  pla
  tay
.endmacro

.macro RESZP label, size
  .ifdef RAM_EXPORT
    label: .res size
    .exportzp label
  .else
    .importzp label
  .endif
.endmacro

.macro RES label, size
  .ifdef RAM_EXPORT
    label: .res size
    .export label
  .else
    .import label
  .endif
.endmacro

.macro wait_for_nmi
  lda nmi_counter
:  cmp nmi_counter
  beq  :-             ; Loop, so long as nmi_counter hasn't changed its value.
.endmacro

.macro nmi_delay frames
  lda #frames
  sta nmi_counter     ; Store the desired frame count.
:  lda nmi_counter    ; In a loop, keep checking the frame count.
  bne :-              ; Loop until it's decremented to 0.
.endmacro

.macro ppu_addr Addr
  ldx #>Addr          ; High byte first.
  stx PPU_ADDR
  ldx #<Addr          ; Then low byte.
  stx PPU_ADDR
.endmacro

.macro ppu_xy cx, cy, nt
  .ifblank nt
    ppu_addr ($2000+(cy*32)+cx)
  .else
    ppu_addr ($2000+(cy*32)+cx+(nt*$400))
  .endif
.endmacro

.macro pal bb, uu, vv, ww
  .ifnblank ww
    .byt bb, uu, vv, ww
  .else
    .byt $00, bb, uu, vv
  .endif
.endmacro

.macro Repeat num, what
  .repeat num
    what
  .endrepeat
.endmacro