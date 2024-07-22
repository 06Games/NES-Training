AS=cl65
TGT=nes
ASFLAGS=--verbose --target $(TGT)

PROJECTS=$(subst /src/,,$(dir $(wildcard */src/.)))
OUTPUT_GAMES=$(addsuffix .nes, $(PROJECTS))
SRCDIR=src
BUILDDIR=build

# Targets
all: build-dir $(addprefix $(BUILDDIR)/, $(OUTPUT_GAMES))

build-dir:
	mkdir -p $(BUILDDIR)

$(BUILDDIR)/%.nes: %/$(SRCDIR)/*.s
	$(AS) $(ASFLAGS) -o $@ $^

clean:
	find . -type f -iname "*.o" -exec rm {} \;
	$(RM) -r $(BUILDDIR)
