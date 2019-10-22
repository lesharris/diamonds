PPU_CTRL            = $2000
PPU_MASK            = $2001
PPU_STATUS          = $2002
PPU_OAM_ADDR        = $2003
PPU_OAM_DATA        = $2004
PPU_SCROLL          = $2005
PPU_ADDR            = $2006
PPU_DATA            = $2007

APU_NOISE_VOL       = $400C
APU_NOISE_FREQ      = $400E
APU_NOISE_TIMER     = $400F
APU_DMC_CTRL        = $4010
APU_CHAN_CTRL       = $4015
APU_FRAME           = $4017

PLAYER1_BUTTON_DATA = $4016
PLAYER2_BUTTON_DATA = $4017

; PPU Memory Map
PTRN_TABLE_0        = $0          ; Size = $1000
PTRN_TABLE_1        = $1000       ; Size = $1000
NAME_TABLE_0        = $2000       ; Size = $3C0
ATTR_TABLE_0        = $23C0       ; Size = $40
NAME_TABLE_1        = $2400       ; Size = $3C0
ATTR_TABLE_1        = $27C0       ; Size = $40
NAME_TABLE_2        = $2800       ; Size = $3C0
ATTR_TABLE_2        = $2BC0       ; Size = $40
NAME_TABLE_3        = $2C00       ; Size = $3C0
ATTR_TABLE_3        = $2FC0       ; Size = $40
BG_PALETTE          = $3F00       ; Size = $10
SPRITE_PALETTE      = $3F10       ; Size = $10

OAM_DMA             = $4014
OAM_RAM             = $0200

NT_0                = %00         ; Use nametable 0 ($2000).
NT_1                = %01         ; Use nametable 1 ($2400).
NT_2                = %10         ; Use nametable 2 ($2800).
NT_3                = %11         ; Use nametable 3 ($2C00).
VRAM_RIGHT          = %000        ; Increment nametable address rightwards, after a write.
VRAM_DOWN           = %100        ; Increment nametable address downwards, after a write.
SPR_0               = %0000       ; Use sprite pattern table 0.
SPR_1               = %1000       ; Use sprite pattern table 1.
BG_0                = %00000      ; Use background pattern table 0 ($0000).
BG_1                = %10000      ; Use background pattern table 1 ($1000).
SPR_8x8             = %00000      ; Use standard 8x8 sprites.
SPR_8x16            = %100000     ; Use 8x16 sprites, instead of 8x8.
NO_VBLANK_NMI       = %00000000   ; Don't generate VBLANK NMIs.
VBLANK_NMI          = %10000000   ; DO generate VBLANK NMIs.

; PPU_MASK bit flags:
COLOR_NORMAL        = %0
COLOR_GRAYSCALE     = %1
HIDE_BG_LHS         = %00         ; Hide left-most 8 pixels of the background.
SHOW_BG_LHS         = %10         ; Show left-most 8 pixels of BG.
HIDE_SPR_LHS        = %000        ; Prevent displaying sprites in left-most 8 pixels of screen.
SHOW_SPR_LHS        = %100        ; Show sprites in left-most 8 pixels of screen.
BG_OFF              = %0000       ; Hide background.
BG_ON               = %1000       ; Show background.
SPR_OFF             = %00000      ; Hide sprites.
SPR_ON              = %10000      ; Show sprites.

; Button Flags
  ; 7 6 5      4     3  2    1    0
  ; A B Select Start Up Down Left Right

bRIGHT              = %00000001
bLEFT               = %00000010
bDOWN               = %00000100
bUP                 = %00001000
bSTART              = %00010000
bSELECT             = %00100000
bB                  = %01000000
bA                  = %10000000

; MMC3 Control addresses

MMC3_BANK_SELECT    = $8000
MMC3_BANK_VALUE     = $8001
MMC3_MIRRORING      = $A000
MMC3_PRG_RAM        = $A001
MMC3_IRQ_LATCH      = $C000
MMC3_IRQ_RELOAD     = $C001
MMC3_IRQ_DISABLE    = $E000
MMC3_IRQ_ENABLE     = $E001
