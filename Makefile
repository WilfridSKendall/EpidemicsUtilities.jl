SHELL          := /usr/bin/bash
LOCATION       := $(shell pwd)
MODULE         := $(notdir $(LOCATION))

QUARTO         := /usr/local/bin/quarto
CSL            := /home/wilfrid/lib/pandoc/CSL/ima-journal-of-applied-mathematics.csl
QUARTO_OPTIONS :=  --from=markdown+tex_math_single_backslash --csl=$(CSL)

JULIA          := $(HOME)/.local/bin/julia

DOCUMENT       := docs/build/$(MODULE)
SOURCE         := src/$(MODULE).jl
SECTIONS       := $(wildcard src/0*.jl)

test_files :=$(wildcard test/*.jl)

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
	$(HOME)/.local/bin/julia -e 'using Literate;         \
	Literate.markdown("$<", name="$@", documenter=false, \
		flavor = Literate.DocumenterFlavor(), codefence="```{julia}" => "```")'
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
	julia test/00-runtests.jl
	@touch .test.stamp

# ====================
# Installation
install:
	$(JULIA) -e 'import EpidemicsCFTP: version      ; println(version)'
	touch src/EpidemicsUtilities.jl
	$(JULIA) -e 'import $(MODULE): version ; println(version)'


# ====================
# List test source: target is `test.pdf`
$(MODULE)-test.pdf: $(MODULE)-test.qmd
	$(QUARTO) render $< --to pdf
	rm $<
$(MODULE)-test.qmd: $(test_files)
	@echo $(test_files)
	@echo "# Unit tests for module \`$(MODULE)\`"                            > $(MODULE)-test.qmd
	@echo "\`\`\`{julia}"							>> $(MODULE)-test.qmd
	@echo "#| echo: false"							>> $(MODULE)-test.qmd
	@echo "import $(MODULE): date, version" 				>> $(MODULE)-test.qmd
	@echo "println(\"$(MODULE) version \$$version, compiled on \$$date\")"	>> $(MODULE)-test.qmd
	@echo "\`\`\`"      							>> $(MODULE)-test.qmd
	@for f in $(test_files) ; do                           \
		echo "## File \`$$f\`" >> $(MODULE)-test.qmd ; \
		echo "\`\`\`julia"     >> $(MODULE)-test.qmd ; \
		cat $$f                >> $(MODULE)-test.qmd ; \
		echo "\`\`\`"          >> $(MODULE)-test.qmd ; \
	done

# ====================
# List Makefile: target is `Makefile.pdf`
include $(HOME)/lib/makefiles/listing-makefile.mak

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
	$(HOME)/.local/bin/julia -e 'import $(MODULE)'
	$(HOME)/.local/bin/julia -e 'Base.compilecache(Base.identify_package("$(MODULE)"))'

