IDIR=include
CC=gcc
CFLAGS=-I$(IDIR)

ODIR=obj
LDIR=lib
LIBS=
_DEPS = steganography.h image_handler.h util.h lodepng.h
DEPS = $(patsubst %,$(IDIR)/%,$(_DEPS))

_OBJ = main.o steganography.o image_handler.o util.o lodepng.o
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))

$(ODIR)/%.o: %.c $(DEPS)
	mkdir -p $(ODIR)
	$(CC) -c -o $@ $< $(CFLAGS)

steg: $(OBJ)
	$(CC) -g3 -o $@ $^ $(CFLAGS) $(LIBS)

.PHONY: clean

clean:
	rm -f $(ODIR)/*.o *~ core $(INCDIR)/*~ steg
