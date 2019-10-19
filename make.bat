ca65 -o background.o -g background.asm
ld65 -o background.nes -C .\linker.cfg --dbgfile background.dbg background.o