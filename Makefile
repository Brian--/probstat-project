# Usually, only these lines need changing
TEXFILE= paper
RDIR= ./R
FIGDIR= ./figs

# list R files
RFILES := $(wildcard $(RDIR)/*.R)
# pdf figures created by R
PDFFIGS := $(wildcard $(FIGDIR)/*.pdf)
# Indicator files to show R file has run
OUT_FILES:= $(RFILES:.R=.Rout)
# Indicator files to show pdfcrop has run
CROP_FILES:= $(PDFFIGS:.pdf=.pdfcrop)

all: $(TEXFILE).pdf $(OUT_FILES) $(CROP_FILES)

# Run every R file
$(RDIR)/%.Rout: $(RDIR)/%.R
	R CMD BATCH $<

# Crop every pdf fig file
$(FIGDIR)/%.pdfcrop: $(FIGDIR)/%.pdf
	pdfcrop $< $< && touch $@

# Compile main tex file and show errors
$(TEXFILE).pdf: $(TEXFILE).tex $(OUT_FILES) $(CROP_FILES)
	latexmk -pdf -quiet $(TEXFILE)

# Run R files
R: $(OUT_FILES)

# View main tex file
view: $(TEXFILE).pdf
	evince $(TEXFILE).pdf &

# Clean up stray files
clean:
	rm -fv $(OUT_FILES) 
	rm -fv $(CROP_FILES)
	rm -fv *.aux *.log *.toc *.blg *.bbl *.synctex.gz
	rm -fv *.out *.bcf *blx.bib *.run.xml
	rm -fv *.fdb_latexmk *.fls
	rm -fv $(TEXFILE).pdf

.PHONY: all clean
