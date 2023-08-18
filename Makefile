SHELL          := /usr/bin/bash
MODULE         := EpidemicsUtilities

QUARTO         := /usr/local/bin/quarto
CSL            := /home/wilfrid/lib/pandoc/CSL/ima-journal-of-applied-mathematics.csl
QUARTO_OPTIONS :=  --from=markdown+tex_math_single_backslash --csl=$(CSL)

#BUILD          := docs/build
DOCUMENT       := docs/build/$(MODULE)
SOURCE         := src/$(MODULE).jl
SECTIONS       := $(wildcard src/0*.jl)

# ====================
# Principal targets
main: docs
test: .test.stamp

# ====================
# Creation of documentation
docs: $(DOCUMENT).pdf

# The following translations is not yet perfect!
# It doesn't include directives "#|" in codeblocks.
$(DOCUMENT).qmd: docs/build/INTERMEDIATE.jl	
	$(HOME)/.local/bin/julia -e 'using Literate; Literate.markdown("$<", name="$@", documenter=false, flavor = Literate.DocumenterFlavor(), codefence="```{julia}" => "```")'
	mv $@.md $@

# Concatenate ordered source files into temporary intermediate file for documentation.
docs/build/INTERMEDIATE.jl: $(SOURCE) $(SECTIONS)
	@cat $(SOURCE) $(SECTIONS) > $@
	@echo $(shell date +"%-d %B %Y")
	sed -i -e's/# date: today/# date: $(shell date +"%d %B %Y")/' $@
	@echo Concatenated $(SECTIONS)

# ====================
# Running tests
.test.stamp: $(wildcard src/*.jl) $(wildcard test/*.jl)
	julia test/runtests.jl
	@touch .test.stamp

# ====================
# Automatic conversion of qmd to pdf
%.pdf: %.qmd $(UTILITIES) ; $(QUARTO) render $< --to pdf $(QUARTO_OPTIONS) --no-cache

# ====================
# Intermediate files
.INTERMEDIATE: docs/build/INTERMEDIATE.jl

# ====================
# Clean-up
clean:
	-rm -f $(wildcard *.ipynb)
	$(HOME)/.local/bin/julia -e 'Base.compilecache(Base.identify_package("EpidemicsUtilities"))'

