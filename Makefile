VERSION = 1.0
PREFIX ?= /usr
BINDIR = $(PREFIX)/bin
DATADIR = $(PREFIX)/share/faah
MANDIR = $(PREFIX)/share/man/man1

all: faah

faah: faah.in
	sed -e 's|@VERSION@|$(VERSION)|g' \
	    -e 's|@DATADIR@|$(DATADIR)|g' $< > $@
	chmod 755 $@

install: faah
	install -d $(DESTDIR)$(BINDIR) $(DESTDIR)$(DATADIR) $(DESTDIR)$(MANDIR)
	install -m 755 faah $(DESTDIR)$(BINDIR)/faah
	install -m 644 faah.mp3 $(DESTDIR)$(DATADIR)/faah.mp3
	install -m 644 faah.1 $(DESTDIR)$(MANDIR)/faah.1

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/faah
	rm -f $(DESTDIR)$(DATADIR)/faah.mp3
	rm -f $(DESTDIR)$(MANDIR)/faah.1
	-rmdir $(DESTDIR)$(DATADIR)

clean:
	rm -f faah

.PHONY: all install uninstall clean
