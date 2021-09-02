# st - simple terminal
# See LICENSE file for copyright and license details.
.POSIX:

include config.mk

SRC = st.c x.c hb.c
OBJ = $(SRC:.c=.o)
OUTOBJ = $(patsubst %.c,out/%.o,$(SRC))

all: options st

options:
	@echo st build options:
	@echo "CFLAGS  = $(STCFLAGS)"
	@echo "LDFLAGS = $(STLDFLAGS)"
	@echo "CC      = $(CC)"
	mkdir -p out

config.h:
	ln -sr config.def.h config.h

.c.o:
	$(CC) $(STCFLAGS) -c $< -o out/$@

st.o: config.h st.h win.h
x.o: arg.h config.h st.h win.h hb.h
hb.o: st.h

$(OBJ): config.h config.mk

st: $(OBJ)
	$(CC) -o out/$@ $(OUTOBJ) $(STLDFLAGS)

clean:
	rm -rf out/
	rm -f out/st $(OBJ) $(OUTOBJ) st-$(VERSION).tar.gz

dist: clean
	mkdir -p out/st-$(VERSION)
	cp -R misc/ Makefile config.mk\
		config.def.h arg.h st.h win.h $(SRC)\
		out/st-$(VERSION)
	tar -cf - out/st-$(VERSION) | gzip > out/st-$(VERSION).tar.gz
	rm -rf out/st-$(VERSION)

install: st
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f out/st $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/st
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	sed "s/VERSION/$(VERSION)/g" < misc/st.1 > $(DESTDIR)$(MANPREFIX)/man1/st.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/st.1
	tic -sx misc/st.info
	@echo Please see the README file regarding the terminfo entry of st.

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/st
	rm -f $(DESTDIR)$(MANPREFIX)/man1/st.1

.PHONY: all options clean dist install uninstall
