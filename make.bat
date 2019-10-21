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
ca65 -o temp/diamonds.o -g src/diamonds.s --listing temp\diamonds.lst.txt

ld65 -o diamonds.nes -C .\diamonds.cfg temp\header.o temp\ram.o temp\diamonds.o --dbgfile diamonds.dbg --mapfile diamonds.map.txt
