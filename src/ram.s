.include "utils.inc"

.segment "ZEROPAGE"

RESZP data_ptr,           2
RESZP nmi_counter,        1

RESZP buttonsp1,          1

RESZP ball_y,             1
RESZP ball_tile,          1
RESZP ball_attr,          1
RESZP ball_x,             1
RESZP ball_yv,            1
RESZP ball_dir,           1

.segment "STACK"
RES stack,              256

.segment "OAM"
RES oam,                256

.segment "RAM"

