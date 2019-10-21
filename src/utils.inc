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
