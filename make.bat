md temp
del temp/*.o
del temp/*.obj
del temp/*.txt
del temp/*.nl
del *.dbg
del *.map.txt
del diamonds.nes

ca65 -o temp/ram.o -g -D RAM_EXPORT src/ram.s --listing temp\ram.lst.txt
ca65 -o temp/header.o -g src/header.s --listing temp\header.lst.txt
ca65 -o temp/input.o -g src/input.s --listing temp\input.lst.txt
ca65 -o temp/vectors.o -g src/vectors.s --listing temp\vectors.lst.txt
ca65 -o temp/gfx.o -g src/gfx.s --listing temp\gfx.lst.txt
ca65 -o temp/data.o -g src/data.s --listing temp\data.list.txt
ca65 -o temp/diamonds.o -g src/diamonds.s --listing temp\diamonds.lst.txt

ld65 -o diamonds.nes -C .\diamonds.cfg temp\header.o temp\ram.o temp\input.o temp\gfx.o temp\diamonds.o temp\data.o  temp\vectors.o --dbgfile diamonds.dbg --mapfile diamonds.map.txt
