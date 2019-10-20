del *.o
del *.bin
del *.txt
del *.nl
del *.dbg
del diamonds.nes

ca65 -o ram.o -g -D RAM_EXPORT ram.s
ca65 -o header.o -g header.s
ca65 -o diamonds.o -g diamonds.s

ld65 -o header.bin -C .\header.cfg header.o
ld65 -o diamonds.bin -C .\linker.cfg --dbgfile diamonds.dbg ram.o diamonds.o

copy /b header.bin+diamonds.bin diamonds.nes