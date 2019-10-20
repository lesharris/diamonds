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

.segment "ZEROPAGE"

RESZP mario_curr_frame,   2
RESZP delay,              1
RESZP ptr,                2

.segment "STACK"
RES stack,                256

.segment "OAM"
RES oam,                  256

.segment "RAM"
RES nmi_counter,          1
RES buttonsp1,            1
RES buttonsp2,            1
RES curr_frame,           1
