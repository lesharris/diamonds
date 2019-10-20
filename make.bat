del *.o
del *.obj
del *.txt
del *.nl
del *.dbg
del diamonds.nes

ca65 -o ram.o -g -D RAM_EXPORT ram.s
ca65 -o header.o -g header.s
ca65 -o diamonds.o -g diamonds.s

ld65 -o header.obj -C .\header.cfg header.o
ld65 -o diamonds.obj -C .\linker.cfg --dbgfile diamonds.dbg ram.o diamonds.o

copy /b header.obj+diamonds.obj diamonds.nes