md temp
del temp/*.o
del temp/*.obj
del temp/*.txt
del temp/*.nl
del *.dbg
del diamonds.nes

ca65 -o temp/ram.o -g -D RAM_EXPORT src/ram.s
ca65 -o temp/header.o -g src/header.s
ca65 -o temp/diamonds.o -g src/diamonds.s

ld65 -o temp/header.obj -C .\header.cfg temp/header.o
ld65 -o temp/diamonds.obj -C .\diamonds.cfg --dbgfile diamonds.dbg temp/ram.o temp/diamonds.o

copy /b "temp\header.obj"+"temp\diamonds.obj" diamonds.nes